import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Tạo playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nhập tên playlist',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                await context.read<PlaylistProvider>().createPlaylist(name);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo playlist mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.playlists.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có playlist nào',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: provider.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = provider.playlists[index];

                  return PlaylistCard(
                    playlist: playlist,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bản cơ bản đã lưu playlist. Có thể mở rộng màn hình chi tiết playlist sau.',
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      provider.deletePlaylist(playlist.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}