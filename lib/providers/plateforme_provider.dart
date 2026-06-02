// services/platform_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformService extends ChangeNotifier {
  bool _isDesktop = false;
  bool _isTablet = false;
  bool _isMobile = true;

  double _width = 0;

  // Getters
  bool get isDesktop => _isDesktop;
  bool get isTablet => _isTablet;
  bool get isMobile => _isMobile;

  double get width => _width;

  // =========================
  // PLATFORM DETECTION
  // =========================

  bool get isWeb => kIsWeb;

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  bool get isNativeMobile => isAndroid || isIOS;

  // =========================
  // CURRENT PLATFORM (SAFE)
  // =========================

  TargetPlatform? get currentPlatform {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return TargetPlatform.android;
      case TargetPlatform.iOS:
        return TargetPlatform.iOS;
      case TargetPlatform.macOS:
        return TargetPlatform.macOS;
      case TargetPlatform.windows:
        return TargetPlatform.windows;
      case TargetPlatform.linux:
        return TargetPlatform.linux;
      default:
        return null;
    }
  }

  // =========================
  // INIT (CALL ONCE)
  // =========================

  void init(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    updateSize(width, notify: false);
  }

  // =========================
  // UPDATE SIZE (SAFE)
  // =========================

  void updateSize(double width, {bool notify = true}) {
    if (_width == width) return; // prevent spam rebuild

    _width = width;

    final oldDesktop = _isDesktop;
    final oldTablet = _isTablet;
    final oldMobile = _isMobile;

    _updateByWidth(width);

    final hasChanged =
        oldDesktop != _isDesktop ||
        oldTablet != _isTablet ||
        oldMobile != _isMobile;

    if (notify && hasChanged) {
      notifyListeners();
    }
  }

  // =========================
  // RESPONSIVE LOGIC
  // =========================

  void _updateByWidth(double width) {
    _isDesktop = width >= 900;
    _isTablet = width >= 600 && width < 900;
    _isMobile = width < 600;
  }

  // =========================
  // RESPONSIVE UI HELPERS
  // =========================

  EdgeInsets get responsivePadding {
    if (_isDesktop) return const EdgeInsets.all(32);
    if (_isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  double get responsiveTitleSize {
    if (_isDesktop) return 32;
    if (_isTablet) return 28;
    return 24;
  }

  double get responsiveBodySize {
    if (_isDesktop) return 18;
    if (_isTablet) return 16;
    return 14;
  }

  double get maxContentWidth {
    if (_isDesktop) return 1100;
    if (_isTablet) return 800;
    return double.infinity;
  }
}
