import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final StorageService _storageService = StorageService();

  List<AppSong> _songs = [];
  int _currentIndex = -1;
  bool _shuffleEnabled = false;
  String _repeatMode = 'off';
  double _volume = 1.0;

  AudioProvider() {
    _init();
    _listenToSongComplete();
  }
  List<AppSong> get songs => _songs;
  int get currentIndex => _currentIndex;
  bool get shuffleEnabled => _shuffleEnabled;
  String get repeatMode => _repeatMode;
  double get volume => _volume;

  AppSong? get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _songs.length) {
      return null;
    }

    return _songs[_currentIndex];
  }
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;

  Future<void> _init() async {
    _shuffleEnabled = await _storageService.getShuffle();
    _repeatMode = await _storageService.getRepeatMode();
    _volume = await _storageService.getVolume();

    await _audioService.setVolume(_volume);
    await _applyRepeatMode();

    notifyListeners();
  }

  void _listenToSongComplete() {
    _audioService.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (_repeatMode == 'one') {
          seek(Duration.zero);
          playPause(forcePlay: true);
        } else {
          nextSong();
        }
      }
    });
  }
  void setSongs(List<AppSong> songs) {
    _songs = songs;
    notifyListeners();
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= _songs.length) {
      return;
    }

    _currentIndex = index;
    final song = _songs[index];

    await _audioService.loadAudio(song.filePath);
    await _audioService.play();

    notifyListeners();
  }

  Future<void> playPause({bool forcePlay = false}) async {
    if (forcePlay) {
      await _audioService.play();
      notifyListeners();
      return;
    }

    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }

    notifyListeners();
  }

  Future<void> nextSong() async {
    if (_songs.isEmpty) {
      return;
    }

    if (_shuffleEnabled) {
      final random = Random();
      final randomIndex = random.nextInt(_songs.length);
      await playSong(randomIndex);
      return;
    }

    int nextIndex = _currentIndex + 1;

    if (nextIndex >= _songs.length) {
      if (_repeatMode == 'all') {
        nextIndex = 0;
      } else {
        await _audioService.stop();
        return;
      }
    }

    await playSong(nextIndex);
  }

  Future<void> previousSong() async {
    if (_songs.isEmpty) {
      return;
    }

    if (_audioService.currentPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int previousIndex = _currentIndex - 1;

    if (previousIndex < 0) {
      previousIndex = _songs.length - 1;
    }

    await playSong(previousIndex);
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await _storageService.saveShuffle(_shuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeatMode() async {
    if (_repeatMode == 'off') {
      _repeatMode = 'all';
    } else if (_repeatMode == 'all') {
      _repeatMode = 'one';
    } else {
      _repeatMode = 'off';
    }

    await _storageService.saveRepeatMode(_repeatMode);
    await _applyRepeatMode();

    notifyListeners();
  }

  Future<void> _applyRepeatMode() async {
    if (_repeatMode == 'one') {
      await _audioService.setLoopMode(LoopMode.one);
    } else {
      await _audioService.setLoopMode(LoopMode.off);
    }
  }

  Future<void> changeVolume(double value) async {
    _volume = value;
    await _audioService.setVolume(value);
    await _storageService.saveVolume(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}