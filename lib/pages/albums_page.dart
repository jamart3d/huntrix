import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
// import 'package:huntrix/pages/track_playlist_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:logger/logger.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage>
    with AutomaticKeepAliveClientMixin {
  late Logger logger;
  List<Map<String, dynamic>>? _cachedAlbumData;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  String? _currentAlbumName;
  bool appStarted = false;
  final GlobalKey _listKey = GlobalKey();

  late SharedPreferences _prefs;
  bool get _displayAlbumReleaseNumber =>
      _prefs.getBool('displayAlbumReleaseNumber') ?? false;

  bool get _randomTrixAtStartupEnabled =>
      _prefs.getBool('randomTrixAtStartupEnabled') ?? false;

  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    logger = context.read<Logger>();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
    logger.i('init happend#########');
    // context.read<TrackPlayerProvider>().addListener(_animateToCurrentAlbum);
  }

  @override
  void dispose() {
    // _itemScrollController.dispose();
    // context.read<TrackPlayerProvider>().removeListener(_animateToCurrentAlbum);
    super.dispose();
  }

  Future<void> _checkAndPerformAppStartProcedure() async {
    if (!appStarted) {
      _performAppStartProcedure();
      setState(() {
        appStarted = true;
      });
    }
  }

  void _performAppStartProcedure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_randomTrixAtStartupEnabled) {
        _handleRandomAlbumSelection(context);
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the current song from TrackPlayerProvider
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    logger.i('dcd, cur song $currentlyPlayingSong}');
    String? newAlbumArt;
    String? newAlbumName;

    if (currentlyPlayingSong != null &&
        (currentlyPlayingSong.albumArt != _currentAlbumArt)) {
      // Update album art and name only when necessary
      newAlbumArt = currentlyPlayingSong.albumArt;
      newAlbumName = currentlyPlayingSong.albumName;
      setState(() {
        logger.i('did change dep, setState, $newAlbumName');
        if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
        if (newAlbumName != null) _currentAlbumName = newAlbumName;
      });
      // Schedule update after build completes
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   setState(() {
      //           logger.i('did change post dep, setState, $newAlbumName');

      //     if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
      //     if (newAlbumName != null) _currentAlbumName = newAlbumName;
      //   });
      // });
    }

    // Load album data
    loadData(context, (albumData) {
      if (albumData != null) {
        // logger.i(
        //     'Album data images will be preloaded. Album count: ${albumData.length} albums');
        preloadAlbumImages(albumData, context);
      }

      if (albumData != null || newAlbumArt != null || newAlbumName != null) {
        // Always update album data and art after changes
        // setState(() {
        //   _cachedAlbumData = albumData ?? _cachedAlbumData;
        //   if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
        //   if (newAlbumName != null) _currentAlbumName = newAlbumName;
        // });
        setState(() {
          _cachedAlbumData = albumData ?? _cachedAlbumData;
        });
      }
    });
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });
    if (albumData != null) {
      // logger.i(
      //     'Album data images will be preloaded. Album count: ${albumData.length} albums');
      preloadAlbumImages(albumData, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          "Select a random trix -->",
        ),
        actions: _buildAppBarActions(context),
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
            child: _buildBody(),
          ),
        ),
      ),
      floatingActionButton:
          _currentAlbumName == null || _currentAlbumName!.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () {
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
        icon: const Icon(
          Icons.question_mark,
          color: Colors.white,
        ),
        onPressed: () => _handleRandomAlbumSelection(context),
      ),
    ];
  }

  void _animateToCurrentAlbum() {
    if (_currentAlbumName != null && _cachedAlbumData != null) {
      final index = _cachedAlbumData!
          .indexWhere((album) => album['album'] == _currentAlbumName);

      if (index != -1) {
        logger.i(
            '_animateToCurrentAlbum $index _currentAlbumName: $_currentAlbumName');

        _itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    }
  }

  void _scrollToIndex(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _handleRandomAlbumSelection(BuildContext context) async {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      final randomIndex = Random().nextInt(_cachedAlbumData!.length);
      //get random album and list of songs
      final randomAlbum = _cachedAlbumData![randomIndex];
      //get art
      final albumArt = randomAlbum['albumArt'] as String;

      // precacheImage(AssetImage(albumArt), context);
      await handleAlbumTap2(randomAlbum, context, logger);
      // precacheImage(AssetImage(albumArt), context);
      logger.i('cur AlbumName: $_currentAlbumName');

      // final index = _cachedAlbumData!
      //     .indexWhere((album) => album['album'] == _currentAlbumName);
      // logger.i(
      //     'Album data length: ${_cachedAlbumData!.length}, name index: $index, Random index: $randomIndex');
      logger.i(
          'index Album: $_currentAlbumName, ra: ${randomAlbum['album']}, l: ${_cachedAlbumData!.length}, ri: $randomIndex');

      setState(() {
        _currentAlbumArt = albumArt;
        _currentAlbumName = randomAlbum['album'] as String;
        logger.i('Album tapped: $_currentAlbumName');
        // if (index != -1) {
        // _scrollToIndex(randomIndex + 1);
        // _animateToCurrentAlbum();
        // }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(randomIndex + 1);
      });

      //  Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => const TrackPlaylistPage(),
      //           ),
      //         );
    } else {
      // Show a snackbar if the album data is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for albums to load')),
      );
    }
  }

  Widget _buildBody() {
    if (_cachedAlbumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_cachedAlbumData!.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return _buildAlbumList();
    }
  }

  Widget _buildAlbumList() {
    return _buildAlbumListView(_cachedAlbumData);
  }

  Widget _buildAlbumListView(List<Map<String, dynamic>>? albumData) {
    Color shadowColor = Colors.redAccent;
    if (albumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (albumData.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return ScrollablePositionedList.builder(
        key: _listKey,
        itemScrollController: _itemScrollController,
        itemCount: albumData.length,
        itemBuilder: (context, index) {
          final album = albumData[index];
          final albumName = album['album'] as String;
          final albumArt = album['albumArt'] as String;

          // Rebuilds properly when _currentAlbumName is updated
          return ListTile(
            horizontalTitleGap: 8,
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
   
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      gaplessPlayback: true,
                      albumArt,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    )),
                if (index == 104) // this is the only local album for now
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.album, color: Colors.green, size: 10),
                  )
                else
                  const Icon(Icons.album, color: Colors.transparent, size: 10),
              ],
            ),
            title: Text(
              _displayAlbumReleaseNumber
                  ? '${index + 1}. ${formatAlbumName(albumName)}'
                  : formatAlbumName(albumName),
              style: TextStyle(
                  color: _currentAlbumName == albumName
                      ? Colors.yellow
                      : Colors.white,
                  fontWeight: _currentAlbumName == albumName
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 16,
         // Suggested code may be subject to a license. Learn more: ~LicenseLog:2571421677.
shadows: _currentAlbumName == albumName ? [
                    Shadow(
                      color: shadowColor,
                      blurRadius: 3,
                    ),
                        Shadow(
                      color: shadowColor,
                      blurRadius: 6,
                    ),
                    //     Shadow(
                    //   color: shadowColor,
                    //   blurRadius: 9,
                    // ),
                    //      Shadow(
                    //   color: shadowColor,
                    //   blurRadius: 12,
                    // ),
                  ] : null // Highlight currently playing album
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                extractDateFromAlbumName(albumName),
                style: TextStyle(
                  color: _currentAlbumName == albumName
                      ? Colors.yellow
                      : Colors.white,
                                        fontWeight: _currentAlbumName == albumName
                        ? FontWeight.bold
                        : FontWeight.normal,
                        fontSize: 10,
                        shadows: _currentAlbumName == albumName ? [
                      Shadow(
                        color: shadowColor,
                        blurRadius: 3,
                      ),
                          Shadow(
                        color: shadowColor,
                        blurRadius: 6,
                      ),
                      //     Shadow(
                      //   color: shadowColor,
                      //   blurRadius: 9,
                      // ),
                      //      Shadow(
                      //   color: shadowColor,
                      //   blurRadius: 12,
                      // ),
                    ] : null // Highlight currently 
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            onLongPress: () {
              handleAlbumTap(album, _handleDataLoaded, context, logger);
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
            // trailing: Text(
            //   'is (${index.toString()})',
            //   style: TextStyle(
            //     color: _currentAlbumName == albumName
            //         ? Colors.yellow
            //         : Colors.white,
            //     fontSize: 16,
            //   ),
            // ),
          );
        },
      );
    }
  }
}
