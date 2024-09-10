import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album_model.dart';

class AlbumRepository {
  final CollectionReference _albumsCollection =
      FirebaseFirestore.instance.collection('albums');

  Future<List<Album>> getAllAlbums() async {
    final QuerySnapshot snapshot = await _albumsCollection.get();
    final List<Album> albums = [];

    // Controllo se ci sono documenti
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        albums.add(Album.fromJson(doc.data() as Map<String, dynamic>));
      }
    }

    return albums;
  }
}
