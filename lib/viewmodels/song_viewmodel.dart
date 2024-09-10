import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../repositories/song_repository.dart';

class SongViewModel extends ChangeNotifier {
  List<Song> songs = [];
  final SongRepository _songRepository = SongRepository();

  Future<void> fetchSongs(String albumId) async {
    songs = await _songRepository.getSongsByAlbumId(albumId);
    notifyListeners();
  }

  Future<String> getSongUrl(String songId) async {
    return await _songRepository.getSongUrl(songId);
  }
}
