import 'package:flutter/material.dart';
import 'package:huntrix/pages/albums_list_wheel_page.dart';
// import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/pages/settings_page.dart';
import 'package:huntrix/pages/albums_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset('assets/images/t_steal.webp',
                  color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            textColor: Colors.white,
            iconColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            textColor: Colors.white,
            iconColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.album),
            title: const Text("albums list"),
            textColor: Colors.white,
            iconColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlbumsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.album_outlined),
            title: const Text("albums wheel"),
            textColor: Colors.white,
            iconColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AlbumListWheelPage()),
              );
            },
          ),
         
        ],
      ),
    );
  }
}
