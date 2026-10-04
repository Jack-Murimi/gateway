import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/people/party_tiles.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../application/customer_providers.dart';
import '../domain/customer.dart';

/// Customers screen with CRUD operations.
class CustomersScreen extends ConsumerStatefulWidget {
  /// Creates the customers screen.
  const CustomersScreen({super.key});

  /// Route path.
  static const String routePath = '/customers';

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return customersAsync.when(
      data: (customers) => _CustomersContent(
        searchController: _searchController,
        customers: customers,
      ),
      loading: () => const LoadingView(),
      error: (err, stack) => ErrorView(title: 'Error loading customers', message: err.toString()),
    );
  }
}

class _CustomersContent extends StatelessWidget {
  const _CustomersContent({
    required this.searchController,
    required this.customers,
  });

  final TextEditingController searchController;
  final List<Customer> customers;

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
                  ),
                  onTap: () => _showCustomerDetails(context, customer),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showCustomerDetails(
    BuildContext context,
    Customer customer,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CustomerDetailDialog(
        customer: customer,
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.balance});

  /// Balance in KES (positive = customer owes us debt).
  final int balance;

  @override
  Widget build(BuildContext context) {
    final status = balance > 0
        ? AppStatus.warning
        : balance < 0
            ? AppStatus.success
            : AppStatus.neutral;

    return StatusBadge(label: formatKes(balance.abs()), status: status);
  }
}

class _CustomerDetailDialog extends StatelessWidget {
  const _CustomerDetailDialog({
    required this.customer,
  });

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);

    return AppDialog(
      title: Text(customer.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phones:', style: theme.textTheme.labelLarge),
            ...customer.phones.map((phone) => Padding(
              padding: EdgeInsets.only(left: spacing.sm, top: spacing.xs),
              child: Text(phone),
            )),
            SizedBox(height: spacing.md),
            Text('Locations:', style: theme.textTheme.labelLarge),
            ...customer.locations.map((loc) => Padding(
              padding: EdgeInsets.only(left: spacing.sm, top: spacing.xs),
              child: Text(loc.address),
            )),
            SizedBox(height: spacing.md),
            Text('Balance: ${formatKes(customer.balance)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
