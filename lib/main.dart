import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

import 'themes/theme_manager.dart';
import 'providers/theme_provider.dart';
import 'providers/phrases_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/connectivity_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/settings_screen.dart';

void main() {
  runApp(const NoWayApp());
}

class NoWayApp extends StatelessWidget {
  const NoWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => PhrasesProvider()),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'NoWay',
                debugShowCheckedModeBanner: false,
                theme: _buildTheme(themeProvider, Brightness.light, lightDynamic),
                darkTheme: _buildTheme(themeProvider, Brightness.dark, darkDynamic),
                themeMode: themeProvider.isDynamicColorsEnabled 
                    ? ThemeMode.system 
                    : (themeProvider.brightness == Brightness.dark 
                        ? ThemeMode.dark 
                        : ThemeMode.light),
                home: const MainNavigation(),
              );
            },
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(ThemeProvider themeProvider, Brightness brightness, ColorScheme? dynamicColorScheme) {
    // If dynamic colors are enabled and available (Android 12+), use them
    if (themeProvider.isDynamicColorsEnabled && dynamicColorScheme != null) {
      return ThemeManager.createDynamicColorTheme(dynamicColorScheme);
    }
    // Otherwise, use predefined theme based on selected palette
    return ThemeManager.getTheme(themeProvider.currentThemeType, brightness);
  }
}

/// Main navigation widget with bottom navigation bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Initialize screens with callbacks
    _screens.addAll([
      HomeScreen(
        onNavigateToFavorites: () => _onItemTapped(1),
      ),
      FavoritesScreen(
        onBack: () => _onItemTapped(0),
      ),
      SettingsScreen(
        onBack: () => _onItemTapped(0),
      ),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Rebuild screens with updated callbacks when index changes
    final screens = [
      HomeScreen(
        onNavigateToFavorites: () => _onItemTapped(1),
      ),
      FavoritesScreen(
        onBack: () => _onItemTapped(0),
      ),
      SettingsScreen(
        onBack: () => _onItemTapped(0),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: colorScheme.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: colorScheme.error),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: colorScheme.primary),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
