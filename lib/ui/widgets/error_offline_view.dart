import 'package:flutter/material.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:m3e_design/m3e_design.dart' hide SpringDescription;

import '../../core/localization/localization_service.dart';

/// An expressive animated offline error view with M3E design.
///
/// Features:
/// - Expanding radar waves animation (searching for signal)
/// - Floating icon with dynamic shadows
/// - Typewriter text animation
/// - M3E spring physics and easing
class ErrorOfflineView extends StatefulWidget {
  /// Callback when the "Go to Favorites" button is pressed
  final VoidCallback? onNavigateToFavorites;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom message to display
  final String? message;

  const ErrorOfflineView({
    super.key,
    this.onNavigateToFavorites,
    this.onRetry,
    this.message,
  });

  @override
  State<ErrorOfflineView> createState() => _ErrorOfflineViewState();
}

class _ErrorOfflineViewState extends State<ErrorOfflineView>
    with TickerProviderStateMixin {
  // Controller for floating animation
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _shadowAnimation;
  
  // Controller for radar waves
  late AnimationController _radarController;
  
  // Controller for typewriter text
  late AnimationController _typewriterController;
  late Animation<int> _typewriterAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating animation with spring physics feel
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    
    _shadowAnimation = Tween<double>(begin: 20, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    
    // Radar waves animation
    _radarController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
          // Typewriter animation
          final String fullText = LocalizationService().translate('checkInternet');
    _typewriterController = AnimationController(
      duration: Duration(milliseconds: fullText.length * 50 + 500),
      vsync: this,
    );
    
    _typewriterAnimation = IntTween(
      begin: 0,
      end: fullText.length,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
    ));
    
    // Start animations
    _floatController.repeat(reverse: true);
    _radarController.repeat();
    _typewriterController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _radarController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(m3e.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radar waves with floating icon
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Expanding radar waves
                  ...List.generate(3, (index) {
                    return _buildRadarWave(index, m3e);
                  }),
                  
                  // Floating icon with dynamic shadow
                  AnimatedBuilder(
                    animation: Listenable.merge([_floatController, _shadowAnimation]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: m3e.colors.errorContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: m3e.colors.error.withOpacity(
                                  0.1 + (20 - _shadowAnimation.value) / 40,
                                ),
                                blurRadius: _shadowAnimation.value,
                                spreadRadius: _shadowAnimation.value / 4,
                                offset: Offset(0, 10 - _floatAnimation.value / 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: m3e.colors.onErrorContainer,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: m3e.spacing.xl),

            // Main error message with fade in
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                LocalizationService().translate('oops'),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: m3e.colors.error,
                ),
              ),
            ),
            
            SizedBox(height: m3e.spacing.sm),

            // Secondary message with fade in (delayed)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                widget.message ?? LocalizationService().translate('worldWantsYes'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: m3e.colors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: m3e.spacing.sm),
            
            // Typewriter animated text
            AnimatedBuilder(
              animation: _typewriterAnimation,
              builder: (context, child) {
                const String fullText = 'Verifica tu conexión a internet';
                final visibleText = fullText.substring(
                  0, 
                  _typewriterAnimation.value.clamp(0, fullText.length),
                );
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      visibleText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: m3e.colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                    // Blinking cursor
                    if (_typewriterAnimation.value < fullText.length)
                      _BlinkingCursor(color: m3e.colors.error),
                  ],
                );
              },
            ),
            
            SizedBox(height: m3e.spacing.xxl),

            // Action buttons with staggered animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retry button
                  if (widget.onRetry != null)
                    ButtonM3E(
                      style: ButtonM3EStyle.outlined,
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(LocalizationService().translate('retry')),
                    ),
                  if (widget.onRetry != null && widget.onNavigateToFavorites != null)
                    SizedBox(width: m3e.spacing.md),
                  
                  // Navigate to favorites button
                  if (widget.onNavigateToFavorites != null)
                    ButtonM3E(
                      style: ButtonM3EStyle.filled,
                      onPressed: widget.onNavigateToFavorites,
                      icon: const Icon(Icons.favorite_rounded),
                      label: Text(LocalizationService().translate('myFavorites')),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarWave(int index, M3ETheme m3e) {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        // Stagger the waves
        final double progress = (_radarController.value + (index * 0.33)) % 1.0;
        final double scale = 0.5 + (progress * 1.5);
        final double opacity = (1 - progress) * 0.3;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: m3e.colors.error.withOpacity(opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Blinking cursor widget for typewriter effect
class _BlinkingCursor extends StatefulWidget {
  final Color color;
  
  const _BlinkingCursor({required this.color});
  
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 16,
            color: widget.color,
            margin: const EdgeInsets.only(left: 2),
          ),
        );
      },
    );
  }
}

