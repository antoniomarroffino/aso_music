import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/song_model.dart';

class SongRepository {
  final CollectionReference _songsCollection =
      FirebaseFirestore.instance.collection('songs');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Song>> getSongsByAlbumId(String albumId) async {
    final QuerySnapshot snapshot =
        await _songsCollection.where('albumId', isEqualTo: albumId).get();

    final List<Song> songs = [];

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        songs.add(Song.fromJson(doc.data() as Map<String, dynamic>));
      }
    }
    return songs;
  }

  Future<String> getSongUrl(String songId) async {
    return await _storage.ref('songs/$songId.wav').getDownloadURL();
  }
}
