import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/providers/track_player_provider.dart';

class TvAlbumDetailPage extends StatefulWidget {
  final List<Track> tracks;
  final String albumArt;
  final String albumName;

  const TvAlbumDetailPage({
    super.key,
    required this.tracks,
    required this.albumArt,
    required this.albumName,
  });

  @override
  _TvAlbumDetailPageState createState() => _TvAlbumDetailPageState();
}

class _TvAlbumDetailPageState extends State<TvAlbumDetailPage> {
  int _focusedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isCapitolTheatre = widget.albumName == '1982-04-10 - Capitol Theatre';
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            // Blurred background
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.albumArt),
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
            // Content
            SafeArea(
              top: true,
              child: Column(
                children: [
                  _buildAlbumHeader(isCapitolTheatre),
                  Expanded(
                    child: _buildTrackList(context, widget.tracks),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumHeader(bool isCapitolTheatre) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              widget.albumArt,
              width: 250,
              height: 250,
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
                  widget.albumName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.tracks.length} tracks',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
                if (isCapitolTheatre) ...[
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.album, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'Special Release',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList(BuildContext context, List<Track> tracks) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context);
    final currentAlbumTitle = trackPlayerProvider.currentAlbumTitle;

    return ListView.builder(
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
            onTap: () {
              if (isCurrentlyPlaying && currentAlbumTitle == track.albumName) {
                Navigator.pushReplacementNamed(context, '/tv_music_player_page');
              }
            },
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
                color: isCurrentlyPlaying && currentAlbumTitle == track.albumName
                    ? Colors.yellow
                    : Colors.white,
                fontSize: 24,
                fontWeight: isFocused || (isCurrentlyPlaying && currentAlbumTitle == track.albumName)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
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

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _focusedIndex = (_focusedIndex + 1).clamp(0, widget.tracks.length - 1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _focusedIndex = (_focusedIndex - 1).clamp(0, widget.tracks.length - 1);
        } else if (event.logicalKey == LogicalKeyboardKey.select) {
          _selectTrack(_focusedIndex);
        }
      });
    }
  }

  void _selectTrack(int index) {
    final trackPlayerProvider = Provider.of<TrackPlayerProvider>(context, listen: false);
    final track = widget.tracks[index];

    if (trackPlayerProvider.currentIndex == index && trackPlayerProvider.currentAlbumTitle == track.albumName) {
      Navigator.pushReplacementNamed(context, '/tv_music_player_page');
    } else {
      // TODO: Implement logic to play the selected track
      // This might involve updating the TrackPlayerProvider to play the selected track
    }
  }
}