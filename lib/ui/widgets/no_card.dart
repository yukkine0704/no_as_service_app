import 'package:flutter/material.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:m3e_design/m3e_design.dart';
import '../../core/models/no_phrase.dart';

/// A reusable card widget for displaying "No" phrases.
///
/// Features:
/// - Material 3 design with rounded corners
/// - Bold typography for prominent phrase display
/// - Contrasting container colors
class NoCard extends StatelessWidget {
  /// The phrase to display on the card
  final NoPhrase phrase;

  /// Background color of the card container
  final Color? backgroundColor;

  /// Text color for the phrase
  final Color? textColor;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Creates a new NoCard widget.
  const NoCard({
    super.key,
    required this.phrase,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use contrasting colors based on brightness
    final isDark = theme.brightness == Brightness.dark;
    final cardBackgroundColor = backgroundColor ?? 
        (isDark 
            ? colorScheme.primaryContainer 
            : colorScheme.primaryContainer.withOpacity(0.9));
    final cardTextColor = textColor ?? 
        (isDark 
            ? colorScheme.onPrimaryContainer 
            : colorScheme.onPrimaryContainer);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NO prefix with emphasis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NO',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cardTextColor.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Main phrase text - Display Large for prominence
              Expanded(
                child: Center(
                  child: Text(
                    phrase.phrase,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: cardTextColor,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Category tag if available
              if (phrase.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    phrase.category!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cardTextColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A variant of NoCard for favorites list with more compact design
class NoCardCompact extends StatelessWidget {
  /// The phrase to display
  final NoPhrase phrase;
  
  /// Callback when share button is pressed
  final VoidCallback? onShare;
  
  /// Callback when delete button is pressed
  final VoidCallback? onDelete;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const NoCardCompact({
    super.key,
    required this.phrase,
    this.onShare,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: m3e.colors.surfaceContainerHigh,
      margin: EdgeInsets.symmetric(
        horizontal: m3e.spacing.md,
        vertical: m3e.spacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(m3e.spacing.md),
          child: Row(
            children: [
              // NO indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m3e.spacing.sm,
                  vertical: m3e.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: m3e.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: m3e.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(width: m3e.spacing.md),
              
              // Phrase text
              Expanded(
                child: Text(
                  phrase.phrase,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onShare != null)
                    IconButtonM3E(
                      variant: IconButtonM3EVariant.standard,
                      size: IconButtonM3ESize.sm,
                      icon: Icon(
                        Icons.share_rounded,
                        color: colorScheme.primary,
                      ),
                      onPressed: onShare,
                      tooltip: 'Share',
                    ),
                  if (onDelete != null)
                    IconButtonM3E(
                      variant: IconButtonM3EVariant.standard,
                      size: IconButtonM3ESize.sm,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
