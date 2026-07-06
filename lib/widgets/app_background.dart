import 'package:flutter/material.dart';

/// Full-screen Luxora hieroglyph stone texture + light overlay (matches main app).
class AppBackground extends StatelessWidget {
  final Widget child;
  final Color? overlayColor;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveOverlayColor = overlayColor ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.scrim.withValues(alpha: 0.62)
            : theme.colorScheme.surface.withValues(alpha: 0.82));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: theme.colorScheme.surface,
                child: const Center(
                  child: Text('Missing assets/images/bg.jpeg'),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: effectiveOverlayColor),
            ),
          ),
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
