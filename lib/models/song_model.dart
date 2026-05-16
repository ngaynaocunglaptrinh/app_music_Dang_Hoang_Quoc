import 'package:on_audio_query/on_audio_query.dart' as audio_query;

class AppSong {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final int duration;
  final int? dateAdded;
  final bool isAsset;

  AppSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    this.duration = 0,
    this.dateAdded,
    this.isAsset = false,
  });

  factory AppSong.fromDeviceSong(audio_query.SongModel song) {
    return AppSong(
      id: song.id,
      title: song.title,
      artist: (song.artist == null || song.artist!.trim().isEmpty)
          ? 'Unknown Artist'
          : song.artist!,
      album: (song.album == null || song.album!.trim().isEmpty)
          ? 'Unknown Album'
          : song.album!,
      filePath: song.data,
      duration: song.duration ?? 0,
      dateAdded: song.dateAdded,
      isAsset: false,
    );
  }

  factory AppSong.fromAsset({
    required int id,
    required String title,
    required String assetPath,
  }) {
    return AppSong(
      id: id,
      title: title,
      artist: 'Sample Music',
      album: 'Sample Songs',
      filePath: assetPath,
      duration: 0,
      isAsset: true,
    );
  }

  factory AppSong.fromJson(Map<String, dynamic> json) {
    return AppSong(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      filePath: json['filePath'] ?? json['assetPath'],
      duration: json['duration'] ?? 0,
      dateAdded: json['dateAdded'],
      isAsset: json['isAsset'] ?? false,
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
      'dateAdded': dateAdded,
      'isAsset': isAsset,
    };
  }
}
