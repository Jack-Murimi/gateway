import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Settings screen with app configuration.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  /// Route path.
  static const String routePath = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _notificationsEnabled = true;
  var _soundEnabled = true;
  var _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      selectedIndex: 3,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'Inventory',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
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
      body: _SettingsContent(
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        darkMode: _darkMode,
        onNotificationsChanged: (value) =>
            setState(() => _notificationsEnabled = value),
        onSoundChanged: (value) => setState(() => _soundEnabled = value),
        onDarkModeChanged: (value) => setState(() => _darkMode = value),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/sales');
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/reports');
        break;
    }
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.darkMode,
    required this.onNotificationsChanged,
    required this.onSoundChanged,
    required this.onDarkModeChanged,
  });

  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool darkMode;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'App Settings',
            subtitle: 'Configure your preferences.',
          ),
          SizedBox(height: spacing.lg),
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for low stock and orders',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: onNotificationsChanged,
                ),
              ),
              _SettingsTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound Effects',
                subtitle: 'Play sounds for transactions',
                trailing: Switch(
                  value: soundEnabled,
                  onChanged: onSoundChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                trailing: Switch(value: darkMode, onChanged: onDarkModeChanged),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Manage your account details',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Log out of your account',
                onTap: () {
                  context.go('/login');
                },
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          Center(
            child: Text(
              'Gateway POS v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: spacing.sm),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
