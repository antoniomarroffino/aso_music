import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/audio_service.dart'; // Aggiungi questo import
import '../utilities/constants.dart';
import '../views/artist_view.dart';
import '../widgets/music_player.dart';

class AlbumDetailView extends StatelessWidget {
  final Album album;

  const AlbumDetailView({
    super.key,
    required this.album,
  });

  Future<List<String>> _getArtistNames(
      List<DocumentReference> artistRefs) async {
    List<String> names = [];
    for (var ref in artistRefs) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header con copertina e info album
          SliverAppBar(
            backgroundColor: backgroundColor,
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                album.name,
                style: const TextStyle(color: primaryColor),
              ),
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Copertina Album
                  FutureBuilder<String>(
                    future: FirebaseService().getDownloadURL(album.coverURL),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Nome Artista
                  Text(
                    album.artist,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lista delle canzoni
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('album')
                .doc(album.id)
                .collection('songs')
                .orderBy('tracklistPosition')
                .snapshots(),
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

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                );
              }

              final songs = snapshot.data?.docs.map((doc) {
                    return Song.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList() ??
                  [];

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    return FutureBuilder<List<String>>(
                      future: _getArtistNames(song.artistRefs),
                      builder: (context, snapshot) {
                        final artistNames = snapshot.data ?? [];
                        return ListTile(
                          leading: Text(
                            '${song.tracklistPosition}',
                            style: const TextStyle(color: primaryColor),
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(color: primaryColor),
                          ),
                          subtitle: Wrap(
                            children: List.generate(
                              artistNames.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistView(
                                        artistId: song.artistRefs[index].id,
                                        artistName: artistNames[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index < artistNames.length - 1
                                        ? 8.0
                                        : 0,
                                  ),
                                  child: Text(
                                    index < artistNames.length - 1
                                        ? '${artistNames[index]}, '
                                        : artistNames[index],
                                    style: TextStyle(
                                      color: primaryColor.withOpacity(0.7),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          trailing: Text(
                            song.duration,
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
                    );
                  },
                  childCount: songs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
