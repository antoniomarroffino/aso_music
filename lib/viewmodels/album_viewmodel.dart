import 'package:flutter/material.dart';
import '../models/album_model.dart';
import '../repositories/album_repository.dart';

class AlbumViewModel extends ChangeNotifier {
  List<Album> albums = [];
  final AlbumRepository _albumRepository = AlbumRepository();

  Future<void> fetchAlbums() async {
    albums = await _albumRepository.getAllAlbums();
    notifyListeners(); // Notifica la UI che i dati sono cambiati
  }
}
