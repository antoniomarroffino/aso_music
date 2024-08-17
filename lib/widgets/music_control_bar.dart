import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicControlBar extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String currentSongTitle;
  final String currentSongArtists;
  final String currentSongDuration; // Nuovo parametro per la durata

  const MusicControlBar({
    Key? key,
    required this.audioPlayer,
    required this.currentSongTitle,
    required this.currentSongArtists,
    required this.currentSongDuration, // Nuovo parametro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.onPlayerStateChanged,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == PlayerState.playing;
        return Visibility(
          visible: currentSongTitle.isNotEmpty,
          child: Container(
            color: Colors.grey[900],
            height: 100, // Altezza modificata per includere durata
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mostra titolo traccia corrente
                    Expanded(
                      child: Text(
                        currentSongTitle,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer.pause();
                        } else {
                          audioPlayer.resume();
                        }
                      },
                    ),
                  ],
                ),
                Text(
                  currentSongArtists,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Duration: $currentSongDuration', // Mostra durata della canzone
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
