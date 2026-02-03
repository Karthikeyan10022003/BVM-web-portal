import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mock_data.dart';
import 'machines_page.dart';
import 'main_layout.dart';
import 'transaction_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;
  String _selectedRange = 'Last 7 Days';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://bvm-web-portal.onrender.com/api/getSalesData'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> list = data['data'];
          setState(() {
            _allTransactions = list.map((e) => TransactionModel.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      setState(() => _isLoading = false);
    }
  }

  List<TransactionModel> get _filteredTransactions {
    final now = DateTime.now();
    DateTime startDate;

    if (_selectedRange == 'Last 7 Days') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (_selectedRange == 'Last 30 Days') {
      startDate = now.subtract(const Duration(days: 30));
    } else if (_selectedRange == 'All Time') {
      return _allTransactions;
    } else if (_selectedRange == 'Custom Range' && _customRange != null) {
      return _allTransactions.where((t) => 
        t.date.isAfter(_customRange!.start) && 
        t.date.isBefore(_customRange!.end.add(const Duration(days: 1)))
      ).toList();
    } else {
      return _allTransactions;
    }

    return _allTransactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  void _onRangeChanged(String range, {DateTimeRange? customRange}) {
    setState(() {
      _selectedRange = range;
      _customRange = customRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double padding = isMobile ? 16 : 32;

        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          body: MainLayout(
            activeTab: 'Dashboard',
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE0CFA9)))
              : SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _StatsRow(transactions: _filteredTransactions),
                    const SizedBox(height: 32),
                    _SalesPerformanceSection(
                      transactions: _filteredTransactions,
                      selectedRange: _selectedRange,
                      onRangeChanged: _onRangeChanged,
                    ),
                    const SizedBox(height: 32),
                    _MachinesTable(transactions: _filteredTransactions),
                  ],
                ),
              ),
          ),
        );
      }
    );
  }
}



