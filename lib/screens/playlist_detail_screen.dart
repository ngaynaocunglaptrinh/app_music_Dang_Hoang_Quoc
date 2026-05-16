import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;
  final List<AppSong> allSongs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.allSongs,
  });

  List<AppSong> _playlistSongs(PlaylistModel playlist) {
    return playlist.songIds
        .map((id) {
      try {
        return allSongs.firstWhere((song) => song.id == id);
      } catch (_) {
        return null;
      }
    })
        .whereType<AppSong>()
        .toList();
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Đổi tên playlist', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tên playlist mới',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                await context.read<PlaylistProvider>().renamePlaylist(
                  playlist.id,
                  controller.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final currentPlaylist = playlistProvider.playlists.firstWhere(
              (item) => item.id == playlist.id,
          orElse: () => playlist,
        );
        final songs = _playlistSongs(currentPlaylist);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(currentPlaylist.name, style: const TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _showRenameDialog(context, currentPlaylist),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${songs.length} bài hát',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                        context.read<AudioProvider>().setQueueAndPlay(songs, 0);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Phát playlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Playlist này chưa có bài hát. Hãy sang tab Bài hát và bấm dấu ba chấm để thêm bài.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                    : ReorderableListView.builder(
                  itemCount: songs.length,
                  onReorder: (oldIndex, newIndex) {
                    playlistProvider.reorderSong(currentPlaylist.id, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Container(
                      key: ValueKey(song.id),
                      child: SongTile(
                        song: song,
                        onTap: () {
                          context.read<AudioProvider>().setQueueAndPlay(songs, index);
                        },
                        trailingExtra: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            playlistProvider.removeSongFromPlaylist(currentPlaylist.id, song.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const MiniPlayer(),
            ],
          ),
        );
      },
    );
  }
}
