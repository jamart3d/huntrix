import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/models/track.dart';
// import 'package:huntrix/pages/music_player_page.dart';
// import 'package:huntrix/pages/track_detail_page.dart';
// import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:logger/logger.dart';

class SongsListPage extends StatefulWidget {
  const SongsListPage({super.key});

  @override
  State<SongsListPage> createState() => _SongsListPageState();
}

class _SongsListPageState extends State<SongsListPage> {
  late Logger logger;
  List<Track>? _allTracks; // To store all tracks
  String? _currentTrackName; // To store the name of the currently playing track
  String? _currentAlbumArt; // To store the current album art

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp'; // Default album art
  }

  @override
  void didChangeDependencies() {
    // Access Logger here
    super.didChangeDependencies();
    logger = context.read<Logger>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (_allTracks == null) {
        final tracks = await loadJsonData(context);
        logger.d("LOADED HOMEPAGE JSON: ${tracks.length}");
        setState(() {
          _allTracks = tracks;
        });
      }
    } catch (e) {
      logger.e("Error loading data: $e");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Songs"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Always use semi-transparent black
          image: DecorationImage(
            image: AssetImage(_currentAlbumArt ?? 'assets/images/t_steal.webp'),
            fit: BoxFit.cover,
            colorFilter: _currentAlbumArt != null // Apply color filter only if album art exists
                ? null // No filter, album art is visible
                : ColorFilter.mode(
                    Colors.black.withOpacity(0.3), // Blend with black
                    BlendMode.darken, // Darken mode for blur effect
                  ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
          child: _allTracks == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _allTracks?.length ?? 0,
                  itemBuilder: (context, index) {
                    final track = _allTracks![index];
                    return ListTile(
                      title: Text(
                        track.trackName,
                        style: TextStyle(
                          color: _currentTrackName == track.trackName
                              ? Colors.yellow
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        track.albumName,
                        style: TextStyle(
                          color: _currentTrackName == track.trackName
                              ? Colors.yellow
                              : Colors.white,
                        ),
                      ), // Added album name to subtitle
                      onTap: () {
                        // final trackPlayerProvider =
                        //     Provider.of<TrackPlayerProvider>(context, listen: false);
                        // final remainingTracks = _allTracks!
                        //     .where((t) => t.albumName == track.albumName)
                        //     .toList();
                        // final album = track.albumName;
                        // final albumTracks = {album: remainingTracks};
                            
                        // trackPlayerProvider.clearPlaylist();
                        // logger.d("Selected track: ${track.trackName}");
                        // logger.d("Added to playlist: ${remainingTracks.length} tracks");
                        // trackPlayerProvider.clearPlayListAddAllFromAlbumStartingFromSelectedAndPlay(track,  albumTracks[albumName]!)


                        
                        // trackPlayerProvider.play(); // Play the selected track
                  //   Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => TrackDetailPage(track: track),
                  //   ),
                  // );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const MusicPlayerPage()),
                        // );

                        setState(() {
                          _currentTrackName = track.trackName;
                          _currentAlbumArt = track.albumArt; // Update album art when a song is played
                        });
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}