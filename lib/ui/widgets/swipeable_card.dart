import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:m3e_design/m3e_design.dart' as m3e_design;

import '../../core/models/no_phrase.dart';
import '../../core/localization/phrase_translation_service.dart';
import '../../core/localization/localization_service.dart';

/// Material 3 Expressive Swipeable Card with shape morphing and spring physics.
///
/// Features:
/// - Shape morphing from RoundedRectangleBorder to organic/circular based on drag
/// - Spring physics for natural overshoot animations
/// - Haptic feedback at threshold points
/// - High chromatic contrast colors
/// - Optimized rendering with ValueNotifier for smooth 60fps
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

  /// Whether to show spring physics animations
  final bool useSpringPhysics;

  const SwipeableCard({
    super.key,
    required this.phrase,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.onSwipeCancel,
    this.backgroundColor,
    this.textColor,
    this.useSpringPhysics = true,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  // Spring physics parameters (Android 16 ME3 standard)
  // Using: mass: 1.0, stiffness: 160.0, damping: 14.0
  static final SpringDescription _springDescription = SpringDescription(
    mass: 1.0,
    stiffness: 160.0,
    damping: 14.0,
  );

  // Threshold for triggering actions
  static const double _swipeThreshold = 100.0;
  static const double _velocityThreshold = 500.0;

  // Animation controller for spring motion
  late AnimationController _controller;
  SpringSimulation? _springSimulation;

  // Use ValueNotifier for drag offset to avoid rebuilding during drag
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier(Offset.zero);
  Offset get _dragOffset => _dragOffsetNotifier.value;
  set _dragOffset(Offset value) => _dragOffsetNotifier.value = value;

  // Track if we've triggered haptic feedback for current swipe direction
  bool _hasTriggeredRightHaptic = false;
  bool _hasTriggeredLeftHaptic = false;

  // Track if card is being animated out (to prevent multiple triggers)
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addListener(_onSpringUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSpringUpdate);
    _controller.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _onSpringUpdate() {
    if (_springSimulation != null && mounted) {
      // Update offset via notifier - doesn't rebuild entire widget tree
      final t = _controller.value;
      final springX = _springSimulation!.x(t);
      _dragOffsetNotifier.value = Offset(springX, _dragOffset.dy);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimatingOut) return; // Prevent interaction during exit animation
    _controller.stop();
    _hasTriggeredRightHaptic = false;
    _hasTriggeredLeftHaptic = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut) return;
    
    // Update offset via notifier - more efficient than setState
    _dragOffsetNotifier.value += details.delta;

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

    // Reset if moved back below threshold
    if (absX < threshold * 0.8) {
      if (_dragOffset.dx > 0) {
        _hasTriggeredRightHaptic = false;
      } else {
        _hasTriggeredLeftHaptic = false;
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimatingOut) return;
    
    final velocity = details.velocity.pixelsPerSecond.dx;
    final absOffset = _dragOffset.dx.abs();
    final absVelocity = velocity.abs();

    // Determine action based on offset and velocity
    if (absOffset > _swipeThreshold || absVelocity > _velocityThreshold) {
      if (_dragOffset.dx > 0) {
        // Swipe right - animate out to favorite
        _animateOut(true, velocity);
      } else {
        // Swipe left - animate out to next
        _animateOut(false, velocity);
      }
    } else {
      // Return to center with spring physics
      _animateToCenter(velocity);
    }
  }

  void _animateOut(bool toRight, double initialVelocity) {
    if (_isAnimatingOut) return;
    _isAnimatingOut = true;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = toRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    // IMPORTANT: Call callbacks IMMEDIATELY, not after animation
    // This allows the parent to show the next card while this one animates out
    if (toRight) {
      widget.onSwipeRight?.call();
    } else {
      widget.onSwipeLeft?.call();
    }

    if (widget.useSpringPhysics) {
      // Create spring simulation for natural throw effect
      _springSimulation = SpringSimulation(
        _springDescription,
        _dragOffset.dx, // Start position
        targetX, // End position (far off screen)
        initialVelocity / 1000, // Initial velocity (scale down for physics)
      );

      // Calculate appropriate duration based on spring settling time
      const settlingTime = 0.8; // Approximate settling time
      _controller.duration = Duration(
        milliseconds: (settlingTime * 1000).toInt(),
      );

      _controller.forward(from: 0).then((_) {
        // Reset state after animation completes
        if (mounted) {
          setState(() {
            _dragOffset = Offset.zero;
            _springSimulation = null;
            _isAnimatingOut = false;
          });
        }
      });
    }
  }

  void _animateToCenter(double initialVelocity) {
    if (widget.useSpringPhysics) {
      // Create spring simulation for natural bounce-back
      _springSimulation = SpringSimulation(
        _springDescription,
        _dragOffset.dx, // Start position
        0.0, // End position (center)
        initialVelocity / 1000, // Initial velocity
      );

      // Spring settling time for return to center
      const settlingTime = 0.6;
      _controller.duration = Duration(
        milliseconds: (settlingTime * 1000).toInt(),
      );

      _controller.forward(from: 0).then((_) {
        widget.onSwipeCancel?.call();
        if (mounted) {
          setState(() {
            _springSimulation = null;
          });
        }
      });
    }
  }

  /// Calculate morph factor based on drag distance (0.0 to 1.0)
  double _calculateMorphFactor(Offset offset) {
    final distance = offset.distance;
    final maxDistance = MediaQuery.of(context).size.width * 0.5;
    return (distance / maxDistance).clamp(0.0, 1.0);
  }

  /// Calculate rotation based on horizontal drag
  double _calculateRotation(Offset offset) {
    return offset.dx / 1000 * 0.3; // Subtle rotation
  }

  Color _adjustColorForSwipe(Color baseColor, Offset offset) {
    // Subtle color shift based on swipe direction
    if (offset.dx > _swipeThreshold) {
      // Swiping right - slightly warm (favorite)
      return Color.lerp(
        baseColor,
        Colors.redAccent.withAlpha(25),
        0.3,
      )!;
    } else if (offset.dx < -_swipeThreshold) {
      // Swiping left - slightly cool (next)
      return Color.lerp(
        baseColor,
        Colors.blueGrey.withAlpha(25),
        0.3,
      )!;
    }
    return baseColor;
  }

  Widget _buildCardContent(Color textColor, ColorScheme colorScheme, m3e_design.M3ETheme m3e) {
    // Translate phrase if language is Spanish
    final displayPhrase = LocalizationService().isSpanish
        ? PhraseTranslationService.translate(widget.phrase.phrase)
        : widget.phrase.phrase;
    
    return Padding(
      padding: EdgeInsets.all(m3e.spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // NO prefix with emphasis
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: m3e.spacing.lg,
              vertical: m3e.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: m3e.colors.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(m3e.spacing.lg),
            ),
            child: Text(
              LocalizationService().translate('noPrefix'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor.withAlpha(178),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ),
          ),
          SizedBox(height: m3e.spacing.lg),

          // Main phrase text
          Expanded(
            child: Center(
              child: Text(
                displayPhrase,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: m3e.spacing.md),

          // Category tag
          if (widget.phrase.category != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: m3e.spacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: m3e.colors.secondary.withAlpha(51),
                borderRadius: BorderRadius.circular(m3e.spacing.lg),
              ),
              child: Text(
                widget.phrase.category!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: textColor.withAlpha(204),
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
    final m3e = Theme.of(context).extension<m3e_design.M3ETheme>() ??
                m3e_design.M3ETheme.defaults(colorScheme);

    // Determine colors based on swipe direction
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.backgroundColor ??
        (isDark
            ? m3e.colors.primaryContainer
            : m3e.colors.primaryContainer.withAlpha(242));
    final textColor = widget.textColor ??
        (isDark
            ? m3e.colors.onPrimaryContainer
            : m3e.colors.onPrimaryContainer);

    return ValueListenableBuilder<Offset>(
      valueListenable: _dragOffsetNotifier,
      builder: (context, dragOffset, child) {
        final morphFactor = _calculateMorphFactor(dragOffset);
        final shape = ExpressiveShapes.lerpShapes(morphFactor);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: dragOffset,
            child: Transform.rotate(
              angle: _calculateRotation(dragOffset),
              child: RepaintBoundary(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  margin: EdgeInsets.symmetric(
                    horizontal: m3e.spacing.lg,
                    vertical: m3e.spacing.md,
                  ),
                  decoration: ShapeDecoration(
                    color: _adjustColorForSwipe(baseColor, dragOffset),
                    shape: shape,
                    shadows: [
                      BoxShadow(
                        color: m3e.colors.primary.withAlpha(
                          (20 + morphFactor * 30).toInt(),
                        ),
                        blurRadius: 8 + morphFactor * 12,
                        offset: Offset(0, 4 + morphFactor * 6),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _buildCardContent(textColor, colorScheme, m3e),
    );
  }
}

/// Helper class for Expressive shape morphing
class ExpressiveShapes {
  /// Interpolate between rounded rectangle and organic shape based on factor (0-1)
  static ShapeBorder lerpShapes(double factor) {
    // Start with RoundedRectangleBorder (radius 32 - M3E xl spacing)
    const baseRadius = 32.0;
    final roundedRect = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(baseRadius - (factor * 8)),
    );

    // As factor increases, morph toward a more organic shape
    // Using StadiumBorder for pill-like shape at higher factors
    final organicShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(baseRadius - (factor * 24)),
    );

    // Lerp between shapes for smooth transition
    return ShapeBorder.lerp(roundedRect, organicShape, factor)
        as ShapeBorder;
  }

  /// Create a continuous border radius that morphs based on drag
  static BorderRadius morphBorderRadius(double factor) {
    // Start with uniform 32 radius (M3E xl spacing)
    // As factor increases, create more organic asymmetric radius
    const baseRadius = 32.0;
    final adjustedRadius = baseRadius - (factor * 16);
    final variation = factor * 8;

    return BorderRadius.only(
      topLeft: Radius.circular(adjustedRadius + variation),
      topRight: Radius.circular(adjustedRadius - variation * 0.5),
      bottomLeft: Radius.circular(adjustedRadius - variation * 0.3),
      bottomRight: Radius.circular(adjustedRadius + variation * 0.7),
    );
  }

  /// Interpolate between two shape borders with custom tween
  static ShapeBorder animatedLerp(
    ShapeBorder from,
    ShapeBorder to,
    double progress,
  ) {
    // Use smoothstep for more natural easing
    final smoothProgress = progress * progress * (3 - 2 * progress);
    return ShapeBorder.lerp(from, to, smoothProgress) as ShapeBorder;
  }
}
