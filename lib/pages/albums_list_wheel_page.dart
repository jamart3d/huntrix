import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:logger/logger.dart';

class AlbumListWheelPage extends StatefulWidget {
  const AlbumListWheelPage({super.key});

  @override
  State<AlbumListWheelPage> createState() => _AlbumListWheelPageState();
}

class _AlbumListWheelPageState extends State<AlbumListWheelPage> {
  late Logger logger;
  List<Map<String, dynamic>>? _cachedAlbumData;
  String? _currentAlbumArt; // To store current album art
  String? _currentAlbumName; // To store the name of the currently playing album

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp'; // Default album art
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger = context.read<Logger>();

    // Restore the current album art and name from TrackPlayerProvider
    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    if (currentlyPlayingSong != null) {
      _currentAlbumArt = currentlyPlayingSong.albumArt;
      _currentAlbumName = currentlyPlayingSong.albumName;
    }

    loadData(context, _handleDataLoaded); // Load album data
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Hunter's Matrix"),
        centerTitle: true,
        forceMaterialTransparency: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: _buildAppBarActions(context),
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          image: DecorationImage(
            image: AssetImage(_currentAlbumArt ?? 'assets/images/t_steal.webp'),
            fit: BoxFit.cover,
            colorFilter: _currentAlbumArt != null
                ? null
                : ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
          child: Stack(
            children: [
              // Album list wheel
              _buildBody(),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentAlbumName == null || _currentAlbumName!.isEmpty
          ? null // Disable the FAB by setting onPressed to null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MusicPlayerPage()),
                );
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0, // Subtle elevation for better visibility
              child: const Icon(
                Icons.play_circle,
                size: 50,
              ),
            ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.question_mark),
        onPressed: () => _handleRandomAlbumSelection(context),
      ),
    ];
  }

  void _handleRandomAlbumSelection(BuildContext context) {
    if (_cachedAlbumData != null) {
      selectRandomAlbum(context, _cachedAlbumData!, logger, _handleDataLoaded);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for albums to load')));
    }
  }

  Widget _buildBody() {
    if (_cachedAlbumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_cachedAlbumData!.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return _buildAlbumWheel();
    }
  }

  Widget _buildAlbumWheel() {
    const int infiniteScrollMultiplier =
        1000; // Number of times to repeat the album list

    return LayoutBuilder(
      builder: (context, constraints) {
        final double wheelHeight =
            constraints.maxHeight * 0.8; // Use 80% of the available height
        final double itemExtent =
            wheelHeight / 1.2; // Show 2 items at a time (larger cards)

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.pixels % itemExtent < 1) {
                HapticFeedback.selectionClick();
              }
            }
            return true;
          },
          child: ListWheelScrollView.useDelegate(
            itemExtent: itemExtent,
            diameterRatio: 2.0, // Adjusted for larger cards
            perspective: 0.001,
            squeeze: 1.2, // Adjusted for larger cards
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.mediumImpact();
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (_cachedAlbumData == null || _cachedAlbumData!.isEmpty) {
                  return null;
                }

                final actualIndex = index % _cachedAlbumData!.length;
                final albumData = _cachedAlbumData![actualIndex];
                final albumName = albumData['album'] as String;
                final albumArt = albumData['albumArt'] as String;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailPage(
                          tracks: albumData['songs'] as List<Track>,
                          albumArt: albumArt,
                          albumName: albumName,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => handleAlbumTap(
                      albumData, _handleDataLoaded, context, logger),
                  child: Container(
                    width: itemExtent * 0.9, // 90% of itemExtent
                    height: itemExtent * 0.9, // Keep it square
                    margin: EdgeInsets.symmetric(vertical: itemExtent * 0.05),
                    child: Card(
                      elevation: 22,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _currentAlbumName == albumName
                              ? Colors.yellow
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              albumArt,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _cachedAlbumData == null
                  ? 0
                  : _cachedAlbumData!.length * infiniteScrollMultiplier,
            ),
          ),
        );
      },
    );
  }

 
}
