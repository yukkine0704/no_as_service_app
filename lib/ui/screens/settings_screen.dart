import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/theme_manager.dart';
import '../../providers/theme_provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack ?? () => Navigator.of(context).pop(),
        ),
        title: const Text('Configuración'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Theme Section
              _buildSectionHeader(context, 'Tema'),
              const SizedBox(height: 8),
              
              // Theme Selector using SegmentedButton
              _buildThemeSelector(context, themeProvider),
              
              const SizedBox(height: 24),
              
              // Dynamic Colors Toggle
              _buildDynamicColorsTile(context, themeProvider),
              
              const Divider(height: 32),
              
              // Appearance Section
              _buildSectionHeader(context, 'Apariencia'),
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
    
    // Available themes (excluding Dynamic for the main selector)
    final themes = [
      {'name': 'Electric Orange', 'type': ThemeType.electricOrange, 'color': AppColorPalettes.electricOrangePrimary},
      {'name': 'Deep Purple', 'type': ThemeType.deepPurple, 'color': AppColorPalettes.deepPurplePrimary},
      {'name': 'Cyber Teal', 'type': ThemeType.cyberTeal, 'color': AppColorPalettes.cyberTealPrimary},
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Theme selection as segmented buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona un tema',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  selected: {themeProvider.isDynamicColorsEnabled ? 'Dynamic' : themeProvider.selectedPaletteName},
                  onSelectionChanged: (Set<String> selection) {
                    final selected = selection.first;
                    if (selected == 'Dynamic') {
                      themeProvider.setDynamicColors(true);
                    } else {
                      themeProvider.setDynamicColors(false);
                      themeProvider.setPalette(selected);
                    }
                  },
                  segments: themes.map((theme) {
                    return ButtonSegment<String>(
                      value: theme['name'] as String,
                      label: Text(
                        (theme['name'] as String).split(' ').first,
                        style: const TextStyle(fontSize: 12),
                      ),
                      icon: Icon(
                        Icons.circle,
                        size: 16,
                        color: theme['color'] as Color,
                      ),
                    );
                  }).toList(),
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
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
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        title: const Text('Colores dinámicos'),
        subtitle: Text(
          'Utiliza los colores de Android 12+ (Monet)',
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
    final isDark = themeProvider.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.indigo : Colors.orange,
            ),
            title: const Text('Modo oscuro'),
            subtitle: Text(
              isDark ? 'Activado' : 'Desactivado',
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
          
          // Segmented button for quick switching
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SegmentedButton<Brightness>(
              selected: {themeProvider.brightness},
              onSelectionChanged: (Set<Brightness> selection) {
                themeProvider.setBrightness(selection.first);
              },
              segments: const [
                ButtonSegment<Brightness>(
                  value: Brightness.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode_rounded, size: 18),
                ),
                ButtonSegment<Brightness>(
                  value: Brightness.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeInfo(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current theme info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
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
                        'Tema actual',
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
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
                      'Los colores se adaptan automáticamente según tu fondo de pantalla en Android 12+',
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
