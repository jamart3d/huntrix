import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:huntrix/pages/albums_page.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/pages/track_detail_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:huntrix/utils/duration_formatter.dart';

class TrackPlaylistPage extends StatefulWidget {
  const TrackPlaylistPage({Key? key}) : super(key: key);

  @override
  _TrackPlaylistPageState createState() => _TrackPlaylistPageState();
}

class _TrackPlaylistPageState extends State<TrackPlaylistPage> {
  late Logger logger;

  @override
  void initState() {
    super.initState();
    logger = context.read<Logger>();
  }

  @override
  Widget build(BuildContext context) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:
            // Text('${trackPlayerProvider.playlist.length} Tracks in ${trackPlayerProvider.currentAlbumTitle}'),
            Text(trackPlayerProvider.currentAlbumTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Playlist'),
                    content: const Text('Clear playlist?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          trackPlayerProvider.clearPlaylist();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlbumsPage(),
                            ),
                          );
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _buildBody(trackPlayerProvider),
    );
  }

  Widget _buildBody(TrackPlayerProvider trackPlayerProvider) {
    final currentTrack = trackPlayerProvider
        .currentlyPlayingSong; // Get the currently playing track

    return Stack(
      children: [
        // Blurred Background
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  currentTrack?.albumArt ?? 'assets/images/t_steal.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        // Track List
        _buildTrackList(trackPlayerProvider),
      ],
    );
  }

  Widget _buildTrackList(TrackPlayerProvider trackPlayerProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: trackPlayerProvider.playlist.length,
            itemBuilder: (context, index) {
              final track = trackPlayerProvider.playlist[index];
              final isCurrentlyPlayingTrack =
                  index == trackPlayerProvider.currentIndex;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackDetailPage(track: track),
                    ),
                  );
                },
                onLongPress: () {
                  if (!isCurrentlyPlayingTrack) {
                    trackPlayerProvider.seekTo(Duration.zero, index: index);
                    trackPlayerProvider.play();
                  }
                },
                child: Card(
                  // Make the card completely transparent
                  color: Colors.transparent,
                  elevation: 0,
                  child: ListTile(
                    title: Text(
                      track.trackName,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isCurrentlyPlayingTrack
                              ? Colors.yellow
                              : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      formatDurationSeconds(track.trackDuration),
                      style: TextStyle(
                        color: isCurrentlyPlayingTrack
                            ? Colors.yellow
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}