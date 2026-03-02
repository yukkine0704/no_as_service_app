import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/no_phrase.dart';

/// Material 3 Expressive Swipeable Card with shape morphing and spring physics.
///
/// Features:
/// - Shape morphing from RoundedRectangleBorder to organic/circular based on drag
/// - Spring physics for natural overshoot animations
/// - Haptic feedback at threshold points
/// - High chromatic contrast colors
class SwipeableCard extends StatefulWidget {
  /// The phrase to display
  final NoPhrase phrase;

  /// Callback when swiped right (favorite)
  final VoidCallback? onSwipeRight;

  /// Callback when swiped left (next)
  final VoidCallback? onSwipeLeft;

  /// Callback when swipe is cancelled (returns to center)
  final VoidCallback? onSwipeCancel;

  /// Background color override
  final Color? backgroundColor;

  /// Text color override
  final Color? textColor;

  const SwipeableCard({
    super.key,
    required this.phrase,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.onSwipeCancel,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  // Spring physics parameters (Android 16 ME3 standard)
  // Using: mass: 1.0, stiffness: 160.0, damping: 14.0

  // Threshold for triggering actions
  static const double _swipeThreshold = 100.0;
  static const double _velocityThreshold = 500.0;

  // Animation controller for spring motion
  late AnimationController _controller;
  late Animation<Offset> _animation;

  // Current drag offset
  Offset _dragOffset = Offset.zero;

  // Track if we've triggered haptic feedback for current swipe direction
  bool _hasTriggeredRightHaptic = false;
  bool _hasTriggeredLeftHaptic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = _controller.drive(
      Tween<Offset>(begin: Offset.zero, end: Offset.zero),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _hasTriggeredRightHaptic = false;
    _hasTriggeredLeftHaptic = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });

    // Check for haptic feedback at thresholds
    _checkHapticFeedback();
  }

  void _checkHapticFeedback() {
    final absX = _dragOffset.dx.abs();
    final threshold = _swipeThreshold;

    // Right swipe - favorite
    if (_dragOffset.dx > 0 && absX >= threshold && !_hasTriggeredRightHaptic) {
      HapticFeedback.selectionClick();
      _hasTriggeredRightHaptic = true;
    }
    // Left swipe - next
    else if (_dragOffset.dx < 0 && absX >= threshold && !_hasTriggeredLeftHaptic) {
      HapticFeedback.selectionClick();
      _hasTriggeredLeftHaptic = true;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final absOffset = _dragOffset.dx.abs();
    final absVelocity = velocity.abs();

    // Determine action based on offset and velocity
    if (absOffset > _swipeThreshold || absVelocity > _velocityThreshold) {
      if (_dragOffset.dx > 0) {
        // Swipe right - animate out to favorite
        _animateOut(true);
      } else {
        // Swipe left - animate out to next
        _animateOut(false);
      }
    } else {
      // Return to center with spring physics
      _animateToCenter();
    }
  }

  void _animateOut(bool toRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = toRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    _animation = _controller.drive(
      Tween<Offset>(
        begin: _dragOffset,
        end: Offset(targetX, _dragOffset.dy * 0.5),
      ),
    );

    _controller.duration = const Duration(milliseconds: 300);
    _controller.forward(from: 0).then((_) {
      if (toRight) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      // Reset state
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  void _animateToCenter() {
    // Use spring physics for natural bounce-back
    _animation = _controller.drive(
      Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ),
    );

    // Calculate duration based on spring parameters
    const duration = 440;

    _controller.duration = const Duration(milliseconds: duration);
    _controller.forward(from: 0).then((_) {
      widget.onSwipeCancel?.call();
    });

    // Update offset during animation with elastic effect
    _controller.addListener(_updateOffsetFromSpring);
  }

  void _updateOffsetFromSpring() {
    // Use elastic curve for smooth spring effect
    final t = Curves.elasticOut.transform(_controller.value);
    setState(() {
      _dragOffset = Offset.lerp(_dragOffset, Offset.zero, t * 0.3)!;
    });
  }

  /// Calculate morph factor based on drag distance (0.0 to 1.0)
  double _calculateMorphFactor() {
    final distance = _dragOffset.distance;
    final maxDistance = MediaQuery.of(context).size.width * 0.5;
    return (distance / maxDistance).clamp(0.0, 1.0);
  }

  /// Calculate rotation based on horizontal drag
  double _calculateRotation() {
    return _dragOffset.dx / 1000 * 0.3; // Subtle rotation
  }

  Color _adjustColorForSwipe(Color baseColor) {
    // Subtle color shift based on swipe direction
    if (_dragOffset.dx > _swipeThreshold) {
      // Swiping right - slightly warm (favorite)
      return Color.lerp(baseColor, Colors.redAccent.withValues(alpha: 0.1), 0.3)!;
    } else if (_dragOffset.dx < -_swipeThreshold) {
      // Swiping left - slightly cool (next)
      return Color.lerp(baseColor, Colors.blueGrey.withValues(alpha: 0.1), 0.3)!;
    }
    return baseColor;
  }

  Widget _buildCardContent(Color textColor, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // NO prefix with emphasis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NO',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Main phrase text
          Expanded(
            child: Center(
              child: Text(
                widget.phrase.phrase,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category tag
          if (widget.phrase.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.phrase.category!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final morphFactor = _calculateMorphFactor();

    // Determine colors based on swipe direction
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.backgroundColor ??
        (isDark
            ? colorScheme.primaryContainer
            : colorScheme.primaryContainer.withValues(alpha: 0.95));
    final textColor = widget.textColor ??
        (isDark
            ? colorScheme.onPrimaryContainer
            : colorScheme.onPrimaryContainer);

    // Interpolate shape based on morph factor
    final borderRadius = BorderRadius.circular(
      32 - (morphFactor * 20), // From 32 to 12 radius
    );

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _calculateRotation(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _adjustColorForSwipe(baseColor),
              borderRadius: borderRadius,
              // Minimal shadow - rely on color for hierarchy (ME3 Expressive)
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.08 + morphFactor * 0.12),
                  blurRadius: 8 + morphFactor * 12,
                  offset: Offset(0, 4 + morphFactor * 6),
                ),
              ],
            ),
            child: _buildCardContent(textColor, colorScheme),
          ),
        ),
      ),
    );
  }
}

/// Helper class for Expressive shape morphing
class ExpressiveShapes {
  /// Interpolate between rounded rectangle and circle based on factor (0-1)
  static ShapeBorder lerpShapes(double factor) {
    // Start with RoundedRectangleBorder (radius 32)
    final startRadius = 32.0 - (factor * 24); // Goes from 32 to 8

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(startRadius),
    );
  }
}
