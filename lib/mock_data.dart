
import 'package:flutter/material.dart';

// Data model
class MachineData {
  final int index;
  final String id;
  final String model;
  final String description;
  final String locationCode;
  final String location;
  final String vendor;
  final String branch;
  final String city;
  final String status;
  final String connectionStatus;
  
  // Legacy fields for Grid View
  final double sales;
  final int stockLevel;

  // New fields for Individual Page
  final List<ProductSlot> slots;
  final double waterLevel; // in Liters
  final double maxWaterLevel; // in Liters
  final double temperature; // in Celsius
  final double cashInBox;
  final List<MachineAlert> alerts;

  MachineData({
    required this.index,
    required this.id,
    required this.model,
    required this.description,
    required this.locationCode,
    required this.location,
    required this.vendor,
    required this.branch,
    required this.city,
    required this.status,
    required this.connectionStatus,
    required this.sales,
    required this.stockLevel,
    this.slots = const [],
    this.waterLevel = 0,
    this.maxWaterLevel = 30,
    this.temperature = 0,
    this.cashInBox = 0,
    this.alerts = const [],
  });
}

class ProductSlot {
  final String id; // e.g., A1, B2
  final String name;
  final double price;
  final String imageAsset;
  final int currentStock;
  final int maxStock;
  final SlotStatus status;
  final String? localImagePath;

  ProductSlot({
    required this.id,
    required this.name,
    required this.price,
    required this.imageAsset,
    required this.currentStock,
    required this.maxStock,
    this.status = SlotStatus.normal,
    this.localImagePath,
  });
}

enum SlotStatus {
  normal,
  lowStock,
  empty,
  error,
}

class MachineAlert {
  final String title;
  final String timeString; // e.g. "2 hours ago"
  final AlertType type;

  MachineAlert({
    required this.title,
    required this.timeString,
    required this.type,
  });
}

enum AlertType {
  error,
  warning,
  info,
}

// Transaction Data Model
class TransactionData {
  final String id;
  final String machineId;
  final String product;
  final String productImage;
  final String date;
  final String time;
  final double amount;
  final String paymentMethod;
  final String status;

