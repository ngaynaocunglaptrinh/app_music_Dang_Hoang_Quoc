import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) return true;

    // on_audio_query tự xử lý READ_MEDIA_AUDIO cho Android 13+
    // và READ_EXTERNAL_STORAGE cho Android cũ.
    final hasPermission = await _audioQuery.permissionsStatus();
    if (hasPermission) return true;

    return _audioQuery.permissionsRequest();
  }

  Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid) return true;
    return _audioQuery.permissionsStatus();
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
