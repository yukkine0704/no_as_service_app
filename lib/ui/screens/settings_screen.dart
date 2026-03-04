import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:m3e_design/m3e_design.dart';

import '../../themes/theme_manager.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/localization/localization_service.dart';

/// Settings screen for theme and appearance customization.
///
/// Features:
/// - Theme selector (Electric Orange, Deep Purple, Cyber Teal)
/// - Dynamic colors toggle (Android 12+ Monet)
/// - Dark/Light mode toggle
class SettingsScreen extends StatelessWidget {
  /// Callback to navigate back
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(
        leading: IconButtonM3E(
          variant: IconButtonM3EVariant.standard,
          size: IconButtonM3ESize.md,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
        titleText: LocalizationService().translate('settings'),
        centerTitle: true,
        shapeFamily: AppBarM3EShapeFamily.round,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Language Section
              _buildSectionHeader(context, LocalizationService().translate('language')),
              const SizedBox(height: 8),
              
              // Language Selector
              _buildLanguageSelector(context),
              
              const Divider(height: 32),
              
              // Theme Section
              _buildSectionHeader(context, LocalizationService().translate('theme')),
              const SizedBox(height: 8),
              
              // Theme Selector using SegmentedButton
              _buildThemeSelector(context, themeProvider),
              
              const SizedBox(height: 24),
              
              // Dynamic Colors Toggle
              _buildDynamicColorsTile(context, themeProvider),
              
              const Divider(height: 32),
              
              // Appearance Section
              _buildSectionHeader(context, LocalizationService().translate('appearance')),
              const SizedBox(height: 8),
              
              // Dark/Light Mode Toggle
              _buildDarkModeTile(context, themeProvider),
              
              const SizedBox(height: 24),
              
              // Theme Info
              _buildThemeInfo(context, themeProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isEnglish = localeProvider.isEnglish;
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
          elevation: 0,
          color: m3e.colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService().translate('selectLanguage'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ButtonGroupM3E(
                  actions: [
                    ButtonGroupM3EAction(
                      label: const Text('🇺🇸 English'),
                      icon: const Icon(Icons.language, size: 18),
                      onPressed: () => localeProvider.setEnglish(),
                    ),
                    ButtonGroupM3EAction(
                      label: const Text('🇪🇸 Español'),
                      icon: const Icon(Icons.language, size: 18),
                      onPressed: () => localeProvider.setSpanish(),
                    ),
                  ],
                  overflow: ButtonGroupM3EOverflow.none,
                  type: ButtonGroupM3EType.standard,
                  shape: ButtonGroupM3EShape.round,
                  selectedIndex: isEnglish ? 0 : 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    
    // Available themes (excluding Dynamic for the main selector)
    final themes = [
      {'name': 'Electric Orange', 'type': ThemeType.electricOrange, 'color': AppColorPalettes.electricOrangePrimary},
      {'name': 'Deep Purple', 'type': ThemeType.deepPurple, 'color': AppColorPalettes.deepPurplePrimary},
      {'name': 'Cyber Teal', 'type': ThemeType.cyberTeal, 'color': AppColorPalettes.cyberTealPrimary},
    ];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      elevation: 0,
      color: m3e.colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Theme selection as button group
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService().translate('selectTheme'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ButtonGroupM3E(
                  actions: themes.map((theme) {
                    return ButtonGroupM3EAction(
                      label: Text(
                        (theme['name'] as String).split(' ').first,
                        style: const TextStyle(fontSize: 12),
                      ),
                      icon: Icon(
                        Icons.circle,
                        size: 16,
                        color: theme['color'] as Color,
                      ),
                      onPressed: () {
                        themeProvider.setDynamicColors(false);
                        themeProvider.setPalette(theme['name'] as String);
                      },
                    );
                  }).toList(),
                  overflow: ButtonGroupM3EOverflow.scroll,
                  type: ButtonGroupM3EType.standard,
                  shape: ButtonGroupM3EShape.round,
                ),
              ],
            ),
          ),
          
          // Theme preview circles
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: themes.map((theme) {
                final isSelected = !themeProvider.isDynamicColorsEnabled && 
                    themeProvider.selectedPaletteName == theme['name'];
                return GestureDetector(
                  onTap: () {
                    themeProvider.setDynamicColors(false);
                    themeProvider.setPalette(theme['name'] as String);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 48 : 40,
                        height: isSelected ? 48 : 40,
                        decoration: BoxDecoration(
                          color: theme['color'] as Color,
                          shape: BoxShape.circle,
                          border: isSelected 
                              ? Border.all(color: colorScheme.primary, width: 3)
                              : null,
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: (theme['color'] as Color).withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                        child: isSelected 
                            ? Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (theme['name'] as String).split(' ').first,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicColorsTile(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      elevation: 0,
      color: m3e.colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.red,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.palette_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(LocalizationService().translate('dynamicColors')),
        subtitle: Text(
          LocalizationService().translate('dynamicColorsDescription'),
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: themeProvider.isDynamicColorsEnabled,
          onChanged: (value) {
            themeProvider.setDynamicColors(value);
          },
        ),
      ),
    );
  }

  Widget _buildDarkModeTile(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    final isDark = themeProvider.brightness == Brightness.dark;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      elevation: 0,
      color: m3e.colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.indigo : Colors.orange,
            ),
            title: Text(LocalizationService().translate('darkMode')),
            subtitle: Text(
              isDark ? LocalizationService().translate('enabled') : LocalizationService().translate('disabled'),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                themeProvider.setBrightness(value ? Brightness.dark : Brightness.light);
              },
            ),
          ),
          
          // Button group for quick switching
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ButtonGroupM3E(
              actions: [
                ButtonGroupM3EAction(
                  label: Text(LocalizationService().translate('light')),
                  icon: const Icon(Icons.light_mode_rounded, size: 18),
                  onPressed: () => themeProvider.setBrightness(Brightness.light),
                ),
                ButtonGroupM3EAction(
                  label: Text(LocalizationService().translate('dark')),
                  icon: const Icon(Icons.dark_mode_rounded, size: 18),
                  onPressed: () => themeProvider.setBrightness(Brightness.dark),
                ),
              ],
              overflow: ButtonGroupM3EOverflow.none,
              type: ButtonGroupM3EType.standard,
              shape: ButtonGroupM3EShape.round,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeInfo(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    
    return Padding(
      padding: EdgeInsets.all(m3e.spacing.md),
      child: Column(
        children: [
          // Current theme info
          Container(
            padding: EdgeInsets.all(m3e.spacing.md),
            decoration: BoxDecoration(
              color: m3e.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService().translate('currentTheme'),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        themeProvider.isDynamicColorsEnabled 
                            ? 'Dynamic (Monet)'
                            : themeProvider.selectedPaletteName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Dynamic colors note
          if (themeProvider.isDynamicColorsEnabled)
            Container(
              padding: EdgeInsets.all(m3e.spacing.sm),
              decoration: BoxDecoration(
                color: m3e.colors.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: m3e.colors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocalizationService().translate('dynamicColorsNote'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
