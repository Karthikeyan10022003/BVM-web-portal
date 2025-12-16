import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mock_data.dart';
import 'individual_machine_page.dart';
import 'main_layout.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample machine data matching the provided image
  final List<MachineData> _allMachines = mockMachines;

  List<MachineData> get _filteredMachines {
    if (_searchQuery.isEmpty) {
      return _allMachines;
    }
    return _allMachines.where((machine) {
      return machine.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          machine.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          machine.model.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: MainLayout(
        activeTab: 'Machines',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Machines',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Search bar and view toggle
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by machine ID, location, or model...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // View toggle buttons
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      children: [
                        _ViewToggleButton(
                          icon: Icons.grid_view,
                          isActive: _isGridView,
                          onTap: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFF333333),
                        ),
                        _ViewToggleButton(
                          icon: Icons.view_list,
                          isActive: !_isGridView,
                          onTap: () {
                            setState(() {
                              _isGridView = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Results count
              Text(
                '${_filteredMachines.length} machine${_filteredMachines.length != 1 ? 's' : ''} found',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Machines display
              _isGridView
                  ? _buildGridView()
                  : _buildListView(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredMachines.length,
      itemBuilder: (context, index) {
        return _MachineGridCard(machine: _filteredMachines[index]);
      },
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 3000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 100, child: _HeaderCell('ID')), 
                    const SizedBox(width: 180, child: _HeaderCell('MACHINE ID')),
                    const SizedBox(width: 180, child: _HeaderCell('MODEL')),
                    const SizedBox(width: 250, child: _HeaderCell('DESCRIPTION')),
                    const SizedBox(width: 100, child: _HeaderCell('CLIENT ID')),
                    const SizedBox(width: 150, child: _HeaderCell('LOCATION')),
                    const SizedBox(width: 100, child: _HeaderCell('BRANCH')),
                    const SizedBox(width: 120, child: _HeaderCell('CITY')),
                    const SizedBox(width: 100, child: _HeaderCell('STATUS')),
                    const SizedBox(width: 120, child: _HeaderCell('CONN STATUS', alignRight: true)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF333333)),
              // Table rows
              ..._filteredMachines.map((machine) => Column(
                children: [
                  _MachineListRow(machine: machine),
                  const Divider(height: 1, color: Color(0xFF333333)),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}



class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFE0CFA9) : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }
}

class _MachineGridCard extends StatefulWidget {
  final MachineData machine;

  const _MachineGridCard({required this.machine});

  @override
  State<_MachineGridCard> createState() => _MachineGridCardState();
}

class _MachineGridCardState extends State<_MachineGridCard> {
  bool _isHovered = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualMachinePage(machine: widget.machine),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? const Color(0xFFE0CFA9) : const Color(0xFF333333),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFE0CFA9).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.machine.id,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _StatusBadge(statusText: widget.machine.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.machine.location.isNotEmpty ? widget.machine.location : 'Unknown Location',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               // Stock level progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Level',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.machine.stockLevel}%',
                        style: GoogleFonts.inter(
                          color: _getStockLevelColor(widget.machine.stockLevel),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.machine.stockLevel / 100,
                      backgroundColor: const Color(0xFF333333),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStockLevelColor(widget.machine.stockLevel),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Sales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Sales',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.machine.sales.toStringAsFixed(2),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE0CFA9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
   Color _getStockLevelColor(int level) {
    if (level >= 70) return Colors.green;
    if (level >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _MachineListRow extends StatefulWidget {
  final MachineData machine;

  const _MachineListRow({required this.machine});

  @override
  State<_MachineListRow> createState() => _MachineListRowState();
}

class _MachineListRowState extends State<_MachineListRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualMachinePage(machine: widget.machine),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _isHovered ? const Color(0xFF252525) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  widget.machine.index.toString(),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
              ),
              SizedBox(
                width: 180,
                child: Text(
                  widget.machine.id,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: 180,
                child: Text(
                  widget.machine.model,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 250,
                child: Text(
                  widget.machine.description,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  widget.machine.locationCode,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  widget.machine.location,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  widget.machine.branch,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  widget.machine.city,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  widget.machine.status,
                  style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 13),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  widget.machine.connectionStatus,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    color: widget.machine.connectionStatus == 'Online' ? Colors.green : Colors.grey[300],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String statusText;

  const _StatusBadge({required this.statusText});

  @override
  Widget build(BuildContext context) {
    Color color = _getStatusColor(statusText);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'online') return Colors.green;
    if (status.toLowerCase().contains('offline')) return Colors.orange;
    return Colors.red;
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
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Data model
// Updated to match the requested image structure + legacy fields for Grid View
// Data model in mock_data.dart
