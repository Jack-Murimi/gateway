import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/components/cards/app_card.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../application/branch_providers.dart';

/// Branch selection dialog shown after login.
class BranchSelectionDialog extends ConsumerWidget {
  /// Creates the branch selection dialog.
  const BranchSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.spacing;
    final branches = ref.watch(userBranchesProvider);

    return PopScope(
      canPop: false, // not dismissible
      child: AlertDialog(
        title: const Text('Select Branch'),
        content: SizedBox(
          width: 400,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: branches.length,
            separatorBuilder: (context, index) => SizedBox(height: spacing.sm),
            itemBuilder: (context, index) {
              final branch = branches[index];
              return AppCard(
                onTap: () {
                  ref.read(currentBranchProvider.notifier).select(branch);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: spacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        branch.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
