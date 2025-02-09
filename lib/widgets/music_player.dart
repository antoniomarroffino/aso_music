import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../utilities/constants.dart';

class MusicPlayer extends StatefulWidget {
  final Song song;
  final VoidCallback? onClose;

  const MusicPlayer({
    Key? key,
    required this.song,
    this.onClose,
  }) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _initAudioPlayer() async {
    try {
      final audioUrl =
          await FirebaseService().getDownloadURL(widget.song.audioURL);
      await _audioPlayer.setUrl(audioUrl);
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<String> _getCoverUrl(String gsUrl) async {
    if (gsUrl.startsWith("gs://")) {
      final storageRef = FirebaseStorage.instance.refFromURL(gsUrl);
      return await storageRef.getDownloadURL();
    }
    return gsUrl;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -20) {
          setState(() => _isExpanded = true);
        } else if (details.primaryDelta! > 20) {
          setState(() => _isExpanded = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isExpanded ? MediaQuery.of(context).size.height : 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: _isExpanded
              ? BorderRadius.zero
              : const BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedPlayer() : _buildMiniPlayer(),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.song.title,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              FutureBuilder<List<String>>(
                future: _getArtistNames(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data?.join(', ') ?? '',
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: primaryColor,
            size: 40,
          ),
          onPressed: () {
            if (_isPlaying) {
              _audioPlayer.pause();
            } else {
              _audioPlayer.play();
            }
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildExpandedPlayer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App bar personalizzata con solo il bottone di chiusura
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: primaryColor, size: 32),
                    onPressed: () => setState(() => _isExpanded = false),
                  ),
                ],
              ),
            ),

            // Copertina
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: FutureBuilder<String>(
                  future: _getCoverUrl(widget.song.coverURL),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.music_note,
                                color: primaryColor,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Informazioni canzone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<String>>(
                    future: _getArtistNames(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data?.join(', ') ?? '',
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.7),
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Slider e durata
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: primaryColor.withOpacity(0.3),
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.3),
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(color: primaryColor),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Controlli di riproduzione
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: primaryColor,
                      size: 64,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getArtistNames() async {
    List<String> names = [];
    for (var ref in widget.song.artistRefs) {
      try {
        DocumentSnapshot artistDoc = await ref.get();
        if (artistDoc.exists) {
          Map<String, dynamic> data = artistDoc.data() as Map<String, dynamic>;
          names.add(data['name'] ?? 'Unknown Artist');
        }
      } catch (e) {
        print('Error fetching artist: $e');
      }
    }
    return names;
  }
}
