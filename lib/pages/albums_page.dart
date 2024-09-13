import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
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
  String? _currentAlbumArt;
  String? _currentAlbumName;

  @override
  bool get wantKeepAlive => true; // Ensure the page state is kept alive

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp'; // Default album art
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
    loadData(context, _handleDataLoaded); // Load album data
  }

  // Handle album data loading and trigger image preloading
  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });

    if (albumData != null) {
      preloadAlbumImages(albumData, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Must call super.build for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text("Hunter's Matrix"),
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
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
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
    return ListView.builder(
      itemCount: _cachedAlbumData?.length ?? 0,
      itemBuilder: (context, index) {
        final albumData = _cachedAlbumData![index];
        final albumName = albumData['album'] as String;
        final albumArt = albumData['albumArt'] as String;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              albumArt, // Use albumArt directly, assuming it's not null
              fit: BoxFit.cover,
              width: 60, // Set a consistent width for the album art
              height: 60, // Set a consistent height for the album art
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
                  tracks: albumData['songs'] as List<Track>,
                  albumArt: albumArt,
                  albumName: albumName,
                ),
              ),
            );
          },
          onLongPress: () =>
              handleAlbumTap(albumData, _handleDataLoaded, context, logger),
        );
      },
    );
  }
}
