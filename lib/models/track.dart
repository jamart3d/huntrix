class Track {
  final String albumName;
  final String? artistName;
  final String trackArtistName;
  final int trackDuration;
  final String trackName;
  late  String trackNumber;
  final String url;
  String? albumArt; 
  // ignore: prefer_typing_uninitialized_variables
  final albumReleaseNumber;
  final String? albumReleaseDate;


  Track({
    required this.albumName,
    this.artistName,
    required this.trackArtistName,
    required this.trackDuration,
    required this.trackName,
    required this.trackNumber,
    required this.url,
    this.albumArt, 
    this.albumReleaseNumber,
    this.albumReleaseDate, 
  });

 @override
     String toString() {
       return '$trackName - $trackArtistName';
     }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      albumName: json['albumName'],
      artistName: json['artistName'],
      trackArtistName: json['trackArtistName'],
      trackDuration: json['trackDuration'],
      trackName: json['trackName'],
      trackNumber: json['trackNumber'],
      url: json['url'],
      albumArt: json['albumArt'], 
      albumReleaseNumber: json['albumReleaseNumber'],
      albumReleaseDate: json['albumReleaseDate'], 
    );
  }

  
}
