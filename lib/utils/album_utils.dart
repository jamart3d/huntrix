import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';

Map<String, List<Track>> groupTracksByAlbum(List<Track> tracks) {
  return tracks.fold({}, (Map<String, List<Track>> albumMap, track) {
    final trackList = (albumMap[track.albumName] ??= []);
    //this re-numbers tracks, 1,2,3...
    track.trackNumber = (trackList.length + 1).toString(); // Convert to String
    trackList.add(track);
    return albumMap;
  });
}

String generateAlbumArt(int albumIndex,
    {String pathPrefix = 'assets/images/trix_album_art/trix',
    String extension = '.webp',
    BuildContext? context}) { // Add optional context parameter

  final albumArtPath = '$pathPrefix${albumIndex.toString().padLeft(2, '0')}$extension';
  if (context != null) {
    precacheImage(AssetImage(albumArtPath), context); // Use the context
  }
  return albumArtPath;
}
void assignAlbumArtToTracks(
    Map<String, List<Track>> groupedTracks, Map<String, int> albumIndexMap) {
  for (final entry in groupedTracks.entries) {
    final albumName = entry.key;
    final tracks = entry.value;
    final albumArtPath = generateAlbumArt(albumIndexMap[albumName] ?? 0);

    for (final track in tracks) {
      track.albumArt = albumArtPath;
    }
  }
}


  String formatAlbumName(String albumName) {
    final parts = albumName.split('-');
    if (parts.length > 3) {
      return parts
          .sublist(3)
          .join('-')
          .replaceAll(RegExp(r'^[^a-zA-Z0-9]'), '');
    }
    return albumName;
  }

  // Helper method to extract the date from the album name
  String extractDateFromAlbumName(String albumName) {
    final parts = albumName.split('-');
    if (parts.length >= 3) {
      return parts.sublist(0, 3).join('-');
    }
    return '';
  }

   Future<void> preloadAlbumImages(
    List<Map<String, dynamic>> albumData, BuildContext context) async {
  for (var album in albumData) {
    final albumArt = album['albumArt'] as String?;
    if (albumArt != null) {
      await precacheImage(AssetImage(albumArt), context);
    }
  }
  
}