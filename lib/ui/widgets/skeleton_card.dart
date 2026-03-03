import 'package:flutter/material.dart';
import 'package:m3e_design/m3e_design.dart';

/// Skeleton card widget for loading states.
///
/// Mimics the structure of SwipeableCard with shimmer animation
/// to provide a smooth loading experience.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: m3e.spacing.lg,
            vertical: m3e.spacing.md,
          ),
          decoration: BoxDecoration(
            color: m3e.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(m3e.spacing.xl),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  m3e.colors.surfaceContainerHighest,
                  m3e.colors.surfaceContainerHighest.withAlpha(204),
                  m3e.colors.surfaceContainerHighest,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: _SlidingGradientTransform(
                  percent: _shimmerController.value,
                ),
              ).createShader(bounds);
            },
            child: Padding(
              padding: EdgeInsets.all(m3e.spacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NO prefix skeleton
                  Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                      color: m3e.colors.primary.withAlpha(38),
                      borderRadius: BorderRadius.circular(m3e.spacing.lg),
                    ),
                  ),
                  SizedBox(height: m3e.spacing.lg),

                  // Main phrase skeleton - multiple lines
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First line
                          Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              color: m3e.colors.onSurface.withAlpha(26),
                              borderRadius: BorderRadius.circular(m3e.spacing.xs),
                            ),
                          ),
                          SizedBox(height: m3e.spacing.md),
                          // Second line (shorter)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 32,
                            decoration: BoxDecoration(
                              color: m3e.colors.onSurface.withAlpha(26),
                              borderRadius: BorderRadius.circular(m3e.spacing.xs),
                            ),
                          ),
                          SizedBox(height: m3e.spacing.md),
                          // Third line (even shorter)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 32,
                            decoration: BoxDecoration(
                              color: m3e.colors.onSurface.withAlpha(26),
                              borderRadius: BorderRadius.circular(m3e.spacing.xs),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: m3e.spacing.md),

                  // Category tag skeleton
                  Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: m3e.colors.secondary.withAlpha(51),
                      borderRadius: BorderRadius.circular(m3e.spacing.lg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Transform for sliding gradient shimmer effect
class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform({required this.percent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (percent * 2 - 0.5),
      0.0,
      0.0,
    );
  }
}

/// Skeleton loading view for the home screen
/// Shows multiple skeleton cards stacked for a realistic loading preview
class SkeletonLoadingView extends StatelessWidget {
  const SkeletonLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final m3e = Theme.of(context).extension<M3ETheme>() ??
                M3ETheme.defaults(colorScheme);

    return Column(
      children: [
        // Instructions placeholder
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m3e.spacing.lg,
            vertical: m3e.spacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: m3e.colors.outline.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: m3e.colors.primary.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: m3e.colors.outline.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),

        // Card stack skeleton
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background card skeleton
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: m3e.spacing.lg,
                    vertical: m3e.spacing.md,
                  ),
                  child: Transform.scale(
                    scale: 0.95,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: m3e.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(m3e.spacing.xl),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main card skeleton
              const Positioned.fill(
                child: SkeletonCard(),
              ),
            ],
          ),
        ),

        // Bottom buttons skeleton
        Padding(
          padding: EdgeInsets.only(bottom: m3e.spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button skeleton
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: m3e.colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: m3e.spacing.md),

              // Favorite button skeleton
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: m3e.colors.primary.withAlpha(102),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: m3e.spacing.md),

              // Skip button skeleton
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: m3e.colors.secondaryContainer.withAlpha(153),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
