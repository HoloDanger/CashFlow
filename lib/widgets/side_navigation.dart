import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/screens/budget_overview_screen.dart';
import 'package:money_tracker/screens/settings_screen.dart';

class SideNavigation extends StatefulWidget {
  final int selectedIndex;
  final Widget child;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  @override
  SideNavigationState createState() => SideNavigationState();
}

class SideNavigationState extends State<SideNavigation> {
  final Logger logger = Logger();
  bool _isDrawerOpen = false;

  static const double drawerWidth = 80.0;
  static const double iconSize = 28.0;
  static const double navItemPadding = 16.0;

  /// Toggles the drawer open/close state.
  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  /// Handles navigation item taps.
  void _onNavItemTapped(int index) {
    setState(() {
      _isDrawerOpen = false;
    });
    if (index == widget.selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BudgetOverviewScreen()),
        );
        break;
      case 2:
        // Navigate to Reports Screen
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  /// Builds a navigation item with icon.
  Widget _buildNavItem(IconData icon, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: navItemPadding),
      child: IconButton(
        icon: Icon(
          icon,
          color: widget.selectedIndex == index ? Colors.white : Colors.white70,
          size: iconSize,
        ),
        onPressed: () => _onNavItemTapped(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the top position dynamically based on AppBar height and status bar
    final double topPosition =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: _isDrawerOpen ? 0 : -drawerWidth,
          top: topPosition,
          bottom: 0,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: drawerWidth,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4CAD73),
                    Color(0xFFAABD36),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.money, 1),
                  _buildNavItem(Icons.show_chart, 2),
                  _buildNavItem(Icons.settings, 3),
                ],
              ),
            ),
          ),
        ),

        // Overlay to close drawer
        if (_isDrawerOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDrawerOpen = false;
                });
              },
              child: Container(),
            ),
          ),
      ],
    );
  }
}
