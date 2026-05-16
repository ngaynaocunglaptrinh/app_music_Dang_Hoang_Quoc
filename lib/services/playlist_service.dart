import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../models/song_model.dart';

class PlaylistService {
  final audio_query.OnAudioQuery _audioQuery = audio_query.OnAudioQuery();

  Future<List<AppSong>> getAllSongs({
    SongSortOption sort = SongSortOption.title,
  }) async {
    final deviceSongs = await _loadDeviceSongs(sort: sort);

    // Nếu máy thật hoặc emulator có nhạc trong bộ nhớ thì ưu tiên dùng nhạc thiết bị.
    if (deviceSongs.isNotEmpty) {
      return deviceSongs;
    }

    // Nếu emulator không có nhạc, dùng nhạc mẫu trong assets để demo.
    return _loadAssetSongs();
  }

  Future<List<AppSong>> _loadDeviceSongs({
    required SongSortOption sort,
  }) async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: _mapSortType(sort),
        orderType: audio_query.OrderType.ASC_OR_SMALLER,
        uriType: audio_query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      final result = songs
          .where((song) {
        final path = song.data.toLowerCase();

        return path.endsWith('.mp3') ||
            path.endsWith('.m4a') ||
            path.endsWith('.aac') ||
            path.endsWith('.wav') ||
            path.endsWith('.flac') ||
            path.endsWith('.ogg');
      })
          .map(AppSong.fromDeviceSong)
          .toList();

      return result;
    } catch (_) {
      // Nếu query nhạc thiết bị lỗi hoặc emulator không có quyền/không có nhạc,
      // app sẽ dùng nhạc mẫu trong assets.
      return [];
    }
  }

  Future<List<AppSong>> _loadAssetSongs() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final audioPaths = manifest.listAssets().where((path) {
      final lowerPath = path.toLowerCase();

      return lowerPath.startsWith('assets/audio/sample_songs/') &&
          (lowerPath.endsWith('.mp3') ||
              lowerPath.endsWith('.m4a') ||
              lowerPath.endsWith('.wav') ||
              lowerPath.endsWith('.aac') ||
              lowerPath.endsWith('.ogg') ||
              lowerPath.endsWith('.flac'));
    }).toList()
      ..sort();

    return List.generate(audioPaths.length, (index) {
      final assetPath = audioPaths[index];
      final fileName = assetPath.split('/').last;

      final nameWithoutExtension = fileName.replaceAll(
        RegExp(
          r'\.(mp3|m4a|wav|aac|ogg|flac)$',
          caseSensitive: false,
        ),
        '',
      );

      final info = _parseAssetSongName(nameWithoutExtension);

      return AppSong(
        id: -100000 - index,
        title: info.title,
        artist: info.artist,
        album: info.album,
        filePath: assetPath,
        duration: 0,
        isAsset: true,
      );
    });
  }

  _AssetSongInfo _parseAssetSongName(String name) {
    // Quy ước tên file:
    // Title - Artist - Album.mp3
    //
    // Ví dụ:
    // Love Story - Taylor - Pop Album.mp3
    // Night Drive - Alan Walker - EDM Album.mp3
    // Blue Sky - Sơn Tùng - VPop Album.mp3

    final parts = name.split(' - ');

    if (parts.length >= 3) {
      return _AssetSongInfo(
        title: parts[0].trim(),
        artist: parts[1].trim(),
        album: parts.sublist(2).join(' - ').trim(),
      );
    }

    // Nếu tên file không đúng format thì vẫn không lỗi app.
    // App sẽ lấy tên file làm title và dùng thông tin mặc định.
    return _AssetSongInfo(
      title: name.trim(),
      artist: 'Sample Music',
      album: 'Sample Songs',
    );
  }

  List<AppSong> searchSongs(List<AppSong> songs, String query) {
    final lowerQuery = query.trim().toLowerCase();

    if (lowerQuery.isEmpty) {
      return songs;
    }

    return songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          song.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<AppSong> filterByArtist(List<AppSong> songs, String artist) {
    if (artist == 'Tất cả nghệ sĩ') {
      return songs;
    }

    return songs.where((song) => song.artist == artist).toList();
  }

  List<AppSong> filterByAlbum(List<AppSong> songs, String album) {
    if (album == 'Tất cả album') {
      return songs;
    }

    return songs.where((song) => song.album == album).toList();
  }

  List<AppSong> sortSongs(List<AppSong> songs, SongSortOption sort) {
    final sorted = [...songs];

    switch (sort) {
      case SongSortOption.title:
        sorted.sort(
              (a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ),
        );
        break;

      case SongSortOption.artist:
        sorted.sort(
              (a, b) => a.artist.toLowerCase().compareTo(
            b.artist.toLowerCase(),
          ),
        );
        break;

      case SongSortOption.album:
        sorted.sort(
              (a, b) => a.album.toLowerCase().compareTo(
            b.album.toLowerCase(),
          ),
        );
        break;

      case SongSortOption.dateAdded:
        sorted.sort(
              (a, b) => (b.dateAdded ?? 0).compareTo(
            a.dateAdded ?? 0,
          ),
        );
        break;
    }

    return sorted;
  }

  audio_query.SongSortType _mapSortType(SongSortOption sort) {
    switch (sort) {
      case SongSortOption.title:
        return audio_query.SongSortType.TITLE;

      case SongSortOption.artist:
        return audio_query.SongSortType.ARTIST;

      case SongSortOption.album:
        return audio_query.SongSortType.ALBUM;

      case SongSortOption.dateAdded:
        return audio_query.SongSortType.DATE_ADDED;
    }
  }
}

class _AssetSongInfo {
  final String title;
  final String artist;
  final String album;

  const _AssetSongInfo({
    required this.title,
    required this.artist,
    required this.album,
  });
}

enum SongSortOption {
  title,
  artist,
  album,
  dateAdded,
}