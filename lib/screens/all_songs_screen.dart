import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/permission_service.dart';
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
  final PermissionService _permissionService = PermissionService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _hasPermission = false;
  List<AppSong> _songs = [];
  List<AppSong> _filteredSongs = [];
  SongSortOption _sortOption = SongSortOption.title;
  String _selectedArtist = 'Tất cả nghệ sĩ';
  String _selectedAlbum = 'Tất cả album';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    _hasPermission = await _permissionService.requestAudioPermission();

    if (_hasPermission) {
      await _loadSongs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs(sort: _sortOption);
      if (!mounted) return;

      await context.read<AudioProvider>().setSongs(songs);

      setState(() {
        _songs = songs;
        _applySearchSortFilter();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải nhạc: $e')),
      );
    }
  }

  void _applySearchSortFilter() {
    List<AppSong> result = [..._songs];
    result = _playlistService.filterByArtist(result, _selectedArtist);
    result = _playlistService.filterByAlbum(result, _selectedAlbum);
    result = _playlistService.searchSongs(result, _searchController.text);
    result = _playlistService.sortSongs(result, _sortOption);
    _filteredSongs = result;
  }

  void _onSearchChanged(String value) {
    setState(_applySearchSortFilter);
  }

  List<String> get _artists {
    final values = _songs.map((song) => song.artist).toSet().toList()..sort();
    return ['Tất cả nghệ sĩ', ...values];
  }

  List<String> get _albums {
    final values = _songs.map((song) => song.album).toSet().toList()..sort();
    return ['Tất cả album', ...values];
  }

  void _showAddToPlaylist(AppSong song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, child) {
            final playlists = playlistProvider.playlists;

            if (playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn chưa có playlist nào. Hãy sang tab Playlist để tạo trước.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              children: playlists.map((playlist) {
                return ListTile(
                  leading: const Icon(Icons.queue_music, color: Colors.white),
                  title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${playlist.songIds.length} bài hát', style: const TextStyle(color: Colors.grey)),
                  onTap: () async {
                    await playlistProvider.addSongToPlaylist(playlist.id, song);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã thêm vào ${playlist.name}')),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _filteredSongs.isEmpty ? _buildEmpty() : _buildSongList(),
        ),
        const MiniPlayer(),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.grey, size: 80),
            const SizedBox(height: 16),
            const Text(
              'App cần quyền đọc nhạc',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy cấp quyền Audio/Music để app quét các file MP3, M4A, WAV, FLAC trong thiết bị.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initialize,
              icon: const Icon(Icons.refresh),
              label: const Text('Xin quyền lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: _permissionService.openSettings,
              child: const Text('Mở cài đặt ứng dụng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm bài hát, nghệ sĩ, album...',
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortDropdown(),
                const SizedBox(width: 8),
                _buildArtistDropdown(),
                const SizedBox(width: 8),
                _buildAlbumDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<SongSortOption>(
      value: _sortOption,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: Colors.white),
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(value: SongSortOption.title, child: Text('Sắp xếp: Title')),
        DropdownMenuItem(value: SongSortOption.artist, child: Text('Sắp xếp: Artist')),
        DropdownMenuItem(value: SongSortOption.album, child: Text('Sắp xếp: Album')),
        DropdownMenuItem(value: SongSortOption.dateAdded, child: Text('Sắp xếp: Mới thêm')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _sortOption = value;
          _applySearchSortFilter();
        });
      },
    );
  }

  Widget _buildArtistDropdown() {
    return DropdownButton<String>(
      value: _artists.contains(_selectedArtist) ? _selectedArtist : 'Tất cả nghệ sĩ',
      dropdownColor: AppColors.card,
      style: const TextStyle(color: Colors.white),
      underline: const SizedBox.shrink(),
      items: _artists.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedArtist = value;
          _applySearchSortFilter();
        });
      },
    );
  }

  Widget _buildAlbumDropdown() {
    return DropdownButton<String>(
      value: _albums.contains(_selectedAlbum) ? _selectedAlbum : 'Tất cả album',
      dropdownColor: AppColors.card,
      style: const TextStyle(color: Colors.white),
      underline: const SizedBox.shrink(),
      items: _albums.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedAlbum = value;
          _applySearchSortFilter();
        });
      },
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
            onMoreTap: () => _showAddToPlaylist(song),
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
              'Hãy chép nhạc MP3/M4A vào thiết bị thật. Nếu dùng emulator, có thể để file trong assets/audio/sample_songs/ để demo.',
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
