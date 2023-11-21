import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  final AudioPlayer _audioPlayer;

  AudioManager() : _audioPlayer = AudioPlayer();

  void setSource(String url) async {
    await _audioPlayer.setSource(UrlSource(url));
  }

  void play() async {
    await _audioPlayer.resume();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
