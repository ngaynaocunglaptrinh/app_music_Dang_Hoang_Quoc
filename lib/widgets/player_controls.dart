import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  IconData _repeatIcon(String mode) {
    if (mode == 'one') {
      return Icons.repeat_one;
    }

    return Icons.repeat;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: provider.shuffleEnabled
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  onPressed: provider.toggleShuffle,
                ),
                const SizedBox(width: 100),
                IconButton(
                  icon: Icon(
                    _repeatIcon(provider.repeatMode),
                    color: provider.repeatMode != 'off'
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  onPressed: provider.toggleRepeatMode,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 44,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: provider.previousSong,
                ),
                const SizedBox(width: 24),
                StreamBuilder<bool>(
                  stream: provider.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;

                    return Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 42,
                        color: Colors.white,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: provider.playPause,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 44,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_next),
                  onPressed: provider.nextSong,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}