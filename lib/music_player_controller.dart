import 'package:audioplayers/audioplayers.dart';

class MusicPlayerController {
  static final AudioPlayer audioPlayer = AudioPlayer();
  static String? currentSongUrl;
  static String? currentSongTitle;

  static Future<void> play(String url, {String? title}) async {
    currentSongUrl = url;
    currentSongTitle = title;
    await audioPlayer.play(UrlSource(url));
  }

  static Future<void> pause() async {
    await audioPlayer.pause();
  }

  static Future<void> stop() async {
    await audioPlayer.stop();
    currentSongUrl = null;
    currentSongTitle = null;
  }
}
