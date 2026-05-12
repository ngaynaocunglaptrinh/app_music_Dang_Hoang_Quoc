import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const String _playlistKey = 'playlists';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _volumeKey = 'volume';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = playlists.map((playlist) => playlist.toJson()).toList();
    await prefs.setString(_playlistKey, jsonEncode(data));
  }
  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_playlistKey);

    if (data == null) {
      return [];
    }

    final List decoded = jsonDecode(data);

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
    await prefs.setString(_repeatKey, value);
  }

  Future<String> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_repeatKey) ?? 'off';
  }

  Future<void> saveVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }
}