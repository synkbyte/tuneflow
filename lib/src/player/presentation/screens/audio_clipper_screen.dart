import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/mini_player.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/support/presentation/screens/support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';

class AudioClipperScreen extends StatefulWidget {
  const AudioClipperScreen({super.key});

  @override
  State<AudioClipperScreen> createState() => _AudioClipperScreenState();
}

class _AudioClipperScreenState extends State<AudioClipperScreen> {
  late double startTime;
  late double endTime;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (playerProvider.isLooping) {
      startTime = audioHandler.clipStart?.inSeconds.toDouble() ?? 0;
      endTime = audioHandler.clipEnd?.inSeconds.toDouble() ?? 0;
    } else {
      startTime = 0;
      endTime = playerProvider.totalDuration.inSeconds.toDouble();
    }
  }

  String formatDuration(double seconds) {
    int mins = (seconds ~/ 60);
    int secs = (seconds % 60).toInt();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final duration = playerProvider.totalDuration.inSeconds.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duration Loop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select Loop Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            RangeSlider(
              values: RangeValues(startTime, endTime),
              max: duration,
              divisions: duration.toInt(),
              labels: RangeLabels(
                formatDuration(startTime),
                formatDuration(endTime),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  startTime = values.start;
                  endTime = values.end;
                });
              },
            ),
            Text(
              'Selected Duration: ${formatDuration(endTime - startTime)}',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (!playerProvider.isLooping)
              PrimaryButton(
                title: audioPlayer.playing ? 'Stop' : 'Test Duration Loop',
                onPressed: () async {
                  if (audioPlayer.playing) {
                    audioPlayer.stop();
                    playerProvider.togglePlayer();
                  } else {
                    playerProvider.togglePlayer();
                    await audioPlayer.setAudioSource(
                      ClippingAudioSource(
                        child: AudioSource.uri(
                          Uri.parse(
                            playerProvider.nowPlaying!.playUrl.excellent,
                          ),
                        ),
                        start: Duration(seconds: startTime.toInt()),
                        end: Duration(seconds: endTime.toInt()),
                      ),
                    );
                    await audioPlayer.play();
                    playerProvider.togglePlayer();
                  }
                },
              ),
            if (!playerProvider.isLooping) const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Loop Selected Duration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              value: playerProvider.isLooping,
              onChanged: (value) {
                setState(() {
                  playerProvider.isLooping = value;
                });
                if (value) {
                  audioHandler.setClipping(
                    Duration(seconds: startTime.toInt()),
                    Duration(seconds: endTime.toInt()),
                  );
                } else {
                  audioHandler.removeClipping();
                }
              },
            ),
            SizedBox(height: 10),
            Column(
              children: [
                Text(
                  'This is a beta feature and we\'re actively working to improve it. Your feedback helps us make it better!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.onBgColor.withValues(alpha: .8),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const SupportScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                  child: Text(
                    'Report Issues or Suggest Improvements',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}
