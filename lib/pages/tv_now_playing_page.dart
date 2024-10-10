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
    super.key,
    required this.tracks,
    required this.albumArt,
    required this.albumName,
  });

  @override
  State<TvNowPlayingPage> createState() => _TvNowPlayingPageState();
}

class _TvNowPlayingPageState extends State<TvNowPlayingPage> {
  late List<Track> _tracks;
  late String _albumArt;
  late String _albumName;
  int _focusedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildLeftSide(),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildRightSide(),
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

  Widget _buildLeftSide() {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              _albumArt,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _albumName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ProgressBar(provider: trackPlayerProvider),
        ],
      ),
    );
  }

  Widget _buildRightSide() {
    return _buildTrackList(context, _tracks);
  }

  Widget _buildTrackList(BuildContext context, List<Track> tracks) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);

    return ListView.builder(
      controller: _scrollController,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrentlyPlaying = trackPlayerProvider.currentIndex == index;
        final isFocused = _focusedIndex == index;

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
                fontSize: 18,
                fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            title: Text(
              track.trackName,
              style: TextStyle(
                color: isCurrentlyPlaying ? Colors.yellow : Colors.white,
                fontSize: 18,
                fontWeight: isFocused || isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDurationSeconds(track.trackDuration),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isCurrentlyPlaying)
                  _buildPlayPauseButton(trackPlayerProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayPauseButton(TrackPlayerProvider trackPlayerProvider) {
    return StreamBuilder<bool>(
      stream: trackPlayerProvider.audioPlayer.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: isPlaying ? trackPlayerProvider.pause : trackPlayerProvider.play,
        );
      },
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _focusedIndex = (_focusedIndex + 1).clamp(0, _tracks.length - 1);
          _scrollToFocusedItem();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _focusedIndex = (_focusedIndex - 1).clamp(0, _tracks.length - 1);
          _scrollToFocusedItem();
        } else if (event.logicalKey == LogicalKeyboardKey.select) {
          _handleSelection();
        }
      });
    }
  }

  void _scrollToFocusedItem() {
    const itemHeight = 56.0; // Approximate height of a ListTile
    final screenHeight = MediaQuery.of(context).size.height;
    final viewportHeight = screenHeight;

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
    trackPlayerProvider.currentIndex = _focusedIndex;
    trackPlayerProvider.play();
  }
}