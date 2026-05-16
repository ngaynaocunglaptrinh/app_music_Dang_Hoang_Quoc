import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../models/playback_state_model.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<bool> get playingStream => player.playingStream;
  Stream<ProcessingState> get processingStateStream => player.processingStateStream;

  bool get isPlaying => player.playing;
  Duration get currentPosition => player.position;
  Duration? get currentDuration => player.duration;

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        await pause();
      }
    });
  }

  Stream<PlaybackStateModel> get playbackStateStream async* {
    await for (final position in positionStream) {
      yield PlaybackStateModel(
        position: position,
        duration: player.duration ?? Duration.zero,
        isPlaying: player.playing,
      );
    }
  }

  Future<void> loadSong(AppSong song) async {
    try {
      await player.stop();
      if (song.isAsset) {
        await player.setAsset(song.filePath);
      } else {
        final file = File(song.filePath);
        if (!await file.exists()) {
          throw Exception('File không tồn tại hoặc đã bị xóa khỏi thiết bị');
        }
        await player.setFilePath(song.filePath);
      }
    } catch (e) {
      throw Exception('Không thể load bài hát: ${song.title}. Lỗi: $e');
    }
  }

  Future<void> play() async => player.play();
  Future<void> pause() async => player.pause();
  Future<void> stop() async => player.stop();
  Future<void> seek(Duration position) async => player.seek(position);
  Future<void> setVolume(double volume) async => player.setVolume(volume);
  Future<void> setSpeed(double speed) async => player.setSpeed(speed);
  Future<void> setLoopMode(LoopMode loopMode) async => player.setLoopMode(loopMode);

  void dispose() {
    player.dispose();
  }
}
