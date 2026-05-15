import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _playlistService = PlaylistService();

  bool _isLoading = true;
  List<AppSong> _songs = [];
  List<AppSong> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await _playlistService.getAllSongs();

      if (!mounted) return;

      context.read<AudioProvider>().setSongs(songs);

      setState(() {
        _songs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi load nhạc: $e'),
        ),
      );
    }
  }

  void _searchSong(String value) {
    setState(() {
      _filteredSongs = _playlistService.searchSongs(_songs, value);
    });
  }

  void _showAddToPlaylist(AppSong song) {
    final playlistProvider = context.read<PlaylistProvider>();
    final playlists = playlistProvider.playlists;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (context) {
        if (playlists.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Bạn chưa có playlist nào. Hãy tạo playlist trước.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: playlists.map((playlist) {
            return ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: Text(
                playlist.name,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await playlistProvider.addSongToPlaylist(playlist.id, song);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm vào ${playlist.name}'),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBox(),
        Expanded(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
              : _filteredSongs.isEmpty
              ? _buildEmpty()
              : _buildSongList(),
        ),
        const MiniPlayer(),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _searchSong,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm bài hát...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return RefreshIndicator(
      onRefresh: _loadSongs,
      child: ListView.builder(
        itemCount: _filteredSongs.length,
        itemBuilder: (context, index) {
          final song = _filteredSongs[index];
          final realIndex = _songs.indexWhere((item) => item.id == song.id);

          return SongTile(
            song: song,
            onTap: () {
              if (realIndex != -1) {
                context.read<AudioProvider>().playSong(realIndex);
              }
            },
            onMoreTap: () {
              _showAddToPlaylist(song);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, color: Colors.grey, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy bài hát',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hãy bỏ file MP3 vào thư mục assets/audio/sample_songs/ rồi chạy lại app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}