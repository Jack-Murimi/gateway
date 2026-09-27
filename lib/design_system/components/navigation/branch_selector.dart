import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Branch option shown in [BranchSelector].
class BranchOption {
  /// Creates a branch option.
  const BranchOption({required this.id, required this.name, this.color});

  /// Branch identifier.
  final String id;

  /// Branch display name.
  final String name;

  /// Optional branch color for visual distinction.
  final Color? color;
}

/// Compact branch selector chip for the app bar.
///
/// Shows the selected branch as a colored chip. Tapping opens a
/// popup menu to switch branches.
class BranchSelector extends StatelessWidget {
  /// Creates a branch selector.
  const BranchSelector({
    super.key,
    required this.branches,
    required this.selectedBranchId,
    required this.onChanged,
  });

  /// Available branches.
  final List<BranchOption> branches;

  /// Selected branch id.
  final String? selectedBranchId;

  /// Called when branch changes.
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

    final selected = branches.firstWhere(
      (b) => b.id == selectedBranchId,
      orElse: () => branches.first,
    );
    final branchColor = selected.color ?? colorScheme.primary;

    return Semantics(
      label: 'Current branch: ${selected.name}',
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        tooltip: 'Switch branch',
        offset: Offset(0, spacing.touchTarget),
        itemBuilder: (context) => [
          for (final branch in branches)
            PopupMenuItem(
              value: branch.id,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: branch.color ?? colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Text(branch.name),
                  if (branch.id == selectedBranchId) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: colorScheme.primary),
                  ],
                ],
              ),
            ),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: branchColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(spacing.xl),
            border: Border.all(
              color: branchColor.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: branchColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                selected.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: branchColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: spacing.xs),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: branchColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
