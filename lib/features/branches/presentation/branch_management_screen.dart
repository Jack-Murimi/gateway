import 'package:flutter/material.dart';

import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
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
  final List<Branch> _branches = [
    const Branch(id: 'jamhuri', name: 'Jamhuri', address: 'Jamhuri Road, Nairobi', phone: '0711000001', isActive: true),
    const Branch(id: 'lavington', name: 'Lavington', address: 'Lavington Mall, Nairobi', phone: '0711000002', isActive: true),
    const Branch(id: 'kileleshwa', name: 'Kileleshwa', address: 'Kileleshwa Drive, Nairobi', phone: '0711000003', isActive: true),
    const Branch(id: 'nextgen', name: 'Nextgen', address: 'Nextgen Plaza, Nairobi', phone: '0711000004', isActive: true),
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

  void _deleteBranch(Branch branch) async {
    final confirm = await confirmDialog(
      context,
      title: 'Delete Branch',
      message: 'Are you sure you want to delete "${branch.name}"?',
      confirmText: 'Delete',
    );
    
    if (confirm == true && mounted) {
      setState(() {
        _branches.removeWhere((b) => b.id == branch.id);
      });
    }
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
                separatorBuilder: (_, _) => const Divider(height: 1),
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
      subtitle: Text('${branch.address} • ${branch.phone}'),
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
  showDialog(
    context: context,
    builder: (context) => _BranchDialog(branch: branch, onSave: onSave),
  );
}

class _BranchDialog extends StatefulWidget {
  const _BranchDialog({required this.branch, required this.onSave});

  final Branch? branch;
  final void Function(Branch) onSave;

  @override
  State<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<_BranchDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _addressController = TextEditingController(text: widget.branch?.address ?? '');
    _phoneController = TextEditingController(text: widget.branch?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Branch name is required' : null;
      _phoneError = _phoneController.text.trim().isEmpty
          ? 'Phone is required'
          : !RegExp(r'^[0-9+\-\s()]+$').hasMatch(_phoneController.text.trim())
              ? 'Invalid phone format'
              : null;
    });
    return _nameError == null && _phoneError == null;
  }

  void _save() {
    if (!_validate()) return;

    final newBranch = Branch(
      id: widget.branch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      isActive: widget.branch?.isActive ?? true,
    );
    widget.onSave(newBranch);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isEditing = widget.branch != null;

    return AppDialog(
      title: Text(isEditing ? 'Edit Branch' : 'Add Branch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Branch Name',
              border: const OutlineInputBorder(),
              errorText: _nameError,
            ),
          ),
          SizedBox(height: spacing.lg),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: spacing.lg),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
              border: const OutlineInputBorder(),
              errorText: _phoneError,
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
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
