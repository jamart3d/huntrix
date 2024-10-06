import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:huntrix/components/player/progress_bar.dart';

class TvNowPlayingPage extends StatefulWidget {
  final List<Track> tracks;
  final String albumArt;
  final String albumName;

  const TvNowPlayingPage({
    Key? key,
    required this.tracks,
    required this.albumArt,
    required this.albumName,
  }) : super(key: key);

  @override
  _TvNowPlayingPageState createState() => _TvNowPlayingPageState();
}

class _TvNowPlayingPageState extends State<TvNowPlayingPage> {
  late List<Track> _tracks;
  late String _albumArt;
  late String _albumName;
  int _focusedIndex = 0;
  bool _isControlFocused = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tracks = widget.tracks;
    _albumArt = widget.albumArt;
    _albumName = widget.albumName;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context, listen: false);
    final currentTrack = trackPlayerProvider.currentTrack;

    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_albumArt),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildNowPlayingHeader(currentTrack, _albumArt, _albumName),
                    Expanded(
                      child: _buildTrackList(context, _tracks),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingHeader(Track? currentTrack, String albumArt, String albumName) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              albumArt,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTrack?.trackName ?? 'No Track Playing',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  albumName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildPlaybackControls(Provider.of<TrackPlayerProvider>(context)),
        ],
      ),
    );
  }

  Widget _buildTrackList(BuildContext context, List<Track> tracks) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);

    return ListView.builder(
      controller: _scrollController,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrentlyPlaying = trackPlayerProvider.currentIndex == index;
        final isFocused = _focusedIndex == index && !_isControlFocused;

        return Container(
          decoration: BoxDecoration(
            color: isFocused ? Colors.white.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Text(
              (index + 1).toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            title: Text(
              track.trackName,
              style: TextStyle(
                color: isCurrentlyPlaying ? Colors.yellow : Colors.white,
                fontSize: 24,
                fontWeight: isFocused || isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              formatDurationSeconds(track.trackDuration),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaybackControls(TrackPlayerProvider trackPlayerProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StreamBuilder<bool>(
          stream: trackPlayerProvider.audioPlayer.playingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return _buildControlButton(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: isPlaying ? trackPlayerProvider.pause : trackPlayerProvider.play,
              isFocused: _isControlFocused,
              isPlayPause: true,
            );
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 200,
          child: ProgressBar(provider: trackPlayerProvider),
        ),
      ],
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
          size: isPlayPause ? 60 : 40,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (!_isControlFocused) {
            _focusedIndex = (_focusedIndex + 1).clamp(0, _tracks.length - 1);
            _scrollToFocusedItem();
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (!_isControlFocused) {
            _focusedIndex = (_focusedIndex - 1).clamp(0, _tracks.length - 1);
            _scrollToFocusedItem();
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _isControlFocused = true;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _isControlFocused = false;
        } else if (event.logicalKey == LogicalKeyboardKey.select) {
          _handleSelection();
        }
      });
    }
  }

  void _scrollToFocusedItem() {
    final itemHeight = 70.0; // Approximate height of a ListTile
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = 200.0; // Height of the header
    final viewportHeight = screenHeight - headerHeight;

    final itemPosition = _focusedIndex * itemHeight;
    final viewportStart = _scrollController.offset;
    final viewportEnd = viewportStart + viewportHeight;

    if (itemPosition < viewportStart) {
      _scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (itemPosition + itemHeight > viewportEnd) {
      _scrollController.animateTo(
        itemPosition + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSelection() {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context, listen: false);
    if (_isControlFocused) {
      trackPlayerProvider.isPlaying ? trackPlayerProvider.pause() : trackPlayerProvider.play();
    } else {
      trackPlayerProvider.currentIndex = _focusedIndex;
      trackPlayerProvider.play();
    }
  }
}