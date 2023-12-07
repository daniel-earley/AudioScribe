import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

enum PlayerState { playing, paused, stopped, completed }

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  PlayerState? _playerState;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playerStateController = StreamController<PlayerState>.broadcast();

  Stream<Duration> get onPositionChanged => _positionController.stream;
  Stream<Duration> get onDurationChanged => _durationController.stream;
  Stream<PlayerState> get onPlayerComplete => _playerStateController.stream;

  AudioManager() {
    _audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
      _positionController.sink.add(newPosition);
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      _durationController.sink.add(newDuration);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      _playerState = PlayerState.completed; // Set state to completed
      _playerStateController.sink.add(_playerState!); // Notify listeners
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
    position += const Duration(seconds: 15);
    await _audioPlayer.seek(position);
  }

  void reverse() async {
    var newPos = position - const Duration(seconds: 15);
    if (newPos < Duration.zero) {
      newPos = Duration.zero;
    }
    position = newPos;
    await _audioPlayer.seek(position);
  }

  Duration get currentPosition => position;
  Duration get totalDuration => _totalDuration;

  void dispose() {
    _audioPlayer.dispose();
    _positionController.close();
    _durationController.close();
    _playerStateController.close();
  }
}
