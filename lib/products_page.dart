import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mock_data.dart';
import 'machines_page.dart';
import 'main_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> _products = [];
  Map<String, dynamic> _stats = {
    'totalProducts': 0,
    'avgPrice': 0.0,
    'lowStock': 0,
  };
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://bvm-web-portal.onrender.com/api/getProducts'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _products = jsonResponse['data']['products'];
            _stats = jsonResponse['data']['stats'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load products: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double padding = isMobile ? 16 : 32;

        return Scaffold(
          backgroundColor: const Color(0xFF141414), // Dark background
          body: MainLayout(
            activeTab: 'Products',
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFDD0)))
              : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            Text(
                    'Products Management',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                const Spacer(),
                const Icon(Icons.notifications, color: Colors.white),
                const SizedBox(width: 50),
                ElevatedButton.icon(
                onPressed: () {
                    // Perform an action
                },
               
                icon: const Icon(Icons.add), // The icon widget
                label: const Text('Add Products'),    // The text label
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFFFDD0),//cream color
                ),
                )
                        ],
                    ),
                 
                const SizedBox(height: 32),
                _StatsRow(stats: _stats),
                const SizedBox(height: 32),
                // child:_buildSearchField(),
                const SizedBox(height: 32),
                _ProductsTable(products: _products),
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
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
           return Column(
             children: [
               Row(
                 children: [
                   Expanded(child: _StatCard(title: 'Total Products', value: stats['totalProducts'].toString())),
                   const SizedBox(width: 16),
                   Expanded(child: _StatCard(title: 'Low Stock', value: stats['lowStock'].toString(), statusColor: Colors.orange)),
                   Expanded(child: _StatCard(title: 'Avg Price', value: '₹${stats['avgPrice'].toStringAsFixed(2)}')),
                 ],
               ),
               const SizedBox(height: 16),
             ],
           );
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Products',
                value: stats['totalProducts'].toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Low Stock',
                value: stats['lowStock'].toString(),
                statusColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Avg Price',
                value: '₹${stats['avgPrice'].toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}
