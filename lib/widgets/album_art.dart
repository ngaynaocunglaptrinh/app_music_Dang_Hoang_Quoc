import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumArt extends StatelessWidget {
  final int? songId;
  final bool isAsset;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;

  const AlbumArt({
    super.key,
    required this.songId,
    this.isAsset = false,
    this.size = 50,
    this.borderRadius = 8,
    this.fallbackIcon = Icons.music_note,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu là nhạc assets hoặc không có id bài hát thật
    // thì không dùng QueryArtworkWidget, chỉ hiện icon mặc định.
    if (isAsset || songId == null || songId == 0) {
      return _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: QueryArtworkWidget(
        id: songId!,
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.circular(borderRadius),
        nullArtworkWidget: _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        fallbackIcon,
        color: Colors.grey,
        size: size * 0.5,
      ),
    );
  }
}