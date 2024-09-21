import 'dart:math';
import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

Future<void> preloadImage(String imagePath) async {
  final imageProvider = AssetImage(imagePath);
  await imageProvider.obtainKey(ImageConfiguration.empty);
}

bool enableLogging = false; // Boolean to control logging

void handleAlbumTap(
    Map<String, dynamic> albumData,
    Function(List<Map<String, dynamic>>?) callback,
    BuildContext context,
    Logger logger) {
  final trackPlayerProvider =
      Provider.of<TrackPlayerProvider>(context, listen: false);
  final albumTracks = albumData['songs'] as List<Track>;
  final albumArt = albumData['albumArt'] as String?;
  // final albumTitle = albumData['album'] as String?;

  trackPlayerProvider.pause();
  trackPlayerProvider.clearPlaylist();
  trackPlayerProvider.addAllToPlaylist(albumTracks);

  if (albumArt != null && albumArt.isNotEmpty) {
    trackPlayerProvider.setCurrentAlbumArt(albumArt);
    preloadImage(albumArt).then((_) {
      // _completeAlbumNavigation(context, trackPlayerProvider, logger, callback,
      //     albumTitle: albumTitle);
    });
  } else {
    if (enableLogging) {
      logger.w('Album art is null or empty');
    }
    // _completeAlbumNavigation(context, trackPlayerProvider, logger, callback,
    //     albumTitle: albumTitle);
  }
}


void handleAlbumTap2(
    Map<String, dynamic> albumData, BuildContext context, Logger logger) {
  final trackPlayerProvider =
      Provider.of<TrackPlayerProvider>(context, listen: false);
  final albumTracks = albumData['songs'] as List<Track>;
  // final albumArt = albumData['albumArt'] as String?;
  // final albumTitle = albumData['album'] as String?;

  trackPlayerProvider.pause();
  trackPlayerProvider.clearPlaylist();
  trackPlayerProvider.addAllToPlaylist(albumTracks);

  
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


Future<void> selectAndPlayRandomAlbum(
    BuildContext context, List<Map<String, dynamic>> albumDataList, Logger logger) async {
  if (albumDataList.isNotEmpty) {
    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);
    final randomIndex = Random().nextInt(albumDataList.length);
    final randomAlbum = albumDataList[randomIndex];
    final randomAlbumTracks = randomAlbum['songs'] as List<Track>;
    final albumArt = randomAlbum['albumArt'] as String?;

    trackPlayerProvider.pause();
    trackPlayerProvider.clearPlaylist();
    trackPlayerProvider.addAllToPlaylist(randomAlbumTracks);
    if (albumArt != null) {
      trackPlayerProvider.setCurrentAlbumArt(albumArt);
    }
    trackPlayerProvider.play();
  } else {
    logger.w('No albums available in albumDataList.');
  }
}

// void _completeAlbumNavigation(
//     BuildContext context,
//     TrackPlayerProvider trackPlayerProvider,
//     Logger logger,
//     Function(List<Map<String, dynamic>>?) callback,
//     {String? albumTitle}) {
//   trackPlayerProvider.play();

//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => const MusicPlayerPage()),
//   );

//   if (albumTitle != null && enableLogging) {
//     logger.d('Playing album: $albumTitle');
//   }

//   callback(null);
// }
