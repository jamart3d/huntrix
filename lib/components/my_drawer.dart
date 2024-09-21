import 'package:flutter/material.dart';
import 'package:huntrix/pages/settings_page.dart';
import 'package:logger/logger.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final routeSettings = ModalRoute.of(context)?.settings;
    final callingPageName = routeSettings?.name;
    Logger().i('Calling Page: $callingPageName');

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset(
                'assets/images/t_steal.webp',
                color: Colors.white,
              ),
            ),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.album,
            text: "go to current album",
            onTap: (){},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            text: "Settings",
            onTap: () => _navigateTo(context, const SettingsPage()),
          ),
          if (callingPageName != '/albums_page')
            _buildDrawerItem(
              context,
              icon: Icons.album,
              text: "Albums List",
              onTap: () => _navigateToExistingPage(context, '/albums_page'),
            ),
          if (callingPageName != '/albums_list_wheel_page')
            _buildDrawerItem(
              context,
              icon: Icons.album_outlined,
              text: "Albums Wheel",
              // onTap: () => Navigator.pushReplacementNamed(context, '/albums_list_wheel_page'),
              onTap: () =>
                  _navigateToExistingPage(context, '/albums_list_wheel_page'),
            ),
        ],
      ),
    );
  }

  // Utility method to build drawer items
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        onTap(); // Execute the provided onTap action
      },
    );
  }

  // Method to handle navigation with MaterialPageRoute
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateToExistingPage(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => route.settings.name == routeName
          ? true
          : false, // Remove routes until you reach the target route
    );
  }
}
