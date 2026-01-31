import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'mock_data.dart';
import 'main_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

  Widget _getPlatformImage(String path) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

class IndividualMachinePage extends StatelessWidget {
  final MachineData machine;

  const IndividualMachinePage({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: MainLayout(
        activeTab: 'Machines',
        child: LayoutBuilder(
          builder: (context, constraints) {
             final bool isMobile = constraints.maxWidth < 600;
             final double padding = isMobile ? 16 : 32;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb / Back Navigation
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.grey[400], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Back to Machines',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Enhanced Header
                  LayoutBuilder(
                    builder: (context, headerConstraints) {
                      bool isSmallHeader = headerConstraints.maxWidth < 700;
                      
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF2C2C2C).withOpacity(0.5), const Color(0xFF1E1E1E).withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: isSmallHeader 
                        ? Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Row(
                                  children: [
                                     Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0CFA9).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE0CFA9).withOpacity(0.3)),
                                      ),
                                      child: const Icon(Icons.coffee_maker, color: Color(0xFFE0CFA9), size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            Text(
                                              machine.id,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _StatusChip(status: machine.status),
                                         ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          machine.location,
                                          style: GoogleFonts.inter(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.circle, color: machine.connectionStatus == 'Online' ? Colors.green : Colors.red, size: 8),
                                      const SizedBox(width: 8),
                                      Text(
                                        machine.connectionStatus,
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                             ],
                          )
                        : Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0CFA9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0CFA9).withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.coffee_maker, color: Color(0xFFE0CFA9), size: 32),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        machine.id,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _StatusChip(status: machine.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        machine.location,
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Icon(Icons.circle, color: machine.connectionStatus == 'Online' ? Colors.green : Colors.red, size: 8),
                                      const SizedBox(width: 8),
                                      Text(
                                        machine.connectionStatus,
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 32),

                  // Main Content Area
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 1000) {
                        return Column(
                          children: [
                            // Stacked layout for small screens
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Product Slots',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (constraints.maxWidth > 500) // Hide total badge on very small screens to save space
                                          _Badge(text: 'Total: ${machine.slots.length}', color: const Color(0xFF2C2C2C), textColor: Colors.grey),
                                        if (constraints.maxWidth > 500)
                                          const SizedBox(width: 12),
                                        _Badge(
                                            text: '${machine.slots.where((s) => s.status == SlotStatus.empty).length} Empty', 
                                            color: const Color(0xFF3E1E1E), 
                                            textColor: const Color(0xFFFF6B6B)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _ProductSlotsGrid(slots: machine.slots, machineId: machine.index),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Column(
                              children: [
                                _WaterTankWidget(
                                  currentLevel: machine.waterLevel,
                                  maxLevel: machine.maxWaterLevel,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.thermostat,
                                        iconColor: Colors.orange,
                                        value: '90 °C',
                                        label: 'Temperature',
                                      ),
                                    ),
                                  ],
                                ),
                                 const SizedBox(height: 24),
                                 if (machine.alerts.isNotEmpty)
                                    _RecentAlertsWidget(alerts: machine.alerts),
                              ],
                            ),
                          ],
                        );
                      }
                      
                      // Original Row layout for large screens
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7, 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Product Slots',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _Badge(text: 'Total: ${machine.slots.length} Slots', color: const Color(0xFF2C2C2C), textColor: Colors.grey),
                                        const SizedBox(width: 12),
                                        _Badge(
                                            text: '${machine.slots.where((s) => s.status == SlotStatus.empty).length} Empty', 
                                            color: const Color(0xFF3E1E1E), 
                                            textColor: const Color(0xFFFF6B6B)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _ProductSlotsGrid(slots: machine.slots, machineId: machine.index),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _WaterTankWidget(
                                  currentLevel: machine.waterLevel,
                                  maxLevel: machine.maxWaterLevel,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.thermostat,
                                        iconColor: Colors.orange,
                                        value: '90 °C',
                                        label: 'Temperature',
                                      ),
                                    ),
                                  ],                                  
                                ),
                                //  const SizedBox(height: 24),
                                //  if (machine.alerts.isNotEmpty)
                                //     _RecentAlertsWidget(alerts: machine.alerts),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2F23),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.inter(
              color: const Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HeaderActionButton({
    required this.text,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE0CFA9) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isPrimary ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ProductSlotsGrid extends StatefulWidget {
  final List<ProductSlot> slots;
  final int machineId;

  const _ProductSlotsGrid({required this.slots, required this.machineId});

  @override
  State<_ProductSlotsGrid> createState() => _ProductSlotsGridState();
}

class _ProductSlotsGridState extends State<_ProductSlotsGrid> {
  List<ProductSlot> _slots = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _slots = List.from(widget.slots);
    _fetchSlots();
  }


  Future<void> _fetchSlots() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/getSlotDetails?machineId=${widget.machineId}'));
      print("Data recieved from api"+response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Attempt to locate the products list based on expected API structure
        List<dynamic>? productsList;
        if (jsonResponse.containsKey('data')) {
            if (jsonResponse['data'] is Map && jsonResponse['data']['products'] != null) {
               productsList = jsonResponse['data']['products'];
            } else if (jsonResponse['data'] is List) {
               productsList = jsonResponse['data'];
            }
        } else if (jsonResponse['products'] != null) {
             productsList = jsonResponse['products'];
        } else if (jsonResponse['result'] != null && jsonResponse['result'] is List) {
             productsList = jsonResponse['result'];
        }
        
        if (productsList != null) {
          final List<ProductSlot> fetchedSlots = productsList.map((data) {
            print("Data of stock :"+data['stockInfo'].toString());
            List stock_data=data['stockInfo'];
            print("Data of stock :"+stock_data.toString());
            int qty=0;
            if(stock_data.isNotEmpty){
              qty=stock_data[0]['qty'];
            }
            return ProductSlot(
              id: data['slotName']?.toString() ?? '',
              name: data['Product Name'] ?? 'Unknown',
              price: ((data['Product Cost'] ?? 0)/100).toDouble(),
              imageAsset: mockAssets[data['Product Name']] ?? data['Product Image'] ?? '',
              
              currentStock: qty??0,
              maxStock: 10,
              status: _parseStatus(data['status']),
              localImagePath: null, 
            );
          }).toList();

          if (mounted) {
            setState(() {
              _slots = fetchedSlots;
              _isLoading = false;
            });
          }
        } else {
           if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() {
             _error = 'Failed to load: ${response.statusCode}';
             _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
           _error = 'Error: $e';
           _isLoading = false;
        });
      }
    }
  }

  SlotStatus _parseStatus(String? status) {
    if (status == null) return SlotStatus.normal;
    switch (status.toLowerCase()) {
      case 'empty': return SlotStatus.empty;
      case 'low': return SlotStatus.lowStock; // Check if API returns 'low' or something else
      case 'error': return SlotStatus.error;
      default: return SlotStatus.normal;
    }
  }

  void _handleSlotUpdate(int index, ProductSlot updatedSlot) {
    setState(() {
      _slots[index] = updatedSlot;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
         height: 200,
         alignment: Alignment.center,
         decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
         child: const CircularProgressIndicator(color: Color(0xFFE0CFA9)),
      );
    }
    
    if (_error != null) {
       return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Text(
          'Failed to load slots: $_error', 
          style: GoogleFonts.inter(color: Colors.red[300]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6, // Wider cards
        ),
        itemCount: _slots.length,
        itemBuilder: (context, index) {
          return _ProductSlotCard(
            slot: _slots[index],
            machineId: widget.machineId,
            onSlotUpdated: (updatedSlot) => _handleSlotUpdate(index, updatedSlot),
          );
        },
      ),
    );
  }
}

