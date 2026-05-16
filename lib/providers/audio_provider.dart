import 'dart:async';
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
  double _speed = 1.0;
  Timer? _saveTimer;
  String? _errorMessage;

  AudioProvider() {
    _init();
    _listenToSongComplete();
    _listenAndSavePlaybackPosition();
  }

  List<AppSong> get songs => _songs;
  int get currentIndex => _currentIndex;
  bool get shuffleEnabled => _shuffleEnabled;
  String get repeatMode => _repeatMode;
  double get volume => _volume;
  double get speed => _speed;
  String? get errorMessage => _errorMessage;

  AppSong? get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _songs.length) return null;
    return _songs[_currentIndex];
  }

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<ProcessingState> get processingStateStream => _audioService.processingStateStream;

  Future<void> _init() async {
    await _audioService.initAudioSession();
    _shuffleEnabled = await _storageService.getShuffle();
    _repeatMode = await _storageService.getRepeatMode();
    _volume = await _storageService.getVolume();
    await _audioService.setVolume(_volume);
    await _applyRepeatMode();
    notifyListeners();
  }

  void _listenToSongComplete() {
    _audioService.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        if (_repeatMode == 'one') {
          await seek(Duration.zero);
          await _audioService.play();
        } else {
          await nextSong();
        }
      }
    });
  }

  void _listenAndSavePlaybackPosition() {
    _audioService.positionStream.listen((position) {
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 800), () async {
        final song = currentSong;
        if (song != null) {
          await _storageService.saveLastPlayback(songId: song.id, position: position);
        }
      });
    });
  }

  Future<void> setSongs(List<AppSong> songs) async {
    _songs = songs;
    notifyListeners();
    await restoreLastPlayback();
  }

  Future<void> restoreLastPlayback() async {
    if (_songs.isEmpty || _currentIndex != -1) return;

    final lastSongId = await _storageService.getLastSongId();
    if (lastSongId == null) return;

    final index = _songs.indexWhere((song) => song.id == lastSongId);
    if (index == -1) return;

    _currentIndex = index;
    final position = await _storageService.getLastPosition();

    try {
      await _audioService.loadSong(_songs[index]);
      if (position > Duration.zero) {
        await _audioService.seek(position);
      }
      notifyListeners();
    } catch (_) {
      _currentIndex = -1;
      notifyListeners();
    }
  }

  Future<void> playSong(int index, {bool startPlaying = true}) async {
    if (index < 0 || index >= _songs.length) return;

    _errorMessage = null;
    _currentIndex = index;
    final song = _songs[index];

    try {
      await _audioService.loadSong(song);
      if (startPlaying) {
        await _audioService.play();
      }
      await _storageService.saveLastPlayback(songId: song.id, position: Duration.zero);
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> setQueueAndPlay(List<AppSong> queue, int startIndex) async {
    _songs = queue;
    notifyListeners();
    await playSong(startIndex);
  }

  Future<void> playPause({bool forcePlay = false}) async {
    final song = currentSong;
    if (song == null && _songs.isNotEmpty) {
      await playSong(0);
      return;
    }

    if (forcePlay) {
      await _audioService.play();
    } else if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioService.stop();
    notifyListeners();
  }

  Future<void> nextSong() async {
    if (_songs.isEmpty) return;

    if (_shuffleEnabled) {
      final random = Random();
      if (_songs.length == 1) {
        await playSong(0);
        return;
      }

      int randomIndex = _currentIndex;
      while (randomIndex == _currentIndex) {
        randomIndex = random.nextInt(_songs.length);
      }
      await playSong(randomIndex);
      return;
    }

    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _songs.length) {
      if (_repeatMode == 'all') {
        nextIndex = 0;
      } else {
        await _audioService.stop();
        notifyListeners();
        return;
      }
    }

    await playSong(nextIndex);
  }

  Future<void> previousSong() async {
    if (_songs.isEmpty) return;

    if (_audioService.currentPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int previousIndex = _currentIndex - 1;
    if (previousIndex < 0) {
      previousIndex = _repeatMode == 'all' ? _songs.length - 1 : 0;
    }

    await playSong(previousIndex);
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    final song = currentSong;
    if (song != null) {
      await _storageService.saveLastPlayback(songId: song.id, position: position);
    }
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
    _volume = value.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> changeSpeed(double value) async {
    _speed = value.clamp(0.5, 2.0);
    await _audioService.setSpeed(_speed);
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
