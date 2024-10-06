import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:huntrix/pages/tv_now_playing_page.dart';

class AlbumsGridPage extends StatefulWidget {
  const AlbumsGridPage({Key? key}) : super(key: key);

  @override
  _AlbumsGridPageState createState() => _AlbumsGridPageState();
}

class _AlbumsGridPageState extends State<AlbumsGridPage> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>>? _cachedAlbumData;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  String? _currentAlbumName;
  late SharedPreferences _prefs;
  bool get _displayAlbumReleaseNumber => _prefs.getBool('displayAlbumReleaseNumber') ?? false;
  final FocusNode _mainFocusNode = FocusNode();
  int _focusedIndex = -1;
  bool _isAppBarFocused = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
    _mainFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _mainFocusNode.removeListener(_onFocusChange);
    _mainFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_mainFocusNode.hasFocus && _focusedIndex == -1) {
      setState(() {
        _focusedIndex = 0;
        _isAppBarFocused = false;
      });
      _scrollToFocusedItem();
    }
  }

  void _scrollToFocusedItem() {
    if (_focusedIndex >= 0 && _cachedAlbumData != null) {
      const crossAxisCount = 2; // This should match the grid's crossAxisCount
      final rowIndex = _focusedIndex ~/ crossAxisCount;
      final itemHeight = MediaQuery.of(context).size.width / crossAxisCount; // Assuming square items
      final scrollOffset = rowIndex * itemHeight;

      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    if (currentlyPlayingSong != null && currentlyPlayingSong.albumArt != _currentAlbumArt) {
      setState(() {
        _currentAlbumArt = currentlyPlayingSong.albumArt!;
        _currentAlbumName = currentlyPlayingSong.albumName;
      });
    }

    loadData(context, (albumData) {
      if (albumData != null) {
        preloadAlbumImages(albumData, context);
        setState(() {
          _cachedAlbumData = albumData;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text("Select a Trix"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.question_mark,
              color: _isAppBarFocused ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _handleRandomAlbumSelection(context),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_currentAlbumArt),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: KeyboardListener(
              focusNode: _mainFocusNode,
              onKeyEvent: (keyEvent) => _handleKeyEvent(keyEvent, context),
              child: _buildGridView(),
            ),
          ),
        ),
      ),
    );
  }

  bool _handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveFocus(2);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveFocus(-2);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveFocus(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveFocus(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
        _handleSelectPress(context);
      } else {
        return false; // Event not handled
      }
      return true; // Event handled
    }
    return false; // Event not handled
  }
  void _moveFocus(int delta) {
    if (_cachedAlbumData == null || _cachedAlbumData!.isEmpty) return;

    setState(() {
      if (_isAppBarFocused) {
        _isAppBarFocused = false;
        _focusedIndex = 0;
      } else {
        int newIndex = _focusedIndex + delta;
        if (newIndex < 0) {
          // If we're at the top of the list and moving up
          if (_focusedIndex < 2) {
            _isAppBarFocused = true;
            _focusedIndex = -1;
          } else {
            _focusedIndex = 0;
          }
        } else if (newIndex >= _cachedAlbumData!.length) {
          _focusedIndex = _cachedAlbumData!.length - 1;
        } else {
          _focusedIndex = newIndex;
        }
      }
    });
    _scrollToFocusedItem();
  }


void _handleRandomAlbumSelection(BuildContext context) {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      final randomIndex = Random().nextInt(_cachedAlbumData!.length);
      final randomAlbum = _cachedAlbumData![randomIndex];
      handleAlbumTap2(randomAlbum, context);
      setState(() {
        _currentAlbumArt = randomAlbum['albumArt'] as String;
        _currentAlbumName = randomAlbum['album'] as String;
        _focusedIndex = randomIndex;
        _isAppBarFocused = false;
      });
      _scrollToFocusedItem();
    }
  }

// ... other imports

void _handleSelectPress(BuildContext context) {
  if (_isAppBarFocused) {
    _handleRandomAlbumSelection(context);
  } else if (_focusedIndex >= 0 && _focusedIndex < _cachedAlbumData!.length) {
    final album = _cachedAlbumData![_focusedIndex];
    // Navigate to TvNowPlayingPage instead of TvAlbumDetailPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TvNowPlayingPage(
          tracks: album['songs'] as List<Track>,
          albumArt: album['albumArt'] as String,
          albumName: album['album'] as String,
        ),
      ),
    );
  }
}

// ... rest of the code

  Widget _buildGridView() {
    if (_cachedAlbumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_cachedAlbumData!.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _cachedAlbumData!.length,
        itemBuilder: (context, index) {
          final album = _cachedAlbumData![index];
          final albumName = album['album'] as String;
          final albumArt = album['albumArt'] as String;

          final isFocused = index == _focusedIndex && !_isAppBarFocused;
          return GestureDetector(
            onTap: () {
              setState(() {
                _focusedIndex = index;
                _isAppBarFocused = false;
              });
              _scrollToFocusedItem();
              _handleSelectPress(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: isFocused 
                ? (Matrix4.identity()..scale(1.05))
                : Matrix4.identity(),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(albumArt, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    
                  ),
                  if (isFocused)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        _displayAlbumReleaseNumber
                            ? '${index + 1}. ${formatAlbumName(albumName)}'
                            : formatAlbumName(albumName),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _currentAlbumName == albumName ? Colors.yellow : Colors.white,
                          shadows: _currentAlbumName == albumName
                              ? [
                                  const Shadow(color: Colors.redAccent, blurRadius: 3),
                                  const Shadow(color: Colors.redAccent, blurRadius: 6),
                                ]
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}