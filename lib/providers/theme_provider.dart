import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/theme_manager.dart';

/// Provider for managing theme selection state with persistence.
///
/// Manages the current selected palette name, dynamic colors (Monet) toggle,
/// brightness mode, and persists all preferences to SharedPreferences.
/// On first run, if Android 12+ dynamic colors are available,
/// dynamic colors will be enabled by default.
class ThemeProvider extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _paletteKey = 'selected_palette';
  static const String _dynamicColorsKey = 'dynamic_colors_enabled';
  static const String _brightnessKey = 'brightness_mode';
  static const String _firstRunKey = 'theme_first_run';

  /// Current selected palette name
  String _selectedPaletteName = 'Electric Orange';

  /// Whether dynamic colors (Monet) are enabled
  bool _isDynamicColorsEnabled = false;

  /// Current brightness mode
  Brightness _brightness = Brightness.dark;

  /// Whether the provider has been initialized
  bool _isInitialized = false;

  /// Getter for selected palette name
  String get selectedPaletteName => _selectedPaletteName;

  /// Getter for dynamic colors enabled status
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;

  /// Getter for current brightness
  Brightness get brightness => _brightness;

  /// Getter for initialization status
  bool get isInitialized => _isInitialized;

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

  /// Initialize the provider by loading saved preferences.
  ///
  /// [dynamicColorScheme] - Optional dynamic color scheme from DynamicColorBuilder.
  /// If this is not null, it indicates Android 12+ is available.
  Future<void> initialize({ColorScheme? dynamicColorScheme}) async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;

    // On first run, check if Android 12+ dynamic colors are available
    if (isFirstRun && dynamicColorScheme != null) {
      // Enable dynamic colors by default on Android 12+
      _isDynamicColorsEnabled = true;
      _selectedPaletteName = 'Dynamic';
      
      // Save these default preferences
      await prefs.setBool(_firstRunKey, false);
      await prefs.setBool(_dynamicColorsKey, true);
      await prefs.setString(_paletteKey, 'Dynamic');
    } else {
      // Load saved preferences
      _selectedPaletteName = prefs.getString(_paletteKey) ?? 'Electric Orange';
      _isDynamicColorsEnabled = prefs.getBool(_dynamicColorsKey) ?? false;
      
      final brightnessString = prefs.getString(_brightnessKey);
      if (brightnessString != null) {
        _brightness = brightnessString == 'dark' ? Brightness.dark : Brightness.light;
      }
      
      // Mark first run as completed if not already done
      if (isFirstRun) {
        await prefs.setBool(_firstRunKey, false);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Changes the theme palette.
  ///
  /// [paletteName] - The name of the palette to set.
  Future<void> setPalette(String paletteName) async {
    if (_selectedPaletteName != paletteName) {
      _selectedPaletteName = paletteName;
      
      // If selecting Dynamic palette, enable dynamic colors
      if (paletteName == 'Dynamic') {
        _isDynamicColorsEnabled = true;
      } else {
        _isDynamicColorsEnabled = false;
      }
      
      // Persist preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paletteKey, paletteName);
      await prefs.setBool(_dynamicColorsKey, _isDynamicColorsEnabled);
      
      notifyListeners();
    }
  }

  /// Toggles dynamic colors (Monet) on/off.
  ///
  /// This is typically used when the user selects the Dynamic palette
  /// or when Android 12+ dynamic colors are available.
  Future<void> toggleDynamicColors() async {
    _isDynamicColorsEnabled = !_isDynamicColorsEnabled;
    if (_isDynamicColorsEnabled) {
      _selectedPaletteName = 'Dynamic';
    }
    
    // Persist preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicColorsKey, _isDynamicColorsEnabled);
    await prefs.setString(_paletteKey, _selectedPaletteName);
    
    notifyListeners();
  }

  /// Enables or disables dynamic colors.
  ///
  /// [enabled] - Whether to enable dynamic colors.
  Future<void> setDynamicColors(bool enabled) async {
    if (_isDynamicColorsEnabled != enabled) {
      _isDynamicColorsEnabled = enabled;
      if (enabled) {
        _selectedPaletteName = 'Dynamic';
      }
      
      // Persist preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dynamicColorsKey, enabled);
      await prefs.setString(_paletteKey, _selectedPaletteName);
      
      notifyListeners();
    }
  }

  /// Toggles between light and dark mode.
  Future<void> toggleBrightness() async {
    _brightness =
        _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    
    // Persist preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brightnessKey, 
        _brightness == Brightness.dark ? 'dark' : 'light');
    
    notifyListeners();
  }

  /// Sets the brightness mode.
  ///
  /// [brightness] - The brightness mode to set.
  Future<void> setBrightness(Brightness brightness) async {
    if (_brightness != brightness) {
      _brightness = brightness;
      
      // Persist preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_brightnessKey, 
          brightness == Brightness.dark ? 'dark' : 'light');
      
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
