import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/people/party_tiles.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Customers screen with CRUD operations.
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

  final List<_Customer> _customers = [
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

  void _addCustomer() {
    showDialog(
      context: context,
      builder: (context) => _CustomerFormDialog(
        onSave: (customer) {
          setState(() {
            _customers.add(customer);
          });
        },
      ),
    );
  }

  void _editCustomer(_Customer customer) {
    showDialog(
      context: context,
      builder: (context) => _CustomerFormDialog(
        customer: customer,
        onSave: (updated) {
          setState(() {
            final index = _customers.indexWhere((c) => c.id == customer.id);
            if (index != -1) _customers[index] = updated;
          });
        },
      ),
    );
  }

  void _deleteCustomer(_Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Delete \"\"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            onPressed: () {
              setState(() {
                _customers.removeWhere((c) => c.id == customer.id);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return AppScaffold(
      title: 'Customers',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addCustomer,
          tooltip: 'Add customer',
        ),
      ],
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
        onEdit: _editCustomer,
        onDelete: _deleteCustomer,
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

class _CustomersContent extends StatelessWidget {
  const _CustomersContent({
    required this.searchController,
    required this.customers,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final TextEditingController searchController;
  final List<_Customer> customers;
  final NumberFormat currency;
  final void Function(_Customer) onEdit;
  final void Function(_Customer) onDelete;

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
      builder: (context) => _CustomerDetailDialog(
        customer: customer,
        currency: currency,
        onEdit: () {
          Navigator.of(context).pop();
          onEdit(customer);
        },
        onDelete: () {
          Navigator.of(context).pop();
          onDelete(customer);
        },
      ),
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
  const _CustomerDetailDialog({
    required this.customer,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final _Customer customer;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(customer.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: '),
          SizedBox(height: spacing.sm),
          Text('Balance: '),
          SizedBox(height: spacing.sm),
          Text('Last Purchase: '),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDelete,
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'Edit',
            onPressed: onEdit,
          ),
        ),
      ],
    );
  }
}

class _CustomerFormDialog extends StatefulWidget {
  const _CustomerFormDialog({
    this.customer,
    required this.onSave,
  });

  final _Customer? customer;
  final void Function(_Customer) onSave;

  @override
  State<_CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<_CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.customer?.name);
  late final _phoneController = TextEditingController(text: widget.customer?.phone);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final customer = _Customer(
        id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        balance: widget.customer?.balance ?? 0,
        lastPurchase: widget.customer?.lastPurchase ?? '-',
      );
      widget.onSave(customer);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<SpacingTheme>()!;
    final isEditing = widget.customer != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.person,
              hintText: 'Customer name',
            ),
            SizedBox(height: spacing.md),
            AppTextField(
              label: 'Phone',
              controller: _phoneController,
              prefixIcon: Icons.phone,
              hintText: '+2547XX XXX XXX',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: isEditing ? 'Save' : 'Add',
          onPressed: _save,
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
