import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/pages/albums_grid_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:huntrix/providers/album_settings_provider.dart';
import 'package:huntrix/helpers/archive_alive_helper.dart';


class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>>? _cachedAlbumData;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  String? _currentAlbumName;
  bool _isPageOffline = false;
  // final bool _isCheckingConnection = false;
  // final String _connectionStatusMessage = '';
  final GlobalKey _listKey = GlobalKey();
  Color _backdropColor = Colors.black.withOpacity(0.5);

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Delay the connection check to allow the UI to build first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });
  }

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

        if (!_currentAlbumName!.startsWith('19')) {
          _currentAlbumName = '19$_currentAlbumName';
        }
      });
    }
  }

  Future<void> _loadData() async {
    await loadData(context, (albumData) {
      if (albumData != null) {
        preloadAlbumImages(albumData, context);
      }
      if (mounted) {
        setState(() {
          _cachedAlbumData = albumData;
        });
      }
    });
  }

  Future<void> _checkConnection() async {
    final result = await checkConnectionWithRetries(
      retryCount: 1, //Or your desired retry count
      onPageOffline: (isOffline) {
        setState(() {
          _isPageOffline = isOffline;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('archive.org offline, only release 105 is available.',
              style: TextStyle(color: Colors.red)),
        ),
      );

          
        });
      },
    );

    switch (result) {
      case 'Connection Successful':
        break; // Do nothing for success
      case 'Temporarily Offline':
        // ... Update UI
        _showSiteUnavailableDialog(
            'The archive.org page is temporarily offline.');
        break;
      case 'No Internet Connection':
        // ... Update UI
        _showSiteUnavailableDialog('No internet connection.');
        break;
      default: // Generic error case
        _showSiteUnavailableDialog(
            'Failed to connect to archive.org.\nonly release 105 is available.');
        break;
    }
  }

  void _showSiteUnavailableDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Issue!',
              style: TextStyle(color: Colors.red, fontSize: 16)),
          backgroundColor: Colors.black.withOpacity(0.5),
          content: Text(message,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () {
                _changeBackdropColor(Colors.red.withOpacity(0.5));
                _scrollToIndex(104);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;

    if (size.width > 600) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AlbumsGridPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text("Select a random trix -->"),
        actions: _buildAppBarActions(),
      ),
      drawer: const MyDrawer(),
      body: _buildBody(),
      floatingActionButton:
          _cachedAlbumData != null ? _buildFloatingActionButton() : null,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        disabledColor: Colors.transparent,
        color: Colors.white,
        icon: const Icon(Icons.question_mark, color: Colors.white),
        onPressed: () => _handleRandomAlbumSelection(context),
      ),
    ];
  }

  void _scrollToCurrentAlbum() {
    if (_currentAlbumName != null && _cachedAlbumData != null) {
      final index = _cachedAlbumData!
          .indexWhere((album) => album['album'] == _currentAlbumName);
      if (index != -1) {
        _scrollToIndex(index);
      }
    }
  }

  void _scrollToIndex(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  Future<void> _handleRandomAlbumSelection(BuildContext context) async {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      final randomIndex = Random().nextInt(_cachedAlbumData!.length);
      final randomAlbum = _cachedAlbumData![randomIndex];
      final albumArt = randomAlbum['albumArt'] as String;

      if (randomIndex >= 0 && randomIndex < (_cachedAlbumData?.length ?? 0)) {
 if (_isPageOffline && randomIndex != 104) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('archive.org offline, only release 105 is available.',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }




        await _preloadAlbumArt(randomIndex);
        final albumTracks = randomAlbum['songs'] as List<Track>;
        await handleAlbumTap2(albumTracks);
      }

      setState(() {
        _currentAlbumArt = albumArt;
        _currentAlbumName = randomAlbum['album'] as String;
      });
      _scrollToCurrentAlbum();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for albums to load')),
      );
    }
  }

  void _changeBackdropColor(Color newColor) {
    setState(() {
      _backdropColor = newColor;
    });
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_currentAlbumArt),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: _backdropColor,
          child: _buildAlbumContent(),
        ),
      ),
    );
  }

  Widget _buildAlbumContent() {
    if (_cachedAlbumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_cachedAlbumData!.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_currentAlbumName != null && _cachedAlbumData != null) {
              final index = _cachedAlbumData!
                  .indexWhere((album) => album['album'] == _currentAlbumName);
              if (index != -1) {
                _scrollToIndex(index);
              }
            }
          });
          return _buildAlbumListView(_cachedAlbumData);
        },
      );
    }
  }

  Widget _buildAlbumListView(List<Map<String, dynamic>>? albumData) {
    return Consumer<AlbumSettingsProvider>(
      builder: (context, albumSettings, child) {
        return ScrollablePositionedList.builder(
          key: _listKey,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: albumData?.length ?? 0,
          itemBuilder: (context, index) {
            final album = albumData![index];
            final albumName = album['album'] as String;
            final albumArt = album['albumArt'] as String;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumDetailPage(
                      tracks: album['songs'] as List<Track>,
                      albumArt: albumArt,
                      albumName: albumName,
                    ),
                  ),
                );
              },
              onLongPress: () async {
                await _handleAlbumTap(album, index);
              },
              child: _buildAlbumCard(albumName, albumArt, index, albumSettings),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumCard(String albumName, String albumArt, int index,
      AlbumSettingsProvider albumSettings) {
    Color shadowColor = Colors.redAccent;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.94,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              child: Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.28,
                      maxHeight: MediaQuery.of(context).size.width * 0.28,
                    ),
                    child: Card(
                      borderOnForeground: true,
                      elevation: 0,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                        side: BorderSide(
                          color: _currentAlbumName == albumName
                              ? Colors.yellow
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        albumArt,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (index == 104)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(90, 90, 0, 0),
                      child: Icon(Icons.album, color: Colors.green, size: 15),
                    )
                  else
                    const Icon(Icons.album,
                        color: Colors.transparent, size: 10),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text(
                      albumSettings.displayAlbumReleaseNumber
                          ? '${index + 1}. ${formatAlbumName(albumName)}'
                          : formatAlbumName(albumName),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _currentAlbumName == albumName
                            ? Colors.yellow
                            : Colors.white,
                        shadows: _currentAlbumName == albumName
                            ? [
                                Shadow(color: shadowColor, blurRadius: 3),
                                Shadow(color: shadowColor, blurRadius: 6),
                              ]
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 5, 10, 10),
                    child: Text(
                      extractDateFromAlbumName(albumName),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _currentAlbumName == albumName
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentAlbumName == albumName
                            ? Colors.yellow
                            : Colors.white,
                        shadows: _currentAlbumName == albumName
                            ? [
                                Shadow(color: shadowColor, blurRadius: 3),
                                Shadow(color: shadowColor, blurRadius: 6),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAlbumTap(Map<String, dynamic> album, int index) async {
    final albumTracks = album['songs'] as List<Track>;

    
    if (_isPageOffline && index != 104) {
      ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
          content: Text('archive.org offline, only release 105 is available.',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }

    await handleAlbumTap2(albumTracks);


    setState(() {
      _currentAlbumArt = album['albumArt'] as String;
      _currentAlbumName = album['album'] as String;
    });
    _scrollToIndex(index);
  }

  Future<void> _preloadAlbumArt(int index) async {
    if (_cachedAlbumData == null || !mounted) return;
    final String albumArt = _cachedAlbumData![index]['albumArt'] as String;
    precacheImage(AssetImage(albumArt), context);
  }

  Widget? _buildFloatingActionButton() {
    if (_currentAlbumName == null || _currentAlbumName!.isEmpty) return null;

    return FloatingActionButton(
      onPressed: () {
        final index = _cachedAlbumData!
            .indexWhere((album) => album['album'] == _currentAlbumName);
        _scrollToIndex(index);
        Navigator.pushNamed(context, '/music_player_page');
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(
        Icons.play_circle,
        color: Colors.yellow,
        shadows: [
          Shadow(color: Colors.redAccent, blurRadius: 3),
          Shadow(color: Colors.redAccent, blurRadius: 6),
        ],
        size: 50,
      ),
    );
  }
}
