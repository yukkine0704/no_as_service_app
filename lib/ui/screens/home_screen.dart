import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:fab_m3e/fab_m3e.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:m3e_design/m3e_design.dart';

import '../../providers/phrases_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../widgets/swipeable_card.dart';
import '../widgets/error_offline_view.dart';
import '../widgets/rate_limit_card.dart';
import '../widgets/skeleton_card.dart';

/// Home screen with card swiper for displaying "No" phrases.
///
/// Features:
/// - Swipeable cards with smooth transitions
/// - Swipe right to add to favorites
/// - Swipe left to load next phrase
/// - Loading and error states
/// - Smooth card entry/exit animations
class HomeScreen extends StatefulWidget {
  /// Callback to navigate to favorites
  final VoidCallback? onNavigateToFavorites;

  const HomeScreen({
    super.key,
    this.onNavigateToFavorites,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentPage = 0;
  
  // Track if rate limit card has been shown - keeps it visible even after cooldown
  bool _hasShownRateLimitCard = false;
  
  // Animation controller for card transitions
  late AnimationController _cardTransitionController;
  late Animation<double> _nextCardScaleAnimation;
  late Animation<double> _nextCardOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // Load phrases when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhrases();
    });
    
    // Initialize card transition animations
    _cardTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _nextCardScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _cardTransitionController,
      curve: Curves.easeOutCubic,
    ));
    
    _nextCardOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _cardTransitionController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start with the "next card" visible but subtle
    _cardTransitionController.value = 1.0;
  }

  @override
  void dispose() {
    _cardTransitionController.dispose();
    super.dispose();
  }

  Future<void> _loadPhrases() async {
    final phrasesProvider = context.read<PhrasesProvider>();
    if (phrasesProvider.phrases.isEmpty) {
      await phrasesProvider.fetchAllPhrases();
    }
  }

  static const int _rateLimitCooldownSeconds = 60;

  void _onSwipeLeft() {
    final phrasesProvider = context.read<PhrasesProvider>();
    final phrases = phrasesProvider.phrases;
    
    // Load more phrases if running low (prefetch for smooth experience)
    if (phrases.length - _currentPage < 5) {
      _prefetchPhrases();
    }
    
    // Animate transition
    _cardTransitionController.value = 0.0;
    
    // Go to next card
    if (_currentPage < phrases.length - 1) {
      setState(() => _currentPage++);
    }
    
    // Animate next card into position
    _cardTransitionController.animateTo(1.0, duration: const Duration(milliseconds: 400));
  }

  /// Prefetch additional phrases to ensure smooth swiping
  Future<void> _prefetchPhrases() async {
    final phrasesProvider = context.read<PhrasesProvider>();
    // Fetch up to 4 phrases in the background
    for (int i = 0; i < 4; i++) {
      phrasesProvider.fetchRandomPhrase();
    }
  }

  void _onSwipeRight() async {
    final phrasesProvider = context.read<PhrasesProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final phrases = phrasesProvider.phrases;

    if (_currentPage >= phrases.length) return;

    final phrase = phrases[_currentPage];

    // Add to favorites
    final success = await favoritesProvider.addFavorite(phrase);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Añadido a favoritos: "${phrase.phrase}"'),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Animate transition
      _cardTransitionController.value = 0.0;

      // Navigate to next card after a short delay to show the animation
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _currentPage < phrases.length - 1) {
          setState(() => _currentPage++);
          // Animate next card into position
          _cardTransitionController.animateTo(1.0, duration: const Duration(milliseconds: 400));
          // Prefetch more phrases if needed
          if (phrases.length - _currentPage < 5) {
            _prefetchPhrases();
          }
        }
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBarM3E(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NO',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('NoWay'),
          ],
        ),
        actions: [
          // Favorites button
          IconButtonM3E(
            variant: IconButtonM3EVariant.standard,
            size: IconButtonM3ESize.md,
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: widget.onNavigateToFavorites,
            tooltip: 'Favoritos',
          ),
          // Refresh button
          IconButtonM3E(
            variant: IconButtonM3EVariant.standard,
            size: IconButtonM3ESize.md,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<PhrasesProvider>().refresh();
            },
            tooltip: 'Nueva frase',
          ),
        ],
        centerTitle: true,
        shapeFamily: AppBarM3EShapeFamily.round,
      ),
      body: Consumer2<PhrasesProvider, ConnectivityProvider>(
        builder: (context, phrasesProvider, connectivityProvider, child) {
          // Check for offline state
          if (!connectivityProvider.isConnected) {
            return ErrorOfflineView(
              onNavigateToFavorites: widget.onNavigateToFavorites,
              onRetry: _loadPhrases,
            );
          }

          // Check for rate limit error
          final bool isRateLimitError = phrasesProvider.hasError &&
              phrasesProvider.errorMessage != null &&
              (phrasesProvider.errorMessage!.toLowerCase().contains('rate limit') ||
               phrasesProvider.errorMessage!.toLowerCase().contains('429'));
          
          // Once rate limit is shown, keep it visible until user swipes it away
          if (isRateLimitError) {
            _hasShownRateLimitCard = true;
            debugPrint('[HomeScreen] Rate limit detected, showing card');
          }
          
          // Show rate limit card if it was triggered (even if error clears)
          if (_hasShownRateLimitCard) {
            return _buildCardSwiper(phrasesProvider, showRateLimit: true);
          }

          // Check for loading state - show skeleton loading
          if (phrasesProvider.isLoading && phrasesProvider.phrases.isEmpty) {
            return const SkeletonLoadingView();
          }

          // Check for error state (non-rate-limit)
          if (phrasesProvider.hasError && phrasesProvider.phrases.isEmpty) {
            return ErrorView(
              message: phrasesProvider.errorMessage ?? 'Error desconocido',
              onRetry: _loadPhrases,
            );
          }

          // Check for empty state
          if (phrasesProvider.phrases.isEmpty) {
            return _buildEmptyState();
          }

          // Build card swiper
          return _buildCardSwiper(phrasesProvider, showRateLimit: false);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay frases disponibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón para cargar nuevas frases',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          ButtonM3E(
            onPressed: _loadPhrases,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Cargar frases'),
            style: ButtonM3EStyle.filled,
          ),
        ],
      ),
    );
  }

  Widget _buildCardSwiper(PhrasesProvider phrasesProvider, {bool showRateLimit = false}) {
    final phrases = phrasesProvider.phrases;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Swipeable Cards Stack or Rate Limit Card
        Expanded(
          child: showRateLimit
              ? _buildSwipeableRateLimitCard()
              : _buildCardStack(phrases, phrasesProvider),
        ),

        // Bottom action buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              FabM3E(
                kind: FabM3EKind.surface,
                size: FabM3ESize.small,
                onPressed: _goToPreviousPage,
                icon: Icon(
                  Icons.undo_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              
              // Swipe right (favorite) button
              FabM3E(
                kind: FabM3EKind.primary,
                size: FabM3ESize.regular,
                onPressed: _onSwipeRight,
                icon: Icon(
                  Icons.favorite_rounded,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              
              // Swipe left (skip) button
              FabM3E(
                kind: FabM3EKind.secondary,
                size: FabM3ESize.small,
                onPressed: _onSwipeLeft,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeableRateLimitCard() {
    return _SimpleSwipeableCard(
      child: RateLimitCard(
        cooldownSeconds: _rateLimitCooldownSeconds,
        onNavigateToFavorites: widget.onNavigateToFavorites,
        onCooldownComplete: () {
          // When cooldown completes, just log it
          // Card stays visible until user swipes it
          debugPrint('[HomeScreen] Rate limit cooldown complete');
        },
      ),
      onSwipe: () {
        // Dismiss rate limit card on swipe (either direction)
        setState(() {
          _hasShownRateLimitCard = false;
        });
        _loadPhrases();
      },
    );
  }

  Widget _buildCardStack(List phrases, PhrasesProvider phrasesProvider) {
    if (phrases.isEmpty || _currentPage >= phrases.length) {
      return const SizedBox.shrink();
    }

    // Show current card and next card for depth effect
    final currentPhrase = phrases[_currentPage];
    final hasNextCard = _currentPage < phrases.length - 1;
    final nextPhrase = hasNextCard ? phrases[_currentPage + 1] : null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Next card (behind) - visible when current card is being swiped
        // Uses AnimatedBuilder for smooth entry animation
        if (nextPhrase != null)
          AnimatedBuilder(
            animation: _cardTransitionController,
            builder: (context, child) {
              return Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Transform.scale(
                    scale: _nextCardScaleAnimation.value,
                    child: Opacity(
                      opacity: _nextCardOpacityAnimation.value,
                      child: IgnorePointer(
                        child: SwipeableCard(
                          phrase: nextPhrase,
                          onSwipeRight: () {},
                          onSwipeLeft: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        
        // Current card (front) - swipeable
        // Uses AnimatedSwitcher for smooth exit when page changes
        // Note: Positioned.fill must be OUTSIDE AnimatedSwitcher to avoid ParentDataWidget error
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: SwipeableCard(
              key: ValueKey<int>(_currentPage), // Key changes when page changes
              phrase: currentPhrase,
              onSwipeRight: () {
                _onSwipeRight();
              },
              onSwipeLeft: () {
                _onSwipeLeft();
              },
              onSwipeCancel: () {
                // Card returned to center - no action needed
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple swipeable wrapper for the rate limit card
/// Allows users to swipe away the card in either direction
class _SimpleSwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipe;

  const _SimpleSwipeableCard({
    required this.child,
    required this.onSwipe,
  });

  @override
  State<_SimpleSwipeableCard> createState() => _SimpleSwipeableCardState();
}

class _SimpleSwipeableCardState extends State<_SimpleSwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _dragOffset = Offset.zero;
  bool _isAnimatingOut = false;

  static const double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimatingOut) return;

    final absOffset = _dragOffset.dx.abs();

    if (absOffset > _swipeThreshold) {
      _animateOut();
    } else {
      _animateBack();
    }
  }

  void _animateOut() {
    _isAnimatingOut = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = _dragOffset.dx > 0 ? screenWidth : -screenWidth;

    // Notify parent immediately so next card can appear
    widget.onSwipe();

    _controller.duration = const Duration(milliseconds: 200);
    final startOffset = _dragOffset;
    final endOffset = Offset(targetX, _dragOffset.dy);

    _controller.reset();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.lerp(startOffset, endOffset, _controller.value) ?? endOffset;
        });
      }
    });
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
          _isAnimatingOut = false;
        });
      }
    });
  }

  void _animateBack() {
    _controller.duration = const Duration(milliseconds: 300);
    final startOffset = _dragOffset;

    _controller.reset();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.lerp(startOffset, Offset.zero, _controller.value) ?? Offset.zero;
        });
      }
    });
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _dragOffset,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Simple loading view widget
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicatorM3E(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
          ),
        ],
      ),
    );
  }
}

/// Error view widget with retry button
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ButtonM3E(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ButtonM3EStyle.filled,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
