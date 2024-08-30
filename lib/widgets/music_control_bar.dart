import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicControlBar extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String currentSongTitle;
  final String currentSongArtists;
  final String currentSongDuration;
  final int playedDuration;
  final int totalDuration; // Durata totale in secondi

  const MusicControlBar({
    Key? key,
    required this.audioPlayer,
    required this.currentSongTitle,
    required this.currentSongArtists,
    required this.currentSongDuration,
    required this.playedDuration,
    required this.totalDuration, // Passa durata totale
  }) : super(key: key);

  @override
  _MusicControlBarState createState() => _MusicControlBarState();
}

class _MusicControlBarState extends State<MusicControlBar> {
  double _dragPosition = 0.0; // Posizione del pallino in percentuale
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Calcola la progressione e gestisci i casi in cui totalDuration è zero o meno
    final progress = widget.totalDuration > 0
        ? (widget.playedDuration / widget.totalDuration).clamp(0.0, 1.0)
        : 0.0;

    // Calcola la posizione del pallino
    final double progressWidth =
        MediaQuery.of(context).size.width - 32.0; // 16.0 padding su ogni lato
    final double ballPosition = progressWidth * progress;

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Padding aggiuntivo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.currentSongTitle,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.audioPlayer.state == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (widget.audioPlayer.state == PlayerState.playing) {
                    widget.audioPlayer.pause();
                  } else {
                    widget.audioPlayer.resume();
                  }
                },
              ),
            ],
          ),
          Text(
            widget.currentSongArtists,
            style: const TextStyle(color: Colors.white70),
          ),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _isDragging = true;
                          _dragPosition =
                              (details.localPosition.dx / progressWidth)
                                  .clamp(0.0, 1.0);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        setState(() {
                          _isDragging = false;
                          final newPosition =
                              (_dragPosition * widget.totalDuration).toInt();
                          widget.audioPlayer
                              .seek(Duration(seconds: newPosition));
                        });
                      },
                      child: Container(
                        height: 4, // Altezza sottile della barra
                        width: progressWidth,
                        color: Colors.grey[700],
                      ),
                    ),
                    Positioned(
                      left: _isDragging
                          ? _dragPosition * progressWidth
                          : ballPosition,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Durata della canzone posizionata a destra
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Spazio tra la barra e la durata
                child: Text(
                  widget.currentSongDuration,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
