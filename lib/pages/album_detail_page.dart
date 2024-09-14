import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';

class AlbumDetailPage extends StatelessWidget {
  final List<Track> tracks;
  final String albumArt;
  final String albumName;

  const AlbumDetailPage({
    super.key,
    required this.tracks,
    required this.albumArt,
    required this.albumName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Container(
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
              ),
            ),
          ),
          // Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                elevation: 0,
                expandedHeight: 300.0,
                // floating: false,
                // pinned: true,
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  
                  // title: Text(
                  //   albumName,
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.bold,
                  //     shadows: [
                  //       Shadow(
                  //         blurRadius: 2.0,
                  //         color: Colors.black,
                  //         offset: Offset(1.0, 1.0),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  background: SizedBox(
                    child: Image.asset(
                      albumArt,
                      // width: 100,
                      // height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
            
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Gap(1),
                    ..._buildTrackList(tracks),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTrackList(List<Track> tracks) {
    return tracks.asMap().entries.map((entry) {
      final index = entry.key;
      final track = entry.value;
      return ListTile(
        dense: true,
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
    }).toList();
  }
}