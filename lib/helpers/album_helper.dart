import 'dart:math';

import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:logger/logger.dart';

void handleAlbumTap(
    Map<String, dynamic> albumData,
    Function(List<Map<String, dynamic>>?) callback,
    BuildContext context,
    Logger logger) {
  final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context,
      listen: false); // Access TrackPlayerProvider with the correct context
  final albumTracks = albumData['songs'] as List<Track>;
  trackPlayerProvider.pause();

  trackPlayerProvider.clearPlaylist();
  trackPlayerProvider.addAllToPlaylist(albumTracks);
  trackPlayerProvider.play();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MusicPlayerPage()),
  );
  callback(null); // Update the background with the current album art
}

Future<void> selectRandomAlbum(
    BuildContext context,
    List<Map<String, dynamic>> albumDataList,
    Logger logger,
    Function(List<Map<String, dynamic>>?) callback) async {
  if (albumDataList.isNotEmpty) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context,
        listen: false); // Access TrackPlayerProvider with the correct context

    final randomIndex = Random().nextInt(albumDataList.length);
    final randomAlbum = albumDataList[randomIndex];

    final albumTitle = randomAlbum['album'] as String?;

    if (albumTitle == null || albumTitle.isEmpty) {
      logger.e('Random album title is null or empty');
      return;
    }

    final randomAlbumTracks = randomAlbum['songs'] as List<Track>;

    trackPlayerProvider.clearPlaylist();
    trackPlayerProvider.addAllToPlaylist(randomAlbumTracks);

    trackPlayerProvider.play();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const MusicPlayerPage()),
    // );

    Navigator.pushReplacementNamed(context, '/music_player_page');
    logger.d('Playing random album: $albumTitle');

    callback(null); // Update the background with the current album art
  } else {
    logger.w('No albums available in albumDataList.');
  }
}
