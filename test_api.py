from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import requests
import json

app = Flask(__name__)
CORS(app)

DB_FILE = "bvm_data.db"

def get_db_connection():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn
@app.route('/api/login',methods=['GET'])
def login():
    username = request.args.get('username')
    password = request.args.get('password')
    
    # For demonstration, we use hardcoded credentials
    if username == 'admin' and password == 'password':
        return jsonify({"status": "success", "message": "Login successful"})
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"}), 401
@app.route('/api/getSlotDetails', methods=['GET'])
def get_slot_details():
   
    # Get machine_id from query params, default to 219
    machine_id = request.args.get('machineId', default=219, type=int)
    
    # Placeholder for the actual API URL - User will update this
    API_URL = "https://cloud-test.vendolite.com/api/apiIntegration/getMachineSlotDetails" 
    headers = {
        'Content-Type': 'application/json',
        'authorization': 'bec2b229e7b1f9612acfc2118287b99175166cc586de43348e5910943fcf91c2'
    }
    body = {
        'machineId': machine_id
    }
    response = requests.post(API_URL, headers=headers, json=body)
    data = response.json()
    
    try:
        # 1. Update local database with data from API
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Clear existing entries for this machine to ensure we only have the latest from API
        cursor.execute("DELETE FROM stock WHERE machine_id = ?", (machine_id,))
        cursor.execute("DELETE FROM slots WHERE machine_id = ?", (machine_id,))
        
        # Cloud API returns data in a list under 'data' key
        slot_entries = data.get("data", [])
        
        for item in slot_entries:
            # Note: API uses 'Product Id', 'Product Name', etc. (with spaces)
            api_slot_id = str(item.get("slotId"))
            slot_name = item.get("slotName")
            row_number = item.get("rowNumber")
            column_number = item.get("coloumnNumber")
            enable = item.get("enable", 1)
            
            product_id = item.get("Product Id")
            product_name = item.get("Product Name") or "Unknown"
            product_cost = item.get("Product Cost") or 0
            product_image = item.get("Product Image")
            
            # Stock info is a list of batches
            stock_info_list = item.get("stockInfo", [])
            total_qty = sum(s.get("qty", 0) for s in stock_info_list)
            max_qty = 10 # Default
            
            if product_id:
                # Upsert Product
                cursor.execute('''
                    INSERT INTO products (product_id, product_name, product_image, product_cost)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT(product_id) DO UPDATE SET
                        product_name = excluded.product_name,
                        product_image = excluded.product_image,
                        product_cost = excluded.product_cost
                ''', (product_id, product_name, product_image, product_cost))
            
            # Upsert Slot
            # We use api_slot_id as the primary key in our slots table for this machine
            cursor.execute('''
                INSERT INTO slots (slot_id, machine_id, slot_name, row_number, column_number, product_id, status, enable)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(slot_id, machine_id) DO UPDATE SET
                    slot_name = excluded.slot_name,
                    row_number = excluded.row_number,
                    column_number = excluded.column_number,
                    product_id = excluded.product_id,
                    enable = excluded.enable
            ''', (api_slot_id, machine_id, slot_name, row_number, column_number, product_id, 'Normal', enable))
            
            # Upsert Stock
            stock_id = f"STK_{machine_id}_{api_slot_id}"
            cursor.execute('''
                INSERT INTO stock (stock_id, slot_id, machine_id, qty, max_qty)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(stock_id) DO UPDATE SET
                    qty = excluded.qty,
                    max_qty = excluded.max_qty
            ''', (stock_id, api_slot_id, machine_id, total_qty, max_qty))
            
        conn.commit()
        
        # 3. Retrieve updated data from DB to ensure consistency and format for Flutter
        query = '''
            SELECT 
                s.slot_name as slotName,
                s.row_number as rowNumber,
                s.column_number as coloumnNumber,
                s.status as status,
                s.enable as enable,
                p.product_name as "Product Name",
                p.product_cost as "Product Cost",
                p.product_image as "Product Image",
                st.qty as stockQty,
                st.max_qty as maxStock
            FROM slots s
            LEFT JOIN products p ON s.product_id = p.product_id
            LEFT JOIN stock st ON s.slot_id = st.slot_id AND s.machine_id = st.machine_id
            WHERE s.machine_id = ?
        '''
        rows = cursor.execute(query, (machine_id,)).fetchall()
        
        products_list = []
        for row in rows:
            product_data = {
                "slotName": row["slotName"],
                "rowNumber": row["rowNumber"],
                "coloumnNumber": row["coloumnNumber"],
                "Product Name": row["Product Name"],
                "Product Cost": row["Product Cost"],
                "Product Image": row["Product Image"],
                "status": row["status"],
                "enable": row["enable"],
                "stockInfo": [
                    {
                        "qty": row["stockQty"] if row["stockQty"] is not None else 0,
                    }
                ]
            }
            products_list.append(product_data)
            
        return jsonify({
            "status": "success",
            "data": {
                "products": products_list
            }
        })
        
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if 'conn' in locals():
            conn.close()
