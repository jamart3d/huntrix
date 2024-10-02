import 'dart:math';
import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';

Future<void> preloadImage(String imagePath) async {
  final imageProvider = AssetImage(imagePath);
  await imageProvider.obtainKey(ImageConfiguration.empty);
}

void handleAlbumTap(Map<String, dynamic> albumData,
    Function(List<Map<String, dynamic>>?) callback, BuildContext context) {
  final trackPlayerProvider =
      Provider.of<TrackPlayerProvider>(context, listen: false);
  final albumTracks = albumData['songs'] as List<Track>;
  final albumArt = albumData['albumArt'] as String?;
  // final albumName = albumData['album'] as String?;
  // final albumRel = albumData['albumReleaseNumber'];


  trackPlayerProvider.pause();
  trackPlayerProvider.clearPlaylist();
  trackPlayerProvider.addAllToPlaylist(albumTracks);

  if (albumArt != null && albumArt.isNotEmpty) {
    // Set the album art for the current track
    trackPlayerProvider.setCurrentAlbumArt(albumArt);
    preloadImage(albumArt).then((_) {});
  }
    callback([albumData]); 
}

Future<void> handleAlbumTap2(
    Map<String, dynamic> albumData, BuildContext context) async {
  final trackPlayerProvider =
      Provider.of<TrackPlayerProvider>(context, listen: false);
  final albumTracks = albumData['songs'] as List<Track>;

  trackPlayerProvider.pause();
  trackPlayerProvider.clearPlaylist();
  trackPlayerProvider.addAllToPlaylist(albumTracks);
}

Future<void> selectRandomAlbum(
    BuildContext context,
    List<Map<String, dynamic>> albumDataList,
    Function(List<Map<String, dynamic>>?) callback) async {
  if (albumDataList.isNotEmpty) {
    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);

    final randomIndex = Random().nextInt(albumDataList.length);
    final randomAlbum = albumDataList[randomIndex];

    final albumTitle = randomAlbum['album'] as String?;

    if (albumTitle == null || albumTitle.isEmpty) {
      return;
    }

    final randomAlbumTracks = randomAlbum['songs'] as List<Track>;

    trackPlayerProvider.clearPlaylist();
    trackPlayerProvider.addAllToPlaylist(randomAlbumTracks);
    trackPlayerProvider.play();

    Navigator.pushReplacementNamed(context, '/music_player_page');

    callback(null);
  } else {}
}

Future<void> selectAndPlayRandomAlbum(
    BuildContext context, List<Map<String, dynamic>> albumDataList) async {
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
  } else {}
}
