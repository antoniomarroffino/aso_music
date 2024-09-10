import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/song_model.dart';

class SongRepository {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('songs');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Song>> getSongsByAlbumId(String albumId) async {
    final snapshot = await _databaseReference
        .orderByChild('albumId')
        .equalTo(albumId)
        .once();
    final List<Song> songs = [];

    if (snapshot.value != null) {
      Map data = snapshot.value as Map;
      data.forEach((key, value) {
        songs.add(Song.fromJson(value));
      });
    }
    return songs;
  }

  Future<String> getSongUrl(String songId) async {
    return await _storage.ref('songs/$songId.wav').getDownloadURL();
  }
}
