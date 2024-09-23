// load_json_data.dart

import 'package:huntrix/utils/album_utils.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.off,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,

  ),
);


Future<List<Track>> loadJsonData(BuildContext context) async {
  final logger = Provider.of<Logger>(context); // Access global logger

  String jsonString =
      await DefaultAssetBundle.of(context).loadString('assets/data.json');
  try {
    jsonString = jsonString.replaceAll('\u00A0', ' ');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => Track.fromJson(item)).toList();
  } catch (e) {
    logger.e('Error loading JSON data: $e'); // Use global logger
    throw Exception('Error loading data. Please try again later.');
  }
}

// This is the function you'll call to load the data
Future<void> loadData(BuildContext context, Function(List<Map<String, dynamic>>?) callback) async {
  final logger = Provider.of<Logger>(context); // Access global logger

  try {
    final tracks = await loadJsonData(context); // Load the JSON data
    // logger.d("LOADED Albums JSON: ${tracks.length}"); // Log the number of tracks

    // Process the tracks and create the album data list
    final albumTracks = groupTracksByAlbum(tracks);
    final albumDataList = _createAlbumDataList(albumTracks);

    // Insert the prefix '19' for albums that don't have it
    final insertedAlbumData = _insertAlbumsWithout19Prefix(albumDataList);

    // Log the album data
    // _logAlbumData(insertedAlbumData);

    // Cache the album data
    callback(insertedAlbumData); 
  } catch (e) {
    logger.e("Error loading data: $e");
  }
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

  void _logAlbumData(List<Map<String, dynamic>> albumDataList) {
    for (var album in albumDataList) {
      logger.d(
          "Album: ${album['album']}, Artist: ${album['artistName']}, Songs: ${album['songCount']}, Release Number: ${album['releaseNumber']}, Release Date: ${album['releaseDate']}");
    }
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