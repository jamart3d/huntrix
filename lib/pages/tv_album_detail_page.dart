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
  State<TvAlbumDetailPage> createState() => _TvAlbumDetailPageState();
}

class _TvAlbumDetailPageState extends State<TvAlbumDetailPage> {
  int _focusedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCapitolTheatre = widget.albumName == '1982-04-10 - Capitol Theatre';
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
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
              child: Row(
                children: [
                  // Left half - Album art and details
                  Expanded(
                    flex: 1,
                    child: _buildAlbumHeader(isCapitolTheatre),
                  ),
                  // Right half - Track list
                  Expanded(
                    flex: 1,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              widget.albumArt,
              // width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(20),
          Text(
            widget.albumName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(10),
          Text(
            '${widget.tracks.length} tracks',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
            ),
          ),
          if (isCapitolTheatre) ...[
            const Gap(10),
            const Row(
              children: [
                Icon(Icons.album, color: Colors.green, size: 30),
                Gap(10),
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
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
      // Navigator.pushReplacementNamed(context, '/tv_music_player_page');
    } else {
      //get the album of the selected track
      final albumName = track.albumName;
// pause the current track
      trackPlayerProvider.pause();
// clear playlist
      trackPlayerProvider.clearPlaylist();

      final albumTracks = widget.tracks.where((track) => track.albumName == albumName).toList();
            final currentIndex = widget.tracks.indexOf(track);

      trackPlayerProvider.addAllToPlaylistAndPlayFromTrack(albumTracks, currentIndex);
 Navigator.pushReplacementNamed(context, '/TvNowPlayingPage');


    }
  }
}