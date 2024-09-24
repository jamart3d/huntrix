import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  TextEditingController _searchQueryController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _searchQueryController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _copySearchQueryToClipboard() {
    final searchQuery = _searchQueryController.text.trim();
    if (searchQuery.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: searchQuery));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search query copied to clipboard')),
      );
    }
  }

  void _copyEmailToClipboard() {
    final emailAddress = _emailController.text.trim();
    if (emailAddress.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: emailAddress));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address copied to clipboard')),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you Hunter!',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'This app was developed as a training exercise, to list, and play/stream a random release from the Hunter\'s Trix Grateful Dead series.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'I take no credit for audio or album artwork.',
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
              'This app is for entertainment purposes only.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Built in google idx, dart/flutter.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'all audio is streamed from archive.org.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            const Text(
              'to indicate its a local/cached album',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you are unfamiliar with Hunter\'s Trix,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(const ClipboardData(
                    text: 'https://www.google.com/search?q=hunter+seamons+matrix'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
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
            const SizedBox(height: 16),
            const Text(
              'future features maybe..',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '  download/cache for offline playback',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Text(
                  '  play random album at startup',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Text(
                  '  google assistant integration',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 16),
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
                    style: TextStyle(fontSize: 10, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchQueryController,
                  decoration: const InputDecoration(
                    hintText: 'Enter search query',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _copySearchQueryToClipboard,
                  child: const Text('Copy Search Query'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _copyEmailToClipboard,
                  child: const Text('Copy Email Address'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
