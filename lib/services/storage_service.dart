import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const _playlistsKey = 'playlists';
  static const _shuffleKey = 'shuffle_enabled';
  static const _repeatModeKey = 'repeat_mode';
  static const _volumeKey = 'volume';
  static const _lastSongIdKey = 'last_song_id';
  static const _lastPositionKey = 'last_position_ms';
  static const _themeKey = 'theme_mode';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = playlists.map((item) => item.toJson()).toList();
    await prefs.setString(_playlistsKey, jsonEncode(data));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistsKey);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((item) => PlaylistModel.fromJson(item)).toList();
  }

  Future<void> saveShuffle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, value);
  }

  Future<bool> getShuffle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_repeatModeKey, value);
  }

  Future<String> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_repeatModeKey) ?? 'off';
  }

  Future<void> saveVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> saveLastPlayback({required int songId, required Duration position}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSongIdKey, songId);
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  Future<int?> getLastSongId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSongIdKey);
  }

  Future<Duration> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastPositionKey) ?? 0;
    return Duration(milliseconds: ms);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true;
  }
}
