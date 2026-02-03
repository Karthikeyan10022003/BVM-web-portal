import 'package:intl/intl.dart';

class TransactionModel {
  final String id;
  final String machineId;
  final String product;
  final String productImage;
  final DateTime date;
  final double amount;
  final String paymentMethod;
  final String status;

  TransactionModel({
    required this.id,
    required this.machineId,
    required this.product,
    required this.productImage,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var dateMs = json['transaction_time'];
    DateTime dt = dateMs != null 
        ? DateTime.fromMillisecondsSinceEpoch(dateMs) 
        : DateTime.now();
        
    // Simple image mapping based on name or default
    String pName = json['product_name'] ?? 'Unknown';
    String img = 'assets/images/cappuccino.png'; // Default
    if (pName.toLowerCase().contains('espresso')) img = 'assets/images/espresso.png';
    else if (pName.toLowerCase().contains('latte')) img = 'assets/images/latte.png';
    
    return TransactionModel(
      id: json['transaction_id']?.toString() ?? '',
      machineId: json['machine_id']?.toString() ?? '',
      product: pName,
      productImage: img,
      date: dt,
      amount: (json['amount']/100 is num) ? (json['amount'] as num).toDouble()/100 : 0.0,
      paymentMethod: json['payment_type'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }
}
