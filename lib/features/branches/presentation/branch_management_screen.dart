import 'package:flutter/material.dart';

import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Branch model for management.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? isActive,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Branch management screen with CRUD operations.
class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  static const String routePath = '/branches';

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final List<Branch> _branches = const [
    Branch(id: 'jamhuri', name: 'Jamhuri', address: 'Jamhuri Road, Nairobi', phone: '0711000001', isActive: true),
    Branch(id: 'lavington', name: 'Lavington', address: 'Lavington Mall, Nairobi', phone: '0711000002', isActive: true),
    Branch(id: 'kileleshwa', name: 'Kileleshwa', address: 'Kileleshwa Drive, Nairobi', phone: '0711000003', isActive: true),
    Branch(id: 'nextgen', name: 'Nextgen', address: 'Nextgen Plaza, Nairobi', phone: '0711000004', isActive: true),
  ];

  void _addBranch() {
    _showBranchDialog(context, onSave: (branch) {
      setState(() {
        _branches.add(branch);
      });
    });
  }

  void _editBranch(Branch branch) {
    _showBranchDialog(context, branch: branch, onSave: (updated) {
      setState(() {
        final index = _branches.indexWhere((b) => b.id == branch.id);
        if (index >= 0) _branches[index] = updated;
      });
    });
  }

  void _deleteBranch(Branch branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete \"\"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _branches.removeWhere((b) => b.id == branch.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleBranchStatus(Branch branch) {
    setState(() {
      final index = _branches.indexWhere((b) => b.id == branch.id);
      if (index >= 0) {
        _branches[index] = branch.copyWith(isActive: !branch.isActive);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AppScaffold(
      title: 'Branch Management',
      selectedIndex: -1,
      onDestinationSelected: (_) {},
      destinations: const [
        AppNavDestination(label: 'Sales', icon: Icons.point_of_sale_outlined),
        AppNavDestination(label: 'Inventory', icon: Icons.inventory_2_outlined),
        AppNavDestination(label: 'Reports', icon: Icons.query_stats_outlined),
        AppNavDestination(label: 'Settings', icon: Icons.settings_outlined),
      ],
      body: SingleChildScrollView(
        padding: spacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Branches',
              subtitle: 'Manage your branch locations.',
            ),
            SizedBox(height: spacing.md),
            Row(
              children: [
                const Spacer(),
                FilledButton.icon(
                  onPressed: _addBranch,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Branch'),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _branches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final branch = _branches[index];
                  return _BranchTile(
                    branch: branch,
                    onEdit: () => _editBranch(branch),
                    onDelete: () => _deleteBranch(branch),
                    onToggleStatus: () => _toggleBranchStatus(branch),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.branch,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final Branch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: branch.isActive ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.store_outlined,
          color: branch.isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        branch.name,
        style: TextStyle(
          color: branch.isActive ? null : colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(' • '),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: branch.isActive,
            onChanged: (_) => onToggleStatus(),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

void _showBranchDialog(
  BuildContext context, {
  Branch? branch,
  required void Function(Branch) onSave,
}) {
  final isEditing = branch != null;
  final nameController = TextEditingController(text: branch?.name ?? '');
  final addressController = TextEditingController(text: branch?.address ?? '');
  final phoneController = TextEditingController(text: branch?.phone ?? '');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isEditing ? 'Edit Branch' : 'Add Branch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Branch Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final newBranch = Branch(
              id: branch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: nameController.text,
              address: addressController.text,
              phone: phoneController.text,
              isActive: branch?.isActive ?? true,
            );
            onSave(newBranch);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
