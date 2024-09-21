import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  
  bool enableLogger = false;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    Future.delayed(Duration.zero, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);
    final logger = Provider.of<Logger>(context);

    if (enableLogger) {
      logger.d('Building MusicPlayerPage');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
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
            if (enableLogger) {
              logger.i("Navigating to AlbumsPage");
            }
            // Navigator.pushReplacementNamed(context, '/albums_page');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              if (enableLogger) {
                logger.i("Navigating to TrackPlaylistPage");
              }
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
      body: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Visibility(
              visible: _opacityAnimation.value > 0,
              child: _buildMusicPlayerContent(
                  context, trackPlayerProvider, logger),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicPlayerContent(BuildContext context,
      TrackPlayerProvider trackPlayerProvider, Logger logger) {
    final isPlaylistEmpty = trackPlayerProvider.playlist.isEmpty;
    final albumArt = trackPlayerProvider.currentAlbumArt;

    return Container(
      decoration: BoxDecoration(
        image: albumArt.isNotEmpty
            ? DecorationImage(
                image: AssetImage(albumArt),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: isPlaylistEmpty
            ? const Center(
                child: Text(
                  'No tracks available',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : Column(
                children: [
                  const Gap(70),
                  if (albumArt.isNotEmpty)
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              gaplessPlayback: true,
                              albumArt,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (trackPlayerProvider.currentAlbumTitle ==
                            '1982-04-10 - Capitol Theatre')
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12.0, right: 24.0),
                            child: Icon(Icons.album,
                                color: Colors.green, size: 30),
                          )
                        else
                          const Icon(Icons.album,
                              color: Colors.transparent, size: 30),
                      ],
                    )
                  else
                    const SizedBox(
                      height: 250,
                      child: Center(
                        child: Text(
                          'No Album Art Available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  const Gap(30),
                  Text(
                    trackPlayerProvider.currentTrack?.trackName ??
                        'No Track Playing',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(4),
                  _PlaybackControls(
                      trackPlayerProvider: trackPlayerProvider,
                      logger: logger,
                      enableLogger: enableLogger),
                  const SizedBox(height: 10),
                  _ProgressBar(trackPlayerProvider: trackPlayerProvider),
                ],
              ),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final TrackPlayerProvider trackPlayerProvider;
  final Logger logger;
  final bool enableLogger;

  const _PlaybackControls({
    required this.trackPlayerProvider,
    required this.logger,
    required this.enableLogger,
  });

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
              icon: const Icon(Icons.skip_previous,
                  size: 40, color: Colors.white),
              onPressed: () {
                trackPlayerProvider.previous();
                if (enableLogger) {
                  logger.i('Previous button pressed');
                }
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
                  if (enableLogger) {
                    logger.i('Pause button pressed');
                  }
                } else {
                  trackPlayerProvider.play();
                  if (enableLogger) {
                    logger.i('Play button pressed');
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
              onPressed: () {
                trackPlayerProvider.next();
                if (enableLogger) {
                  logger.i('Next button pressed');
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final TrackPlayerProvider trackPlayerProvider;

  const _ProgressBar({required this.trackPlayerProvider});

  @override
  Widget build(BuildContext context) {
    return ProgressBar(provider: trackPlayerProvider);
  }
}
