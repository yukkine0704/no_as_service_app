import 'dart:async';
import 'package:flutter/material.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:m3e_design/m3e_design.dart';
import '../../core/enums/offline_card_state.dart';

/// Dynamic offline card with multiple states for the swiping system.
///
/// States:
/// - [OfflineCardState.visibleOffline]: Shows offline UI with wifi-off icon
/// - [OfflineCardState.connectedWaiting]: Shows connected UI with checkmark
/// - [OfflineCardState.autoRevealing]: Shows loading indicator while revealing
///
/// Features:
/// - Animated transitions between states
/// - M3E design system compliance
/// - Auto-reveal countdown visualization
class OfflineCard extends StatefulWidget {
  /// Current state of the offline card
  final OfflineCardState state;

  /// Number of cached phrases available
  final int cachedPhrasesCount;

  /// Callback when user wants to go to favorites
  final VoidCallback? onNavigateToFavorites;

  /// Callback when user manually dismisses the card
  final VoidCallback? onDismiss;

  /// Callback when user wants to check connection
  final VoidCallback? onCheckConnection;

  /// Time remaining for auto-reveal (in seconds)
  final int? autoRevealSecondsRemaining;

  const OfflineCard({
    super.key,
    required this.state,
    required this.cachedPhrasesCount,
    this.onNavigateToFavorites,
    this.onDismiss,
    this.onCheckConnection,
    this.autoRevealSecondsRemaining,
  });

  @override
  State<OfflineCard> createState() => _OfflineCardState();
}

class _OfflineCardState extends State<OfflineCard>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _checkmarkController;
  late AnimationController _transitionController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _opacityAnimation;

  // Local countdown for auto-reveal
  int? _countdownSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _countdownSeconds = widget.autoRevealSecondsRemaining;
  }

  void _initializeAnimations() {
    // Pulse animation for icons
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    // Checkmark animation for connected state
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );

    // Transition animation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _transitionController.forward();
  }

  @override
  void didUpdateWidget(OfflineCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle state transitions
    if (oldWidget.state != widget.state) {
      _onStateChanged(oldWidget.state, widget.state);
    }

    // Handle countdown updates
    if (widget.autoRevealSecondsRemaining != null &&
        widget.autoRevealSecondsRemaining != _countdownSeconds) {
      _startCountdown(widget.autoRevealSecondsRemaining!);
    }
  }

  void _onStateChanged(OfflineCardState oldState, OfflineCardState newState) {
    debugPrint('[OfflineCard] State changed: $oldState -> $newState');

    // Animate transition
    _transitionController.reverse().then((_) {
      if (mounted) {
        _transitionController.forward();
      }
    });

    // Trigger checkmark animation when transitioning to connected
    if (newState == OfflineCardState.connectedWaiting) {
      _checkmarkController.forward();
      _startCountdown(3);
    }

    // Stop countdown when leaving connected state
    if (oldState == OfflineCardState.connectedWaiting &&
        newState != OfflineCardState.connectedWaiting) {
      _stopCountdown();
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_countdownSeconds != null && _countdownSeconds! > 0) {
          _countdownSeconds = _countdownSeconds! - 1;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = null);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _checkmarkController.dispose();
    _transitionController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
        M3ETheme.defaults(colorScheme);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: m3e.spacing.lg,
          vertical: m3e.spacing.md,
        ),
        decoration: _buildDecoration(m3e, colorScheme),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(m3e.spacing.xl),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _OfflinePatternPainter(
                    color: colorScheme.outline.withOpacity(0.08),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(m3e.spacing.xl),
                child: _buildContent(theme, m3e, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(M3ETheme m3e, ColorScheme colorScheme) {
    switch (widget.state) {
      case OfflineCardState.visibleOffline:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surfaceContainerHighest.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(m3e.spacing.xl),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );

      case OfflineCardState.connectedWaiting:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.6),
              colorScheme.tertiaryContainer.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(m3e.spacing.xl),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        );

      case OfflineCardState.autoRevealing:
        return BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(m3e.spacing.xl),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
          ),
        );

      case OfflineCardState.hidden:
        return const BoxDecoration();
    }
  }

  Widget _buildContent(ThemeData theme, M3ETheme m3e, ColorScheme colorScheme) {
    switch (widget.state) {
      case OfflineCardState.visibleOffline:
        return _buildOfflineContent(theme, m3e, colorScheme);
      case OfflineCardState.connectedWaiting:
        return _buildConnectedContent(theme, m3e, colorScheme);
      case OfflineCardState.autoRevealing:
        return _buildRevealingContent(theme, m3e, colorScheme);
      case OfflineCardState.hidden:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOfflineContent(ThemeData theme, M3ETheme m3e, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated wifi-off icon
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _floatController]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: colorScheme.outline,
            ),
          ),
        ),
        SizedBox(height: m3e.spacing.xl),

        // Main message
        Text(
          'Sin conexión',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: m3e.spacing.sm),

        // Subtitle
        Text(
          'Has visto todas las frases disponibles offline',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: m3e.spacing.xs),

        // Cached count badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: m3e.spacing.md,
            vertical: m3e.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(m3e.spacing.lg),
          ),
          child: Text(
            '${widget.cachedPhrasesCount} frases en caché',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: m3e.spacing.xl),

        // Action buttons
        Column(
          children: [
            // Go to favorites button
            if (widget.onNavigateToFavorites != null)
              ButtonM3E(
                onPressed: widget.onNavigateToFavorites,
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('Ver mis favoritos'),
                style: ButtonM3EStyle.filled,
              ),
            SizedBox(height: m3e.spacing.md),

            // Check connection button
            if (widget.onCheckConnection != null)
              ButtonM3E(
                onPressed: widget.onCheckConnection,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Verificar conexión'),
                style: ButtonM3EStyle.outlined,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectedContent(ThemeData theme, M3ETheme m3e, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated checkmark
        ScaleTransition(
          scale: _checkmarkAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        SizedBox(height: m3e.spacing.xl),

        // Main message
        Text(
          '¡Conexión restablecida!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: m3e.spacing.sm),

        // Subtitle with countdown
        Text(
          _countdownSeconds != null && _countdownSeconds! > 0
              ? 'Continuando en $_countdownSeconds segundos...'
              : 'Desliza para continuar',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: m3e.spacing.xl),

        // Continue button
        if (widget.onDismiss != null)
          ButtonM3E(
            onPressed: widget.onDismiss,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Continuar ahora'),
            style: ButtonM3EStyle.filled,
          ),
      ],
    );
  }

  Widget _buildRevealingContent(ThemeData theme, M3ETheme m3e, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loading indicator
        const LoadingIndicatorM3E(),
        SizedBox(height: m3e.spacing.xl),

        // Message
        Text(
          'Cargando nuevas frases...',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Painter for creating a wifi signal pattern background
class _OfflinePatternPainter extends CustomPainter {
  final Color color;

  _OfflinePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final center = Offset(x + spacing / 2, y + spacing / 2);
        const iconSize = 16.0;

        // Draw wifi arc
        final rect = Rect.fromCenter(
          center: center.translate(0, -4),
          width: iconSize,
          height: iconSize,
        );
        canvas.drawArc(rect, -2.5, 2.0, false, paint);

        // Draw slash through wifi
        canvas.drawLine(
          Offset(center.dx - iconSize / 2, center.dy + iconSize / 3),
          Offset(center.dx + iconSize / 2, center.dy - iconSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
