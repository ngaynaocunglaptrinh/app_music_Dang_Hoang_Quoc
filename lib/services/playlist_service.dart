import 'package:flutter/services.dart';
import '../models/song_model.dart';

class PlaylistService {
  Future<List<AppSong>> getAllSongs() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final audioPaths = manifest
        .listAssets()
        .where((path) {
      final lowerPath = path.toLowerCase();

      return lowerPath.startsWith('assets/audio/sample_songs/') &&
          (lowerPath.endsWith('.mp3') ||
              lowerPath.endsWith('.m4a') ||
              lowerPath.endsWith('.wav') ||
              lowerPath.endsWith('.aac') ||
              lowerPath.endsWith('.ogg') ||
              lowerPath.endsWith('.flac'));
    })
        .toList()
      ..sort();

    return List.generate(audioPaths.length, (index) {
      final assetPath = audioPaths[index];
      final fileName = assetPath.split('/').last;

      final title = fileName.replaceAll(
        RegExp(r'\.(mp3|m4a|wav|aac|ogg|flac)$', caseSensitive: false),
        '',
      );

      return AppSong(
        id: index + 1,
        title: title,
        artist: 'Local Music',
        album: 'Sample Songs',
        assetPath: assetPath,
      );
    });
  }

  List<AppSong> searchSongs(List<AppSong> songs, String query) {
    final lowerQuery = query.toLowerCase();

    return songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          song.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}