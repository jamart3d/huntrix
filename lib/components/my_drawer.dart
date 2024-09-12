import 'package:flutter/material.dart';
import 'package:huntrix/pages/albums_list_wheel_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/pages/settings_page.dart';
import 'package:huntrix/pages/albums_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset('assets/images/t_steal.webp'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
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
            onTap: () {
              Navigator.pop(context);
                            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  const AlbumsPage()),
              );

            },
          ),
      
          ListTile(
            leading: const Icon(Icons.album_outlined),
            title: const Text("albums wheel"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AlbumListWheelPage()),
              );
            },
          ),
                    ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text("Music Player"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MusicPlayerPage()),
              );
            },
          ),


          // Removed the ListTile for adding random album as it is not needed anymore.
        ],
      ),
    );
  }
}

