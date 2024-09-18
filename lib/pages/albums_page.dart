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
import 'package:logger/logger.dart';
import 'package:huntrix/utils/album_utils.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger = context.read<Logger>();
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    bool shouldUpdateState = false;
    String? newAlbumArt;
    String? newAlbumName;

    // Check if the currentlyPlayingSong is different from the current background
    if (currentlyPlayingSong != null &&
        (currentlyPlayingSong.albumArt != _currentAlbumArt ||
            currentlyPlayingSong.albumName != _currentAlbumName)) {
      shouldUpdateState = true;
      newAlbumArt = currentlyPlayingSong.albumArt;
      newAlbumName = currentlyPlayingSong.albumName;
    }

    loadData(context, (albumData) {
      if (albumData != null) {
        shouldUpdateState = true;
        logger.i(
            'Album data images will be preloaded. Album count: ${albumData.length} albums');
        preloadAlbumImages(albumData, context);
      }

      if (shouldUpdateState) {
        setState(() {
          if (newAlbumArt != null) _currentAlbumArt = newAlbumArt;
          if (newAlbumName != null) _currentAlbumName = newAlbumName;
          if (albumData != null) _cachedAlbumData = albumData;
        });
      }
    });
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });
    if (albumData != null) {
      logger.i(
          'Album data images will be preloaded. Album count: ${albumData.length} albums');
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
        title: const Text("Select a random trix -->"),
        actions: _buildAppBarActions(context),
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          image: DecorationImage(
            image: AssetImage(_currentAlbumArt),
            fit: BoxFit.cover,
            // colorFilter: _currentAlbumArt != null
            //     ? null
            //     : ColorFilter.mode(
            //         Colors.black.withOpacity(0.5),
            //         BlendMode.darken,
            //       ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              _buildBody(),
              _currentAlbumName != null && _currentAlbumName!.isNotEmpty
                  ? GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dx < 0) {
                          // Changed condition
                          // Swipe to the left
                          logger.i('Swiped to the left!');
                          Navigator.pushNamed(context, '/music_player_page');
                          logger.i('Navigated to music player page.');
                        }
                      },
                      child: Container(),
                    )
                  : Container(),
            ],
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

  void _handleRandomAlbumSelection(BuildContext context) async {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      final randomIndex = Random().nextInt(_cachedAlbumData!.length);
      final randomAlbum = _cachedAlbumData![randomIndex];
      final albumName = randomAlbum['album'] as String;
      final albumArt = randomAlbum['albumArt'] as String;

      precacheImage(AssetImage(albumArt), context);
      handleAlbumTap2(randomAlbum, context, logger);

      await Navigator.push(
        // Use await here
        context,
        MaterialPageRoute(
          builder: (context) => AlbumDetailPage(
            tracks: randomAlbum['songs'] as List<Track>,
            albumArt: albumArt,
            albumName: albumName,
          ),
        ),
      );

      // Update the background image after Navigator.pop
      // setState(() {
      //   _currentAlbumArt = albumArt;
      //   _currentAlbumName = albumName;
      // });
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
    // Move data handling to a separate method
    return _buildAlbumListView(_cachedAlbumData);
  }

  Widget _buildAlbumListView(List<Map<String, dynamic>>? albumData) {
    if (albumData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (albumData.isEmpty) {
      return const Center(child: Text("No albums available."));
    } else {
      return ListView.builder(
        itemCount: albumData.length,
        itemBuilder: (context, index) {
          final album = albumData[index]; // Rename 'albumData' to 'album'
          final albumName = album['album'] as String;
          final albumArt = album['albumArt'] as String;

          // Load album art synchronously:
          // final albumArtImage = Image.asset(albumArt);

          return ListTile(
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      albumArt, // Use the synchronously loaded image
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
              formatAlbumName(albumName),
              style: TextStyle(
                color: _currentAlbumName == albumName
                    ? Colors.yellow
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              extractDateFromAlbumName(albumName),
              style: TextStyle(
                color: _currentAlbumName == albumName
                    ? Colors.yellow
                    : Colors.white,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            // onTap: () =>
          );
        },
      );
    }
  }
}
