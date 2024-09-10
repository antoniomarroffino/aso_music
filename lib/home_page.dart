import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'album_detail_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Future<List<Map<String, dynamic>>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = _fetchAlbums();
  }

  Future<List<Map<String, dynamic>>> _fetchAlbums() async {
    final snapshot = await _firestore.collection('album').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data(),
              'id': doc.id, // Aggiungi l'ID del documento ai dati dell'album
            })
        .toList();
  }

  Future<String> _getImageUrl(String coverURL) async {
    try {
      final ref = _storage.refFromURL(coverURL);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _albumsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No albums found'));
          }

          final albums = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              final coverURL = album['coverURL'] as String;

              return FutureBuilder<String>(
                future: _getImageUrl(coverURL),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (imageSnapshot.hasError) {
                    return Center(child: Text('Error: ${imageSnapshot.error}'));
                  }

                  if (!imageSnapshot.hasData || imageSnapshot.data!.isEmpty) {
                    return const Center(child: Text('Image not found'));
                  }

                  final imageUrl = imageSnapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumDetailPage(
                            album: album,
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              album['name'] as String,
                              style: Theme.of(context).textTheme.subtitle1,
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              album['artist'] as String,
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
