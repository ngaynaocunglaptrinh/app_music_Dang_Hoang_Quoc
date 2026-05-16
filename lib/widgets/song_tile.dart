import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  final AppSong song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final Widget? trailingExtra;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
    this.trailingExtra,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: AlbumArt(songId: song.id, isAsset: song.isAsset),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textGrey),
      ),
      trailing: trailingExtra ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DurationFormatter.format(Duration(milliseconds: song.duration)),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: onMoreTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
