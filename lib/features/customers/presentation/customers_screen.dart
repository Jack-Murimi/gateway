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

/// Customers screen with search and details.
class CustomersScreen extends StatefulWidget {
  /// Creates the customers screen.
  const CustomersScreen({super.key});

  /// Route path.
  static const String routePath = '/customers';

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  static const _customers = [
    _Customer(
      id: '1',
      name: 'John Kamau',
      phone: '+254712345678',
      balance: -2400,
      lastPurchase: '2024-01-15',
    ),
    _Customer(
      id: '2',
      name: 'Mary Wanjiku',
      phone: '+254723456789',
      balance: 0,
      lastPurchase: '2024-01-14',
    ),
    _Customer(
      id: '3',
      name: 'Peter Ochieng',
      phone: '+254734567890',
      balance: -5600,
      lastPurchase: '2024-01-13',
    ),
    _Customer(
      id: '4',
      name: 'Grace Muthoni',
      phone: '+254745678901',
      balance: 1200,
      lastPurchase: '2024-01-12',
    ),
    _Customer(
      id: '5',
      name: 'James Kibet',
      phone: '+254756789012',
      balance: 0,
      lastPurchase: '2024-01-10',
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
      title: 'Customers',
      selectedIndex: 1,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'Customers',
          icon: Icons.people_outlined,
          selectedIcon: Icons.people,
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
      body: _CustomersContent(
        searchController: _searchController,
        customers: _customers,
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

class _CustomersContent extends StatelessWidget {
  const _CustomersContent({
    required this.searchController,
    required this.customers,
    required this.currency,
  });

  final TextEditingController searchController;
  final List<_Customer> customers;
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
            title: 'Customer Directory',
            subtitle: 'Search and manage customer accounts.',
          ),
          SizedBox(height: spacing.lg),
          AppSearchField(
            label: 'Search customers',
            controller: searchController,
            hintText: 'Name or phone',
          ),
          SizedBox(height: spacing.lg),
          if (customers.isEmpty)
            const EmptyView(
              title: 'No customers found',
              message: 'Add your first customer to get started.',
            )
          else
            Column(
              children: customers.map((customer) {
                return CustomerTile(
                  name: customer.name,
                  subtitle: customer.phone,
                  trailing: _BalanceChip(
                    balance: customer.balance,
                    currency: currency,
                  ),
                  onTap: () =>
                      _showCustomerDetails(context, customer, currency),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showCustomerDetails(
    BuildContext context,
    _Customer customer,
    NumberFormat currency,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _CustomerDetailDialog(customer: customer, currency: currency),
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

class _CustomerDetailDialog extends StatelessWidget {
  const _CustomerDetailDialog({required this.customer, required this.currency});

  final _Customer customer;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(customer.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: ${customer.phone}'),
          SizedBox(height: spacing.sm),
          Text('Balance: ${currency.format(customer.balance)}'),
          SizedBox(height: spacing.sm),
          Text('Last Purchase: ${customer.lastPurchase}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'New Sale',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class _Customer {
  const _Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.lastPurchase,
  });

  final String id;
  final String name;
  final String phone;
  final double balance;
  final String lastPurchase;
}
