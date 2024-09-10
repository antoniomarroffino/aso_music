import 'package:firebase_database/firebase_database.dart';
import '../models/album_model.dart';

class AlbumRepository {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('albums');

  Future<List<Album>> getAllAlbums() async {
    final snapshot = await _databaseReference.once();
    final List<Album> albums = [];

    // Controllo se il valore non è nullo
    if (snapshot.value != null) {
      Map data = snapshot.value as Map;
      data.forEach((key, value) {
        albums.add(Album.fromJson(value));
      });
    }
    return albums;
  }
}