class _ProductSlotCard extends StatelessWidget {
  final ProductSlot slot;
  final int machineId;
  final Function(ProductSlot) onSlotUpdated;

  const _ProductSlotCard({required this.slot, required this.machineId, required this.onSlotUpdated});

  @override
  Widget build(BuildContext context) {
    bool isEmpty = slot.status == SlotStatus.empty;
    
    // Determine status color and text
    Color statusColor;
    String statusText;
    
    if (isEmpty || slot.currentStock == 0) {
      statusColor = const Color(0xFFFF4444); // Red
      statusText = 'Empty';
    } else if (slot.currentStock < 3) {
      statusColor = Colors.orange;
      statusText = 'Low'; // Or 'Low Stock'
    } else {
      statusColor = const Color(0xFF00C853); // Green
      statusText = 'Healthy';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161618), // Slightly darker card background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: ID Badge and Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: ID Badge + Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          slot.id,
                          style: GoogleFonts.inter(
                            color: Colors.blue[200],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final result = await showDialog<ProductSlot>(
                            context: context,
                            builder: (context) => _EditSlotDialog(slot: slot, machineId: machineId),
                          );
                          if (result != null) {
                            onSlotUpdated(result);
                          }
                        },
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row: Image + Text
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                             color: Colors.black26, 
                          ),
                          child: (slot.localImagePath != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _getPlatformImage(slot.localImagePath!),
                                )
                              : (slot.imageAsset.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: _buildSlotImage(slot.imageAsset),
                                    )
                                  : const Icon(Icons.inventory_2_outlined, color: Colors.grey)),
                        ),
                        const SizedBox(width: 12),
                        // Name and Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isEmpty ? 'Empty Slot' : slot.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '₹${slot.price.toInt()}.00',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Section: Progress Bar and Status
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: isEmpty ? 0 : (slot.currentStock / slot.maxStock),
                    backgroundColor: const Color(0xFF333333),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${slot.currentStock} / ${slot.maxStock}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotImage(String path) {
    if (path.isEmpty) {
      return const Center(child: Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 24));
    }

    String decodedPath = path.trim();
    // Recursively decode
    int decodeAttempts = 0;
    while (decodedPath.contains('%') && decodeAttempts < 3) {
      try {
        decodedPath = Uri.decodeFull(decodedPath);
      } catch (_) {
        break; // Stop if decoding fails
      }
      decodeAttempts++;
    }

    if (decodedPath.toLowerCase().startsWith('http')) {
      return Image.network(
        decodedPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
           return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 24));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: const Color(0xFFE0CFA9),
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
    
    return Image.asset(
      path, 
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 24)),
    );
  }
}


