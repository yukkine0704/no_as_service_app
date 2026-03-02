import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/phrases_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../widgets/swipeable_card.dart';
import '../widgets/error_offline_view.dart';

/// Home screen with card swiper for displaying "No" phrases.
///
/// Features:
/// - Swipeable cards
/// - Swipe right to add to favorites
/// - Swipe left to load next phrase
/// - Loading and error states
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

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Load phrases when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhrases();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPhrases() async {
    final phrasesProvider = context.read<PhrasesProvider>();
    if (phrasesProvider.phrases.isEmpty) {
      await phrasesProvider.fetchAllPhrases();
    }
  }

  void _onSwipeLeft() {
    final phrasesProvider = context.read<PhrasesProvider>();
    final phrases = phrasesProvider.phrases;
    
    // Load more phrases if running low
    if (phrases.length - _currentPage < 3) {
      phrasesProvider.fetchRandomPhrase();
    }
    
    // Go to next page
    if (_currentPage < phrases.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSwipeRight() {
    final phrasesProvider = context.read<PhrasesProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final phrases = phrasesProvider.phrases;

    if (_currentPage >= phrases.length) return;

    final phrase = phrases[_currentPage];

    // Add to favorites
    favoritesProvider.addFavorite(phrase);
    if (mounted) {
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
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: widget.onNavigateToFavorites,
            tooltip: 'Favoritos',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<PhrasesProvider>().refresh();
            },
            tooltip: 'Nueva frase',
          ),
        ],
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

          // Check for loading state
          if (phrasesProvider.isLoading && phrasesProvider.phrases.isEmpty) {
            return const LoadingView(
              message: 'Cargando frases...',
            );
          }

          // Check for error state
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
          return _buildCardSwiper(phrasesProvider);
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
          FilledButton.icon(
            onPressed: _loadPhrases,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Cargar frases'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSwiper(PhrasesProvider phrasesProvider) {
    final phrases = phrasesProvider.phrases;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left instruction
              Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Siguiente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
              // Counter
              Text(
                '${_currentPage + 1}/${phrases.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // Right instruction
              Row(
                children: [
                  Text(
                    'Favorito',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Swipeable Cards Stack
        Expanded(
          child: _buildCardStack(phrases, phrasesProvider),
        ),

        // Bottom action buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              FloatingActionButton.small(
                heroTag: 'previous',
                onPressed: _goToPreviousPage,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.undo_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              
              // Swipe right (favorite) button
              FloatingActionButton(
                heroTag: 'favorite',
                onPressed: _onSwipeRight,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.favorite_rounded,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              
              // Swipe left (skip) button
              FloatingActionButton.small(
                heroTag: 'skip',
                onPressed: _onSwipeLeft,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
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
        // Next card (behind)
        if (nextPhrase != null)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Transform.scale(
                scale: 0.95,
                child: Opacity(
                  opacity: 0.5,
                  child: SwipeableCard(
                    phrase: nextPhrase,
                    onSwipeRight: () {},
                    onSwipeLeft: () {},
                  ),
                ),
              ),
            ),
          ),
        
        // Current card (front)
        Positioned.fill(
          child: SwipeableCard(
            key: ValueKey(currentPhrase.id),
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
      ],
    );
  }
}
