import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getSongUrl(String songId) async {
    return await _storage.ref('songs/$songId.wav').getDownloadURL();
  }
}
