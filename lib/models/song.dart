import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final List<DocumentReference>
      artistRefs; // Cambiato da List<String> a List<DocumentReference>
  final String audioURL;
  final String coverURL;
  final String duration;
  final int stream;
  final String title;
  final int tracklistPosition;
  List<String> artistNames = []; // Lista per memorizzare i nomi degli artisti

  Song({
    required this.id,
    required this.artistRefs,
    required this.audioURL,
    required this.coverURL,
    required this.duration,
    required this.stream,
    required this.title,
    required this.tracklistPosition,
  });

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      artistRefs: (map['artist'] as List?)
              ?.map((ref) => ref as DocumentReference)
              .toList() ??
          [],
      audioURL: map['audioURL'] ?? '',
      coverURL: map['coverURL'] ?? '',
      duration: map['duration'] ?? '',
      stream: map['stream'] ?? 0,
      title: map['title'] ?? '',
      tracklistPosition: map['tracklistPosition'] ?? 0,
    );
  }
}
