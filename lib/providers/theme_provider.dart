import 'package:flutter/material.dart';
import '../../themes/theme_manager.dart';

/// Provider for managing theme selection state.
///
/// Manages the current selected palette name, dynamic colors (Monet) toggle,
/// and provides methods to change palette and toggle dynamic colors.
class ThemeProvider extends ChangeNotifier {
  /// Current selected palette name
  String _selectedPaletteName = 'Electric Orange';

  /// Whether dynamic colors (Monet) are enabled
  bool _isDynamicColorsEnabled = false;

  /// Current brightness mode
  Brightness _brightness = Brightness.dark;

  /// Getter for selected palette name
  String get selectedPaletteName => _selectedPaletteName;

  /// Getter for dynamic colors enabled status
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;

  /// Getter for current brightness
  Brightness get brightness => _brightness;

  /// Getter for current theme type
  ThemeType get currentThemeType {
    if (_isDynamicColorsEnabled) {
      return ThemeType.dynamic;
    }
    return _getThemeTypeFromName(_selectedPaletteName);
  }

  /// Get the available palettes
  List<Map<String, dynamic>> get availablePalettes =>
      ThemeManager.availablePalettes;

  /// Converts palette name to ThemeType
  ThemeType _getThemeTypeFromName(String name) {
    switch (name) {
      case 'Electric Orange':
        return ThemeType.electricOrange;
      case 'Deep Purple':
        return ThemeType.deepPurple;
      case 'Cyber Teal':
        return ThemeType.cyberTeal;
      case 'Dynamic':
        return ThemeType.dynamic;
      default:
        return ThemeType.electricOrange;
    }
  }

  /// Changes the theme palette.
  ///
  /// [paletteName] - The name of the palette to set.
  void setPalette(String paletteName) {
    if (_selectedPaletteName != paletteName) {
      _selectedPaletteName = paletteName;
      // If selecting Dynamic palette, enable dynamic colors
      if (paletteName == 'Dynamic') {
        _isDynamicColorsEnabled = true;
      } else {
        _isDynamicColorsEnabled = false;
      }
      notifyListeners();
    }
  }

  /// Toggles dynamic colors (Monet) on/off.
  ///
  /// This is typically used when the user selects the Dynamic palette
  /// or when Android 12+ dynamic colors are available.
  void toggleDynamicColors() {
    _isDynamicColorsEnabled = !_isDynamicColorsEnabled;
    if (_isDynamicColorsEnabled) {
      _selectedPaletteName = 'Dynamic';
    }
    notifyListeners();
  }

  /// Enables or disables dynamic colors.
  ///
  /// [enabled] - Whether to enable dynamic colors.
  void setDynamicColors(bool enabled) {
    if (_isDynamicColorsEnabled != enabled) {
      _isDynamicColorsEnabled = enabled;
      if (enabled) {
        _selectedPaletteName = 'Dynamic';
      }
      notifyListeners();
    }
  }

  /// Toggles between light and dark mode.
  void toggleBrightness() {
    _brightness =
        _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    notifyListeners();
  }

  /// Sets the brightness mode.
  ///
  /// [brightness] - The brightness mode to set.
  void setBrightness(Brightness brightness) {
    if (_brightness != brightness) {
      _brightness = brightness;
      notifyListeners();
    }
  }

  /// Gets the current theme data based on selected options.
  ///
  /// [dynamicColorScheme] - Optional dynamic color scheme for Monet colors.
  ThemeData getTheme({ColorScheme? dynamicColorScheme}) {
    if (_isDynamicColorsEnabled && dynamicColorScheme != null) {
      return ThemeManager.createDynamicColorTheme(dynamicColorScheme);
    }
    return ThemeManager.getTheme(currentThemeType, _brightness);
  }

  /// Checks if a specific palette is currently selected.
  ///
  /// [paletteName] - The palette name to check.
  bool isPaletteSelected(String paletteName) {
    if (_isDynamicColorsEnabled && paletteName == 'Dynamic') {
      return true;
    }
    return _selectedPaletteName == paletteName;
  }
}
