import 'package:flutter/material.dart';
import 'package:money_tracker/screens/budget_management_screen.dart';
import 'package:money_tracker/screens/category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Handle drawer open
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontVariations: <FontVariation>[FontVariation('wght', 700)],
            shadows: <Shadow>[
              Shadow(
                offset: Offset(-2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAD73), Color(0xFFAABD36)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal[600]),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                // Handle profile settings
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.teal[600]),
              title: Text(
                'Manage Categories',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money, color: Colors.teal[600]),
              title: Text(
                'Manage Budgets',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BudgetManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.teal[600]),
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                // Handle notifications settings
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.teal[600]),
              title: Text(
                'Privacy',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                // Handle privacy settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.teal[600]),
              title: Text(
                'Help',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                // Handle help or support
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.teal[600]),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              onTap: () {
                // Handle user logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