/// An expressive animated error view for general errors (not just offline)
///
/// Features:
/// - Pulsing error rings animation
/// - Floating LoadingIndicatorM3E with dynamic shadows
/// - Staggered fade-in animations
/// - M3E spring physics and easing
class ErrorView extends StatefulWidget {
  /// The error message to display
  final String message;
  
  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView>
    with TickerProviderStateMixin {
  // Controller for floating animation
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _shadowAnimation;
  
  // Controller for pulsing rings
  late AnimationController _pulseController;
  
  // Controller for shake effect
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    
    _shadowAnimation = Tween<double>(begin: 18, end: 6).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    
    // Pulse animation for rings
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Shake animation for error effect
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    
    // Start animations
    _floatController.repeat(reverse: true);
    _pulseController.repeat();
    
    // Trigger shake after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(m3e.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing rings with floating loading indicator
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing error rings
                  ...List.generate(3, (index) {
                    return _buildPulseRing(index, m3e);
                  }),
                  
                  // Floating LoadingIndicatorM3E with shake and dynamic shadow
                  AnimatedBuilder(
                    animation: Listenable.merge([_floatController, _shadowAnimation]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _shakeAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: m3e.colors.errorContainer,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: m3e.colors.error.withOpacity(
                                    0.15 + (18 - _shadowAnimation.value) / 50,
                                  ),
                                  blurRadius: _shadowAnimation.value,
                                  spreadRadius: _shadowAnimation.value / 3,
                                  offset: Offset(0, 8 - _floatAnimation.value / 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: LoadingIndicatorM3E(
                                color: m3e.colors.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: m3e.spacing.xl),

            // Main error message with fade in and slide
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 25 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                LocalizationService().translate('somethingWentWrong'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: m3e.colors.error,
                ),
              ),
            ),
            
            SizedBox(height: m3e.spacing.md),

            // Error message with typewriter-like reveal
            _TypewriterText(
              text: widget.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: m3e.colors.onSurface.withOpacity(0.7),
              ),
            ),
            
            SizedBox(height: m3e.spacing.xxl),

            // Retry button with bounce animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: widget.onRetry != null
                ? ButtonM3E(
                    style: ButtonM3EStyle.filled,
                    onPressed: () {
                      // Trigger shake on retry
                      _shakeController.forward().then((_) => _shakeController.reverse());
                      widget.onRetry!();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(LocalizationService().translate('retry')),
                  )
                : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing(int index, M3ETheme m3e) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Stagger the pulses
        final double progress = (_pulseController.value + (index * 0.33)) % 1.0;
        final double scale = 0.6 + (progress * 1.3);
        final double opacity = (1 - progress) * 0.25;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: m3e.colors.error.withOpacity(opacity),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Typewriter text widget for error messages
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  
  const _TypewriterText({
    required this.text,
    this.style,
  });
  
  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 30 + 300),
      vsync: this,
    );
    
    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final visibleText = widget.text.substring(
          0,
          _animation.value.clamp(0, widget.text.length),
        );
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                visibleText,
                style: widget.style,
                textAlign: TextAlign.center,
              ),
            ),
            if (_animation.value < widget.text.length)
              _BlinkingCursor(color: widget.style?.color ?? Colors.grey),
          ],
        );
      },
    );
  }
}

/// A loading view with animated indicator
class LoadingView extends StatelessWidget {
  /// Optional message to display
  final String? message;

  const LoadingView({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicatorM3E(
            color: m3e.colors.primary,
          ),
          if (message != null) ...[
            SizedBox(height: m3e.spacing.md),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: m3e.colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
