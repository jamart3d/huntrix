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

final logger = Logger(
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
  late Logger logger;
  List<Map<String, dynamic>>? _cachedAlbumData;
  String? _currentAlbumArt;
  String? _currentAlbumName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp';
      // logger.i('AlbumsPage initState called');

  }


@override
void dispose() {
  logger.i('AlbumsPage dispose called');
  super.dispose();
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger = context.read<Logger>();
    final trackPlayerProvider = context.watch<TrackPlayerProvider>();
    final currentlyPlayingSong = trackPlayerProvider.currentlyPlayingSong;

    if (currentlyPlayingSong != null) {
      setState(() {
        _currentAlbumArt = currentlyPlayingSong.albumArt;
        _currentAlbumName = currentlyPlayingSong.albumName;
      });
    }
    loadData(context, _handleDataLoaded);
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });
        if (albumData != null) {
            logger.i('Album data loaded: ${albumData.length} albums');
      
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
        title: const Text("A List of Hunter's trix"),
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
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
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

  void _handleRandomAlbumSelection(BuildContext context) {
    if (_cachedAlbumData != null && _cachedAlbumData!.isNotEmpty) {
      selectRandomAlbum(context, _cachedAlbumData!, logger, _handleDataLoaded);
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

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                albumArt,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.grey);
                },
              ),
            ),
            title: Text(
              formatAlbumName(albumName),
              style: TextStyle(
                color:
                    _currentAlbumName == albumName ? Colors.yellow : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              extractDateFromAlbumName(albumName),
              style: TextStyle(
                color:
                    _currentAlbumName == albumName ? Colors.yellow : Colors.white,
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
            onLongPress: () => handleAlbumTap(
                album, _handleDataLoaded, context, logger),
          );
        },
      );
    }
  }
}