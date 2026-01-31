
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'main_layout.dart';
// import 'mock_data.dart'; // No longer needed for transactions

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

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  static const int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1; // Reset to page 1 on refresh
    });

    try {
      // Use 127.0.0.1 for local/emulator, or localhost for web
      // Adjust port if needed
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/getSalesData'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> list = data['data'];
          setState(() {
            _transactions = list.map((e) => TransactionModel.fromJson(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Unknown API Error';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;
      final double padding = isMobile ? 16 : 32;

      return Scaffold(
        backgroundColor: const Color(0xFF141414),
        body: MainLayout(
          activeTab: 'Transactions',
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),
                
                // Stats Cards
                _buildStatsCards(isMobile),
                const SizedBox(height: 32),

                // Search and Filters
                _buildFilterBar(),
                const SizedBox(height: 24),

                // Transactions Table
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFFE0CFA9)))
                else if (_errorMessage != null)
                  Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                else
                  _buildTransactionTable(),
                
                 const SizedBox(height: 24),
                 // Pagination (Visual only)
                 _buildPagination(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction History',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor all coffee vending machine sales and status.',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
                onPressed: () {},
              ),
            ),
             const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, color: Colors.black, size: 20),
              label: Text(
                'Export Report',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0CFA9),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsCards(bool isMobile) {
    // Calculate stats dynamic? Or keep mock for now? 
    // Let's use simple mock values for stats or derive from loaded data if we want.
    // For now, static is fine as requested only list update.
    
    double revenue = 0;
    int successCount = 0;
    for(var t in _transactions) {
        revenue += t.amount;
        if(t.status.toUpperCase() == 'SUCCESS') successCount++;
    }
    double successRate = _transactions.isNotEmpty ? (successCount / _transactions.length * 100) : 0;

    List<Widget> cards = [
      _buildStatCard(
        title: 'TOTAL TRANSACTIONS',
        value: '${_transactions.length}',
        subtitle: 'Total loaded transactions',
        badgeContent: '+12%',
        badgeColor: Colors.green,
      ),
      _buildStatCard(
        title: 'REVENUE', // Changed from Today since we fetch all available
        value: '₹${revenue.toStringAsFixed(2)}',
        subtitle: 'Total revenue from loaded data',
        topRightWidget: Row(
          children: [
             Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE0CFA9), shape: BoxShape.circle),),
             const SizedBox(width: 8),
             Text('Live', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)) 
          ],
        ),
      ),
      _buildStatCard(
        title: 'SUCCESS RATE',
        value: '${successRate.toStringAsFixed(1)}%',
        subtitle: 'Transaction completion efficiency',
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    String? badgeContent,
    Color? badgeColor,
    Widget? topRightWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 12,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badgeContent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                     badgeContent,
                     style: GoogleFonts.inter(
                       color: badgeColor ?? Colors.grey,
                       fontSize: 12,
                       fontWeight: FontWeight.bold,
                     ),
                  ),
                ),
               if (topRightWidget != null) topRightWidget,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
     return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by Transaction ID, Machine ID or Product...',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                         setState(() {
                           _currentPage = 1;
                         });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
           height: 48,
           padding: const EdgeInsets.symmetric(horizontal: 16),
           decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
               children: [
                 Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                 const SizedBox(width: 8),
                 Text(
                   'All Time', // Dynamic?
                   style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                 ),
                 const SizedBox(width: 8),
                 Icon(Icons.keyboard_arrow_down, color: Colors.grey[400], size: 16),
               ],
            ),
        ),
        const SizedBox(width: 16),
        Container(
           height: 48,
           padding: const EdgeInsets.symmetric(horizontal: 16),
           decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
               children: [
                 Icon(Icons.filter_list, color: Colors.grey[400], size: 16),
                 const SizedBox(width: 8),
                 Text(
                   'Filters',
                   style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                 ),
               ],
            ),
        ),
      ],
     );
  }

  Widget _buildTransactionTable() {
    // Filter logic
    final filter = _searchController.text.toLowerCase();
    final filtered = _transactions.where((t) {
        return t.id.toLowerCase().contains(filter) || 
               t.machineId.toLowerCase().contains(filter) ||
               t.product.toLowerCase().contains(filter);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Filter logic
          final filter = _searchController.text.toLowerCase();
          final filtered = _transactions.where((t) {
              return t.id.toLowerCase().contains(filter) || 
                     t.machineId.toLowerCase().contains(filter) ||
                     t.product.toLowerCase().contains(filter);
          }).toList();

          final int totalItems = filtered.length;
          final int startIndex = (_currentPage - 1) * _pageSize;
          final int endIndex = (startIndex + _pageSize < totalItems) ? startIndex + _pageSize : totalItems;
          final paginatedList = filtered.isEmpty ? [] : filtered.sublist(startIndex, endIndex);

          return Column(
            children: [
              // Header
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                 child: Row(
                    children: [
                       _buildHeaderCell('TRANSACTION\nID', width: 120),
                       _buildHeaderCell('MACHINE ID', width: 120),
                       _buildHeaderCell('PRODUCT', width: 180),
                       _buildHeaderCell('DATE\n& TIME', width: 100),
                       _buildHeaderCell('AMOUNT', width: 100),
                       _buildHeaderCell('METHOD', width: 100),
                       _buildHeaderCell('STATUS', width: 120),
                       _buildHeaderCell('ACTIONS', width: 80, alignRight: true),
                    ],
                 ),
               ),
               const Divider(height: 1, color: Color(0xFF333333)),
               
               // Rows
               if (paginatedList.isEmpty)
                  Padding(padding: EdgeInsets.all(24), child: Text("No transactions found", style: TextStyle(color: Colors.grey))),

               ...paginatedList.map((txn) => Column(
                 children: [
                   _buildTransactionRow(txn as TransactionModel),
                   if (txn != paginatedList.last)
                    const Divider(height: 1, color: Color(0xFF333333)),
                 ],
               )),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeaderCell(String text, {double? width, bool alignRight = false}) {
     Widget child = Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.inter(
        color: Colors.grey[500],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
    
    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(child: child);
  }

  Widget _buildTransactionRow(TransactionModel txn) { // Updated Type
     final dateFormat = DateFormat('MMM dd, yyyy');
     final timeFormat = DateFormat('hh:mm a');

     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
       child: Row(
         children: [
           SizedBox(
             width: 120,
             child: Text(
               txn.id,
               style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
               overflow: TextOverflow.ellipsis,
             ),
           ),
           SizedBox(
             width: 120,
             child: Text(
               txn.machineId,
               style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
             ),
           ),
           SizedBox(
             width: 180,
             child: Row(
               children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(4),
                       color: Colors.grey[800],
                       // Ensure asset exists, otherwise use Icon, or network image
                       image: DecorationImage(
                           image: AssetImage(txn.productImage), 
                           fit: BoxFit.cover,
                           onError: (e, s) {
                               // Fallback?
                           }
                       ),
                    ),
                    // Just in case asset doesn't load visually, can add child: Icon(Icons.coffee, size: 16, color: Colors.grey)
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                     txn.product,
                     style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                     overflow: TextOverflow.ellipsis,
                    ),
                  ),
               ],
             ),
           ),
           SizedBox(
             width: 100,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(dateFormat.format(txn.date), style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                 Text(timeFormat.format(txn.date), style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11)),
               ],
             ),
           ),
            SizedBox(
             width: 100,
             child: Text(
               '₹${txn.amount.toStringAsFixed(2)}',
               style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
             ),
           ),
            SizedBox(
             width: 100,
             child: Row(
               children: [
                 Icon(
                   // Simple mapping
                   txn.paymentMethod.toUpperCase().contains('CARD') ? Icons.credit_card : 
                   (txn.paymentMethod.toUpperCase().contains('UPI') ? Icons.qr_code : Icons.money),
                   color: Colors.grey[500],
                   size: 16,
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                    child: Text(
                        txn.paymentMethod,
                        style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                    ),
                 ),
               ],
             ),
           ),
            SizedBox(
             width: 120,
             child: Row(
               children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(txn.status))),
                  const SizedBox(width: 8),
                  Text(
                   txn.status,
                   style: GoogleFonts.inter(color: _getStatusColor(txn.status), fontSize: 13),
                 ),
               ],
             ),
           ),
           const Spacer(),
           IconButton(
             icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
             onPressed: () {},
           ),
         ],
       ),
     );
  }

  Color _getStatusColor(String status) {
    status = status.toUpperCase();
    if (status == 'SUCCESS' || status == 'COMPLETED') return Colors.green;
    if (status == 'FAILURE' || status == 'FAILED') return Colors.red;
    if (status == 'REFUNDED') return Colors.orange;
    return Colors.grey;
  }

  Widget _buildPagination() {
    final filter = _searchController.text.toLowerCase();
    final filtered = _transactions.where((t) {
        return t.id.toLowerCase().contains(filter) || 
               t.machineId.toLowerCase().contains(filter) ||
               t.product.toLowerCase().contains(filter);
    }).toList();

    final int totalItems = filtered.length;
    final int totalPages = (totalItems / _pageSize).ceil();
    final int startItem = totalItems == 0 ? 0 : (_currentPage - 1) * _pageSize + 1;
    final int endItem = (_currentPage * _pageSize < totalItems) ? _currentPage * _pageSize : totalItems;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $startItem-$endItem of $totalItems transactions',
          style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
        ),
        Row(
          children: [
            OutlinedButton(
               onPressed: _currentPage > 1 ? () {
                 setState(() {
                   _currentPage--;
                 });
               } : null,
               style: OutlinedButton.styleFrom(
                 side: BorderSide(color: _currentPage > 1 ? const Color(0xFFE0CFA9) : const Color(0xFF333333)),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                 foregroundColor: _currentPage > 1 ? const Color(0xFFE0CFA9) : Colors.grey[400],
               ),
               child: const Text('Previous'),
            ),
             const SizedBox(width: 12),
            OutlinedButton(
               onPressed: _currentPage < totalPages ? () {
                 setState(() {
                   _currentPage++;
                 });
               } : null,
               style: OutlinedButton.styleFrom(
                 side: BorderSide(color: _currentPage < totalPages ? const Color(0xFFE0CFA9) : const Color(0xFF333333)),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                 foregroundColor: _currentPage < totalPages ? const Color(0xFFE0CFA9) : Colors.grey[400],
               ),
               child: const Text('Next'),
            ),
          ],
        )
      ],
    );
  }
}