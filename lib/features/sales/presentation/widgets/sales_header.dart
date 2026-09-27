import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/breakpoints.dart';
import '../../../../design_system/theme/theme_extensions.dart';

import '../../domain/sales_models.dart';

/// Header section for Sales screen with date/time, receipt, and customer.
/// Branch is NOT shown here — it's already in the app bar via BranchSelector.
class SalesHeader extends StatelessWidget {
  /// Creates the sales header.
  const SalesHeader({
    super.key,
    required this.date,
    required this.receiptNumber,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final String receiptNumber;
  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.windowSizeClass;
    final useTwoRows = sizeClass != WindowSizeClass.large;

    if (useTwoRows) {
      return _TwoRowHeader(
        date: date,
        receiptNumber: receiptNumber,
        selectedCustomer: selectedCustomer,
        selectedLocation: selectedLocation,
        onCustomerChanged: onCustomerChanged,
        onLocationChanged: onLocationChanged,
        customers: customers,
      );
    }

    return _OneRowHeader(
      date: date,
      receiptNumber: receiptNumber,
      selectedCustomer: selectedCustomer,
      selectedLocation: selectedLocation,
      onCustomerChanged: onCustomerChanged,
      onLocationChanged: onLocationChanged,
      customers: customers,
    );
  }
}

class _OneRowHeader extends StatelessWidget {
  const _OneRowHeader({
    required this.date,
    required this.receiptNumber,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final String receiptNumber;
  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final dateFormatter = DateFormat.yMd();
    final timeFormatter = DateFormat.jm();

    return Padding(
      padding: spacing.page,
      child: Row(
        children: [
          Expanded(
            child: _buildField(
              context,
              label: 'Date',
              child: Text(dateFormatter.format(date)),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: _buildField(
              context,
              label: 'Time',
              child: Text(timeFormatter.format(date)),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: _buildField(
              context,
              label: 'Receipt #',
              child: Text(
                receiptNumber,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(width: spacing.lg),
          Expanded(
            flex: 2,
            child: _CustomerField(
              selectedCustomer: selectedCustomer,
              selectedLocation: selectedLocation,
              onCustomerChanged: onCustomerChanged,
              onLocationChanged: onLocationChanged,
              customers: customers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: child,
        ),
      ],
    );
  }
}

class _TwoRowHeader extends StatelessWidget {
  const _TwoRowHeader({
    required this.date,
    required this.receiptNumber,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final String receiptNumber;
  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final dateFormatter = DateFormat.yMd();
    final timeFormatter = DateFormat.jm();

    return Padding(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.calendar_today,
                  label: dateFormatter.format(date),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _InfoChip(
                  icon: Icons.access_time,
                  label: timeFormatter.format(date),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _InfoChip(icon: Icons.receipt, label: receiptNumber),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          _CustomerField(
            selectedCustomer: selectedCustomer,
            selectedLocation: selectedLocation,
            onCustomerChanged: onCustomerChanged,
            onLocationChanged: onLocationChanged,
            customers: customers,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerField extends StatefulWidget {
  const _CustomerField({
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  State<_CustomerField> createState() => _CustomerFieldState();
}

class _CustomerFieldState extends State<_CustomerField> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  var _showSuggestions = false;
  List<Customer> _filteredCustomers = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.phone.contains(query),
            )
            .toList();
      }
      _selectedIndex = 0;
    });
  }

  void _selectCustomer(Customer customer) {
    widget.onCustomerChanged(customer);
    _controller.text = customer.name;
    setState(() {
      _showSuggestions = false;
      _filteredCustomers = widget.customers;
    });
  }

  void _handleKey(KeyEvent event) {
    if (!_showSuggestions) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(
            0,
            _filteredCustomers.length - 1,
          );
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(
            0,
            _filteredCustomers.length - 1,
          );
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredCustomers.isNotEmpty &&
            _selectedIndex < _filteredCustomers.length) {
          _selectCustomer(_filteredCustomers[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() => _showSuggestions = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Customer', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search customer by name or phone',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: widget.selectedCustomer.isWalkIn
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        widget.onCustomerChanged(Customer.walkIn);
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              _filterCustomers(value);
              setState(() => _showSuggestions = value.isNotEmpty);
            },
            onTap: () {
              setState(() => _showSuggestions = _controller.text.isNotEmpty);
            },
            onFieldSubmitted: (value) {
              if (_filteredCustomers.isNotEmpty) {
                _selectCustomer(_filteredCustomers.first);
              }
            },
          ),
        ),
        if (_showSuggestions && _filteredCustomers.isNotEmpty) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredCustomers.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final customer = _filteredCustomers[index];
                  final selected = index == _selectedIndex;

                  return ListTile(
                    selected: selected,
                    selectedTileColor: colorScheme.primaryContainer,
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                    title: Text(customer.name),
                    subtitle: customer.phone.isNotEmpty
                        ? Text(customer.phone)
                        : null,
                    onTap: () => _selectCustomer(customer),
                  );
                },
              ),
            ),
          ),
        ],
        if (!widget.selectedCustomer.isWalkIn &&
            widget.selectedCustomer.locations.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Location:', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<Location>(
                  value: widget.selectedLocation,
                  isDense: true,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: widget.selectedCustomer.locations.map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: Text(loc.address, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (loc) {
                    if (loc != null) widget.onLocationChanged(loc);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
