import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';

class PlaylistService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Future<List<AppSong>> getAllSongs() async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    return songs.map((song) => AppSong.fromAudioQuery(song)).toList();
  }
  List<AppSong> searchSongs(List<AppSong> songs, String query) {
    final lowerQuery = query.toLowerCase();
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}