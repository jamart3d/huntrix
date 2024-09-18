class Track {
  final String albumName;
  final String altUrl;
  final String? artistName;
  final String trackArtistName;
  final int trackDuration;
  final String trackName;
  late  String trackNumber;
  final String url;
  String? albumArt; 
  final int albumReleaseNumber;
  final String? albumReleaseDate;


  Track({
    required this.albumName,
    required this.altUrl,
    this.artistName,
    required this.trackArtistName,
    required this.trackDuration,
    required this.trackName,
    required this.trackNumber,
    required this.url,
    this.albumArt, 
    required this.albumReleaseNumber,
    this.albumReleaseDate, 
  });

 @override
     String toString() {
       return '$trackName - $trackArtistName';
     }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      albumName: json['albumName'],
      altUrl: json['alt_url'],
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
