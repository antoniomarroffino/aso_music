import '../models/album.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbumRepository {
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<Album>> getAlbums() {
    return _firebaseService.getAlbumsStream().map((snapshot) {
      try {
        List<Album> albums = snapshot.docs.map((doc) {
          print('Document data: ${doc.data()}');
          return Album.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Ordina gli album per anno in ordine decrescente
        albums.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));

        return albums;
      } catch (e) {
        print('Error in getAlbums: $e');
        rethrow;
      }
    });
  }
}