class _WaterTankWidget extends StatelessWidget {
  final double currentLevel;
  final double maxLevel;

  const _WaterTankWidget({required this.currentLevel, required this.maxLevel});

  @override
  Widget build(BuildContext context) {
    final percentage = (currentLevel / maxLevel * 100).clamp(0, 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Level',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                   color: percentage < 20 ? const Color(0x33FF6B6B) : const Color(0x332196F3),
                   borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  percentage < 20 ? 'Low' : 'Normal',
                  style: GoogleFonts.inter(
                    color: percentage < 20 ? const Color(0xFFFF6B6B) : Colors.blue, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w600
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
               // If constrained on mobile, maybe adjust layout of tank
               bool isSmall = constraints.maxWidth < 350;
               
               if (isSmall) {
                  return Column(
                     children: [
                        // Tank Visual
                        Container(
                          height: 150,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                           child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Water
                                FractionallySizedBox(
                                  heightFactor: percentage / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                       gradient: LinearGradient(
                                         begin: Alignment.topCenter,
                                         end: Alignment.bottomCenter,
                                         colors: [Colors.blue[400]!, Colors.blue[800]!],
                                       ),
                                    ),
                                  ),
                                ),
                                // Glass reflection shine
                                 Positioned(
                                   top: 10, right: 8,
                                   child: Container(
                                     height: 30, width: 3,
                                     decoration: BoxDecoration(
                                       color: Colors.white.withOpacity(0.1),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                   ),
                                 ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                              _TankStat(label: 'Capacity', value: '${maxLevel.toInt()}L'),
                              _TankStat(label: 'Current', value: '${currentLevel.toStringAsFixed(1)}L', highlight: true),
                              _TankStat(label: 'Level', value: '$percentage%'),
                           ],
                        )
                     ],
                  );
               }

               return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tank Visual
                  Container(
                    height: 180,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(39),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Water
                          FractionallySizedBox(
                            heightFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                 gradient: LinearGradient(
                                   begin: Alignment.topCenter,
                                   end: Alignment.bottomCenter,
                                   colors: [Colors.blue[400]!, Colors.blue[800]!],
                                 ),
                              ),
                            ),
                          ),
                          // Glass reflection shine
                           Positioned(
                             top: 10, right: 10,
                             child: Container(
                               height: 40, width: 4,
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                             ),
                           ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _TankStat(label: 'Capacity', value: '${maxLevel.toInt()}L'),
                       const SizedBox(height: 16),
                       _TankStat(label: 'Current', value: '${currentLevel.toStringAsFixed(1)}L', highlight: true),
                       const SizedBox(height: 16),
                       _TankStat(label: 'Level', value: '$percentage%'),
                    ],
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}

class _TankStat extends StatelessWidget {
   final String label;
   final String value;
   final bool highlight;
   const _TankStat({required this.label, required this.value, this.highlight = false});
   
