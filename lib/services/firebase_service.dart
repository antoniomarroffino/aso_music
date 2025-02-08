import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  Stream<QuerySnapshot> getAlbumsStream() {
    return _firestore
        .collection('album')
        .orderBy('releaseYear',
            descending: true) // Ordina per anno in ordine decrescente
        .snapshots();
  }

  // Metodo per convertire gs:// URL in URL scaricabili
  Future<String> getDownloadURL(String gsUrl) async {
    try {
      String path = gsUrl.replaceFirst('gs://', '');
      int index = path.indexOf('/');
      String bucketName = path.substring(0, index);
      String objectPath = path.substring(index + 1);

      final ref = _storage.ref(objectPath);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting download URL: $e');
      throw Exception('Unable to get download URL');
    }
  }
}
