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
              'I take no credit for artwork nor audio.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
               Text(
              'all audio is streamed from archive.org.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
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
                  //              Text(
                  //                ',',
                  // style: TextStyle(fontSize: 16, color: Colors.white),
                  //              ),
                 ],
               ),
               Text('to indicate its a local/cached album',
                style: TextStyle(fontSize: 16, color: Colors.white),
                ),

            SizedBox(height: 16),
            Text(
              'If you are unfamiliar with Hunter\'s Trix,',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text('google "hunter seamons matrix"',
            style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 16),
             Text(
              'future features maybe..',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  download/cache audio for offline playback',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  play random album at startup',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '  google assitant intergratation',
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
