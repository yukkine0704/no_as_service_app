import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:m3e_design/m3e_design.dart';

import '../../providers/favorites_provider.dart';
import '../../core/localization/localization_service.dart';
import '../widgets/no_card.dart';

/// Favorites screen displaying saved phrases.
///
/// Features:
/// - Scrollable list of saved phrases
/// - Share and delete options for each item
/// - Empty state when no favorites
class FavoritesScreen extends StatefulWidget {
  /// Callback to navigate back
  final VoidCallback? onBack;

  const FavoritesScreen({
    super.key,
    this.onBack,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  void _sharePhrase(String phrase) {
    Clipboard.setData(ClipboardData(text: 'NO: $phrase'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white),
            const SizedBox(width: 8),
            Text(LocalizationService().translate('phraseCopied')),
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

  Future<void> _deletePhrase(String phraseId, String phrase) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text(LocalizationService().translate('removeFromFavorites')),
        content: Text('${LocalizationService().translate('confirmRemove')} "$phrase" ${LocalizationService().translate('fromFavorites')}?'),
        actions: [
          ButtonM3E(
            onPressed: () => Navigator.of(context).pop(false),
            label: Text(LocalizationService().translate('cancel')),
            style: ButtonM3EStyle.text,
          ),
          ButtonM3E(
            onPressed: () => Navigator.of(context).pop(true),
            label: Text(LocalizationService().translate('delete')),
            style: ButtonM3EStyle.filled,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<FavoritesProvider>().removeFavorite(phraseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(LocalizationService().translate('removedFromFavorites')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_sweep),
        title: Text(LocalizationService().translate('deleteAllFavorites')),
        content: Text(LocalizationService().translate('confirmDeleteAll')),
        actions: [
          ButtonM3E(
            onPressed: () => Navigator.of(context).pop(false),
            label: Text(LocalizationService().translate('cancel')),
            style: ButtonM3EStyle.text,
          ),
          ButtonM3E(
            onPressed: () => Navigator.of(context).pop(true),
            label: Text(LocalizationService().translate('deleteAll')),
            style: ButtonM3EStyle.filled,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<FavoritesProvider>().clearAllFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_sweep, color: Colors.white),
                const SizedBox(width: 8),
                Text(LocalizationService().translate('allFavoritesDeleted')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return Scaffold(
      appBar: AppBarM3E(
        leading: IconButtonM3E(
          variant: IconButtonM3EVariant.standard,
          size: IconButtonM3ESize.md,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(LocalizationService().translate('myFavorites')),
          ],
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              if (favoritesProvider.isEmpty) return const SizedBox.shrink();
              return IconButtonM3E(
                variant: IconButtonM3EVariant.standard,
                size: IconButtonM3ESize.md,
                icon: const Icon(Icons.delete_sweep_rounded),
                onPressed: _clearAllFavorites,
                tooltip: LocalizationService().translate('deleteAll'),
              );
            },
          ),
        ],
        centerTitle: true,
        shapeFamily: AppBarM3EShapeFamily.round,
        density: AppBarM3EDensity.regular,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          // Loading state
          if (favoritesProvider.isLoading) {
            return const Center(
              child: LoadingIndicatorM3E(),
            );
          }

          // Empty state
          if (favoritesProvider.isEmpty) {
            return _buildEmptyState(m3e);
          }

          // Favorites list
          return _buildFavoritesList(favoritesProvider, m3e);
        },
      ),
    );
  }

  Widget _buildEmptyState(M3ETheme m3e) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(m3e.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: m3e.colors.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: m3e.colors.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: m3e.spacing.lg),
            
            // Title
            Text(
              LocalizationService().translate('noFavoritesYet'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: m3e.spacing.sm),
            
            // Subtitle
            Text(
              LocalizationService().translate('favoritesAppearHere'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: m3e.colors.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: m3e.spacing.lg),
            
            // Back to home button
            ButtonM3E(
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.swipe_rounded),
              label: Text(LocalizationService().translate('explorePhrases')),
              style: ButtonM3EStyle.filled,
              size: ButtonM3ESize.md,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesProvider favoritesProvider, M3ETheme m3e) {
    final favorites = favoritesProvider.favorites;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header with count
        Container(
          padding: EdgeInsets.all(m3e.spacing.md),
          child: Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: colorScheme.error,
                size: 20,
              ),
              SizedBox(width: m3e.spacing.sm),
              Text(
                '${favorites.length} ${favorites.length == 1 ? LocalizationService().translate('phraseSaved') : LocalizationService().translate('phrasesSaved')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: m3e.colors.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),

        // List of favorites
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: m3e.spacing.md),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final phrase = favorites[index];
              return NoCardCompact(
                phrase: phrase,
                onShare: () => _sharePhrase(phrase.phrase),
                onDelete: () => _deletePhrase(phrase.id, phrase.phrase),
              );
            },
          ),
        ),
      ],
    );
  }
}
