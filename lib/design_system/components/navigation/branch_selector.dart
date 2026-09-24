import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Branch option shown in [BranchSelector].
class BranchOption {
  /// Creates a branch option.
  const BranchOption({required this.id, required this.name});

  /// Branch identifier.
  final String id;

  /// Branch display name.
  final String name;
}

/// Accessible branch selector for branch-aware screens.
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
    final spacing = context.spacing;

    return Semantics(
      label: 'Current branch selector',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: spacing.touchTarget),
        child: DropdownMenu<String>(
          initialSelection: selectedBranchId,
          onSelected: onChanged,
          leadingIcon: const Icon(Icons.storefront_outlined),
          label: const Text('Branch'),
          dropdownMenuEntries: [
            for (final branch in branches) DropdownMenuEntry(value: branch.id, label: branch.name),
          ],
        ),
      ),
    );
  }
}
