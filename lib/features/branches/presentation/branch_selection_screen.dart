import 'package:flutter/material.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/branch_selector.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Branch selection screen after login.
class BranchSelectionScreen extends StatelessWidget {
  /// Creates the branch selection screen.
  const BranchSelectionScreen({super.key});

  /// Route path.
  static const String routePath = '/select-branch';

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final branches = const [
      BranchOption(id: 'main', name: 'Main Branch'),
      BranchOption(id: 'west', name: 'Westlands'),
      BranchOption(id: 'east', name: 'Eastleigh'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: spacing.page,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Select Branch',
                    subtitle: 'Choose your working location for this session.',
                  ),
                  SizedBox(height: spacing.xl),
                  _BranchList(branches: branches),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchList extends StatelessWidget {
  const _BranchList({required this.branches});

  final List<BranchOption> branches;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final branch in branches) ...[
          AppButton(
            label: branch.name,
            variant: AppButtonVariant.secondary,
            onPressed: () => _selectBranch(context, branch.id),
            icon: Icons.store_outlined,
          ),
          SizedBox(height: spacing.md),
        ],
      ],
    );
  }

  void _selectBranch(BuildContext context, String branchId) {
    // ponytail: replace with real branch state management when ready
    // For now, navigate to POS
    Navigator.of(context).pop(branchId);
  }
}
