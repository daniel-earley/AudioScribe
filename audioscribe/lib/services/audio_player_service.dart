import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration position = Duration.zero;

  AudioManager() {
    _audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
    });
  }

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

  void forward() async {
    position += Duration(seconds: 15);
    await _audioPlayer.seek(position);
  }

  void reverse() async {
    var newPos = position - Duration(seconds: 15);
    if (newPos < Duration.zero) {
      newPos = Duration.zero;
    }
    position = newPos;
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
