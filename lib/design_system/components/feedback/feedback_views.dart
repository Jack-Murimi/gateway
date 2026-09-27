import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../buttons/app_button.dart';

/// Centered loading state.
class LoadingView extends StatelessWidget {
  /// Creates a loading view.
  const LoadingView({super.key, this.message = 'Loading'});

  /// Loading message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: spacing.md),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Centered empty state.
class EmptyView extends StatelessWidget {
  /// Creates an empty state.
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  /// Empty state title.
  final String title;

  /// Empty state message.
  final String message;

  /// Empty state icon.
  final IconData icon;

  /// Optional action widget.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: '$title. $message',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.onSurfaceVariant),
            SizedBox(height: spacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: spacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[SizedBox(height: spacing.lg), action!],
          ],
        ),
      ),
    );
  }
}

/// Centered error state.
class ErrorView extends StatelessWidget {
  /// Creates an error state.
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  /// Error title.
  final String title;

  /// Error message.
  final String message;

  /// Optional retry handler.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      label: '$title. $message',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.error),
            SizedBox(height: spacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: spacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: spacing.lg),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline offline banner.
class OfflineBanner extends StatelessWidget {
  /// Creates an offline banner.
  const OfflineBanner({
    super.key,
    this.message = 'Offline mode. Some data may be out of date.',
  });

  /// Banner message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radii = context.radii;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: radii.card,
        ),
        child: Padding(
          padding: spacing.compact,
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: colors.onTertiaryContainer),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
