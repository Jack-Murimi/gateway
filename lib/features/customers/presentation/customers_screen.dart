import 'package:flutter/material.dart';
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
      phones: [
        _PhoneEntry(number: '+254712345678', label: 'John', isDefault: true),
        _PhoneEntry(number: '+254722111222', label: 'Mary (wife)'),
      ],
      locations: [
        _LocationEntry(address: '123 Main St, Westlands', label: 'Home', isDefault: true),
      ],
      balance: -2400,
      lastPurchase: '2024-01-15',
    ),
    _Customer(
      id: '2',
      name: 'Mary Wanjiku',
      phones: [
        _PhoneEntry(number: '+254723456789', label: 'Mary', isDefault: true),
      ],
      locations: [
        _LocationEntry(address: '456 Oak Ave, Kilimani', label: 'Home', isDefault: true),
        _LocationEntry(address: '789 Work Rd, CBD', label: 'Office'),
      ],
      balance: 0,
      lastPurchase: '2024-01-14',
    ),
    _Customer(
      id: '3',
      name: 'Peter Ochieng',
      phones: [
        _PhoneEntry(number: '+254734567890', label: 'Peter', isDefault: true),
        _PhoneEntry(number: '+254744555666', label: 'House'),
      ],
      locations: [
        _LocationEntry(address: '321 Lake View, Kisumu', label: 'Home', isDefault: true),
      ],
      balance: -5600,
      lastPurchase: '2024-01-13',
    ),
    _Customer(
      id: '4',
      name: 'Grace Muthoni',
      phones: [
        _PhoneEntry(number: '+254745678901', label: 'Grace', isDefault: true),
      ],
      locations: [
        _LocationEntry(address: '555 Green Lane, Nakuru', label: 'Home', isDefault: true),
      ],
      balance: 1200,
      lastPurchase: '2024-01-12',
    ),
    _Customer(
      id: '5',
      name: 'James Kibet',
      phones: [
        _PhoneEntry(number: '+254756789012', label: 'James', isDefault: true),
        _PhoneEntry(number: '+254766888999', label: 'Mai (househelp)', description: 'Call after 6pm'),
      ],
      locations: [
        _LocationEntry(address: '999 Hill Rd, Eldoret', label: 'Home', isDefault: true),
      ],
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
        content: Text('Delete "${customer.name}"? This cannot be undone.'),
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
                  subtitle: customer.defaultPhone.number,
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
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(customer.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phones:', style: theme.textTheme.labelLarge),
            ...customer.phones.map((p) => Padding(
              padding: EdgeInsets.only(left: spacing.sm, top: spacing.xs),
              child: Row(
                children: [
                  if (p.isDefault)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.xs),
                      child: Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.label}: ${p.number}'),
                        if (p.description != null)
                          Text(
                            p.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: spacing.md),
            Text('Locations:', style: theme.textTheme.labelLarge),
            ...customer.locations.map((l) => Padding(
              padding: EdgeInsets.only(left: spacing.sm, top: spacing.xs),
              child: Row(
                children: [
                  if (l.isDefault)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.xs),
                      child: Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l.label}: ${l.address}'),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: spacing.md),
            Text('Balance: ${currency.format(customer.balance)}'),
            SizedBox(height: spacing.sm),
            Text('Last Purchase: ${customer.lastPurchase}'),
          ],
        ),
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
        AppButton(
          label: 'Edit',
          onPressed: onEdit,
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
  late List<_PhoneEntry> _phones = widget.customer?.phones.toList() ?? [_PhoneEntry(number: '', label: 'Primary', isDefault: true)];
  late List<_LocationEntry> _locations = widget.customer?.locations.toList() ?? [_LocationEntry(address: '', label: 'Home', isDefault: true)];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isEditing = widget.customer != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Customer Name',
                controller: _nameController,
                prefixIcon: Icons.person,
                hintText: 'e.g., Kamau Family',
              ),
              SizedBox(height: spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Phones', style: Theme.of(context).textTheme.labelLarge),
                  TextButton.icon(
                    onPressed: _addPhone,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              ..._phones.asMap().entries.map((entry) => _PhoneInput(
                entry: entry.value,
                index: entry.key,
                onChanged: (phone) => _phones[entry.key] = phone,
                onRemove: _phones.length > 1 ? () => _removePhone(entry.key) : null,
                onSetDefault: () => _setDefaultPhone(entry.key),
              )),
              SizedBox(height: spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Locations', style: Theme.of(context).textTheme.labelLarge),
                  TextButton.icon(
                    onPressed: _addLocation,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              ..._locations.asMap().entries.map((entry) => _LocationInput(
                entry: entry.value,
                index: entry.key,
                onChanged: (location) => _locations[entry.key] = location,
                onRemove: _locations.length > 1 ? () => _removeLocation(entry.key) : null,
                onSetDefault: () => _setDefaultLocation(entry.key),
              )),
            ],
          ),
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

  void _addPhone() => setState(() => _phones.add(_PhoneEntry(number: '', label: '')));
  void _removePhone(int index) => setState(() => _phones.removeAt(index));
  void _setDefaultPhone(int index) {
    setState(() {
      _phones = _phones.asMap().entries.map((e) => e.value.copyWith(isDefault: e.key == index)).toList();
    });
  }

  void _addLocation() => setState(() => _locations.add(_LocationEntry(address: '', label: '')));
  void _removeLocation(int index) => setState(() => _locations.removeAt(index));
  void _setDefaultLocation(int index) {
    setState(() {
      _locations = _locations.asMap().entries.map((e) => e.value.copyWith(isDefault: e.key == index)).toList();
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final customer = _Customer(
        id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phones: _phones.where((p) => p.number.isNotEmpty).toList(),
        locations: _locations.where((l) => l.address.isNotEmpty).toList(),
        balance: widget.customer?.balance ?? 0,
        lastPurchase: widget.customer?.lastPurchase ?? '-',
      );
      widget.onSave(customer);
      Navigator.of(context).pop();
    }
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.entry,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    required this.onSetDefault,
  });

  final _PhoneEntry entry;
  final int index;
  final void Function(_PhoneEntry) onChanged;
  final VoidCallback? onRemove;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Row(
        children: [
          if (entry.isDefault)
            Padding(
              padding: EdgeInsets.only(right: spacing.xs),
              child: Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.primary),
            )
          else
            IconButton(
              onPressed: onSetDefault,
              icon: const Icon(Icons.star_border, size: 14),
              tooltip: 'Set as default',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: entry.label,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g., John, Mary (wife), House',
                    isDense: true,
                  ),
                  onChanged: (v) => onChanged(entry.copyWith(label: v)),
                ),
                SizedBox(height: spacing.xs),
                TextFormField(
                  initialValue: entry.number,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+2547XX XXX XXX',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => onChanged(entry.copyWith(number: v)),
                ),
                if (entry.description != null || index > 0)
                  TextFormField(
                    initialValue: entry.description ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g., Call after 6pm',
                      isDense: true,
                    ),
                    onChanged: (v) => onChanged(entry.copyWith(description: v.isEmpty ? null : v)),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  const _LocationInput({
    required this.entry,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    required this.onSetDefault,
  });

  final _LocationEntry entry;
  final int index;
  final void Function(_LocationEntry) onChanged;
  final VoidCallback? onRemove;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Row(
        children: [
          if (entry.isDefault)
            Padding(
              padding: EdgeInsets.only(right: spacing.xs),
              child: Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.primary),
            )
          else
            IconButton(
              onPressed: onSetDefault,
              icon: const Icon(Icons.star_border, size: 14),
              tooltip: 'Set as default',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: entry.label,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g., Home, Office',
                    isDense: true,
                  ),
                  onChanged: (v) => onChanged(entry.copyWith(label: v)),
                ),
                SizedBox(height: spacing.xs),
                TextFormField(
                  initialValue: entry.address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Street, area, city',
                    isDense: true,
                  ),
                  maxLines: 2,
                  onChanged: (v) => onChanged(entry.copyWith(address: v)),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

class _PhoneEntry {
  const _PhoneEntry({
    required this.number,
    required this.label,
    this.description,
    this.isDefault = false,
  });

  final String number;
  final String label;
  final String? description;
  final bool isDefault;

  _PhoneEntry copyWith({
    String? number,
    String? label,
    String? description,
    bool? isDefault,
  }) {
    return _PhoneEntry(
      number: number ?? this.number,
      label: label ?? this.label,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class _LocationEntry {
  const _LocationEntry({
    required this.address,
    required this.label,
    this.isDefault = false,
  });

  final String address;
  final String label;
  final bool isDefault;

  _LocationEntry copyWith({
    String? address,
    String? label,
    bool? isDefault,
  }) {
    return _LocationEntry(
      address: address ?? this.address,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class _Customer {
  const _Customer({
    required this.id,
    required this.name,
    required this.phones,
    required this.locations,
    required this.balance,
    required this.lastPurchase,
  });

  final String id;
  final String name;
  final List<_PhoneEntry> phones;
  final List<_LocationEntry> locations;
  final double balance;
  final String lastPurchase;

  _PhoneEntry get defaultPhone => phones.firstWhere((p) => p.isDefault, orElse: () => phones.first);
  _LocationEntry get defaultLocation => locations.firstWhere((l) => l.isDefault, orElse: () => locations.first);
}
