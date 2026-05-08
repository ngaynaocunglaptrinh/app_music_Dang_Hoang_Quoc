import 'package:on_audio_query/on_audio_query.dart';

class AppSong {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final int duration;

  AppSong({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    required this.duration,
  });

  factory AppSong.fromAudioQuery(SongModel song) {
    return AppSong(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album,
      filePath: song.data,
      duration: song.duration ?? 0,
    );
  }

  factory AppSong.fromJson(Map<String, dynamic> json) {
    return AppSong(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      filePath: json['filePath'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration,
    };
  }
}