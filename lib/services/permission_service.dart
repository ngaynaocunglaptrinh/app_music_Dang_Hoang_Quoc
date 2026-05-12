import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final audioStatus = await Permission.audio.request();

    if (audioStatus.isGranted) {
      return true;
    }
    final storageStatus = await Permission.storage.request();

    if (storageStatus.isGranted) {
      return true;
    }
    if (audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final audioStatus = await Permission.audio.status;
    final storageStatus = await Permission.storage.status;
    return audioStatus.isGranted || storageStatus.isGranted;
  }
}