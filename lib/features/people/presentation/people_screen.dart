import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../domain/staff.dart';
import '../application/staff_providers.dart';

/// People (Staff) screen with role management.
class PeopleScreen extends ConsumerStatefulWidget {
  /// Creates the people screen.
  const PeopleScreen({super.key});

  /// Route path.
  static const String routePath = '/people';

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider);

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
      body: staffAsync.when(
        data: (staff) {
          final filtered = _searchQuery.isEmpty
              ? staff
              : staff.where((s) {
                  final query = _searchQuery.toLowerCase();
                  return s.name.toLowerCase().contains(query) ||
                         s.id.toLowerCase().contains(query);
                }).toList();

          return _PeopleContent(
            searchController: _searchController,
            staff: filtered,
            onSearchChanged: (q) => setState(() => _searchQuery = q),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          title: 'Failed to load staff',
          message: e.toString(),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/sales');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

class _PeopleContent extends StatelessWidget {
  const _PeopleContent({
    required this.searchController,
    required this.staff,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final List<Staff> staff;
  final ValueChanged<String> onSearchChanged;

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
            hintText: 'Name or ID',
            onChanged: onSearchChanged,
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
                    subtitle: Text('Branch: ${member.branchId}${member.phone != null ? ' • ${member.phone}' : ''}'),
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

  void _showStaffDetails(BuildContext context, Staff member) {
    showDialog(
      context: context,
      builder: (context) => _StaffDetailDialog(member: member),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (label, status) = switch (role) {
      UserRole.admin => ('Admin', AppStatus.info),
      UserRole.director => ('Director', AppStatus.success),
      UserRole.salesperson => ('Salesperson', AppStatus.neutral),
      UserRole.rider => ('Rider', AppStatus.neutral),
    };

    return StatusBadge(label: label, status: status);
  }
}

class _StaffDetailDialog extends StatelessWidget {
  const _StaffDetailDialog({required this.member});

  final Staff member;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AppDialog(
      title: Text(member.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${member.id}'),
          SizedBox(height: spacing.sm),
          Text('Role: ${member.role.name.toUpperCase()}'),
          SizedBox(height: spacing.sm),
          Text('Branch: ${member.branchId}'),
          if (member.phone != null) ...[
            SizedBox(height: spacing.sm),
            Text('Phone: ${member.phone}'),
          ],
          SizedBox(height: spacing.sm),
          Text('Status: ${member.isActive ? 'Active' : 'Inactive'}'),
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
              // ponytail: implement staff edit dialog with role picker
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
