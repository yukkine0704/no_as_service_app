import 'dart:async';
import 'package:flutter/material.dart';

/// An animated rate limit card with playful/mocking design.
///
/// Displays when the user hits the API rate limit (120 requests)
/// with a countdown timer for the cooldown period.
class RateLimitCard extends StatefulWidget {
  /// The remaining cooldown time in seconds
  final int cooldownSeconds;

  /// Callback when the cooldown timer reaches zero
  final VoidCallback? onCooldownComplete;

  /// Callback when the user wants to go to favorites
  final VoidCallback? onNavigateToFavorites;

  const RateLimitCard({
    super.key,
    required this.cooldownSeconds,
    this.onCooldownComplete,
    this.onNavigateToFavorites,
  });

  @override
  State<RateLimitCard> createState() => _RateLimitCardState();
}

class _RateLimitCardState extends State<RateLimitCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    debugPrint('[RateLimitCard] initState - creating controllers');
    _remainingSeconds = widget.cooldownSeconds;

    // Bounce animation for the devil icon
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Shake animation for mischievous effect
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    debugPrint('[RateLimitCard] Controllers created - bounce: $_bounceController, shake: $_shakeController');

    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _bounceController.repeat(reverse: true);
    _shakeController.repeat(reverse: true);

    // Start countdown timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        widget.onCooldownComplete?.call();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    debugPrint('[RateLimitCard] dispose - disposing controllers');
    _bounceController.dispose();
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.errorContainer,
            colorScheme.tertiaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _MischiefPatternPainter(
                  color: colorScheme.error.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated devil/mischievous icon
                  AnimatedBuilder(
                    animation: Listenable.merge([_bounceController, _shakeController]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          20 * _shakeAnimation.value,
                          -10 * _bounceAnimation.value,
                        ),
                        child: Transform.rotate(
                          angle: _shakeAnimation.value * 0.5,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.error.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.sentiment_very_dissatisfied_rounded,
                        size: 56,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main message
                  Text(
                    '¡Alto ahí!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mocking subtitle
                  Text(
                    '¿Tantas negativas necesitas?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Has alcanzado el límite de 120 solicitudes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Countdown timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Espera un poco...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formattedTime,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.error,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action button
                  if (widget.onNavigateToFavorites != null)
                    FilledButton.icon(
                      onPressed: widget.onNavigateToFavorites,
                      icon: const Icon(Icons.favorite_rounded),
                      label: const Text('Ver mis favoritos'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for creating a subtle mischief pattern background
class _MischiefPatternPainter extends CustomPainter {
  final Color color;

  _MischiefPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small X marks scattered around
        final offsetX = (x + spacing / 2) % spacing;
        final offsetY = (y + spacing / 2) % spacing;
        final center = Offset(x + offsetX, y + offsetY);
        const markSize = 8.0;

        canvas.drawLine(
          Offset(center.dx - markSize, center.dy - markSize),
          Offset(center.dx + markSize, center.dy + markSize),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + markSize, center.dy - markSize),
          Offset(center.dx - markSize, center.dy + markSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
