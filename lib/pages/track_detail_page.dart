import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/utils/duration_formatter.dart';
import 'package:huntrix/models/track.dart';

class TrackDetailPage extends StatelessWidget {
  final Track track;

  const TrackDetailPage({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(track.trackName),
      ),
      // Use a Container with BoxDecoration and BackdropFilter for the blurred background
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(track.albumArt ?? 'assets/images/t_steal.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity as needed
          child: Container(
            color: Colors.black.withOpacity(
                0.5), // Add a semi-transparent overlay for better contrast
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                // Make the card completely transparent
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display album art if available, otherwise a placeholder
                      if (track.albumArt != null)
                        Image.asset(
                          track.albumArt!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        // Placeholder image or text if album art is not available
                        const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('No Album Art Available',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
              
                      const SizedBox(height: 16),
              
                      // Track details with white text color
                      Text(
                        track.trackName,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'Artist: ${track.artistName ?? track.trackArtistName}',
                      //   style: const TextStyle(fontSize: 18, color: Colors.white),
                      // ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   'Album: ${track.albumName}',
                      //   style: const TextStyle(fontSize: 16, color: Colors.white),
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        'Track Number: ${track.trackNumber}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${formatDurationSeconds(track.trackDuration)}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      // Add more track details as needed
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
