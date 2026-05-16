import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<PlaylistModel> _playlists = [];
  List<PlaylistModel> get playlists => _playlists;

  PlaylistProvider() {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == id);
    if (index == -1 || newName.trim().isEmpty) return;

    _playlists[index] = _playlists[index].copyWith(
      name: newName.trim(),
      updatedAt: DateTime.now(),
    );

    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((playlist) => playlist.id == id);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, AppSong song) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    if (playlist.songIds.contains(song.id)) return;

    _playlists[index] = playlist.copyWith(
      songIds: [...playlist.songIds, song.id],
      updatedAt: DateTime.now(),
    );

    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    _playlists[index] = playlist.copyWith(
      songIds: playlist.songIds.where((id) => id != songId).toList(),
      updatedAt: DateTime.now(),
    );

    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> reorderSong(String playlistId, int oldIndex, int newIndex) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index == -1) return;

    final ids = [..._playlists[index].songIds];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);

    _playlists[index] = _playlists[index].copyWith(
      songIds: ids,
      updatedAt: DateTime.now(),
    );

    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }
}
