import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_bar_m3e/app_bar_m3e.dart';
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
/// - Language selector with Chips
/// - Expressive M3E design following Android 16 QPR1 guidelines
class SettingsScreen extends StatelessWidget {
  /// Callback to navigate back
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(Theme.of(context).colorScheme);

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
            padding: EdgeInsets.symmetric(vertical: m3e.spacing.md),
            children: [
              // Theme Preview Card (Expressive)
              _buildThemePreviewCard(context, themeProvider),

              SizedBox(height: m3e.spacing.lg),

              // Appearance Section
              _buildSectionHeader(context, LocalizationService().translate('appearance')),

              SizedBox(height: m3e.spacing.sm),

              // Theme Selector - Simplified with expressive circles
              _buildThemeSelector(context, themeProvider),

              SizedBox(height: m3e.spacing.md),

              // Dynamic Colors Toggle
              _buildDynamicColorsTile(context, themeProvider),

              // M3 Divider with inset
              _buildSectionDivider(context),

              // Display Mode Section
              _buildSectionHeader(context, LocalizationService().translate('displayMode')),

              SizedBox(height: m3e.spacing.sm),

              // Dark/Light Mode Toggle
              _buildDarkModeTile(context, themeProvider),

              // M3 Divider with inset
              _buildSectionDivider(context),

              // Language Section
              _buildSectionHeader(context, LocalizationService().translate('language')),

              SizedBox(height: m3e.spacing.sm),

              // Language Selector with Chips
              _buildLanguageSelector(context),

              SizedBox(height: m3e.spacing.xl),
            ],
          );
        },
      ),
    );
  }

  /// Section header following M3E guidelines
  /// Uses labelLarge with onSurfaceVariant for clear hierarchy
  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m3e.spacing.md,
        vertical: m3e.spacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// M3 Divider with inset for visual grouping
  Widget _buildSectionDivider(BuildContext context) {
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(Theme.of(context).colorScheme);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m3e.spacing.md),
      child: Divider(
        indent: m3e.spacing.md,
        endIndent: m3e.spacing.md,
        height: 1,
      ),
    );
  }

  /// Expressive Theme Preview Card
  /// Shows current active colors in a visual card format
  Widget _buildThemePreviewCard(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      child: Card(
        elevation: 0,
        color: m3e.colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(m3e.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: m3e.spacing.sm),
                  Text(
                    LocalizationService().translate('currentTheme'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              SizedBox(height: m3e.spacing.md),

              // Theme name
              Text(
                themeProvider.isDynamicColorsEnabled
                    ? 'Dynamic (Monet)'
                    : themeProvider.selectedPaletteName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              SizedBox(height: m3e.spacing.md),

              // Color palette preview
              Row(
                children: [
                  _buildColorSwatch(context, colorScheme.primary, 'Primary'),
                  SizedBox(width: m3e.spacing.sm),
                  _buildColorSwatch(context, colorScheme.secondary, 'Secondary'),
                  SizedBox(width: m3e.spacing.sm),
                  _buildColorSwatch(context, colorScheme.tertiary, 'Tertiary'),
                  SizedBox(width: m3e.spacing.sm),
                  _buildColorSwatch(context, colorScheme.surfaceContainerHighest, 'Surface'),
                ],
              ),

              // Dynamic colors note
              if (themeProvider.isDynamicColorsEnabled) ...[
                SizedBox(height: m3e.spacing.md),
                Container(
                  padding: EdgeInsets.all(m3e.spacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      SizedBox(width: m3e.spacing.sm),
                      Expanded(
                        child: Text(
                          LocalizationService().translate('dynamicColorsNote'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Color swatch widget for theme preview
  Widget _buildColorSwatch(BuildContext context, Color color, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Simplified Theme Selector
  /// Uses only expressive circular previews (removed redundant ButtonGroup)
  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    // Available themes
    final themes = [
      {'name': 'Electric Orange', 'type': ThemeType.electricOrange, 'color': AppColorPalettes.electricOrangePrimary},
      {'name': 'Deep Purple', 'type': ThemeType.deepPurple, 'color': AppColorPalettes.deepPurplePrimary},
      {'name': 'Cyber Teal', 'type': ThemeType.cyberTeal, 'color': AppColorPalettes.cyberTealPrimary},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      child: Card(
        elevation: 0,
        color: m3e.colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(m3e.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService().translate('selectTheme'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: m3e.spacing.md),
              // Expressive theme circles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: themes.map((theme) {
                  final isSelected = !themeProvider.isDynamicColorsEnabled &&
                      themeProvider.selectedPaletteName == theme['name'];
                  return _buildThemeCircle(
                    context,
                    theme: theme,
                    isSelected: isSelected,
                    onTap: () async {
                      await themeProvider.setDynamicColors(false);
                      await themeProvider.setPalette(theme['name'] as String);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Expressive theme selection circle
  Widget _buildThemeCircle(
    BuildContext context, {
    required Map<String, dynamic> theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColor = theme['color'] as Color;
    final themeName = (theme['name'] as String).split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isSelected ? 64 : 56,
            height: isSelected ? 64 : 56,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: isSelected ? 0.5 : 0.3),
                  blurRadius: isSelected ? 12 : 8,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            themeName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamic Colors Toggle with improved ListTile
  Widget _buildDynamicColorsTile(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      child: Card(
        elevation: 0,
        color: m3e.colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SwitchListTile(
          value: themeProvider.isDynamicColorsEnabled,
          onChanged: (value) async {
            await themeProvider.setDynamicColors(value);
          },
          secondary: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            LocalizationService().translate('dynamicColors'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            LocalizationService().translate('dynamicColorsDescription'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          activeThumbColor: colorScheme.primary,
          contentPadding: EdgeInsets.symmetric(
            horizontal: m3e.spacing.md,
            vertical: m3e.spacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Dark/Light Mode Toggle with SwitchListTile
  Widget _buildDarkModeTile(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);
    final isDark = themeProvider.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
      child: Card(
        elevation: 0,
        color: m3e.colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SwitchListTile(
              value: isDark,
              onChanged: (value) async {
                await themeProvider.setBrightness(
                  value ? Brightness.dark : Brightness.light,
                );
              },
              secondary: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.indigo.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? Colors.indigo : Colors.orange,
                  size: 24,
                ),
              ),
              title: Text(
                LocalizationService().translate('darkMode'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                isDark
                    ? LocalizationService().translate('enabled')
                    : LocalizationService().translate('disabled'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              activeThumbColor: colorScheme.primary,
              contentPadding: EdgeInsets.symmetric(
                horizontal: m3e.spacing.md,
                vertical: m3e.spacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Language Selector with M3 Chips
  Widget _buildLanguageSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isEnglish = localeProvider.isEnglish;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: m3e.spacing.md),
          child: Card(
            elevation: 0,
            color: m3e.colors.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(m3e.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService().translate('selectLanguage'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: m3e.spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLanguageChip(
                          context,
                          label: 'English',
                          flag: '🇺🇸',
                          isSelected: isEnglish,
                          onSelected: (_) => localeProvider.setEnglish(),
                        ),
                      ),
                      SizedBox(width: m3e.spacing.sm),
                      Expanded(
                        child: _buildLanguageChip(
                          context,
                          label: 'Español',
                          flag: '🇪🇸',
                          isSelected: !isEnglish,
                          onSelected: (_) => localeProvider.setSpanish(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// M3 Language Chip
  Widget _buildLanguageChip(
    BuildContext context, {
    required String label,
    required String flag,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: m3e.spacing.md,
            vertical: m3e.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.secondaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.secondary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              SizedBox(width: m3e.spacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: m3e.spacing.sm),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
