import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _repeatLabel(String mode) {
    if (mode == 'all') return 'Repeat all';
    if (mode == 'one') return 'Repeat one';
    return 'Repeat off';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return const Center(
              child: Text(
                'Chưa có bài hát đang phát',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool smallScreen = constraints.maxHeight < 680;

              final double albumSize = smallScreen ? 210 : 270;
              final double horizontalPadding = smallScreen ? 18 : 24;
              final double titleFontSize = smallScreen ? 21 : 24;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      smallScreen ? 12 : 20,
                      horizontalPadding,
                      20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AlbumArt(
                          songId: song.id,
                          isAsset: song.isAsset,
                          size: albumSize,
                          borderRadius: 20,
                        ),

                        SizedBox(height: smallScreen ? 18 : 28),

                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          song.artist,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          song.album,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        SizedBox(height: smallScreen ? 18 : 26),

                        StreamBuilder<Duration>(
                          stream: provider.positionStream,
                          builder: (context, positionSnapshot) {
                            return StreamBuilder<Duration?>(
                              stream: provider.durationStream,
                              builder: (context, durationSnapshot) {
                                final position =
                                    positionSnapshot.data ?? Duration.zero;

                                final duration = durationSnapshot.data ??
                                    Duration(
                                      milliseconds: song.duration,
                                    );

                                return ProgressBar(
                                  position: position,
                                  duration: duration,
                                  onSeek: provider.seek,
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(height: smallScreen ? 8 : 10),

                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              backgroundColor: AppColors.card,
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                provider.shuffleEnabled
                                    ? 'Shuffle on'
                                    : 'Shuffle off',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Chip(
                              backgroundColor: AppColors.card,
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                _repeatLabel(provider.repeatMode),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: smallScreen ? 10 : 14),

                        const PlayerControls(),

                        SizedBox(height: smallScreen ? 10 : 14),

                        Row(
                          children: [
                            const Icon(
                              Icons.speed,
                              color: Colors.grey,
                              size: 22,
                            ),
                            Expanded(
                              child: Slider(
                                value: provider.speed.clamp(0.5, 2.0),
                                min: 0.5,
                                max: 2.0,
                                divisions: 6,
                                label:
                                '${provider.speed.toStringAsFixed(1)}x',
                                activeColor: AppColors.primary,
                                onChanged: provider.changeSpeed,
                              ),
                            ),
                            SizedBox(
                              width: 42,
                              child: Text(
                                '${provider.speed.toStringAsFixed(1)}x',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}