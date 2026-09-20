import 'package:flutter/services.dart';
import 'fullscreen_stub.dart'
    if (dart.library.js_interop) 'fullscreen_web.dart';

class FullscreenService {
  static bool _nativeFullscreen = false;

  static bool get isFullscreen => FullscreenPlatform.isFullscreen || _nativeFullscreen;

  static Future<void> toggleFullscreen() async {
    await FullscreenPlatform.toggleFullscreen();
    _nativeFullscreen = !_nativeFullscreen;
    if (_nativeFullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
