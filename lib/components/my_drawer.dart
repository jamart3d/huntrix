import 'package:flutter/material.dart';
import 'package:huntrix/pages/settings_page.dart'; // Import your SettingsPage

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final routeSettings = ModalRoute.of(context)?.settings;
    final callingPageName = routeSettings?.name;
    final size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset(
                'assets/images/t_steal.webp', // Replace with your image asset
                color: Colors.white,
              ),
            ),
          ),
          // IMPORTANT: Wrap the ListTiles in a FocusScope
          FocusScope(
            autofocus: true, // Autofocus this scope
            child: Column( // Or ListView if you have more items
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  text: "Settings",
                  onTap: () => _navigateTo(context, const SettingsPage()),
                ),
                if (callingPageName != '/albums_page' && size.width < 600)
                  _buildDrawerItem(
                    context,
                    icon: Icons.album,
                    text: "Albums List",
                    onTap: () => _navigateToExistingPage(context, '/albums_page'),
                  ),
                if (callingPageName != '/albums_list_wheel_page' && size.width < 600)
                  _buildDrawerItem(
                    context,
                    icon: Icons.album_outlined,
                    text: "Albums Wheel",
                    onTap: () =>
                        _navigateToExistingPage(context, '/albums_list_wheel_page'),
                  ),
                if (size.width > 600)
                  _buildDrawerItem(
                    context,
                    icon: Icons.tv_rounded,
                    text: "tv view",
                    onTap: () =>
                        _navigateToExistingPage(context, '/albums_grid_page'),
                  ),

              ],
            ),
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
      focusColor: Colors.yellow.withOpacity(0.5),
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