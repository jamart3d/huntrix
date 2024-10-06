import 'package:flutter/material.dart';
import 'package:huntrix/providers/track_player_provider.dart';

class ProgressBar extends StatelessWidget {
  final TrackPlayerProvider provider;

  const ProgressBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 30.0,
      child: StreamBuilder<Duration?>(
        stream: provider.positionStream,
        builder: (context, positionSnapshot) {
          final position = positionSnapshot.data ?? Duration.zero;

          return StreamBuilder<Duration?>(
            stream: provider.durationStream,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;

              return Row(
                children: [
                  // Current position on the left
                  Text(
                    style: const TextStyle(
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          color: Colors.redAccent,
                          blurRadius: 3,
                        ),
                        Shadow(
                          color: Colors.redAccent,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    provider.formattedCurrentDuration,
                  ),

                  // Slider
                  Expanded(
                    child: Semantics(
                      label: 'Seek slider',
                      value:
                          '${provider.formattedCurrentDuration} of ${provider.formattedTotalDuration}',
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(),
                        child: Slider(
                          activeColor: Colors.yellow,
                          inactiveColor: const Color.fromARGB(116, 255, 235, 59),
                          thumbColor: Colors.yellow,                          
                          value: position.inSeconds.toDouble(),
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            provider.seekTo(Duration(seconds: value.toInt()));
                          },
                          label: provider.formattedCurrentDuration,
                        ),
                      ),
                    ),
                  ),
                  // Total duration on the right
                  Text(
                    style: const TextStyle(
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          color: Colors.redAccent,
                          blurRadius: 3,
                        ),
                        Shadow(
                          color: Colors.redAccent,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    provider.formattedTotalDuration,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
