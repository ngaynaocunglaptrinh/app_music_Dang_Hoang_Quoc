import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _repeatText(String mode) {
    if (mode == 'all') {
      return 'Lặp tất cả';
    }

    if (mode == 'one') {
      return 'Lặp một bài';
    }

    return 'Không lặp';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, ThemeProvider>(
      builder: (context, audioProvider, themeProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.card,
              child: SwitchListTile(
                value: themeProvider.isDarkMode,
                activeColor: AppColors.primary,
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Bật/tắt giao diện tối',
                  style: TextStyle(color: Colors.grey),
                ),
                onChanged: (_) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            Card(
              color: AppColors.card,
              child: SwitchListTile(
                value: audioProvider.shuffleEnabled,
                activeColor: AppColors.primary,
                title: const Text(
                  'Shuffle',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Phát ngẫu nhiên',
                  style: TextStyle(color: Colors.grey),
                ),
                onChanged: (_) {
                  audioProvider.toggleShuffle();
                },
              ),
            ),
            Card(
              color: AppColors.card,
              child: ListTile(
                title: const Text(
                  'Repeat Mode',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _repeatText(audioProvider.repeatMode),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.repeat, color: Colors.white),
                onTap: audioProvider.toggleRepeatMode,
              ),
            ),
            Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Âm lượng',
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: audioProvider.volume,
                      min: 0,
                      max: 1,
                      activeColor: AppColors.primary,
                      onChanged: audioProvider.changeVolume,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Offline Music Player\nFlutter project demo',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}