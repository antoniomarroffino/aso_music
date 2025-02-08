import '../repositories/album_repository.dart';
import '../models/album.dart';

class AlbumController {
  final AlbumRepository _albumRepository = AlbumRepository();

  Stream<List<Album>> getAlbums() {
    return _albumRepository.getAlbums();
  }
}
