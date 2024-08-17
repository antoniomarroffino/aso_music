import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../music_player_controller.dart';

class MusicControlBar extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String? currentSongTitle;
  final String? currentSongUrl;

  const MusicControlBar({
    super.key,
    required this.audioPlayer,
    this.currentSongTitle,
    this.currentSongUrl,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.onPlayerStateChanged,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == PlayerState.playing;

        return Visibility(
          visible: currentSongUrl != null,
          child: Container(
            color: Colors.grey[900],
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mostra il titolo della traccia corrente
                Text(
                  currentSongTitle ?? 'No track playing',
                  style: const TextStyle(color: Colors.white),
                ),
                // Pulsante Play/Pause
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (currentSongUrl != null) {
                      if (isPlaying) {
                        audioPlayer.pause();
                      } else {
                        audioPlayer.play(UrlSource(currentSongUrl!));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