  TransactionData({
    required this.id,
    required this.machineId,
    required this.product,
    required this.productImage,
    required this.date,
    required this.time,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}

// Helper to generate slots
List<ProductSlot> _generateSlots(int count) {
  final List<ProductSlot> slots = [];
  final List<String> products = [
    'Espresso','Latte','Chocso Bytes Jd','cappuccino','cappuccino','Chocso Bytes Jd'
  ];
  final List<double> prices = [1.50, 1.50, 1.00, 2.00, 1.25, 1.00, 1.75, 0.0, 2.50, 2.25, 1.80, 1.50];

  for (int i = 0; i < count; i++) {
    int row = i ~/ 4; // 4 columns
    int col = i % 4;
    String id = '${String.fromCharCode(65 + row)}${col + 1}'; // A1, A2...
    
    // logic to match image somewhat
    int pIndex = i % products.length;
    String name = products[pIndex];
    double price = prices[pIndex];
    int stock = 10;
    int max = 10;
    SlotStatus status = SlotStatus.normal;

    String assetPath = '';
    if (name.toLowerCase().contains('espresso')) {
      assetPath = 'assets/images/espresso.jpg';
    } else if (name.toLowerCase().contains('chocso')) {
      assetPath = 'assets/images/chocso_bytes_jd.jpg';
    } else if (name.toLowerCase().contains('cappuccino')) {
      assetPath = 'assets/images/cappacuino.jpg';
    }

    slots.add(ProductSlot(
      id: id,
      name: name,
      price: price,
      imageAsset: assetPath,
      currentStock: stock,
      maxStock: max,
      status: status,
    ));
  }
  return slots;
}
final Map<String, String> mockAssets = {
  'Espresso': 'images/espresso.jpg',
  'Latte': 'images/latte.jpg',
  'cappuccino': 'images/cappuccino.jpg',
  'Chocso BytesJD': 'images/chocso_bytes_jd.jpg',
  'Hot Chocolate': 'images/hot_chocolate.jpg',
  
};

// Sample machine data
final List<MachineData> mockMachines = [
  MachineData(
    index: 224,
    id: '2VE0000224',
    model: 'VENT10INCS',
    description: '22 Inch Hybrid Elevator',
    locationCode: 'CL0318',
    location: 'Nibilish',
    vendor: 'Nibilish',
    branch: 'BR00389',
    city: 'Nibilish',
    status: 'Online',
    connectionStatus: 'Disconnected',
    sales: 2450.75,
    stockLevel: 85,
  ),
  MachineData(
    index: 219,
    id: '2VE0000219',
    model: 'VENT22INEC',
    description: '22 Inch Spring MAchine',
    locationCode: 'CL0051',
    location: 'Anna Nagar,TamilNadu',
    vendor: 'Robo udpi',
    branch: 'BR00364',
    city: 'Tulunad',
    status: 'Online',
    connectionStatus: 'Disconnected',
    sales: 2105.50,
    stockLevel: 60,
    waterLevel: 24.5,
    maxWaterLevel: 30.0,
    temperature: 4.2,
    cashInBox: 184.00,
    slots: _generateSlots(4),
    alerts: [ 
        MachineAlert(title: 'Coin jam detected', timeString: '2 hours ago', type: AlertType.error),
        MachineAlert(title: 'Slot A4 Low Stock', timeString: '5 hours ago', type: AlertType.warning),
    ],
  ),
  MachineData(
    index: 222,
    id: '2VE0000222',
    model: 'VENT22INCS',
    description: '22 Inch Spring MAchine',
    locationCode: '',
    location: '',
    vendor: '',
    branch: '',
    city: '',
    status: 'Online',
    connectionStatus: 'Disconnected',
    sales: 1988.00,
    stockLevel: 90,
  ),
  MachineData(
    index: 221,
    id: 'IVE0000221',
    model: 'VENT32INCH',
    description: 'Icecream Vending Machine',
    locationCode: 'CL0010',
    location: 'Riota',
    vendor: 'Riota',
    branch: 'BR00003',
    city: 'Bangalore',
    status: 'Online',
    connectionStatus: 'Disconnected',
    sales: 1850.25,
    stockLevel: 25,
  ),
];

// Dashboard specific mock data (simplified for the table)
class DashboardMachineData {
  final String id;
  final String location;
  final String status;
  final String sales;
  final Color statusColor;

  const DashboardMachineData({
    required this.id,
    required this.location,
    required this.status,
    required this.sales,
    required this.statusColor,
  });
}

final List<DashboardMachineData> dashboardTopMachines = [
  const DashboardMachineData(
    id: 'VM-00842',
    location: 'Grand Central Station',
    status: 'Active',
    sales: '2,450.75',
    statusColor: Colors.green,
  ),
  const DashboardMachineData(
    id: 'VM-01121',
    location: 'City Public Library',
    status: 'Active',
    sales: '2,105.50',
    statusColor: Colors.green,
  ),
  const DashboardMachineData(
    id: 'VM-00309',
    location: 'Tech Park, Building C',
    status: 'Active',
    sales: '1,988.00',
    statusColor: Colors.green,
  ),
  const DashboardMachineData(
    id: 'VM-00715',
    location: 'Downtown Metro Stop',
    status: 'Inactive',
    sales: '1,850.25',
    statusColor: Colors.orange,
  ),
  const DashboardMachineData(
    id: 'VM-01588',
    location: 'University Student Center',
    status: 'Active',
    sales: '1,792.00',
    statusColor: Colors.green,
  ),
];

// Mock Transactions Data
final List<TransactionData> mockTransactions = [
  TransactionData(
    id: 'TXN-902341',
    machineId: '2VE0000224',
    product: 'Espresso',
    productImage: 'assets/images/espresso.jpg',
    date: 'Oct 30, 2023',
    time: '14:24 PM',
    amount: 45.00,
    paymentMethod: 'UPI',
    status: 'Completed',
  ),
  TransactionData(
    id: 'TXN-902339',
    machineId: '2VE0000219',
    product: 'Caffè Latte',
    productImage: 'assets/images/latte.jpg',
    date: 'Oct 30, 2023',
    time: '13:10 PM',
    amount: 65.00,
    paymentMethod: 'Cash',
    status: 'Completed',
  ),
  TransactionData(
    id: 'TXN-902335',
    machineId: '2VE0000222',
    product: 'Hot Chocolate',
    productImage: 'assets/images/hot_chocolate.jpg',
    date: 'Oct 30, 2023',
    time: '12:45 PM',
    amount: 55.00,
    paymentMethod: 'Card',
    status: 'Failed',
  ),
  TransactionData(
    id: 'TXN-902331',
    machineId: 'IVE0000221',
    product: 'Cappuccino',
    productImage: 'assets/images/cappuccino.jpg',
    date: 'Oct 30, 2023',
    time: '11:55 AM',
    amount: 75.00,
    paymentMethod: 'UPI',
    status: 'Refunded',
  ),
  TransactionData(
    id: 'TXN-902328',
    machineId: '2VE0000224',
    product: 'Espresso',
    productImage: 'assets/images/espresso.jpg',
    date: 'Oct 29, 2023',
    time: '18:12 PM',
    amount: 45.00,
    paymentMethod: 'Card',
    status: 'Completed',
  ),
  TransactionData(
    id: 'TXN-902325',
    machineId: '2VE0000219',
    product: 'Caffè Latte',
    productImage: 'assets/images/latte.jpg',
    date: 'Oct 29, 2023',
    time: '17:40 PM',
    amount: 65.00,
    paymentMethod: 'UPI',
    status: 'Completed',
  ),
  TransactionData(
    id: 'TXN-902320',
    machineId: '2VE0000222',
    product: 'Hot Chocolate',
    productImage: 'assets/images/hot_chocolate.jpg',
    date: 'Oct 29, 2023',
    time: '15:20 PM',
    amount: 55.00,
    paymentMethod: 'Cash',
    status: 'Completed',
  ),
];
