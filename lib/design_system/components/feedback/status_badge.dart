import 'package:flutter/material.dart';

import '../../theme/semantic_colors.dart';

/// Visual status indicator with semantic color and icon.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.status,
    super.key,
  });

  final String label;
  final StatusType status;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final (bg, fg, icon) = switch (status) {
      StatusType.success => (
          semantic.successContainer,
          semantic.onSuccessContainer,
          Icons.check_circle,
        ),
      StatusType.warning => (
          semantic.warningContainer,
          semantic.onWarningContainer,
          Icons.warning,
        ),
      StatusType.danger => (
          semantic.dangerContainer,
          semantic.onDangerContainer,
          Icons.error,
        ),
      StatusType.info => (
          semantic.infoContainer,
          semantic.onInfoContainer,
          Icons.info,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType {
  success,
  warning,
  danger,
  info,
}
