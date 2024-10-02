import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AlbumListWheelPage extends StatefulWidget {
  const AlbumListWheelPage({super.key});

  @override
  State<AlbumListWheelPage> createState() => _AlbumListWheelPageState();
}

class _AlbumListWheelPageState extends State<AlbumListWheelPage> {
  List<Map<String, dynamic>>? _cachedAlbumData;
  String? _currentAlbumName;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  late FixedExtentScrollController _scrollController;

  late SharedPreferences _prefs;
  bool get _displayAlbumReleaseNumber =>
      _prefs.getBool('displayAlbumReleaseNumber') ?? false;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
  }

  void _preloadFirstThreeAlbums() {
    if (_cachedAlbumData == null || !mounted) return;

    for (int i = 0; i < 6 && i < _cachedAlbumData!.length; i++) {
      final String albumArt = _cachedAlbumData![i]['albumArt'] as String;
      precacheImage(AssetImage(albumArt), context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the current song from TrackPlayerProvider
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    String? newAlbumArt;
    String? newAlbumName;

    if (currentlyPlayingSong != null &&
        (currentlyPlayingSong.albumArt != _currentAlbumArt)) {
      // Update album art and name only when necessary
      newAlbumArt = currentlyPlayingSong.albumArt;
      newAlbumName = currentlyPlayingSong.albumName;
     if (!newAlbumName.startsWith('19')) {
  newAlbumName = '19$newAlbumName'; // No need for ! here since we've checked for null
}
      setState(() {
        if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
        if (newAlbumName != null) _currentAlbumName = newAlbumName;
        
      });
    }

    // Load album data
    loadData(context, (albumData) {
      if (albumData != null) {
        preloadAlbumImages(albumData, context);
      }

      if (albumData != null || newAlbumArt != null || newAlbumName != null) {
        setState(() {
          _cachedAlbumData = albumData ?? _cachedAlbumData;
        });
      }
    });
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
            image: AssetImage(_currentAlbumArt),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
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
      floatingActionButton: _currentAlbumName == null ||
              _currentAlbumName!.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                final index = _cachedAlbumData!.indexWhere((releaseNumber) =>
                    releaseNumber['album'] == _currentAlbumName);
                if (index >= 0 &&
                    index < (_cachedAlbumData?.length ?? 0)) {
                  scrollToIndex(index);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No album found')));
                }
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
      selectRandomAlbum(context, _cachedAlbumData!, _handleDataLoaded);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double wheelHeight = constraints.maxHeight * 0.8;
        final double itemExtent = wheelHeight / 1.6;
        Color shadowColor = Colors.redAccent;

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
            controller: _scrollController,
            itemExtent: itemExtent,
            diameterRatio: 2.0,
            perspective: 0.001,
            squeeze: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.mediumImpact();
              preloadAlbumImagesAroundIndex(index, context);
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
                    handleAlbumTap(albumData, _handleDataLoaded, context);
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
                          width: 3,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              gaplessPlayback: true,
                              albumArt,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, bottom: 70),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                ' ${_displayAlbumReleaseNumber ? '${actualIndex + 1}. ${formatAlbumName(albumName)}' : ''}',
                                style: TextStyle(
                                    color: _currentAlbumName == albumName
                                        ? Colors.yellow
                                        : Colors.white,
                                    fontWeight: _currentAlbumName == albumName
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 18,
                                    shadows: _currentAlbumName == albumName
                                        ? [
                                            Shadow(
                                              color: shadowColor,
                                              blurRadius: 3,
                                            ),
                                            Shadow(
                                              color: shadowColor,
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 48.0, bottom: 54),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                ' ${_displayAlbumReleaseNumber ? extractDateFromAlbumName(albumName) : ''}',
                                style: TextStyle(
                                    color: _currentAlbumName == albumName
                                        ? Colors.yellow
                                        : Colors.white,
                                    fontWeight: _currentAlbumName == albumName
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                    shadows: _currentAlbumName == albumName
                                        ? [
                                            Shadow(
                                              color: shadowColor,
                                              blurRadius: 3,
                                            ),
                                            Shadow(
                                              color: shadowColor,
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null),
                              ),
                            ),
                          ),
                        ],
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

  void scrollToIndex(int index) {
    if (_cachedAlbumData != null && index < _cachedAlbumData!.length) {
      final double itemExtent =
          _scrollController.position.viewportDimension / 2;

      if (_scrollController.offset.toInt() != (index * itemExtent).toInt()) {
        _scrollController.animateTo(
          index * itemExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushNamed(context, '/music_player_page');
      }
    }
  }

  
}