   @override
   Widget build(BuildContext context) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
         Text(value, style: GoogleFonts.inter(
           color: highlight ? Colors.white : Colors.grey[300], 
           fontSize: 18, 
           fontWeight: FontWeight.w600)
         ),
       ],
     );
   }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
           Text(
            label,
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RecentAlertsWidget extends StatelessWidget {
  final List<MachineAlert> alerts;

  const _RecentAlertsWidget({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Alerts',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
             Text(
              'No recent alerts',
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              separatorBuilder: (c, i) => const Divider(color: Color(0xFF333333), height: 24),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      alert.type == AlertType.error ? Icons.error_outline : Icons.warning_amber_rounded,
                      color: alert.type == AlertType.error ? const Color(0xFFFF6B6B) : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.timeString,
                            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'View all 12 alerts',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00C853),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditSlotDialog extends StatefulWidget {
  final ProductSlot slot;
  final int machineId;

  const _EditSlotDialog({required this.slot, required this.machineId});

  @override
  State<_EditSlotDialog> createState() => _EditSlotDialogState();
}

class _EditSlotDialogState extends State<_EditSlotDialog> {
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late double _maxCapacity;
  late bool _isEnabled;
  XFile? _pickedImageFile;
  String? _stockErrorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.slot.name);
    _skuController = TextEditingController(text: 'PRD-CHO-003'); // Mock SKU
    _priceController = TextEditingController(text: widget.slot.price.toStringAsFixed(2));
    _stockController = TextEditingController(text: widget.slot.currentStock.toString());
    _maxCapacity = widget.slot.maxStock.toDouble();
    _isEnabled = widget.slot.status != SlotStatus.error && widget.slot.status != SlotStatus.empty;
    _stockController.addListener(_validateStock);
  }

  void _validateStock() {
    final stock = int.tryParse(_stockController.text);
    if (stock != null && stock > _maxCapacity) {
      setState(() {
        _stockErrorText = 'Cannot exceed max capacity (${_maxCapacity.toInt()})';
      });
    } else {
      if (_stockErrorText != null) {
        setState(() {
          _stockErrorText = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _stockController.removeListener(_validateStock);
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Edit Slot ${widget.slot.id}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0CFA9).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE0CFA9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF333333)),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update product details and inventory.',
                      style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Product Image & Details Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Placeholder
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Image',
                              style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      _pickedImageFile = image;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Center(
                                  child: _pickedImageFile != null 
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: _getPlatformImage(_pickedImageFile!.path),
                                      )
                                    : (widget.slot.localImagePath != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(7),
                                            child: _getPlatformImage(widget.slot.localImagePath!),
                                          )
                                        : (widget.slot.imageAsset.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: Image.asset(widget.slot.imageAsset, fit: BoxFit.contain, width: 60, height: 60),
                                              )
                                            : const Icon(Icons.add_a_photo, color: Colors.grey))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'JPG, PNG max 2MB',
                              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Inputs
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DialogInput(
                                label: 'PRODUCT NAME',
                                controller: _nameController,
                              ),
                              const SizedBox(height: 16),
                              _DialogInput(
                                label: 'SKU / ID',
                                controller: _skuController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pricing & Stock
                    Row(
                      children: [
                        Expanded(
                          child: _DialogInput(
                            label: 'Price (₹)',
                            controller: _priceController,
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 12, top: 14),
                              child: Text('₹ ', style: TextStyle(color: Colors.grey)),
                            ),
                            suffix: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Text('INR', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               _DialogInput(
                                label: 'Current Stock',
                                controller: _stockController,
                                errorText: _stockErrorText,
                                suffix: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: const BoxDecoration(
                                    border: Border(left: BorderSide(color: Color(0xFF333333))),
                                  ),
                                  child: Text('/ ${_maxCapacity}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 12),
                                  const SizedBox(width: 6),
                                  Text('Healthy Level', style: GoogleFonts.inter(color: Colors.green, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Max Capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Max Capacity', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('${_maxCapacity.toInt()} Units', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF556070),
                        inactiveTrackColor: const Color(0xFF2C2C2C),
                        thumbColor: const Color(0xFFE0CFA9),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _maxCapacity,
                        min: 0,
                        max: 30,
                        onChanged: (val) {
                          setState(() => _maxCapacity = val);
                          _validateStock();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10)),
                        Text('10', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10)),
                        Text('20', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10)),
                        Text('30', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10)),

                      ],
                    ),
                    const SizedBox(height: 32),

                    // Slot Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Slot Status', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text('Enable or disable this slot for customers', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                          Switch(
                            value: _isEnabled,
                            onChanged: (val) => setState(() => _isEnabled = val),
                            activeColor: const Color(0xFFE0CFA9),
                            activeTrackColor: const Color(0xFFE0CFA9).withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   if (_isSaving) ...[
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE0CFA9))),
                      const SizedBox(width: 16),
                   ],
                  TextButton(
                     onPressed: _isSaving ? null : () => Navigator.pop(context),
                     style: TextButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF333333))),
                     ),
                     child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_stockErrorText != null || _isSaving) ? null : () async {
                      setState(() {
                        _isSaving = true;
                      });

                      try {
                        // Prepare payload
                        final double price = double.tryParse(_priceController.text) ?? widget.slot.price;
                        final int stock = int.tryParse(_stockController.text) ?? widget.slot.currentStock;
                        final int maxStock = _maxCapacity.toInt();
                        
                        // Simple status logic: if disabled -> Empty, else if stock=0 -> Empty, else Normal
                        // But wait, the user might want 'error' status? 
                        // For this edit dialog, let's keep it simple.
                        final String statusStr = !_isEnabled ? 'Empty' : (stock == 0 ? 'Empty' : 'Normal');

                        final body = {
                          'machineId': widget.machineId,
                          'slotId': widget.slot.id,
                          'name': _nameController.text,
                          'price': price,
                          'stock': stock,
                          'maxStock': maxStock,
                          'status': statusStr,
                          'enable': _isEnabled,
                          // 'localImage': _pickedImageFile?.path // Send this eventually?
                        };

                        final response = await http.post(
                          Uri.parse('http://127.0.0.1:5000/api/updateSlot'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(body),
                        );

                        if (response.statusCode == 200) {
                           // Success
                           final updatedSlot = ProductSlot(
                              id: widget.slot.id,
                              name: _nameController.text,
                              price: price,
                              imageAsset: widget.slot.imageAsset, 
                              maxStock: maxStock,
                              currentStock: stock,
                              status: _isEnabled ? (stock == 0 ? SlotStatus.empty : SlotStatus.normal) : SlotStatus.empty, 
                              localImagePath: _pickedImageFile?.path ?? widget.slot.localImagePath,
                           );
                           if (mounted) Navigator.pop(context, updatedSlot);
                        } else {
                           // Error
                           setState(() => _isSaving = false);
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: ${response.statusCode}')));
                        }
                      } catch (e) {
                         setState(() => _isSaving = false);
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0CFA9),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;

  const _DialogInput({
    required this.label,
    required this.controller,
    this.prefix,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: errorText != null ? const Color(0xFFFF6B6B) : const Color(0xFF333333)),
          ),
          child: Row(
            children: [
              if (prefix != null) prefix!,
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    isDense: true,
                  ),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: GoogleFonts.inter(color: const Color(0xFFFF6B6B), fontSize: 12),
          ),
        ],
      ],
    );
  }
}