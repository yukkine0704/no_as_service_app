import 'package:flutter/material.dart';

// Material 3 Expressive Color Scheme Variant (Android 16 QPR1)
class _ExpressiveColorScheme {
  static ColorScheme fromSeed({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // Apply Expressive variant adjustments for higher chromatic contrast
    // and more vibrant colors typical of Android 16 ME3
    if (brightness == Brightness.light) {
      return baseScheme.copyWith(
        // Increase primary saturation for more expressive look
        primary: _saturateColor(baseScheme.primary, 0.15),
        onPrimary: baseScheme.onPrimary,
        primaryContainer: _saturateColor(baseScheme.primaryContainer, 0.1),
        onPrimaryContainer: baseScheme.onPrimaryContainer,
        
        // Boost secondary for visual hierarchy
        secondary: _saturateColor(baseScheme.secondary, 0.1),
        onSecondary: baseScheme.onSecondary,
        secondaryContainer: _saturateColor(baseScheme.secondaryContainer, 0.08),
        onSecondaryContainer: baseScheme.onSecondaryContainer,
        
        // Tertiary gets more prominence in expressive
        tertiary: _saturateColor(baseScheme.tertiary, 0.12),
        onTertiary: baseScheme.onTertiary,
        tertiaryContainer: _saturateColor(baseScheme.tertiaryContainer, 0.08),
        onTertiaryContainer: baseScheme.onTertiaryContainer,
        
        // Error colors stay clear
        error: baseScheme.error,
        onError: baseScheme.onError,
        errorContainer: baseScheme.errorContainer,
        onErrorContainer: baseScheme.onErrorContainer,
        
        // Surface colors - minimal shadows, rely on color
        surface: baseScheme.surface,
        onSurface: baseScheme.onSurface,
        surfaceContainerHighest: baseScheme.surfaceContainerHighest,
        onSurfaceVariant: baseScheme.onSurfaceVariant,
        
        // Outline - softer for expressive feel
        outline: baseScheme.outline.withOpacity(0.7),
        outlineVariant: baseScheme.outlineVariant,
        
        // Shadow removed in expressive (rely on color)
        shadow: Colors.transparent,
        scrim: baseScheme.scrim,
        
        // Inverse colors for better contrast
        inverseSurface: baseScheme.inverseSurface,
        onInverseSurface: baseScheme.onInverseSurface,
        inversePrimary: baseScheme.inversePrimary,
      );
    } else {
      // Dark mode - expressive adjustments
      return baseScheme.copyWith(
        primary: _saturateColor(baseScheme.primary, 0.1),
        onPrimary: baseScheme.onPrimary,
        primaryContainer: _saturateColor(baseScheme.primaryContainer, 0.15),
        onPrimaryContainer: baseScheme.onPrimaryContainer,
        
        secondary: _saturateColor(baseScheme.secondary, 0.08),
        onSecondary: baseScheme.onSecondary,
        secondaryContainer: _saturateColor(baseScheme.secondaryContainer, 0.1),
        onSecondaryContainer: baseScheme.onSecondaryContainer,
        
        tertiary: _saturateColor(baseScheme.tertiary, 0.1),
        onTertiary: baseScheme.onTertiary,
        tertiaryContainer: _saturateColor(baseScheme.tertiaryContainer, 0.1),
        onTertiaryContainer: baseScheme.onTertiaryContainer,
        
        error: baseScheme.error,
        onError: baseScheme.onError,
        errorContainer: baseScheme.errorContainer,
        onErrorContainer: baseScheme.onErrorContainer,
        
        surface: baseScheme.surface,
        onSurface: baseScheme.onSurface,
        surfaceContainerHighest: baseScheme.surfaceContainerHighest,
        onSurfaceVariant: baseScheme.onSurfaceVariant,
        
        outline: baseScheme.outline.withOpacity(0.5),
        outlineVariant: baseScheme.outlineVariant,
        
        shadow: Colors.transparent,
        scrim: baseScheme.scrim,
        
        inverseSurface: baseScheme.inverseSurface,
        onInverseSurface: baseScheme.onInverseSurface,
        inversePrimary: baseScheme.inversePrimary,
      );
    }
  }

  /// Increase color saturation for expressive look
  static Color _saturateColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0)).toColor();
  }
}

// Helper to apply Expressive variant to existing ColorScheme
ColorScheme applyExpressiveVariant(ColorScheme scheme, Brightness brightness) {
  return _ExpressiveColorScheme.fromSeed(
    seedColor: scheme.primary,
    brightness: brightness,
  ).copyWith(
    // Preserve original colors but enhance with expressive treatment
    primary: scheme.primary,
    primaryContainer: scheme.primaryContainer,
    secondary: scheme.secondary,
    secondaryContainer: scheme.secondaryContainer,
    tertiary: scheme.tertiary,
    tertiaryContainer: scheme.tertiaryContainer,
    surface: scheme.surface,
    surfaceContainerHighest: scheme.surfaceContainerHighest,
  );
}

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
  static ThemeData _createTheme(ColorScheme colorScheme, {bool expressive = true}) {
    final isDark = colorScheme.brightness == Brightness.dark;
    
    // Apply expressive adjustments if enabled (Material 3 Expressive - Android 16 ME3)
    final effectiveColorScheme = expressive 
        ? applyExpressiveVariant(colorScheme, colorScheme.brightness)
        : colorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: effectiveColorScheme,
      brightness: colorScheme.brightness,
      
      // AppBar theme - flat for expressive
      appBarTheme: AppBarTheme(
        backgroundColor: effectiveColorScheme.surface,
        foregroundColor: effectiveColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),

      // Card theme - minimal elevation, rely on color
      cardTheme: CardThemeData(
        color: effectiveColorScheme.surfaceContainerHighest,
        elevation: 0, // No elevation - use color for hierarchy
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Filled card for containers
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: effectiveColorScheme.primary,
          foregroundColor: effectiveColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColorScheme.surfaceContainerHighest,
          foregroundColor: effectiveColorScheme.onSurface,
          elevation: 0, // Flat in expressive
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: effectiveColorScheme.primary,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: effectiveColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: effectiveColorScheme.primary,
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
              ? effectiveColorScheme.primary
              : isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.selected)
              ? effectiveColorScheme.primary.withOpacity(0.3)
              : isDark ? Colors.grey[600]! : Colors.grey[200]!,
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: effectiveColorScheme.primary,
        inactiveTrackColor: effectiveColorScheme.surfaceContainerHighest,
        thumbColor: effectiveColorScheme.primary,
        overlayColor: effectiveColorScheme.primary.withOpacity(0.2),
      ),

      // Bottom navigation bar - flat style
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: effectiveColorScheme.surface,
        selectedItemColor: effectiveColorScheme.primary,
        unselectedItemColor: effectiveColorScheme.onSurface.withOpacity(0.6),
        elevation: 0, // No elevation
      ),

      // Navigation bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: effectiveColorScheme.surface,
        indicatorColor: effectiveColorScheme.primaryContainer,
        elevation: 0,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: effectiveColorScheme.surfaceContainerHighest,
        selectedColor: effectiveColorScheme.primary,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider theme - subtle
      dividerTheme: DividerThemeData(
        color: effectiveColorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
      ),

      // SnackBar - flat style
      snackBarTheme: SnackBarThemeData(
        backgroundColor: effectiveColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: effectiveColorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: effectiveColorScheme.primaryContainer,
        foregroundColor: effectiveColorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
    return _createTheme(dynamicColorScheme, expressive: true);
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