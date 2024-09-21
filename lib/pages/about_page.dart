import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Huntrix'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
              'I take no credit for the artwork or the audio.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
               Row(
                 children: [
                   Text(
                                 'except for album 105, which has an ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                               ),
                Icon(
                  Icons.album,
                  color: Colors.green,
                ),
                               Text(
                                 ',',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                               ),
                 ],
               ),
            Text(
              'all audio is streamed from archive.org.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'If you are unfamiliar with Hunter\'s Trix,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text('google "hunter seamons matrix".',
            style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 16),
             Text(
              'planed features...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  download for offline playback,',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  auto random album play at startup,',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  google assitant intergartation',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  more to come...',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                      SizedBox(height: 16),
                Text(
                  'jamart3d@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
