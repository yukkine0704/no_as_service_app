import 'package:flutter/material.dart';

// Predefined color palettes
class AppColorPalettes {
  // Electric Orange - Vibrant & Energetic
  static const Color electricOrangePrimary = Color(0xFFFF6B00);
  static const Color electricOrangeSecondary = Color(0xFFFF8F33);
  static const Color electricOrangeTertiary = Color(0xFFFFB86C);
  static const Color electricOrangeNeutral = Color(0xFF2C2C2C);
  static const Color electricOrangeNeutralVariant = Color(0xFF4D4D4D);

  // Deep Purple - Elegant & Modern
  static const Color deepPurplePrimary = Color(0xFF6366F1);
  static const Color deepPurpleSecondary = Color(0xFF818CF8);
  static const Color deepPurpleTertiary = Color(0xFFA5B4FC);
  static const Color deepPurpleNeutral = Color(0xFF1E1B4B);
  static const Color deepPurpleNeutralVariant = Color(0xFF312E81);

  // Cyber Teal - Futuristic & Dynamic
  static const Color cyberTealPrimary = Color(0xFF06B6D4);
  static const Color cyberTealSecondary = Color(0xFF22D3EE);
  static const Color cyberTealTertiary = Color(0xFF67E8F9);
  static const Color cyberTealNeutral = Color(0xFF0F172A);
  static const Color cyberTealNeutralVariant = Color(0xFF1E293B);
}

enum ThemeType {
  electricOrange,
  deepPurple,
  cyberTeal,
  dynamic, // Android 12+ dynamic colors
}

class ThemeManager {
  // Create a color scheme from predefined colors (Material 3)
  static ColorScheme _createColorScheme(Color primary, Color secondary, 
                                       Color tertiary, Color neutral, 
                                       Color neutralVariant, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      secondary: secondary,
      tertiary: tertiary,
      surface: brightness == Brightness.light ? Colors.white : neutral,
      surfaceVariant: brightness == Brightness.light 
          ? const Color(0xFFF5F5F5) 
          : neutralVariant,
      background: brightness == Brightness.light ? Colors.white : neutral,
      error: Colors.redAccent,
    );
  }

  // Create a Material 3 theme with specified color palette
  static ThemeData _createTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.selected)
              ? colorScheme.primary
              : isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.selected)
              ? colorScheme.primary.withOpacity(0.3)
              : isDark ? Colors.grey[600]! : Colors.grey[200]!,
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceVariant,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.2),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
        elevation: 8,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.surfaceVariant,
        thickness: 1,
      ),
    );
  }

  // Get predefined theme for a specific type
  static ThemeData getTheme(ThemeType type, Brightness brightness) {
    switch (type) {
      case ThemeType.electricOrange:
        return _createTheme(
          _createColorScheme(
            AppColorPalettes.electricOrangePrimary,
            AppColorPalettes.electricOrangeSecondary,
            AppColorPalettes.electricOrangeTertiary,
            AppColorPalettes.electricOrangeNeutral,
            AppColorPalettes.electricOrangeNeutralVariant,
            brightness,
          ),
        );
      
      case ThemeType.deepPurple:
        return _createTheme(
          _createColorScheme(
            AppColorPalettes.deepPurplePrimary,
            AppColorPalettes.deepPurpleSecondary,
            AppColorPalettes.deepPurpleTertiary,
            AppColorPalettes.deepPurpleNeutral,
            AppColorPalettes.deepPurpleNeutralVariant,
            brightness,
          ),
        );
      
      case ThemeType.cyberTeal:
        return _createTheme(
          _createColorScheme(
            AppColorPalettes.cyberTealPrimary,
            AppColorPalettes.cyberTealSecondary,
            AppColorPalettes.cyberTealTertiary,
            AppColorPalettes.cyberTealNeutral,
            AppColorPalettes.cyberTealNeutralVariant,
            brightness,
          ),
        );
      
      case ThemeType.dynamic:
        // Dynamic color theme is created from system colors (handled in main)
        // This fallback ensures we still return a valid theme
        return getTheme(ThemeType.electricOrange, brightness);
    }
  }

  // Create dynamic color theme (Android 12+ Monet colors)
  static ThemeData createDynamicColorTheme(ColorScheme dynamicColorScheme) {
    return _createTheme(dynamicColorScheme);
  }

  // Helper method to get predefined palettes for UI selection
  static List<Map<String, dynamic>> get availablePalettes => [
        {
          'name': 'Electric Orange',
          'type': ThemeType.electricOrange,
          'color': AppColorPalettes.electricOrangePrimary,
          'description': 'Vibrant & energetic',
        },
        {
          'name': 'Deep Purple',
          'type': ThemeType.deepPurple,
          'color': AppColorPalettes.deepPurplePrimary,
          'description': 'Elegant & modern',
        },
        {
          'name': 'Cyber Teal',
          'type': ThemeType.cyberTeal,
          'color': AppColorPalettes.cyberTealPrimary,
          'description': 'Futuristic & dynamic',
        },
        {
          'name': 'Dynamic',
          'type': ThemeType.dynamic,
          'color': const Color(0xFF6200EE),
          'description': 'Android 12+ dynamic colors',
        },
      ];
}