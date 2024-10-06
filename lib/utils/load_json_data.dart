import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/album_utils.dart';

Future<void> loadData(BuildContext context, Function(List<Map<String, dynamic>>?) callback) async {
  try {
    final tracks = await loadJsonData(context);
    final albumTracks = groupTracksByAlbum(tracks);
    final albumDataList = _createAlbumDataList(albumTracks);
    final insertedAlbumData = _insertAlbumsWithout19Prefix(albumDataList);
    callback(insertedAlbumData);
  } catch (e) {
    if (context.mounted)_showErrorSnackBar(context, 'Error loading data: $e');
  }
}

Future<List<Track>> loadJsonData(BuildContext context) async {
  String jsonString;
  try {
    jsonString = await DefaultAssetBundle.of(context).loadString('assets/data.json');
    jsonString = jsonString.replaceAll('\u00A0', ' '); // Important!

    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => Track.fromJson(item)).toList();
  } catch (e) {
    if (context.mounted)_showErrorSnackBar(context, 'Error loading JSON: $e');
    rethrow; // Re-throw the exception to propagate the error
  }
}

// Helper function to show an error snackbar
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red,
    ),
  );
}


List<Map<String, dynamic>> _createAlbumDataList(
      Map<String, List<Track>> albumTracks) {
    final Map<String, int> albumIndex = {};
    int index = 1;
    for (final albumName in albumTracks.keys) {
      albumIndex[albumName] = index++;
    }
    assignAlbumArtToTracks(albumTracks, albumIndex);

    return albumTracks.entries
        .map((entry) => {
              'album': entry.key,
              'songs': entry.value,
              'songCount': entry.value.length,
              'artistName': entry.value.first.artistName ??
                  entry.value.first.trackArtistName,
              'albumArt': entry.value.first.albumArt,
              'releaseNumber': albumIndex[entry.key],
              'releaseDate': entry.key.toString().startsWith('19')
                  ? entry.key
                  : '19${entry.key}',
            })
        .toList();
  }


//this fixes albums that don't start with 19
  List<Map<String, dynamic>> _insertAlbumsWithout19Prefix(List<Map<String, dynamic>> albumDataList) {
    for (var i = 0; i < albumDataList.length; i++) {
      final album = albumDataList[i];
      if (!album['album'].toString().startsWith('19')) {
        albumDataList[i]['album'] = '19${album['album']}';
      }
    }
    return albumDataList;
  }