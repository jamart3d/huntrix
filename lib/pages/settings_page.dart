import 'package:flutter/material.dart';
import 'package:huntrix/pages/about_page.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/providers/album_settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: Consumer<AlbumSettingsProvider>(
        builder: (context, albumSettings, child) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: const Text("display release order number"),
                textColor: Colors.white,
                trailing: Switch(
                  value: albumSettings.displayAlbumReleaseNumber,
                  onChanged: (newValue) {
                    albumSettings.setDisplayAlbumReleaseNumber(newValue);
                  },
                ),
              ),
              ListTile(
                title: const Text("About"),
                textColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}