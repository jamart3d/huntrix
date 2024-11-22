import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Huntrix'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you Hunter! and The Grateful Dead!',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app lists, plays (with gapless playback) MP3 files from Archive.org and provides a way to select a random release from Hunter\'s Trix series of matrix\'s treatments of choice Grateful Dead shows..',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),   
            const Text(
              'I take no credit for the audio or album artwork.',
              style: TextStyle(color: Colors.yellow, fontSize: 16, shadows: [
                Shadow(
                  color: Colors.redAccent,
                  blurRadius: 3,
                ),
                Shadow(
                  color: Colors.redAccent,
                  blurRadius: 6,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app was developed as a training exercise and is for entertainment purposes only.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Text(
              'Built in Google IDX, with Dart/Flutter.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'All audio is streamed,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Row(
              children: [
                Text(
                  'except for album 105, which has an icon ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Icon(
                  Icons.album,
                  color: Colors.green,
                ),
              ],
            ),
            const Text(
              ' to indicate it\'s a local/cached album.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usage: \n? to play a random release\nLong press in list/wheel view to play release\nNormal press will only display songs in release',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Row(
              children: [
                Icon(
                  Icons.play_circle,
                  color: Colors.yellow,
                  shadows: [
                    Shadow(color: Colors.redAccent, blurRadius: 3),
                    Shadow(color: Colors.redAccent, blurRadius: 6),
                  ],
                ),
                Text(
                  ' will bring up music player controls',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Future features maybe..',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  Download/save selections for offline playback',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  Play random album at startup',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  Google Assistant integration',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  AA and TV integration',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16),
              ],
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: 'jamart3d@gmail.com'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Email address copied to clipboard')),
                );
              },
              child: const Text(
                'jamart3d@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _launchUrl('https://archive.org/donate/'),
              child: const Text(
                'Consider donating to The Internet Archive',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl(
                  'https://www.google.com/search?q=hunter+seamons+matrix'),
              child: const Text(
                'And if you are unfamiliar with Hunter\'s Trix',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Users are responsible for complying with copyright laws.  See:',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            InkWell(
              onTap: () => _launchUrl('https://archive.org/about/terms.php'),
              child: const Text(
                'Archive.org Terms of Use',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
