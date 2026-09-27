import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/cards/stat_card.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/navigation/branch_selector.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Reports dashboard with KPIs and charts.
class ReportsScreen extends StatefulWidget {
  /// Creates the reports screen.
  const ReportsScreen({super.key});

  /// Route path.
  static const String routePath = '/reports';

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  var _selectedBranchId = 'all';

  static const _branches = [
    BranchOption(id: 'all', name: 'All Branches'),
    BranchOption(id: 'main', name: 'Main Branch'),
    BranchOption(id: 'west', name: 'Westlands'),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return AppScaffold(
      title: 'Reports',
      selectedIndex: 2,
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
      actions: [
        Padding(
          padding: spacing.compact,
          child: BranchSelector(
            branches: _branches,
            selectedBranchId: _selectedBranchId,
            onChanged: (id) => setState(() => _selectedBranchId = id ?? 'all'),
          ),
        ),
      ],
      body: _ReportsContent(currency: currency),
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
      case 3:
        context.go('/settings');
        break;
    }
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.currency});

  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Dashboard',
            subtitle: 'Business performance overview.',
          ),
          SizedBox(height: spacing.lg),
          AppTextField(
            label: 'Filter by date range',
            controller: TextEditingController(text: 'Last 7 days'),
            hintText: 'Select range',
            prefixIcon: Icons.date_range,
          ),
          SizedBox(height: spacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final cardWidth = isWide
                  ? (constraints.maxWidth - spacing.lg * 3) / 4
                  : constraints.maxWidth;

              return Wrap(
                spacing: spacing.lg,
                runSpacing: spacing.lg,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Total Sales',
                      value: currency.format(245800),
                      icon: Icons.trending_up,
                      supportingText: '+12% from last week',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Transactions',
                      value: '156',
                      icon: Icons.receipt_long,
                      supportingText: '23 today',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Avg. Sale',
                      value: currency.format(1575),
                      icon: Icons.analytics,
                      supportingText: '+8% increase',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      label: 'Customers',
                      value: '89',
                      icon: Icons.people,
                      supportingText: 'Active this week',
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: spacing.xl),
          const SectionHeader(
            title: 'Top Products',
            subtitle: 'Best selling items this period.',
          ),
          SizedBox(height: spacing.lg),
          _TopProductsList(currency: currency),
          SizedBox(height: spacing.xl),
          const SectionHeader(
            title: 'Branch Comparison',
            subtitle: 'Performance across locations.',
          ),
          SizedBox(height: spacing.lg),
          _BranchComparison(currency: currency),
        ],
      ),
    );
  }
}

class _TopProductsList extends StatelessWidget {
  const _TopProductsList({required this.currency});

  final NumberFormat currency;

  static const _products = [
    ('13kg LPG Cylinder Refill', 45, 148500),
    ('6kg LPG Cylinder Refill', 38, 68400),
    ('Double Burner Stove', 12, 57600),
    ('Burner Regulator Kit', 23, 28750),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: _products.asMap().entries.map((entry) {
          final (name, quantity, total) = entry.value;
          return ListTile(
            leading: CircleAvatar(child: Text('#${entry.key + 1}')),
            title: Text(name),
            subtitle: Text('$quantity sold'),
            trailing: Text(
              currency.format(total),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BranchComparison extends StatelessWidget {
  const _BranchComparison({required this.currency});

  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final branches = [
      ('Main Branch', 156200, 0.64),
      ('Westlands', 89600, 0.36),
    ];

    return Column(
      children: branches.map((branch) {
        final (name, total, percent) = branch;
        return Card(
          margin: EdgeInsets.only(bottom: spacing.md),
          child: Padding(
            padding: spacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      currency.format(total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),
                LinearProgressIndicator(value: percent, minHeight: 8),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
