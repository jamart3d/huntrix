import 'package:flutter/material.dart';
import 'package:huntrix/pages/albums_list_wheel_page.dart';
import 'package:huntrix/pages/albums_page.dart';
import 'package:huntrix/pages/music_player_page.dart';
import 'package:huntrix/pages/track_playlist_page.dart';
import 'package:huntrix/providers/track_player_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  //   if (kReleaseMode) {
  //    CustomImageCache();
  // }
  runApp(const HunTrix());
}

class HunTrix extends StatelessWidget {
  const HunTrix({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Logger>(create: (_) => logger),
        ChangeNotifierProvider(
            create: (context) =>
                TrackPlayerProvider(logger: context.read<Logger>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'huntrex',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const AlbumsPage(),
        routes: {
          '/albums_page': (context) => const AlbumsPage(),
          '/music_player_page': (context) => const MusicPlayerPage(),
          '/song_playlist_page': (context) => const TrackPlaylistPage(),
          '/albums_list_wheel_page': (context) => const AlbumListWheelPage(),
        },
      ),
    );
  }
}

// class CustomImageCache extends WidgetsFlutterBinding {
//   @override
//   ImageCache createImageCache() {
//     ImageCache imageCache = super.createImageCache();
//     // Set your image cache size
//     imageCache.maximumSizeBytes = 1024 * 1024 * 400; // 100 MB
//     return imageCache;
//   }
// }