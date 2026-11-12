import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class AccessibilityProvider extends ChangeNotifier {
  bool _isHighContrast = false;
  bool _isLargeFont = false;
  bool _isTextOnly = true;

  bool get isHighContrast => _isHighContrast;
  bool get isLargeFont => _isLargeFont;
  bool get isTextOnly => _isTextOnly;

  double get textScaleFactor => _isLargeFont ? AppConstants.largeTextScale : 1.0;

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    notifyListeners();
  }

  void toggleLargeFont() {
    _isLargeFont = !_isLargeFont;
    notifyListeners();
  }

  void setTextOnly(bool value) {
    _isTextOnly = value;
    notifyListeners();
  }
}