// Widget _buildSearchField() {
//     return TextField(
//       controller: _searchController,
//       onChanged: (value) {
//         setState(() {
//           _searchQuery = value;
//         });
//       },
//       style: GoogleFonts.inter(
//         color: Colors.white,
//         fontSize: 14,
//       ),
//       decoration: InputDecoration(
//         hintText: 'Search by machine ID, location, or model...',
//         hintStyle: GoogleFonts.inter(
//           color: Colors.grey[600],
//           fontSize: 14,
//         ),
//         prefixIcon: Icon(
//           Icons.search,
//           color: Colors.grey[600],
//           size: 20,
//         ),
//         suffixIcon: _searchQuery.isNotEmpty
//             ? IconButton(
//                 icon: Icon(
//                   Icons.clear,
//                   color: Colors.grey[600],
//                   size: 20,
//                 ),
//                 onPressed: () {
//                   _searchController.clear();
//                   setState(() {
//                     _searchQuery = '';
//                   });
//                 },
//               )
//             : null,
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//       ),
//     );
//   }

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
  const _SalesPerformanceSection();

  @override
  Widget build(BuildContext context) { 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
             // Stack header items on very small screens
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
                          _DateRangeButton(text: 'Last 7 Days', isActive: true),
                          const SizedBox(width: 12),
                          _DateRangeButton(text: 'Last 30 Days'),
                          const SizedBox(width: 12),
                          _DateRangeButton(text: 'Custom', hasDropdown: true),
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
                    _DateRangeButton(text: 'Last 7 Days', isActive: true),
                    const SizedBox(width: 12),
                    _DateRangeButton(text: 'Last 30 Days'),
                    const SizedBox(width: 12),
                    _DateRangeButton(text: 'Custom Range', hasDropdown: true),
                  ],
                ),
              ],
            );
          }
        ),
        
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1100) { // Increased breakpoint for stacking charts
              return Column(
                children: [
                  const SizedBox(height: 300, child: _RevenueChart()),
                  const SizedBox(height: 24),
                  const SizedBox(height: 400, child: _TopSellingBeveragesChart()), // Increased height for mobile legend readability
                ],
              );
            }
            return SizedBox(
              height: 340,
              child: Row(
                children: [
                  const Expanded(flex: 2, child: _RevenueChart()),
                  const SizedBox(width: 24),
                  const Expanded(flex: 1, child: _TopSellingBeveragesChart()),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool hasDropdown;

  const _DateRangeButton({
    required this.text,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

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
                        const style = TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Oct 1', style: style);
                            break;
                          case 4:
                            text = const Text('Oct 8', style: style);
                            break;
                          case 8:
                            text = const Text('Oct 15', style: style);
                            break;
                          case 12:
                            text = const Text('Oct 22', style: style);
                            break;
                          case 16:
                            text = const Text('Oct 30', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(1)}k'
                              : '${value.toInt()}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 16,
                minY: 0,
                maxY: 2000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 800),
                      FlSpot(1, 1000),
                      FlSpot(2, 900),
                      FlSpot(3, 1100),
                      FlSpot(4, 1000),
                      FlSpot(5, 1400),
                      FlSpot(6, 1300),
                      FlSpot(7, 1600),
                      FlSpot(8, 1500),
                      FlSpot(9, 1100),
                      FlSpot(10, 1200),
                      FlSpot(11, 900),
                      FlSpot(12, 1000),
                      FlSpot(13, 800),
                      FlSpot(14, 1100),
                      FlSpot(15, 900),
                      FlSpot(16, 700),
                    ],
                    isCurved: true,
                    color: const Color(0xFFE0CFA9),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
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
                        return LineTooltipItem(
                          'Oct 18\n1,120.50',
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
  const _TopSellingBeveragesChart();

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
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF8D6E63), // Cappuccino Brown
                        value: 35,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF4E342E), // Espresso Dark Brown
                        value: 20,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFA1887F), // Cold Coffee Light Brown
                        value: 20,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFD7CCC8), // Tea Beige
                        value: 15,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF81C784), // Green Tea Green
                        value: 10,
                        radius: 20,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '35%',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cappuccino',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _LegendItem(
            color: Color(0xFF8D6E63),
            label: 'Cappuccino',
            percentage: '35%',
          ),
          const SizedBox(height: 8),
          const _LegendItem(
            color: Color(0xFF4E342E),
            label: 'Espresso',
            percentage: '20%',
          ),
          const SizedBox(height: 8),
          const _LegendItem(
            color: Color(0xFFA1887F),
            label: 'Cold Coffee',
            percentage: '20%',
          ),
          const SizedBox(height: 8),
          const _LegendItem(
            color: Color(0xFFD7CCC8),
            label: 'Tea',
            percentage: '15%',
          ),
          const SizedBox(height: 8),
          const _LegendItem(
            color: Color(0xFF81C784),
            label: 'Green Tea',
            percentage: '10%',
          ),
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

class _ProductsTable extends StatelessWidget {
  final List<dynamic> products;
  const _ProductsTable({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Master List',
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
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No products found', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ...products.map((product) {
                           return Column(
                            children: [
                               _TableRow(
                                id: product['product_id'] ?? 'N/A',
                                name: product['product_name'] ?? 'Unknown',
                                cost: '₹${((product['product_cost'] ?? 0) / 100).toStringAsFixed(2)}',
                                image: product['product_image'] ?? '',
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
          Expanded(flex: 2, child: _HeaderCell('PRODUCT ID')),
          Expanded(flex: 1, child: _HeaderCell('IMAGE')),
          Expanded(flex: 3, child: _HeaderCell('NAME')),
          Expanded(flex: 2, child: _HeaderCell('COST', alignRight: true)),
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
  final String name;
  final String cost;
  final String image;

  const _TableRow({
    required this.id,
    required this.name,
    required this.cost,
    required this.image,
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
            flex: 1,
            child: image.isNotEmpty 
              ? SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      image, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                )
              : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: GoogleFonts.inter(color: Colors.grey[300]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cost,
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
