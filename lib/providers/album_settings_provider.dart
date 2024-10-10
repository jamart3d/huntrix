import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumSettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  late bool _displayAlbumReleaseNumber = false;

  bool get displayAlbumReleaseNumber => _displayAlbumReleaseNumber;

  AlbumSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _displayAlbumReleaseNumber =
        _prefs.getBool('displayAlbumReleaseNumber') ?? false;
    notifyListeners();
  }

  Future<void> setDisplayAlbumReleaseNumber(bool value) async {
    _displayAlbumReleaseNumber = value;
    await _prefs.setBool('displayAlbumReleaseNumber', value);
    notifyListeners();
  }

  void toggleDisplayAlbumReleaseNumber() {
    setDisplayAlbumReleaseNumber(!_displayAlbumReleaseNumber);
  }
}
