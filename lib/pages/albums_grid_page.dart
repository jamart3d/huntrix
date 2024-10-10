import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/tv_album_detail_page.dart';
import 'package:huntrix/pages/tv_now_playing_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:huntrix/providers/album_settings_provider.dart';

class AlbumsGridPage extends StatefulWidget {
  const AlbumsGridPage({super.key});

  @override
  State<AlbumsGridPage> createState() => _AlbumsGridPageState();
}

class _AlbumsGridPageState extends State<AlbumsGridPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Map<String, dynamic>>? _cachedAlbumData;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  String? _currentAlbumName;
  final FocusNode _mainFocusNode = FocusNode();
  int _focusedIndex = -1;
  bool _isAppBarFocused = true;
  final ScrollController _scrollController = ScrollController();

  bool get _displayAlbumReleaseNumber =>
      Provider.of<AlbumSettingsProvider>(context, listen: false).displayAlbumReleaseNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mainFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainFocusNode.removeListener(_onFocusChange);
    _mainFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadData(context, (albumData) {
        if (albumData != null) {
          preloadAlbumImages(albumData, context);
          setState(() {
            _cachedAlbumData = albumData;
          });
        }
      });
    }
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
      const crossAxisCount = 4;
      final rowIndex = _focusedIndex ~/ crossAxisCount;
      final itemHeight = MediaQuery.of(context).size.width / crossAxisCount;
      final scrollOffset = rowIndex * itemHeight;

      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToCurrentAlbum() {
    if (_cachedAlbumData != null && _currentAlbumName != null) {
      final currentIndex = _cachedAlbumData!
          .indexWhere((album) => album['album'] == _currentAlbumName);
      if (currentIndex != -1) {
        setState(() {
          _focusedIndex = currentIndex;
          _isAppBarFocused = false;
        });
        _scrollToFocusedItem();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    if (currentlyPlayingSong != null &&
        currentlyPlayingSong.albumArt != _currentAlbumArt) {
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
    return Consumer<AlbumSettingsProvider>(
      builder: (context, albumSettings, child) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            if (_isAppBarFocused) {
              return true;
            } else {
              if (_focusedIndex >= 0 && _focusedIndex <= 3) {
                setState(() {
                  _isAppBarFocused = true;
                  _focusedIndex = -1;
                });
                _scrollToFocusedItem();
                return false;
              } else {
                setState(() {
                  _focusedIndex = 0;
                });
                _scrollToFocusedItem();
                return false;
              }
            }
          },
          child: Scaffold(
            appBar: _focusedIndex == 0 || _isAppBarFocused
                ? AppBar(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    centerTitle: true,
                    title: Row(
                      children: [
                        Text(_currentAlbumName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const Text(' --> ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.album,
                            color: _currentAlbumName != null
                                ? Colors.yellow
                                : Colors.transparent,
                          ),
                          onPressed: () => _scrollToCurrentAlbum(),
                        ),
                      ],
                    ),
                    actions: [
                      const Text('select a random trix -->'),
                      IconButton(
                        icon: const Icon(
                          Icons.question_mark,
                          color: Colors.white,
                        ),
                        onPressed: () => _handleRandomAlbumSelection(context),
                      ),
                    ],
                  )
                : null,
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
          ),
        );
      },
    );
  }

  bool _handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveFocus(4);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveFocus(-4);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveFocus(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveFocus(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _handleSelectPress(context);
      } else {
        return false;
      }
      return true;
    }
    return false;
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
          if (_focusedIndex >= 0 && _focusedIndex <= 3) {
            _isAppBarFocused = true;
            _focusedIndex = -1;
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

  Future<void> _handleRandomAlbumSelection(BuildContext context) async {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      final randomIndex = Random().nextInt(_cachedAlbumData!.length);
      final randomAlbum = _cachedAlbumData![randomIndex];
      final albumTracks = randomAlbum['songs'] as List<Track>;
      await handleAlbumTap2(albumTracks);
      setState(() {
        _currentAlbumArt = randomAlbum['albumArt'] as String;
        _currentAlbumName = randomAlbum['album'] as String;
        _focusedIndex = randomIndex;
        _isAppBarFocused = false;
      });
      _scrollToFocusedItem();
    }
  }

  void _handleSelectPress(BuildContext context) {
    if (_focusedIndex >= 0 && _focusedIndex < _cachedAlbumData!.length) {
      final album = _cachedAlbumData![_focusedIndex];
      final targetPage = (_currentAlbumName == album['album'])
          ? TvNowPlayingPage(
              tracks: album['songs'] as List<Track>,
              albumArt: album['albumArt'] as String,
              albumName: album['album'] as String,
            )
          : TvAlbumDetailPage(
              tracks: album['songs'] as List<Track>,
              albumArt: album['albumArt'] as String,
              albumName: album['album'] as String,
            );
      Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage));
    }
  }

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
          crossAxisCount: 4,
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
                              color: Colors.white.withOpacity(0.1),
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
                          color: _currentAlbumName == albumName
                              ? Colors.yellow
                              : Colors.white,
                          shadows: _currentAlbumName == albumName
                              ? [
                                  const Shadow(
                                      color: Colors.redAccent, blurRadius: 3),
                                  const Shadow(
                                      color: Colors.redAccent, blurRadius: 6),
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
