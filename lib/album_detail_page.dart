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
  int _playedDuration = 0; // Tempo in secondi già riprodotto della traccia
  bool _streamUpdated =
      false; // Indica se il contatore di streams è stato aggiornato
  String? _currentSongTitle;
  String? _currentSongUrl;
  late Future<List<Map<String, dynamic>>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture =
        _fetchSongs(); // Inizializza il Future per il caricamento delle canzoni
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
      final audioUrl = songData['audioURL'] as String; // Aggiungi l'audio URL
      final streams =
          songData['streams'] as int? ?? 0; // Aggiungi il numero di streams

      final artistRefs = songData['artists'] as List<dynamic>;
      final artistNames = await _fetchArtistNames(artistRefs);

      return {
        'id': doc.id, // ID del documento della canzone
        'title': title ?? '',
        'tracklistPosition': tracklistPosition,
        'audioURL': audioUrl, // Salva l'audio URL
        'streams': streams, // Salva il numero di streams
        'artists': artistNames,
        'artistRefs': artistRefs,
      };
    }).toList());

    // Ordina le canzoni in base alla posizione nella tracklist
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
          'id': artistDoc.id, // Include l'ID del documento
        });
      }
    }

    return artistDetails;
  }

  Future<String?> _getAudioUrl(String gsUrl) async {
    try {
      // Estrai il path dal link gs://
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);

      // Ottieni l'URL di download
      final audioUrl = await ref.getDownloadURL();
      return audioUrl;
    } catch (e) {
      print('Errore nell\'ottenere l\'URL di download: $e');
      return null;
    }
  }

  void _playSong(
      String gsUrl, int index, String songId, String songTitle) async {
    try {
      // Cambia lo stato dell'elemento attualmente riprodotto
      setState(() {
        _currentlyPlayingIndex = index;
        _playedDuration = 0;
        _streamUpdated = false;
        _currentSongTitle = songTitle;
        _currentSongUrl = gsUrl;
      });

      // Converte l'URL gs:// in un URL HTTPS
      String? audioUrl = await _getAudioUrl(gsUrl);

      if (audioUrl == null) {
        print('Errore: impossibile ottenere l\'URL del file audio.');
        return;
      }

      // Log dell'URL per il debug
      print('Playing URL: $audioUrl');

      // Ferma l'audio precedente, se c'è
      await _audioPlayer.stop();

      // Riproduci la nuova traccia
      await _audioPlayer.play(UrlSource(audioUrl));

      // Ascolta il progresso della riproduzione
      _audioPlayer.onPositionChanged.listen((Duration p) async {
        setState(() {
          _playedDuration = p.inSeconds;
        });

        // Se la canzone è stata riprodotta per almeno 30 secondi, aggiorna il contatore di streams
        if (_playedDuration >= 30 && !_streamUpdated) {
          await _incrementStreamCount(songId);
          setState(() {
            _streamUpdated = true; // Evita di incrementare più volte
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
      'streams': FieldValue.increment(1),
    });

    print('Stream count incrementato per songId: $songId');
  }

  @override
  void dispose() {
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
            // Mostra un indicatore di caricamento solo per il caricamento dei dati
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
              // Mostra la copertura dell'album e il nome nella parte superiore
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
                    const SizedBox(height: 16.0),
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
                    final streams = song['streams'] as int;
                    final artists =
                        song['artists'] as List<Map<String, dynamic>>;

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
                            '$streams streams',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: RichText(
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
                      onTap: () => _playSong(
                          audioUrl, index, song['id'] as String, title),
                    );
                  },
                ),
              ),
              // Barra di controllo della musica in fondo alla pagina
              MusicControlBar(
                audioPlayer: _audioPlayer,
                currentSongTitle: _currentSongTitle,
                currentSongUrl: _currentSongUrl,
              ),
            ],
          );
        },
      ),
    );
  }
}
