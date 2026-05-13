import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final int songId;
  final double size;
  final double borderRadius;

  const AlbumArt({
    super.key,
    required this.songId,
    this.size = 52,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      artworkWidth: size,
      artworkHeight: size,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.music_note,
          color: Colors.grey,
          size: size * 0.45,
        ),
      ),
    );
  }
}