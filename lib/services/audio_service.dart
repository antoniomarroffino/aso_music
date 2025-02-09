import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'firebase_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initStreams();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Song? _currentSong;

  // Getters
  AudioPlayer get player => _audioPlayer;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _audioPlayer.playing;

  void _initStreams() {
    // Inizializza gli stream una sola volta
    _audioPlayer.playerStateStream.listen((state) {
      // Gestisci i cambiamenti di stato se necessario
    });
  }

  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      final audioUrl = await FirebaseService().getDownloadURL(song.audioURL);
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing song: $e');
      rethrow;
    }
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.play();
  void stop() => _audioPlayer.stop();
}
