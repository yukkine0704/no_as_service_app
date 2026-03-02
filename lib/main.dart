import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'themes/theme_manager.dart';

void main() {
  runApp(const NoWayApp());
}

class NoWayApp extends StatelessWidget {
  const NoWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'NoWay',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(lightDynamic, Brightness.light),
          darkTheme: _buildTheme(darkDynamic, Brightness.dark),
          themeMode: ThemeMode.system,
          home: const HomePage(),
        );
      },
    );
  }

  // Build theme with dynamic color support (Android 12+ Monet)
  ThemeData _buildTheme(ColorScheme? dynamicColorScheme, Brightness brightness) {
    // If dynamic colors are available (Android 12+), use them
    if (dynamicColorScheme != null) {
      return ThemeManager.createDynamicColorTheme(dynamicColorScheme);
    }
    // Otherwise, fall back to predefined Electric Orange theme
    return ThemeManager.getTheme(ThemeType.electricOrange, brightness);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoWay App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to NoWay!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            // Display available theme palettes
            ...ThemeManager.availablePalettes.map((palette) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: palette['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${palette['name']}: ${palette['description']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
