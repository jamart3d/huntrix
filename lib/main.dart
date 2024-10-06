import 'package:flutter/material.dart';
import 'package:huntrix/pages/albums_list_wheel_page.dart';
import 'package:huntrix/pages/albums_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/pages/track_playlist_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:huntrix/pages/albums_grid_page.dart'; 
import 'package:huntrix/providers/album_settings_provider.dart';

Future<void> main() async {
  CustomImageCache();
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    // androidNotificationIcon: "mimmap/lc_launcher",
    preloadArtwork: true,
  );
  runApp(const HunTrix());
}

class HunTrix extends StatelessWidget {
  const HunTrix({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TrackPlayerProvider(),

        ),
        ChangeNotifierProvider(
          create: (context) => AlbumSettingsProvider(),
          
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Huntrex',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const AlbumsPage(),
        initialRoute: '/albums_page',
        routes: {
          '/albums_page': (context) => const AlbumsPage(),
          '/music_player_page': (context) => const MusicPlayerPage(),
          '/song_playlist_page': (context) => const TrackPlaylistPage(),
          '/albums_list_wheel_page': (context) => const AlbumListWheelPage(),
          '/albums_grid_page': (context) => const AlbumsGridPage(),
        },
      ),
    );
  }
}

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    // image cache size bump to 400MB
    imageCache.maximumSizeBytes = 1024 * 1024 * 400; // 100 MB
    return imageCache;
  }
}