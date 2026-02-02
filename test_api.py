from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
# Note: serviceAccountKey.json must be in the same directory
try:
    cred = credentials.Certificate("bvm_db_key.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Firebase initialized successfully")
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    # Fallback/Error handling: in a real app, you might want to exit or use a mock
    db = None

@app.route('/api/login', methods=['GET'])
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
    if db is None:
        return jsonify({"status": "error", "message": "Firebase not initialized"}), 500

    # Get machine_id from query params, default to 219
    machine_id = str(request.args.get('machineId', default=219))
    
    API_URL = "https://cloud-test.vendolite.com/api/apiIntegration/getMachineSlotDetails" 
    headers = {
        'Content-Type': 'application/json',
        'authorization': 'bec2b229e7b1f9612acfc2118287b99175166cc586de43348e5910943fcf91c2'
    }
    body = {
        'machineId': int(machine_id)
    }
    
    try:
        response = requests.post(API_URL, headers=headers, json=body)
        data = response.json()
        
        # 1. Update/Sync with Firestore
        slot_entries = data.get("data", [])
        
        batch = db.batch()
        
        for item in slot_entries:
            api_slot_id = str(item.get("slotId"))
            product_id = item.get("Product Id")
            
            # Upsert Product if it exists in API response
            if product_id:
                product_ref = db.collection('products').document(str(product_id))
                product_data = {
                    "product_id": str(product_id),
                    "product_name": item.get("Product Name") or "Unknown",
                    "product_image": item.get("Product Image"),
                    "product_cost": item.get("Product Cost") or 0
                }
                batch.set(product_ref, product_data, merge=True)
            
            # Upsert Slot
            slot_ref = db.collection('machines').document(machine_id).collection('slots').document(api_slot_id)
            
            # Stock info handling (simplify to flat structure in slot doc)
            stock_info_list = item.get("stockInfo", [])
            total_qty = sum(s.get("qty", 0) for s in stock_info_list)
            
            slot_data = {
                "slot_id": api_slot_id,
                "machine_id": machine_id,
                "slot_name": item.get("slotName"),
                "row_number": item.get("rowNumber"),
                "column_number": item.get("coloumnNumber"),
                "product_id": str(product_id) if product_id else None,
                "status": "Normal",
                "enable": item.get("enable", 1),
                "stock_qty": total_qty,
                "max_qty": 10 # Default
            }
            batch.set(slot_ref, slot_data, merge=True)
            
        batch.commit()
        
        # 2. Retrieve updated data from Firestore
        slots_ref = db.collection('machines').document(machine_id).collection('slots')
        slots = slots_ref.stream()
        
        products_list = []
        for slot_doc in slots:
            s = slot_doc.to_dict()
            
            # Enrich with product info
            p_name = "Unknown"
            p_cost = 0
            p_image = None
            
            if s.get('product_id'):
                p_ref = db.collection('products').document(s['product_id']).get()
                if p_ref.exists:
                    p = p_ref.to_dict()
                    p_name = p.get('product_name', 'Unknown')
                    p_cost = p.get('product_cost', 0)
                    p_image = p.get('product_image')
            
            products_list.append({
                "slotName": s.get("slot_name"),
                "rowNumber": s.get("row_number"),
                "coloumnNumber": s.get("column_number"),
                "Product Name": p_name,
                "Product Cost": p_cost,
                "Product Image": p_image,
                "status": s.get("status"),
                "enable": s.get("enable"),
                "stockInfo": [{"qty": s.get("stock_qty", 0)}]
            })
            
        return jsonify({
            "status": "success",
            "data": {
                "products": products_list
            }
        })
        
    except Exception as e:
        print(f"Error in getSlotDetails: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/getSalesData', methods=['GET'])
def get_sales_data():
    if db is None:
        return jsonify({"status": "error", "message": "Firebase not initialized"}), 500
        
    try:
        machine_id = str(request.args.get('machineId', default=219))
        url = "https://cloud-test.vendolite.com/api/apiIntegration/getSalesForMachine"
        headers = {
            'Content-Type': 'application/json',
            'authorization': 'bec2b229e7b1f9612acfc2118287b99175166cc586de43348e5910943fcf91c2'
        }
        body = {'machineId': int(machine_id)}
        
        response = requests.post(url, headers=headers, json=body)
        api_data = response.json()
        
        if api_data.get('code') == 'SUCCESS':
            transactions_list = api_data.get('data', [])
            batch = db.batch()
            
            for item in transactions_list:
                t_id = str(item.get('id'))
                cart_data = item.get('cartData', [])
                amount_data = item.get('amountData', [])
                
                p_name = "Unknown"
                p_id = None
                s_name = None
                if cart_data:
                    p_name = cart_data[0].get('productName')
                    p_id = str(cart_data[0].get('productId'))
                    s_name = cart_data[0].get('slotName')
                
                pay_type = "Unknown"
                if amount_data:
                    pay_type = amount_data[0].get('Payment Type')

                t_ref = db.collection('machines').document(machine_id).collection('transactions').document(t_id)
                t_data = {
                    "transaction_id": t_id,
                    "machine_id": machine_id,
                    "product_name": p_name,
                    "product_id": p_id,
                    "slot_name": s_name,
                    "amount": item.get('amountReceived') or (cart_data[0].get('amount') if cart_data else 0),
                    "payment_type": pay_type,
                    "status": item.get('status'),
                    "transaction_time": item.get('transactionTime'),
                    "created_at": item.get('createdAt')
                }
                batch.set(t_ref, t_data, merge=True)
            
            batch.commit()
            
            # Fetch from Firestore
            docs = db.collection('machines').document(machine_id).collection('transactions').order_by('transaction_time', direction=firestore.Query.DESCENDING).stream()
            result_data = [doc.to_dict() for doc in docs]
            
            return jsonify({
                "status": "success", 
                "data": result_data,
                "msg": "Data synchronized with Firebase"
            })
        else:
            return jsonify({"status": "error", "message": "API Failure", "api_response": api_data}), 500
            
    except Exception as e:
        print(f"Error in getSalesData: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/getProducts', methods=['GET'])
def get_products():
    if db is None:
        return jsonify({"status": "error", "message": "Firebase not initialized"}), 500
        
    try:
        products_docs = db.collection('products').stream()
        products = [doc.to_dict() for doc in products_docs]
        
        total_products = len(products)
        avg_price = 0
        if total_products > 0:
            prices = [p.get('product_cost', 0) for p in products]
            avg_price = sum(prices) / total_products
            
        # Low Stock - In Firestore we need to query individual machine slots
        # For the purpose of this demo, we'll check across all machines or a default one
        # Let's check machine 219's slots for low stock
        low_stock_count = 0
        m_id = "219"
        slots = db.collection('machines').document(m_id).collection('slots').where('stock_qty', '<', 3).stream()
        low_stock_count = len(list(slots))

        return jsonify({
            "status": "success",
            "data": {
                "products": products,
                "stats": {
                    "totalProducts": total_products,
                    "avgPrice": avg_price / 100.0,
                    "lowStock": low_stock_count
                }
            }
        })
    except Exception as e:
        print(f"Error in getProducts: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/updateSlot', methods=['POST'])
def update_slot():
    if db is None:
        return jsonify({"status": "error", "message": "Firebase not initialized"}), 500
        
    try:
        data = request.json
        slot_id = str(data.get('slotId'))
        machine_id = str(data.get('machineId', "219"))
        
        slot_ref = db.collection('machines').document(machine_id).collection('slots').document(slot_id)
        slot_doc = slot_ref.get()
        
        if not slot_doc.exists:
            return jsonify({"status": "error", "message": "Slot not found"}), 404
            
        s_data = slot_doc.to_dict()
        product_id = s_data.get('product_id')
        
        updates = {}
        p_updates = {}
        
        if 'name' in data:
            p_updates['product_name'] = data['name']
        if 'price' in data:
            p_updates['product_cost'] = int(data['price'] * 100)
        if 'stock' in data:
            updates['stock_qty'] = data['stock']
        if 'maxStock' in data:
            updates['max_qty'] = data['maxStock']
        if 'status' in data:
            updates['status'] = data['status']
        if 'enable' in data:
            updates['enable'] = 1 if data['enable'] else 0
            
        if updates:
            slot_ref.update(updates)
            
        if p_updates and product_id:
            db.collection('products').document(product_id).update(p_updates)
            
        return jsonify({"status": "success", "message": "Slot and Product updated in Firestore"})
        
    except Exception as e:
        print(f"Error in updateSlot: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
