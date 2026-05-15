class AppSong {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String assetPath;
  final int duration;

  AppSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.assetPath,
    this.duration = 0,
  });

  factory AppSong.fromJson(Map<String, dynamic> json) {
    return AppSong(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      assetPath: json['assetPath'],
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'assetPath': assetPath,
      'duration': duration,
    };
  }
}