import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:huntrix/components/my_drawer.dart';
import 'package:huntrix/helpers/album_helper.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/pages/album_detail_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/utils/load_json_data.dart';
import 'package:logger/logger.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  late Logger logger;
  List<Map<String, dynamic>>? _cachedAlbumData;
  String? _currentAlbumArt; // To store current album art
  String? _currentAlbumName; // To store the name of the currently playing album

  @override
  void initState() {
    super.initState();
    _currentAlbumArt = 'assets/images/t_steal.webp'; // Default album art
  }

  @override
  void didChangeDependencies() {
    // Access Logger here
    super.didChangeDependencies();
    logger = context.read<Logger>();
    loadData(context, _handleDataLoaded); // Call the new function
  }

  void _handleDataLoaded(List<Map<String, dynamic>>? albumData) {
    setState(() {
      _cachedAlbumData = albumData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        // forceMaterialTransparency: true,
        // foregroundColor: Colors.black,
        // backgroundColor: Colors.transparent,
        // elevation: 0,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MusicPlayerPage()),
          );
        },
        backgroundColor: Colors.transparent,
        splashColor: Colors.white,
        enableFeedback: false,
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
        // final releaseNumber = albumData['releaseNumber'];
        // final releaseDate = albumData['releaseDate'];

        return SizedBox(
          // height: 200,
          child: ListTile(
            leading: SizedBox(
              // height: double.infinity,
              // width: 200,
              child: Image.asset(
                albumArt, // Use albumArt directly, assuming it's not null
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              //chop the date out of the album name
              albumName
                  .split('-')
                  .sublist(3)
                  .join('-')
                  .replaceAll(RegExp(r'^[^a-zA-Z0-9]'), ''),
              style: TextStyle(
                color: _currentAlbumName == albumName
                    ? Colors.yellow
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              //just the date out of the album name
              albumName.split('-').sublist(0, 3).join('-'),
              style: TextStyle(
                color: _currentAlbumName == albumName
                    ? Colors.yellow
                    : Colors.white,
              ),
            ),
            contentPadding: EdgeInsets.zero,
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
          ),
        );
      },
    );
  }
}