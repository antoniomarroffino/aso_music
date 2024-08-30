import 'dart:async';
import 'package:aso_music/widgets/music_control_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'bio_artist.dart'; // Importa la pagina bio_artist.dart

class AlbumDetailPage extends StatefulWidget {
  final Map<String, dynamic> album;
  final String imageUrl;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.imageUrl,
  });

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  int _playedDuration = 0;
  bool _streamUpdated = false;
  late Future<List<Map<String, dynamic>>> _songsFuture;
  late Map<String, bool> _songsUpdatedMap;
  StreamSubscription<Duration>? _positionSubscription;
  String _currentSongTitle = '';
  String _currentSongUrl = '';
  String _currentSongDuration = ''; // Durata della canzone
  int _totalDuration = 0; // Durata totale in secondi

  @override
  void initState() {
    super.initState();
    _songsFuture = _fetchSongs();
    _songsUpdatedMap = {};
  }

  Future<List<Map<String, dynamic>>> _fetchSongs() async {
    final firestore = FirebaseFirestore.instance;
    final albumId = widget.album['id'] as String;

    final songSnapshot = await firestore
        .collection('album')
        .doc(albumId)
        .collection('songs')
        .get();

    final songs = await Future.wait(songSnapshot.docs.map((doc) async {
      final songData = doc.data() as Map<String, dynamic>;

      final title = songData['title'] as String?;
      final tracklistPosition = songData['tracklistPosition'] as int;
      final audioUrl = songData['audioURL'] as String;
      final streams = songData['stream'] as int? ?? 0; // Nome corretto
      final duration = songData['duration'] as String?; // Durata

      final artistRefs = songData['artist'] as List<dynamic>; // Nome corretto
      final artistNames = await _fetchArtistNames(artistRefs);

      return {
        'id': doc.id,
        'title': title ?? '',
        'tracklistPosition': tracklistPosition,
        'audioURL': audioUrl,
        'stream': streams, // Nome corretto
        'artist': artistNames, // Nome corretto
        'artistRefs': artistRefs,
        'duration': duration ?? '0:00', // Imposta durata predefinita
      };
    }).toList());

    songs.sort((a, b) => (a['tracklistPosition'] as int)
        .compareTo(b['tracklistPosition'] as int));

    return songs;
  }

  Future<List<Map<String, dynamic>>> _fetchArtistNames(
      List<dynamic> artistRefs) async {
    final firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> artistDetails = [];

    for (var ref in artistRefs) {
      final artistDoc = await (ref as DocumentReference).get();
      final artistData = artistDoc.data() as Map<String, dynamic>?;
      if (artistData != null) {
        artistDetails.add({
          'name': artistData['name'] as String,
          'id': artistDoc.id,
        });
      }
    }

    return artistDetails;
  }

  Future<String?> _getAudioUrl(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      final audioUrl = await ref.getDownloadURL();
      return audioUrl;
    } catch (e) {
      print('Errore nell\'ottenere l\'URL di download: $e');
      return null;
    }
  }

  void _playSong(String gsUrl, int index, String songId, String songTitle,
      String songDuration) async {
    try {
      setState(() {
        _currentlyPlayingIndex = index;
        _playedDuration = 0;
        _streamUpdated = false;
        _currentSongTitle = songTitle;
        _currentSongUrl = gsUrl;
        _currentSongDuration = songDuration;
        _totalDuration = _parseDuration(songDuration); // Calcola durata totale
      });

      String? audioUrl = await _getAudioUrl(gsUrl);

      if (audioUrl == null) {
        print('Errore: impossibile ottenere l\'URL del file audio.');
        return;
      }

      print('Playing URL: $audioUrl');

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));

      _positionSubscription?.cancel();

      _positionSubscription =
          _audioPlayer.onPositionChanged.listen((Duration p) async {
        setState(() {
          _playedDuration = p.inSeconds;
        });

        if (_playedDuration >= 30 && !_songsUpdatedMap.containsKey(songId)) {
          await _incrementStreamCount(songId);
          setState(() {
            _songsUpdatedMap[songId] = true;
          });
        }
      });
    } catch (e) {
      print('Errore nella riproduzione: $e');
    }
  }

  Future<void> _incrementStreamCount(String songId) async {
    final firestore = FirebaseFirestore.instance;
    final albumId = widget.album['id'] as String;

    final songRef = firestore
        .collection('album')
        .doc(albumId)
        .collection('songs')
        .doc(songId);

    await songRef.update({
      'stream': FieldValue.increment(1), // Nome corretto
    });

    print('Stream count incrementato per songId: $songId');
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 0; // Durata non valida
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album['name'] as String),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No songs found'));
          }

          final songs = snapshot.data!;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.album['name'] as String,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final title = song['title'] as String;
                    final tracklistPosition = song['tracklistPosition'] as int;
                    final audioUrl = song['audioURL'] as String;
                    final streams = song['stream'] as int; // Nome corretto
                    final artists = song['artist']
                        as List<Map<String, dynamic>>; // Nome corretto
                    final duration = song['duration'] as String; // Durata

                    final isPlaying = _currentlyPlayingIndex == index;

                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                            '$tracklistPosition. ',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              color: isPlaying ? Colors.orange : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$streams stream',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: artists.asMap().entries.map((entry) {
                                final artist = entry.value;
                                final isLastArtist =
                                    entry.key == artists.length - 1;

                                return TextSpan(
                                  text: (artist['name'] as String) +
                                      (isLastArtist ? '' : ', '),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BioArtistPage(
                                            artistId: artist['id'] as String,
                                          ),
                                        ),
                                      );
                                    },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  5), // Spazio tra il testo e il progress bar
                          LinearProgressIndicator(
                            value: _currentlyPlayingIndex == index
                                ? (_playedDuration / _totalDuration)
                                : 0,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ],
                      ),
                      onTap: () => _playSong(audioUrl, index,
                          song['id'] as String, title, duration),
                    );
                  },
                ),
              ),
              if (_currentlyPlayingIndex != null)
                MusicControlBar(
                  audioPlayer: _audioPlayer,
                  currentSongTitle: _currentSongTitle,
                  currentSongArtists: songs[_currentlyPlayingIndex ?? 0]
                          ['artist']
                      .map((artist) => artist['name'])
                      .join(', '),
                  currentSongDuration: _currentSongDuration, // Passa durata
                  playedDuration: _playedDuration, // Passa durata giocata
                  totalDuration: _totalDuration, // Passa durata totale
                ),
            ],
          );
        },
      ),
    );
  }
}
