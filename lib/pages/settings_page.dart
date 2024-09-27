import 'package:flutter/material.dart';
import 'package:huntrix/pages/about_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _randomTrixAtStartupEnabled = false;
  bool _displayAlbumReleaseNumber = false;

  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _randomTrixAtStartupEnabled = prefs.getBool('randomTrixAtStartupEnabled') ?? false;
      _displayAlbumReleaseNumber = prefs.getBool('displayAlbumReleaseNumber') ?? false;
      _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0]; 
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('randomTrixAtStartupEnabled', _randomTrixAtStartupEnabled);
    await prefs.setBool('displayAlbumReleaseNumber', _displayAlbumReleaseNumber);
    await prefs.setInt('themeMode', _themeMode.index); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('this does nothing'),
            textColor: Colors.white,
            iconColor: Colors.white,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  _saveSettings();
                });
              },
            ),
          ),
          //todo: add more settings
          // ListTile(
          //   title: const Text("random trix at startup"),
          //   textColor: Colors.white,
          //   trailing: Switch(
          //     value: _randomTrixAtStartupEnabled,
          //     onChanged: (value) {
          //       setState(() {
          //         _randomTrixAtStartupEnabled = value;
          //         _saveSettings();
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: const Text("display release order number"),
          //   textColor: Colors.white,
          //   trailing: Switch(
          //     value: _displayAlbumReleaseNumber,
          //     onChanged: (value) {
          //       setState(() {
          //         _displayAlbumReleaseNumber = value;
          //         _saveSettings();
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: Text(_getThemeModeTitle(_themeMode)), 
          //   textColor: Colors.white,
          //   onTap: () {
          //     showModalBottomSheet(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: ThemeMode.values.map((ThemeMode mode) {
          //             return ListTile(
          //               title: Text(_getThemeModeTitle(mode)),
          //               onTap: () {
          //                 setState(() {
          //                   _themeMode = mode;
          //                   _saveSettings();
          //                 });
          //                 Navigator.pop(context); 
          //               },
          //             );
          //           }).toList(),
          //         );
          //       },
          //     );
          //   },
          // ),
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
      ),
    );
  }

}