class _StatsRow extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _StatsRow({required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0;
    for (var t in transactions) {
      totalRevenue += t.amount;
    }
    String totalTransactions = transactions.length.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
           return Column(
             children: [
               Row(
                 children: [
                   Expanded(child: _StatCard(title: 'Total Revenue', value: '₹${totalRevenue.toStringAsFixed(2)}')),
                   const SizedBox(width: 16),
                   Expanded(child: _StatCard(title: 'Total Sales', value: totalTransactions)),
                 ],
               ),
               const SizedBox(height: 16),
               Row(
                 children: [
                    Expanded(child: _StatCard(title: 'Active Machines', value: '1,150', statusColor: Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(title: 'Users Online', value: '12')),
                 ],
               )
             ],
           );
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Revenue',
                value: '₹${totalRevenue.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Sales',
                value: totalTransactions,
                statusColor: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Active Machines',
                value: '1',
                statusColor: Colors.green,
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: _StatCard(
            //     title: 'Users Online',
            //     value: '12',
            //   ),
            // ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? statusColor;

  const _StatCard({required this.title, required this.value, this.statusColor});

  @override
  Widget build(BuildContext context) {
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
            children: [
              if (statusColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded( // Prevent text overflow
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesPerformanceSection extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String selectedRange;
  final Function(String, {DateTimeRange? customRange}) onRangeChanged;

  const _SalesPerformanceSection({
    required this.transactions,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
             if (constraints.maxWidth < 600) {
               return Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(
                      'Sales Performance',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DateRangeButton(
                            text: 'Last 7 Days', 
                            isActive: selectedRange == 'Last 7 Days',
                            onTap: () => onRangeChanged('Last 7 Days'),
                          ),
                          const SizedBox(width: 12),
                          _DateRangeButton(
                            text: 'Last 30 Days',
                            isActive: selectedRange == 'Last 30 Days',
                            onTap: () => onRangeChanged('Last 30 Days'),
                          ),
                          const SizedBox(width: 12),
                          _DateRangeButton(
                            text: 'All Time',
                            isActive: selectedRange == 'All Time',
                            onTap: () => onRangeChanged('All Time'),
                          ),
                          const SizedBox(width: 12),
                          _DateRangeButton(
                            text: selectedRange == 'Custom Range' ? 'Custom Range' : 'Custom', 
                            hasDropdown: true,
                            isActive: selectedRange == 'Custom Range',
                            onTap: () => _showCustomDatePicker(context),
                          ),
                        ],
                      ),
                    ),
                 ],
               );
             }

             return Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Text(
                  'Sales Performance',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DateRangeButton(
                      text: 'Last 7 Days', 
                      isActive: selectedRange == 'Last 7 Days',
                      onTap: () => onRangeChanged('Last 7 Days'),
                    ),
                    const SizedBox(width: 12),
                    _DateRangeButton(
                      text: 'Last 30 Days',
                      isActive: selectedRange == 'Last 30 Days',
                      onTap: () => onRangeChanged('Last 30 Days'),
                    ),
                    const SizedBox(width: 12),
                    _DateRangeButton(
                      text: 'All Time',
                      isActive: selectedRange == 'All Time',
                      onTap: () => onRangeChanged('All Time'),
                    ),
                    const SizedBox(width: 12),
                    _DateRangeButton(
                      text: 'Custom Range', 
                      hasDropdown: true,
                      isActive: selectedRange == 'Custom Range',
                      onTap: () => _showCustomDatePicker(context),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
        
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1100) {
              return Column(
                children: [
                  SizedBox(height: 300, child: _RevenueChart(transactions: transactions)),
                  const SizedBox(height: 24),
                  SizedBox(height: 400, child: _TopSellingBeveragesChart(transactions: transactions)),
                ],
              );
            }
            return SizedBox(
              height: 340,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _RevenueChart(transactions: transactions)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _TopSellingBeveragesChart(transactions: transactions)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE0CFA9),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onRangeChanged('Custom Range', customRange: picked);
    }
  }
}

class _DateRangeButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool hasDropdown;
  final VoidCallback onTap;

  const _DateRangeButton({
    required this.text,
    required this.onTap,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF333333) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF333333)), // Subtle border
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _RevenueChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Generate spots from transactions
    Map<String, double> dailyRevenue = {};
    for (var t in transactions) {
      String dateKey = DateFormat('MMM dd').format(t.date);
      dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + t.amount;
    }

    List<String> sortedDates = dailyRevenue.keys.toList();
    // Sort dates if needed (they should already be somewhat sorted if transactions are sorted)
    // For simplicity, let's keep them as they appear or sort them by actual DateTime if we have it
    // Better to sort properly:
    List<DateTime> dateObjects = dailyRevenue.keys.map((d) => DateFormat('MMM dd').parse(d)).toList();
    // Adjust year for sorted dates comparison if needed, but relative order within a year is usually enough for dashboard.
    
    List<FlSpot> spots = [];
    double maxY = 1000;
    for (int i = 0; i < sortedDates.length; i++) {
        double amount = dailyRevenue[sortedDates[i]]!;
        spots.add(FlSpot(i.toDouble(), amount));
        if (amount > maxY) maxY = amount;
    }
    
    if(spots.isEmpty) {
        spots = [const FlSpot(0, 0)];
    }

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
                'Revenue Over Time',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: GoogleFonts.inter(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontSize: 10);
                        int index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                             // Show every Nth label to avoid crowding
                             int interval = (sortedDates.length / 5).ceil();
                             if (index % interval == 0) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(sortedDates[index], style: style),
                                );
                             }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY / 4).clamp(100, double.infinity),
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000
                              ? '₹${(value / 1000).toStringAsFixed(1)}k'
                              : '₹${value.toInt()}',
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sortedDates.length - 1).toDouble().clamp(0, double.infinity),
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFE0CFA9),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: spots.length < 20), // Only show dots for small datasets
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFE0CFA9).withOpacity(0.3),
                          const Color(0xFFE0CFA9).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        int index = touchedSpot.x.toInt();
                        String date = index < sortedDates.length ? sortedDates[index] : '';
                        return LineTooltipItem(
                          '$date\n₹${touchedSpot.y.toStringAsFixed(2)}',
                          GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSellingBeveragesChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TopSellingBeveragesChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    Map<String, int> productCounts = {};
    for (var t in transactions) {
      productCounts[t.product] = (productCounts[t.product] ?? 0) + 1;
    }

    var sortedProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int total = transactions.length;
    List<Color> colors = [
      const Color(0xFF8D6E63),
      const Color(0xFF4E342E),
      const Color(0xFFA1887F),
      const Color(0xFFD7CCC8),
      const Color(0xFF81C784),
    ];

    List<PieChartSectionData> sections = [];
    for (int i = 0; i < sortedProducts.length && i < 5; i++) {
        double percentage = (sortedProducts[i].value / total) * 100;
        sections.add(PieChartSectionData(
            color: colors[i % colors.length],
            value: percentage,
            radius: 20,
            showTitle: false,
        ));
    }

    // Centered text for the top product
    String topProduct = sortedProducts.isNotEmpty ? sortedProducts[0].key : 'N/A';
    double topPercentage = sortedProducts.isNotEmpty ? (sortedProducts[0].value / total * 100) : 0;

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
                'Top Selling Beverages',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                   Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),),
                   const SizedBox(width: 6),
                   Text('Live', style: GoogleFonts.inter(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: sections.isEmpty ? [PieChartSectionData(color: Colors.grey, value: 100, radius: 20, showTitle: false)] : sections,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${topPercentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        topProduct,
                        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(sortedProducts.length > 5 ? 5 : sortedProducts.length, (i) {
             return Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: _LegendItem(
                 color: colors[i % colors.length],
                 label: sortedProducts[i].key,
                 percentage: '${(sortedProducts[i].value / total * 100).toStringAsFixed(0)}%',
               ),
             );
          }),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[300],
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          percentage,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MachinesTable extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _MachinesTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Calculate machine performance
    Map<String, double> machineRevenue = {};
    for (var t in transactions) {
      machineRevenue[t.machineId] = (machineRevenue[t.machineId] ?? 0) + t.amount;
    }

    var sortedMachines = machineRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Machines',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final double minWidth = 800;
            final double contentWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      const _TableHeader(),
                      if (sortedMachines.isEmpty)
                         const Padding(padding: EdgeInsets.all(24), child: Text("No machine data for this range", style: TextStyle(color: Colors.grey))),
                      
                      ...sortedMachines.take(5).map((entry) {
                         final machineId = entry.key;
                         final revenue = entry.value;
                         
                         // Try to find machine in mock data for location
                         final mockMachine = mockMachines.firstWhere((m) => m.id == machineId, 
                            orElse: () => MachineData(index: 0, id: machineId, model: '', description: '', locationCode: '', location: 'Unknown Location', vendor: '', branch: '', city: '', status: 'Online', connectionStatus: '', sales: 0, stockLevel: 0));

                         Color statusColor = Colors.green;
                         if (mockMachine.status.toLowerCase() != 'online') statusColor = Colors.orange;
                         
                         return Column(
                          children: [
                             _TableRow(
                              id: machineId,
                              location: mockMachine.location,
                              status: mockMachine.status,
                              sales: revenue.toStringAsFixed(2),
                              statusColor: statusColor,
                            ),
                            const Divider(height: 1, color: Color(0xFF333333)),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _HeaderCell('MACHINE ID')),
          Expanded(flex: 3, child: _HeaderCell('LOCATION')),
          Expanded(flex: 2, child: _HeaderCell('STATUS')),
          Expanded(flex: 2, child: _HeaderCell('REVENUE', alignRight: true)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool alignRight;

  const _HeaderCell(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.inter(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String id;
  final String location;
  final String status;
  final String sales;
  final Color statusColor;

  const _TableRow({
    required this.id,
    required this.location,
    required this.status,
    required this.sales,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              id,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              location,
              style: GoogleFonts.inter(color: Colors.grey[300]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sales,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}