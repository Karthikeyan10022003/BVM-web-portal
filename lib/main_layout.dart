import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'machines_page.dart';
import 'products_page.dart';
import 'transactions_page.dart';
import 'login_page.dart';
class MainLayout extends StatefulWidget {
  final Widget child;
  final String activeTab;

  const MainLayout({
    super.key,
    required this.child,
    required this.activeTab,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          appBar: isMobile
              ? AppBar(
                  backgroundColor: const Color(0xFF1E1E1E),
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    'BVM Portal',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  backgroundColor: const Color(0xFF1E1E1E),
                  child: _SidebarContent(activeTab: widget.activeTab),
                )
              : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar for Desktop
              if (!isMobile)
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(right: BorderSide(color: Color(0xFF333333))),
                  ),
                  child: _SidebarContent(activeTab: widget.activeTab),
                ),

              // Main Content
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final String activeTab;

  const _SidebarContent({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Area
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0CFA9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    "/images/vending-machine.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'BVM Portal',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Navigation Items
        _SidebarItem(
          icon: Icons.dashboard_rounded,
          title: 'Dashboard',
          isActive: activeTab == 'Dashboard',
          onTap: () {
            if (activeTab != 'Dashboard') {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const DashboardPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            } else {
               // Close drawer if open and already on page
               if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                 Navigator.pop(context);
               }
            }
          },
        ),
        _SidebarItem(
          icon: Icons.coffee_maker_rounded,
          title: 'Machines',
          isActive: activeTab == 'Machines',
          onTap: () {
            if (activeTab != 'Machines') {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const MachinesPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            } else {
               if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                 Navigator.pop(context);
               }
            }
          },
        ),
        _SidebarItem(
          icon: Icons.coffee_maker_rounded,
          title: 'Products',
          isActive: activeTab == 'Products',
          onTap: () {
            if(activeTab != 'Products') {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const ProductsPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            } else {
               if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                 Navigator.pop(context);
               }
            }

          },
        ),
        _SidebarItem(
          icon: Icons.receipt_long_rounded,
          title: 'Transactions',
          isActive: activeTab == 'Transactions',
          onTap: () {
            if (activeTab != 'Transactions') {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const TransactionsPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            } else {
               if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                 Navigator.pop(context);
               }
            }
          },
        ),
        // _SidebarItem(
        //   icon: Icons.settings_rounded,
        //   title: 'Settings',
        //   isActive: activeTab == 'Settings',
        //   onTap: () {},
        // ),

        const Spacer(),

        // // User Profile / Footer
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   margin: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFF252525),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Row(
        //     children: [
        //       const CircleAvatar(
        //         radius: 16,
        //         backgroundColor: Color(0xFFE0CFA9),
        //         child: Text('AD',
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontSize: 12,
        //                 fontWeight: FontWeight.bold)),
        //       ),
        //       const SizedBox(width: 12),
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text('Admin User',
        //                 style: GoogleFonts.inter(
        //                     color: Colors.white,
        //                     fontSize: 13,
        //                     fontWeight: FontWeight.w600)),
        //             Text('admin@bvm.com',
        //                 style: GoogleFonts.inter(
        //                     color: Colors.grey, fontSize: 11)),
        //           ],
        //         ),
        //       ),
        //       InkWell(
        //         onTap: () {
        //           Navigator.pushAndRemoveUntil(
        //             context,
        //             MaterialPageRoute(builder: (context) => const LoginPage()),
        //             (route) => false,
        //           );
        //         },
        //         child: const Icon(Icons.logout, color: Colors.grey, size: 18),
        //       ),

        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFE0CFA9)
                : (_isHovered ? const Color(0xFF252525) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isActive
                    ? Colors.black
                    : (_isHovered ? Colors.white : Colors.grey[400]),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: widget.isActive
                      ? Colors.black
                      : (_isHovered ? Colors.white : Colors.grey[400]),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
