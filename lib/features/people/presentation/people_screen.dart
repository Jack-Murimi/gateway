import 'package:flutter/material.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// People (Staff) screen with role management.
class PeopleScreen extends StatefulWidget {
  /// Creates the people screen.
  const PeopleScreen({super.key});

  /// Route path.
  static const String routePath = '/people';

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final _searchController = TextEditingController();

  static const _staff = [
    _StaffMember(
      id: '1',
      name: 'Alice Mwangi',
      role: _Role.admin,
      email: 'alice@gateway.co.ke',
      branch: 'All Branches',
    ),
    _StaffMember(
      id: '2',
      name: 'Bob Omondi',
      role: _Role.manager,
      email: 'bob@gateway.co.ke',
      branch: 'Main Branch',
    ),
    _StaffMember(
      id: '3',
      name: 'Carol Njeri',
      role: _Role.cashier,
      email: 'carol@gateway.co.ke',
      branch: 'Main Branch',
    ),
    _StaffMember(
      id: '4',
      name: 'David Kipchoge',
      role: _Role.cashier,
      email: 'david@gateway.co.ke',
      branch: 'Westlands',
    ),
    _StaffMember(
      id: '5',
      name: 'Emily Wambui',
      role: _Role.manager,
      email: 'emily@gateway.co.ke',
      branch: 'Westlands',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staff',
      selectedIndex: 1,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'Staff',
          icon: Icons.badge_outlined,
          selectedIcon: Icons.badge,
        ),
        AppNavDestination(
          label: 'Reports',
          icon: Icons.query_stats_outlined,
          selectedIcon: Icons.query_stats,
        ),
        AppNavDestination(
          label: 'Settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
        ),
      ],
      body: _PeopleContent(searchController: _searchController, staff: _staff),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/sales');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/reports');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
}

class _PeopleContent extends StatelessWidget {
  const _PeopleContent({required this.searchController, required this.staff});

  final TextEditingController searchController;
  final List<_StaffMember> staff;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Staff Management',
            subtitle: 'Manage roles and permissions.',
          ),
          SizedBox(height: spacing.lg),
          AppSearchField(
            label: 'Search staff',
            controller: searchController,
            hintText: 'Name or email',
          ),
          SizedBox(height: spacing.lg),
          if (staff.isEmpty)
            const EmptyView(
              title: 'No staff members',
              message: 'Add your first team member.',
            )
          else
            Column(
              children: staff.map((member) {
                return Card(
                  margin: EdgeInsets.only(bottom: spacing.md),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(member.name.substring(0, 1)),
                    ),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    trailing: _RoleBadge(role: member.role),
                    onTap: () => _showStaffDetails(context, member),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showStaffDetails(BuildContext context, _StaffMember member) {
    showDialog(
      context: context,
      builder: (context) => _StaffDetailDialog(member: member),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final _Role role;

  @override
  Widget build(BuildContext context) {
    final (label, status) = switch (role) {
      _Role.admin => ('Admin', AppStatus.info),
      _Role.manager => ('Manager', AppStatus.success),
      _Role.cashier => ('Cashier', AppStatus.neutral),
    };

    return StatusBadge(label: label, status: status);
  }
}

class _StaffDetailDialog extends StatelessWidget {
  const _StaffDetailDialog({required this.member});

  final _StaffMember member;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(member.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${member.email}'),
          SizedBox(height: spacing.sm),
          Text('Role: ${member.role.name.toUpperCase()}'),
          SizedBox(height: spacing.sm),
          Text('Branch: ${member.branch}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'Edit Permissions',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

enum _Role { admin, manager, cashier }

class _StaffMember {
  const _StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.branch,
  });

  final String id;
  final String name;
  final _Role role;
  final String email;
  final String branch;
}
