import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:huntrix/pages/track_playlist_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/components/player/progress_bar.dart';

class TvMusicPlayerPage extends StatefulWidget {
  const TvMusicPlayerPage({super.key});

  @override
  _TvMusicPlayerPageState createState() => _TvMusicPlayerPageState();
}

class _TvMusicPlayerPageState extends State<TvMusicPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  int _focusedIndex = 1; // Start with play/pause button focused

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

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _focusedIndex = (_focusedIndex - 1).clamp(0, 2);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _focusedIndex = (_focusedIndex + 1).clamp(0, 2);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        _performAction();
      }
    }
  }

  void _performAction() {
    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);
    switch (_focusedIndex) {
      case 0:
        trackPlayerProvider.previous();
        break;
      case 1:
        trackPlayerProvider.audioPlayer.playing
            ? trackPlayerProvider.pause()
            : trackPlayerProvider.play();
        break;
      case 2:
        trackPlayerProvider.next();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Visibility(
                visible: _opacityAnimation.value > 0,
                child: _buildTvMusicPlayerContent(context, trackPlayerProvider),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTvMusicPlayerContent(
      BuildContext context, TrackPlayerProvider trackPlayerProvider) {
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
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (albumArt.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        albumArt,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const SizedBox(
                      height: 300,
                      width: 300,
                      child: Center(
                        child: Text(
                          'No Album Art Available',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  const Gap(30),
                  Text(
                    trackPlayerProvider.currentTrack?.trackName ??
                        'No Track Playing',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
                  _TvPlaybackControls(
                    trackPlayerProvider: trackPlayerProvider,
                    focusedIndex: _focusedIndex,
                  ),
                  const SizedBox(height: 20),
                  _ProgressBar(trackPlayerProvider: trackPlayerProvider),
                ],
              ),
      ),
    );
  }
}

class _TvPlaybackControls extends StatelessWidget {
  final TrackPlayerProvider trackPlayerProvider;
  final int focusedIndex;

  const _TvPlaybackControls({
    required this.trackPlayerProvider,
    required this.focusedIndex,
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
            _buildControlButton(
              icon: Icons.skip_previous,
              onPressed: trackPlayerProvider.previous,
              isFocused: focusedIndex == 0,
            ),
            const SizedBox(width: 20),
            _buildControlButton(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: isPlaying
                  ? trackPlayerProvider.pause
                  : trackPlayerProvider.play,
              isFocused: focusedIndex == 1,
              isPlayPause: true,
            ),
            const SizedBox(width: 20),
            _buildControlButton(
              icon: Icons.skip_next,
              onPressed: trackPlayerProvider.next,
              isFocused: focusedIndex == 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isFocused,
    bool isPlayPause = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isFocused ? 16 : 8),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: isPlayPause ? 80 : 60,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
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