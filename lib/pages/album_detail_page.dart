import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';

class AlbumDetailPage extends StatelessWidget {
  final List<Track> tracks;
  final String albumArt;
  final String albumName;

  const AlbumDetailPage(
      {super.key,
      required this.tracks,
      required this.albumArt,
      required this.albumName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(albumName),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(albumArt),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album Art (Silver)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2), // Silver color
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 200,
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        albumArt,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Gap(16),
                  // Album Name (White)
                  Text(
                    albumName
                        .split('-')
                        .sublist(3)
                        .join('-')
                        .replaceAll(RegExp(r'^[^a-zA-Z0-9]'), ''),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Gap(16),
                  // Track List
                  _buildTrackList(tracks),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackList(List<Track> tracks) {
    return Expanded(
      child: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return ListTile(
            leading: Text(
              (index + 1).toString(),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            title: Text(
              track.trackName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: Text(
              formatDurationSeconds(track.trackDuration),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
