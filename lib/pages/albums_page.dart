import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:huntrix/utils/album_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.info,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>>? _cachedAlbumData;
  String _currentAlbumArt = 'assets/images/t_steal.webp';
  String? _currentAlbumName;
  bool appStarted = false;
  final GlobalKey _listKey = GlobalKey();

  late SharedPreferences _prefs;
  bool get _displayAlbumReleaseNumber =>
      _prefs.getBool('displayAlbumReleaseNumber') ?? true;

  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  bool get wantKeepAlive => true;

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
        newAlbumName = '19$newAlbumName';
      }

      setState(() {
        if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
        if (newAlbumName != null) _currentAlbumName = newAlbumName;

        logger.i(
            'AAAA newAlbumName1: $newAlbumName _currentAlbumName $_currentAlbumName');
      });

      // final releaseNumber = _cachedAlbumData
      //     ?.indexWhere((albumName) => albumName['album'] == _currentAlbumName);
      // final releaseNumber = findReleaseNumberAndPrintAlbums();

      // print('releaseNumber1: $releaseNumber');

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   _scrollToIndex(releaseNumber!);
      // });
    }

    // Load album data
    loadData(context, (albumData) {
      if (albumData != null) {
        preloadAlbumImages(albumData, context);
      }

      if (albumData != null || newAlbumArt != null || newAlbumName != null) {
        setState(() {
          _cachedAlbumData = albumData ?? _cachedAlbumData;
          logger
              .i('BBBBB cachedAlbumData length1: ${_cachedAlbumData?.length}');
        });
      }

      // final releaseNumber = _cachedAlbumData
      //     ?.indexWhere((albumName) => albumName['album'] == _currentAlbumName);
      final releaseNumber2 = findReleaseNumberAndPrintAlbums();

      logger.i(
          'CCCCC releaseNumber2: $releaseNumber2 newAlbumName2: $newAlbumName _currentAlbumName $_currentAlbumName');
      //  _scrollToIndex(releaseNumber2!);

      //    WidgetsBinding.instance.addPostFrameCallback((_) {
      //   _scrollToIndex(releaseNumber2!);
      // });
    });
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    logger.i('_handleDataLoaded');
    setState(() {
      _cachedAlbumData = albumData;
      logger.i('_handleDataLoaded albumData: ${_cachedAlbumData?.length}');
    });
    if (albumData != null) {
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
      floatingActionButton: _currentAlbumName == null ||
              _currentAlbumName!.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                final index = _cachedAlbumData!.indexWhere((releaseNumber) =>
                    releaseNumber['album'] == _currentAlbumName);
                logger.i(
                    'fba i $index - _currentAlbumName $_currentAlbumName l ${_cachedAlbumData?.length} -  ${_cachedAlbumData?[index]}');

                _scrollToIndex(index);

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
      final randomAlbum = _cachedAlbumData![randomIndex];
      final albumArt = randomAlbum['albumArt'] as String;

      if (randomIndex >= 0 && randomIndex < (_cachedAlbumData?.length ?? 0)) {
        await handleAlbumTap2(randomAlbum, context);
      }

      setState(() {
        _currentAlbumArt = albumArt;
        _currentAlbumName = randomAlbum['album'] as String;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(randomIndex + 1);
      });
    } else {
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

          return GestureDetector(
            // Added GestureDetector for tap and long press
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
              logger.i('olp Album index: $index, Album: $albumName');

              if (index >= 0 && index < (_cachedAlbumData?.length ?? 0)) {
                await handleAlbumTap2(album, context);
                setState(() {
                  _currentAlbumArt = albumArt;
                  _currentAlbumName = albumName;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndex(index + 1);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please wait for albums to load')),
                );
              }

              // handleAlbumTap(album, _handleDataLoaded, context);
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.94,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.28,
                              maxHeight:
                                  MediaQuery.of(context).size.width * 0.28,
                            ),
                            child: Image.asset(
                              gaplessPlayback: true,
                              albumArt,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (index == 104)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(90, 90, 0, 0),
                              child: Icon(Icons.album,
                                  color: Colors.green, size: 15),
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
                              _displayAlbumReleaseNumber
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
                                        Shadow(
                                          color: shadowColor,
                                          blurRadius: 3,
                                        ),
                                        Shadow(
                                          color: shadowColor,
                                          blurRadius: 6,
                                        ),
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
                                        Shadow(
                                          color: shadowColor,
                                          blurRadius: 3,
                                        ),
                                        Shadow(
                                          color: shadowColor,
                                          blurRadius: 6,
                                        ),
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
            ),
          );
        },
      );
    }
  }

  int? findReleaseNumberAndPrintAlbums() {
    int i = 0;

    logger.i('ddd findReleaseNumberAndPrintAlbums1 $_currentAlbumName');
    // if (!_currentAlbumName!.startsWith('19')) {
    //   _currentAlbumName = '19${_currentAlbumName!}';
    // }

    while (i < _cachedAlbumData!.length) {
      final currentAlbum = _cachedAlbumData![i];
      //  logger.i(
      //     'FUCK!!! - ${currentAlbum['releaseNumber']}  - ${currentAlbum['album']}  - $_currentAlbumName');

      if (currentAlbum['album'] == _currentAlbumName) {
        logger.i(
            'DDDDDDDD findReleaseNumberAndPrintAlbums2  ${currentAlbum['releaseNumber']} - ${currentAlbum['album']} - $_currentAlbumName');

        return i; // Return the index if a match is found
      }

      i++;
    }

    return null; // Return null if no match is found
  }
}
