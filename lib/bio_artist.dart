import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BioArtistPage extends StatefulWidget {
  final String artistId;

  const BioArtistPage({super.key, required this.artistId});

  @override
  _BioArtistPageState createState() => _BioArtistPageState();
}

class _BioArtistPageState extends State<BioArtistPage> {
  // Stato per tenere traccia del numero di canzoni visualizzate
  int _displayedSongsCount = 5;

  Future<Map<String, dynamic>?> _fetchArtistData() async {
    final firestore = FirebaseFirestore.instance;
    final artistDoc =
        await firestore.collection('artists').doc(widget.artistId).get();
    return artistDoc.data();
  }

  Future<String?> _getProfileImageUrl(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      final profileUrl = await ref.getDownloadURL();
      return profileUrl;
    } catch (e) {
      print('Errore nell\'ottenere l\'URL di download: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTopSongs() async {
    final firestore = FirebaseFirestore.instance;
    final albums = await firestore.collection('album').get();
    final topSongs = <Map<String, dynamic>>[];

    for (var album in albums.docs) {
      final songs = await album.reference.collection('songs').get();
      for (var song in songs.docs) {
        final songData = song.data();
        final List<dynamic> artists = songData['artist'];

        // Controlla se uno degli artisti è lo stesso dell'artista corrente
        bool isArtistInSong = artists.any((artistRef) {
          if (artistRef is DocumentReference) {
            return artistRef.id == widget.artistId;
          }
          return false;
        });

        if (isArtistInSong) {
          topSongs.add(songData);
        }
      }
    }

    // Ordina le canzoni per numero di ascolti
    topSongs.sort((a, b) => (b['stream'] as int).compareTo(a['stream'] as int));
    return topSongs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Bio'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchArtistData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Artist not found'));
          }

          final artistData = snapshot.data!;
          final artistName = artistData['name'] as String;
          final artistDescription = artistData['bio'] as String?;
          final profileUrl = artistData['profileURL'] as String?;

          return FutureBuilder<String?>(
            future: profileUrl != null ? _getProfileImageUrl(profileUrl) : null,
            builder: (context, profileSnapshot) {
              Widget profileImage;

              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                profileImage = const CircularProgressIndicator();
              } else if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                profileImage = ClipOval(
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                final imageUrl = profileSnapshot.data!;
                profileImage = ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    profileImage,
                    const SizedBox(height: 16),
                    Text(
                      artistName,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    if (artistDescription != null &&
                        artistDescription.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8),
                        child: Text(
                          artistDescription,
                          style:
                              Theme.of(context).textTheme.bodyText2?.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 32),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 40,
                      endIndent: 40,
                    ),
                    // Sezione dei pezzi più ascoltati
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchTopSongs(),
                      builder: (context, songsSnapshot) {
                        if (songsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (songsSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${songsSnapshot.error}'));
                        }

                        final topSongs = songsSnapshot.data ?? [];

                        if (topSongs.isEmpty) {
                          return const Center(
                              child: Text('No top songs available'));
                        }

                        final displayedSongs =
                            topSongs.take(_displayedSongsCount).toList();

                        return Column(
                          children: [
                            ...displayedSongs.map((song) {
                              return ListTile(
                                title: Text(song['title']),
                                subtitle: Text('Streams: ${song['stream']}'),
                              );
                            }).toList(),
                            if (_displayedSongsCount < topSongs.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _displayedSongsCount += 5;
                                  });
                                },
                                child: const Text('Estendi'),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
