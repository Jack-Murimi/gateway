import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/people/party_tiles.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Suppliers screen with search and details.
class SuppliersScreen extends StatefulWidget {
  /// Creates the suppliers screen.
  const SuppliersScreen({super.key});

  /// Route path.
  static const String routePath = '/suppliers';

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();

  static const _suppliers = [
    _Supplier(
      id: '1',
      name: 'Kenya Gas Ltd',
      phone: '+254720111222',
      balance: -45000,
      lastDelivery: '2024-01-15',
    ),
    _Supplier(
      id: '2',
      name: 'Pro Gas Kenya',
      phone: '+254733222333',
      balance: 0,
      lastDelivery: '2024-01-12',
    ),
    _Supplier(
      id: '3',
      name: 'Total Energies',
      phone: '+254744333444',
      balance: -120000,
      lastDelivery: '2024-01-10',
    ),
    _Supplier(
      id: '4',
      name: 'Hashi Energy',
      phone: '+254755444555',
      balance: 25000,
      lastDelivery: '2024-01-08',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return AppScaffold(
      title: 'Suppliers',
      selectedIndex: 1,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'Suppliers',
          icon: Icons.local_shipping_outlined,
          selectedIcon: Icons.local_shipping,
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
      body: _SuppliersContent(
        searchController: _searchController,
        suppliers: _suppliers,
        currency: currency,
      ),
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

class _SuppliersContent extends StatelessWidget {
  const _SuppliersContent({
    required this.searchController,
    required this.suppliers,
    required this.currency,
  });

  final TextEditingController searchController;
  final List<_Supplier> suppliers;
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
            title: 'Supplier Directory',
            subtitle: 'Manage supplier accounts and orders.',
          ),
          SizedBox(height: spacing.lg),
          AppSearchField(
            label: 'Search suppliers',
            controller: searchController,
            hintText: 'Name or phone',
          ),
          SizedBox(height: spacing.lg),
          if (suppliers.isEmpty)
            const EmptyView(
              title: 'No suppliers found',
              message: 'Add your first supplier to get started.',
            )
          else
            Column(
              children: suppliers.map((supplier) {
                return SupplierTile(
                  name: supplier.name,
                  subtitle: supplier.phone,
                  trailing: _BalanceChip(
                    balance: supplier.balance,
                    currency: currency,
                  ),
                  onTap: () =>
                      _showSupplierDetails(context, supplier, currency),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showSupplierDetails(
    BuildContext context,
    _Supplier supplier,
    NumberFormat currency,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _SupplierDetailDialog(supplier: supplier, currency: currency),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.balance, required this.currency});

  final double balance;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final status = balance < 0
        ? AppStatus.danger
        : balance > 0
        ? AppStatus.success
        : AppStatus.neutral;

    return StatusBadge(label: currency.format(balance.abs()), status: status);
  }
}

class _SupplierDetailDialog extends StatelessWidget {
  const _SupplierDetailDialog({required this.supplier, required this.currency});

  final _Supplier supplier;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(supplier.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: ${supplier.phone}'),
          SizedBox(height: spacing.sm),
          Text('Balance: ${currency.format(supplier.balance)}'),
          SizedBox(height: spacing.sm),
          Text('Last Delivery: ${supplier.lastDelivery}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'New Order',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class _Supplier {
  const _Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.lastDelivery,
  });

  final String id;
  final String name;
  final String phone;
  final double balance;
  final String lastDelivery;
}
