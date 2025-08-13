import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  static Future<bool> ensurePhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
}
