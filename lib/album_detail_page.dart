import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'bio_artist.dart'; // Importa la pagina bio_artist.dart

class AlbumDetailPage extends StatelessWidget {
  final Map<String, dynamic> album;
  final String imageUrl;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.imageUrl,
  });

  Future<List<Map<String, dynamic>>> _fetchSongs() async {
    final firestore = FirebaseFirestore.instance;
    final albumId = album['id'] as String;

    final songSnapshot = await firestore
        .collection('album')
        .doc(albumId)
        .collection('songs')
        .get();

    final songs = await Future.wait(songSnapshot.docs.map((doc) async {
      final songData = doc.data();

      final title = songData['title'] as String?;
      final tracklistPosition = songData['tracklistPosition'] as int; // Aggiungi la posizione nella tracklist

      final artistRefs = songData['artists'] as List<dynamic>;
      final artistNames = await _fetchArtistNames(artistRefs);

      return {
        'title': title ?? '',
        'tracklistPosition': tracklistPosition, // Salva la posizione nella tracklist
        'artists': artistNames,
        'artistRefs': artistRefs,
      };
    }).toList());

    // Ordina le canzoni in base alla posizione nella tracklist
    songs.sort((a, b) => (a['tracklistPosition'] as int).compareTo(b['tracklistPosition'] as int));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album['name'] as String),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No songs found'));
          }

          final songs = snapshot.data!;
          return Column(
            children: [
              const SizedBox(height: 50.0),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                album['name'] as String,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (context, index) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final title = song['title'] as String;
                    final tracklistPosition = song['tracklistPosition'] as int;
                    final artists =
                    song['artists'] as List<Map<String, dynamic>>;

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
                          Text(title),
                        ],
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          children: artists.asMap().entries.map((entry) {
                            final artist = entry.value;
                            final isLastArtist =
                                entry.key == artists.length - 1;

                            return TextSpan(
                              text: artist['name'] as String +
                                  (isLastArtist ? '' : ', '),
                              style: const TextStyle(
                                color: Colors.black, // Colore nero
                                decoration: TextDecoration.none, // Nessuna sottolineatura
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
