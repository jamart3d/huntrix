import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void dispose() {
    super.dispose();
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
              'Thank you Hunter!, and Grateful Dead..',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'this app lists, plays/streams, with gapless of playback mp3 files from archive.org,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 2),
            const Text('and provides a way to select a random release from Hunter\'s Trix series of matrix\'s recordings of select Grateful Dead shows.',
            style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('169 releases and counting!',
            style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'i take no credit for audio or album artwork.',
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
            const SizedBox(height: 8),
            const Text(
              'this app was developed as a training exercise, and is for entertainment purposes only.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Text(
              'built in google idx, with dart/flutter.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'all audio is streamed from archive.org.',
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
              'to indicate its a local/cached album',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you are unfamiliar with Hunter\'s Trix,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: 'hunter+seamons+matrix'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text copied to clipboard')),
                );
              },
              child: const Text(
                'google "hunter seamons matrix"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Usage: \n? to play a random release\nlong press in list/wheel view to play release\nnormal press will only display songs in release',
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
                  // size: 20,
                ),
                Text(
                  ' will bring up music player controls',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),


            const SizedBox(height: 16),
            const Text(
              'future features maybe..',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  download/save cache for offline playback',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  play random album at startup',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  google assistant integration',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                    Text(
                  '  aa and tv integration',
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
                  fontSize: 12,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Content accessed through this app is sourced from the Internet Archive (Archive.org)Users are solely responsible for verifying the copyright status of any content and must ensure their use complies with applicable copyright laws and fair use guidelines. Please refer to the individual item page on Archive.org for any available license information.',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


