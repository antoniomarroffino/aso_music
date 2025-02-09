import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../services/firebase_service.dart';
import '../utilities/constants.dart';
import '../views/album_detail_view.dart';
import '../widgets/music_player.dart';
import '../services/audio_service.dart';

class ArtistView extends StatelessWidget {
  final String artistId;
  final String artistName;

  const ArtistView({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header con foto profilo e info artista
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('artists')
                .doc(artistId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Errore: ${snapshot.error}',
                        style: const TextStyle(color: primaryColor)),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                );
              }

              final artistData = snapshot.data!.data() as Map<String, dynamic>;
              final artist = Artist.fromMap(artistData, artistId);

              return SliverAppBar(
                backgroundColor: backgroundColor,
                expandedHeight: 300,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    artist.name,
                    style: const TextStyle(color: primaryColor),
                  ),
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: primaryColor,
                        child: artist.profileURL.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  artist.profileURL,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: backgroundColor,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 80,
                                color: backgroundColor,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          artist.bio,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Titolo sezione "Brani più popolari"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Brani più popolari',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Lista delle canzoni più popolari
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('album').snapshots(),
            builder: (context, albumSnapshot) {
              if (albumSnapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Errore: ${albumSnapshot.error}',
                      style: const TextStyle(color: primaryColor),
                    ),
                  ),
                );
              }

              if (!albumSnapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                );
              }

              return FutureBuilder<List<Song>>(
                future:
                    Future.wait(albumSnapshot.data!.docs.map((albumDoc) async {
                  QuerySnapshot songsSnapshot = await FirebaseFirestore.instance
                      .collection('album')
                      .doc(albumDoc.id)
                      .collection('songs')
                      .get();

                  return songsSnapshot.docs
                      .map((doc) => Song.fromMap(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .where((song) =>
                          song.artistRefs.any((ref) => ref.id == artistId))
                      .toList();
                })).then((lists) {
                  List<Song> allSongs = lists.expand((list) => list).toList();
                  allSongs.sort((a, b) => b.stream.compareTo(a.stream));
                  return allSongs.take(5).toList();
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Errore nel caricamento delle canzoni: ${snapshot.error}',
                          style: const TextStyle(color: primaryColor),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    );
                  }

                  final topSongs = snapshot.data!;

                  if (topSongs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Nessun brano disponibile',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = topSongs[index];
                        return ListTile(
                          leading: Text(
                            '${index + 1}',
                            style: const TextStyle(color: primaryColor),
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(color: primaryColor),
                          ),
                          trailing: Text(
                            '${song.stream} ascolti',
                            style: const TextStyle(color: primaryColor),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => MusicPlayer(song: song),
                            );
                          },
                        );
                      },
                      childCount: topSongs.length,
                    ),
                  );
                },
              );
            },
          ),
          // Titolo sezione "Album"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Album',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Lista degli album (scroll orizzontale)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('album').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Errore: ${snapshot.error}',
                      style: const TextStyle(color: primaryColor),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                );
              }

              return FutureBuilder<List<Album>>(
                future: Future.wait(snapshot.data!.docs.map((albumDoc) async {
                  QuerySnapshot songsSnapshot = await FirebaseFirestore.instance
                      .collection('album')
                      .doc(albumDoc.id)
                      .collection('songs')
                      .get();

                  bool artistAppearsInAlbum = songsSnapshot.docs.any((songDoc) {
                    List<DocumentReference> artistRefs =
                        List<DocumentReference>.from(
                            songDoc.get('artist') as List);
                    return artistRefs.any((ref) => ref.id == artistId);
                  });

                  if (artistAppearsInAlbum) {
                    return Album.fromMap(
                        albumDoc.data() as Map<String, dynamic>, albumDoc.id);
                  }
                  return null;
                })).then((albums) {
                  return albums
                      .where((album) => album != null)
                      .cast<Album>()
                      .toList()
                    ..sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Errore nel caricamento degli album: ${snapshot.error}',
                          style: const TextStyle(color: primaryColor),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    );
                  }

                  final albums = snapshot.data!;

                  if (albums.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Nessun album disponibile',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220, // Altezza fissa per la riga degli album
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        scrollDirection: Axis.horizontal, // Scroll orizzontale
                        itemCount: albums.length,
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 160, // Larghezza fissa per ogni album
                              child: FutureBuilder<String>(
                                future: FirebaseService()
                                    .getDownloadURL(album.coverURL),
                                builder: (context, snapshot) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AlbumDetailView(album: album),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.black87,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          AspectRatio(
                                            aspectRatio:
                                                1, // Mantiene l'immagine quadrata
                                            child: snapshot.hasData
                                                ? Image.network(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              primaryColor),
                                                    ),
                                                  ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              album.name,
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
