import 'package:web/web.dart' as web;

class FullscreenPlatform {
  static bool _isFullscreen = false;
  static bool get isFullscreen => _isFullscreen;

  static Future<void> toggleFullscreen() async {
    try {
      if (web.document.fullscreenElement != null) {
        web.document.exitFullscreen();
        _isFullscreen = false;
      } else {
        web.document.documentElement?.requestFullscreen();
        _isFullscreen = true;
      }
    } catch (_) {
      // Fullscreen not permitted or user cancelled
    }
  }
}
