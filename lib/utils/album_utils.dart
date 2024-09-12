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
    String extension = '.webp'}) {
  // Add error handling or fallback mechanism if needed
  return '$pathPrefix${albumIndex.toString().padLeft(2, '0')}$extension';
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
