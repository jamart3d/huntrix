import 'package:flutter/foundation.dart';

class AlbumStateProvider with ChangeNotifier {
  int _currentIndex = 0;
  String _currentAlbumName = '';
  int _currentReleaseNumber = 0;

  int get currentIndex => _currentIndex;
  String get currentAlbumName => _currentAlbumName;
  int get currentReleaseNumber => _currentReleaseNumber;

  void updateCurrentAlbum(int index, String albumName, int releaseNumber) {
    _currentIndex = index;
    _currentAlbumName = albumName;
    _currentReleaseNumber = releaseNumber;
    notifyListeners();
  }
}