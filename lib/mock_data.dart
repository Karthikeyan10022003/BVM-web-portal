
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

    // if (name == 'Blueberry Bar') {
    //   stock = 8;
    //   max = 10;
    // }
    // if (id == 'A4') {
    //     name = 'Potato Chips';
    //     stock = 1;
    //     max = 10;
    //     status = SlotStatus.error; // Just to show the warning icon
    // }
    // if (id == 'B4') {
    //     name = 'Empty Slot';
    //     stock = 0;
    //     status = SlotStatus.empty;
    // }

    // Asset mapping
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
    index: 223,
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
