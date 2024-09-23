import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:huntrix/utils/album_utils.dart';
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
  String? _currentAlbumArt;
  String? _currentAlbumName;

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp';
    loadData(context, _handleDataLoaded);
  }

  void _preloadFirstThreeAlbums() {
    if (_cachedAlbumData == null || !mounted) return;

    for (int i = 0; i < 6 && i < _cachedAlbumData!.length; i++) {
      final String albumArt = _cachedAlbumData![i]['albumArt'] as String;
      precacheImage(AssetImage(albumArt), context).then((_) {
        if (mounted) {
          logger.d('Preloaded album art: $albumArt');
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger = context.read<Logger>();

    final trackPlayerProvider =
        Provider.of<TrackPlayerProvider>(context, listen: false);
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    if (currentlyPlayingSong != null) {
      _currentAlbumArt = currentlyPlayingSong.albumArt;
      _currentAlbumName = currentlyPlayingSong.albumName;
    }

    loadData(context, _handleDataLoaded);
  }

  // Handle loaded album data and preload images
  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });

    if (albumData != null) {
      preloadAlbumImages(albumData, context);
      _preloadFirstThreeAlbums();
    }
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              _buildBody(),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _currentAlbumName == null || _currentAlbumName!.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const MusicPlayerPage()),
                    // );

                     Navigator.pushNamed(context, '/music_player_page');
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
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
    // const int infiniteScrollMultiplier = 1000;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double wheelHeight = constraints.maxHeight * 0.8;
        final double itemExtent = wheelHeight / 1.6;

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
            diameterRatio: 2.0,
            perspective: 0.001,
            squeeze: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.mediumImpact();
              preloadAlbumImagesAroundIndex(
                  index, context); // Preload images around the selected index
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
                  onLongPress: () {
                    handleAlbumTap(
                        albumData, _handleDataLoaded, context, logger);
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
                  child: Container(
                    width: itemExtent * 0.9,
                    height: itemExtent * 0.9,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          gaplessPlayback: true,
                          albumArt,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount:
                  _cachedAlbumData == null ? 0 : _cachedAlbumData!.length,
            ),
          ),
        );
      },
    );
  }

  void preloadAlbumImagesAroundIndex(int currentIndex, BuildContext context) {
    const int preloadRange = 24; // Adjust as needed
    for (int i = currentIndex - preloadRange;
        i <= currentIndex + preloadRange;
        i++) {
      if (i >= 0 && i < _cachedAlbumData!.length) {
        final String albumArt = _cachedAlbumData![i]['albumArt'] as String;
        precacheImage(AssetImage(albumArt), context);
      }
    }
  }
}