# Ensure transactions table exists
def init_transaction_table():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id INTEGER PRIMARY KEY,
                machine_id INTEGER,
                product_name TEXT,
                product_id TEXT,
                slot_name TEXT,
                amount INTEGER,
                payment_type TEXT,
                status TEXT,
                transaction_time INTEGER,
                created_at TEXT
            )
        ''')
        conn.commit()
        conn.close()
    except Exception as e:
        print(f"Error initializing transaction table: {e}")

init_transaction_table()

@app.route('/api/getSalesData', methods=['GET'])
def get_sales_data():
    try:
        # Get machine_id from query params, default to 219
        machine_id = request.args.get('machineId', default=219, type=int)

        url = "https://cloud-test.vendolite.com/api/apiIntegration/getSalesForMachine"
        headers = {
            'Content-Type': 'application/json',
            'authorization': 'bec2b229e7b1f9612acfc2118287b99175166cc586de43348e5910943fcf91c2'
        }
        body = {
            'machineId': machine_id
        }
        
        response = requests.post(url, headers=headers, json=body)
        api_data = response.json()
        
        if api_data.get('code') == 'SUCCESS':
            conn = get_db_connection()
            cursor = conn.cursor()
            
            # Clear existing transactions for this machine to ensure sync
            # Note: In a real production sync, we might want to be incremental, but for this viewer, replacing is safer to avoid dupes/stale data.
            cursor.execute("DELETE FROM transactions WHERE machine_id = ?", (machine_id,))
            
            transactions_list = api_data.get('data', [])
            
            for item in transactions_list:
                transaction_id = item.get('id')
                status = item.get('status')
                transaction_time = item.get('transactionTime')
                created_at = item.get('createdAt')
                amount = item.get('amountReceived')
                
                # Extract Slot/Product Info from cartData
                cart_data = item.get('cartData', [])
                product_name = "Unknown"
                product_id = None
                slot_name = None
                
                if cart_data and len(cart_data) > 0:
                    first_item = cart_data[0]
                    product_name = first_item.get('productName')
                    product_id = first_item.get('productId')
                    slot_name = first_item.get('slotName')
                    # Fallback for amount if amountReceived is 0 or missing
                    if amount == 0 and first_item.get('amount'):
                         amount = first_item.get('amount')

                # Extract Payment Info from amountData
                amount_data = item.get('amountData', [])
                payment_type = "Unknown"
                if amount_data and len(amount_data) > 0:
                    payment_type = amount_data[0].get('Payment Type')
                
                cursor.execute('''
                    INSERT INTO transactions (transaction_id, machine_id, product_name, product_id, slot_name, amount, payment_type, status, transaction_time, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (transaction_id, machine_id, product_name, product_id, slot_name, amount, payment_type, status, transaction_time, created_at))
            
            conn.commit()
            
            # Now fetch from DB to return (ensuring our DB view is what we serve)
            rows = cursor.execute("SELECT * FROM transactions WHERE machine_id = ? ORDER BY transaction_time DESC", (machine_id,)).fetchall()
            
            # Convert to dictionary list
            result_data = []
            for row in rows:
                result_data.append(dict(row))
            
            conn.close()
            
            return jsonify({
                "status": "success", 
                "data": result_data,
                "msg": "Data fetched from Cloud and stored in DB"
            })
            
        else:
            return jsonify({"status": "error", "message": "Failed to fetch data from cloud", "api_response": api_data}), 500

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
        
