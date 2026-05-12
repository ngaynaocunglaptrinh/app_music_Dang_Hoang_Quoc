import 'package:just_audio/just_audio.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<bool> get playingStream => player.playingStream;
  Stream<ProcessingState> get processingStateStream => player.processingStateStream;
  bool get isPlaying => player.playing;
  Duration get currentPosition => player.position;

  Stream<PlaybackStateModel> get playbackStateStream async* {
    await for (final position in positionStream) {
      yield PlaybackStateModel(
        position: position,
        duration: player.duration ?? Duration.zero,
        isPlaying: player.playing,
      );
    }
  }

  Future<void> loadAudio(String filePath) async {
    await player.setFilePath(filePath);
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await player.setLoopMode(loopMode);
  }
  void dispose() {
    player.dispose();
  }
}