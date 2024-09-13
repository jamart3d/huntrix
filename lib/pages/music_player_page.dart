import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huntrix/pages/albums_page.dart';
import 'package:huntrix/pages/track_playlist_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:huntrix/components/player/progress_bar.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  @override
  void initState() {
    super.initState();
    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);
    trackPlayerProvider.loadAlbumAndArtistData();
  }

  @override
  Widget build(BuildContext context) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);
    final logger = Provider.of<Logger>(context);

    logger.d('Building MusicPlayerPage');

    // If the playlist is empty, just display the background image
    final isPlaylistEmpty = trackPlayerProvider.playlist.isEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend background to the app bar
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Now Playing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            logger.i("Navigating to AlbumsPage");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlbumsPage(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              logger.i("Navigating to TrackPlaylistPage");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackPlaylistPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              trackPlayerProvider.currentAlbumArt.isNotEmpty
                  ? trackPlayerProvider.currentAlbumArt
                  : 'assets/images/t_steal.webp', // Default image if no album art
            ),
            fit: BoxFit.cover,
            colorFilter: trackPlayerProvider.currentAlbumArt.isEmpty
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  )
                : null,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0, sigmaY: 10.0, // Adjust blur intensity as needed
          ),
          child: isPlaylistEmpty
              ? const SizedBox.shrink() // If playlist is empty, show nothing
              : Column(
                  children: [
                    // Display album art if available, otherwise a placeholder
                    if (trackPlayerProvider.currentAlbumArt.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/t_steal.webp'),
                          image: AssetImage(trackPlayerProvider.currentAlbumArt),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      // Placeholder image or text if album art is not available
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No Album Art Available',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Track Title
                          Text(
                            trackPlayerProvider.playlist[trackPlayerProvider.currentIndex].trackName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(10),
                          // Playback Controls
                          _PlaybackControls(
                              trackPlayerProvider: trackPlayerProvider,
                              logger: logger),
                          const SizedBox(height: 10),
                          // Progress Bar
                          _ProgressBar(trackPlayerProvider: trackPlayerProvider),
                          // const SizedBox(height: 10),
                          // // Album Name
                          // Text(
                          //   trackPlayerProvider.currentAlbumTitle.isNotEmpty
                          //       ? trackPlayerProvider.currentAlbumTitle
                          //       : 'Unknown Album',
                          //   style: const TextStyle(fontSize: 16, color: Colors.white),
                          //   textAlign: TextAlign.center,
                          // ),
                          const Gap(30),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Playback Controls Widget
class _PlaybackControls extends StatelessWidget {
  final TrackPlayerProvider trackPlayerProvider;
  final Logger logger;

  const _PlaybackControls(
      {required this.trackPlayerProvider, required this.logger});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: trackPlayerProvider.audioPlayer.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                trackPlayerProvider.previous();
                logger.i('Previous button pressed');
              },
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 60,
                color: Colors.white,
              ),
              onPressed: () {
                if (isPlaying) {
                  trackPlayerProvider.pause();
                  logger.i('Pause button pressed');
                } else {
                  trackPlayerProvider.play();
                  logger.i('Play button pressed');
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                trackPlayerProvider.next();
                logger.i('Next button pressed');
              },
            ),
          ],
        );
      },
    );
  }
}

// Progress Bar Widget
class _ProgressBar extends StatelessWidget {
  final TrackPlayerProvider trackPlayerProvider;

  const _ProgressBar({required this.trackPlayerProvider});

  @override
  Widget build(BuildContext context) {
    return ProgressBar(provider: trackPlayerProvider);
  }
}