@app.route('/api/getProducts', methods=['GET'])
def get_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get all products
        products_rows = cursor.execute("SELECT * FROM products").fetchall()
        products = [dict(row) for row in products_rows]
        
        # Calculate Stats
        total_products = len(products)
        
        # Average Price
        avg_price = 0
        if total_products > 0:
            prices = [p.get('product_cost', 0) for p in products if p.get('product_cost') is not None]
            if prices:
                avg_price = sum(prices) / len(prices)
        
        # Low Stock - Count slots with qty < 3
        low_stock_count = cursor.execute("SELECT COUNT(*) as count FROM stock WHERE qty < 3").fetchone()['count']
        
        conn.close()
        
        return jsonify({
            "status": "success",
            "data": {
                "products": products,
                "stats": {
                    "totalProducts": total_products,
                    "avgPrice": avg_price / 100.0, # Return in dollars/units
                    "lowStock": low_stock_count
                }
            }
        })
    except Exception as e:
        print(f"Error fetching products: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/updateSlot', methods=['POST'])
def update_slot():
    try:
        data = request.json
        if not data:
            return jsonify({"status": "error", "message": "No data provided"}), 400
            
        slot_id = data.get('slotId')
        machine_id = data.get('machineId', 219) # Default to 219 if not provided
        
        # Fields to update
        name = data.get('name')
        price = data.get('price') # Float dollars?
        stock = data.get('stock')
        max_stock = data.get('maxStock')
        status = data.get('status')
        # localImage = data.get('localImage') # Store path if needed?
        
        # We need to update:
        # 1. Product Name (in products table) -> Wait, products valid for multiple slots? 
        #    For simplicity in this machine-specific view, we'll assume we update the product linked to this slot.
        #    Or we should update the slot to point to a new product if ID changes?
        #    The Dialog allows editing Name. Let's update the product name for the product linked to this slot.
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get current product ID for this slot
        row = cursor.execute("SELECT product_id FROM slots WHERE slot_id = ? AND machine_id = ?", (slot_id, machine_id)).fetchone()
        if not row:
            return jsonify({"status": "error", "message": "Slot not found"}), 404
        
        product_id = row['product_id']
        
        # Update Product
        if name or price is not None:
            # Convert price back to cents if needed. Flutter sends double (e.g. 1.50). DB stores int cents (150).
            cost_cents = int(price * 100) if price is not None else None
            
            update_fields = []
            params = []
            if name:
                update_fields.append("product_name = ?")
                params.append(name)
            if cost_cents is not None:
                update_fields.append("product_cost = ?")
                params.append(cost_cents)
            
            if update_fields:
                params.append(product_id)
                cursor.execute(f"UPDATE products SET {', '.join(update_fields)} WHERE product_id = ?", params)
        
        # Update Stock
        if stock is not None or max_stock is not None:
            update_fields = []
            params = []
            if stock is not None:
                update_fields.append("qty = ?")
                params.append(stock)
            if max_stock is not None:
                update_fields.append("max_qty = ?")
                params.append(max_stock)
            
            if update_fields:
                params.append(slot_id)
                params.append(machine_id)
                cursor.execute(f"UPDATE stock SET {', '.join(update_fields)} WHERE slot_id = ? AND machine_id = ?", params)

        # Update Slot Status
        # The dialog sends 'status' enum string maybe?
        if status:
             cursor.execute("UPDATE slots SET status = ? WHERE slot_id = ? AND machine_id = ?", (status, slot_id, machine_id))
        
        enable = data.get('enable')
        if enable is not None:
             # enable can be boolean or int 0/1, sqlite uses int 0/1
             enable_val = 1 if enable else 0
             cursor.execute("UPDATE slots SET enable = ? WHERE slot_id = ? AND machine_id = ?", (enable_val, slot_id, machine_id))

        conn.commit()
        conn.close()
        
        return jsonify({"status": "success", "message": "Slot updated"})

    except Exception as e:
        print(f"Update Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)