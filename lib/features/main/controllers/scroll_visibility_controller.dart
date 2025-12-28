import 'package:flutter/foundation.dart';

/// Controller to manage navbar visibility based on scroll direction
/// This is shared across screens to control the main navbar
class ScrollVisibilityController extends ChangeNotifier {
  static final ScrollVisibilityController _instance =
      ScrollVisibilityController._internal();

  factory ScrollVisibilityController() => _instance;

  ScrollVisibilityController._internal();

  bool _isNavbarVisible = true;
  double _lastScrollOffset = 0;

  // Threshold for scroll direction detection (in pixels)
  static const double _scrollThreshold = 10.0;

  bool get isNavbarVisible => _isNavbarVisible;

  /// Update visibility based on scroll position
  /// Call this from scroll listeners
  void onScroll(double currentOffset) {
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Scrolling down - hide navbar
    if (scrollDelta > _scrollThreshold && _isNavbarVisible) {
      _isNavbarVisible = false;
      notifyListeners();
    }
    // Scrolling up - show navbar
    else if (scrollDelta < -_scrollThreshold && !_isNavbarVisible) {
      _isNavbarVisible = true;
      notifyListeners();
    }

    _lastScrollOffset = currentOffset;
  }

  /// Reset to visible state (e.g., when navigating to a new screen)
  void reset() {
    _isNavbarVisible = true;
    _lastScrollOffset = 0;
    notifyListeners();
  }

  /// Force show navbar
  void show() {
    if (!_isNavbarVisible) {
      _isNavbarVisible = true;
      notifyListeners();
    }
  }

  /// Force hide navbar
  void hide() {
    if (_isNavbarVisible) {
      _isNavbarVisible = false;
      notifyListeners();
    }
  }
}
