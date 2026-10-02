import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/breakpoints.dart';
import '../../../../design_system/theme/theme_extensions.dart';

import '../../domain/sales_models.dart';

/// Header section for Sales screen with date, receipt, and customer.
/// Branch is NOT shown here — it's already in the app bar via BranchSelector.
class SalesHeader extends StatelessWidget {
  /// Creates the sales header.
  const SalesHeader({
    super.key,
    required this.date,
    this.onDateChanged,
    required this.receiptNumber,
    this.onReceiptNumberChanged,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final ValueChanged<DateTime>? onDateChanged;
  final String receiptNumber;
  final ValueChanged<String>? onReceiptNumberChanged;
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
        onDateChanged: onDateChanged,
        receiptNumber: receiptNumber,
        onReceiptNumberChanged: onReceiptNumberChanged,
        selectedCustomer: selectedCustomer,
        selectedLocation: selectedLocation,
        onCustomerChanged: onCustomerChanged,
        onLocationChanged: onLocationChanged,
        customers: customers,
      );
    }

    return _OneRowHeader(
      date: date,
      onDateChanged: onDateChanged,
      receiptNumber: receiptNumber,
      onReceiptNumberChanged: onReceiptNumberChanged,
      selectedCustomer: selectedCustomer,
      selectedLocation: selectedLocation,
      onCustomerChanged: onCustomerChanged,
      onLocationChanged: onLocationChanged,
      customers: customers,
    );
  }
}

// ---------------------------------------------------------------------------
// One-row header (large screens)
// ---------------------------------------------------------------------------
class _OneRowHeader extends StatelessWidget {
  const _OneRowHeader({
    required this.date,
    this.onDateChanged,
    required this.receiptNumber,
    this.onReceiptNumberChanged,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final ValueChanged<DateTime>? onDateChanged;
  final String receiptNumber;
  final ValueChanged<String>? onReceiptNumberChanged;
  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: spacing.page,
      child: Row(
        children: [
          Expanded(
            child: _DateField(
              date: date,
              onDateChanged: onDateChanged,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: _ReceiptField(
              receiptNumber: receiptNumber,
              onChanged: onReceiptNumberChanged,
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
}

// ---------------------------------------------------------------------------
// Two-row header (compact / medium screens)
// ---------------------------------------------------------------------------
class _TwoRowHeader extends StatelessWidget {
  const _TwoRowHeader({
    required this.date,
    this.onDateChanged,
    required this.receiptNumber,
    this.onReceiptNumberChanged,
    required this.selectedCustomer,
    required this.selectedLocation,
    required this.onCustomerChanged,
    required this.onLocationChanged,
    required this.customers,
  });

  final DateTime date;
  final ValueChanged<DateTime>? onDateChanged;
  final String receiptNumber;
  final ValueChanged<String>? onReceiptNumberChanged;
  final Customer selectedCustomer;
  final Location selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<Location> onLocationChanged;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateField(
                  date: date,
                  onDateChanged: onDateChanged,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _ReceiptField(
                  receiptNumber: receiptNumber,
                  onChanged: onReceiptNumberChanged,
                ),
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

// ---------------------------------------------------------------------------
// Date field — tappable, bordered, calendar icon in accent color.
// ---------------------------------------------------------------------------
class _DateField extends StatelessWidget {
  const _DateField({required this.date, this.onDateChanged});

  final DateTime date;
  final ValueChanged<DateTime>? onDateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat.yMd();

    // Using a read-only TextFormField so we get consistent bordered styling.
    // A new controller is built from the current date value each build;
    // that's fine since the field is read-only.
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: dateFormatter.format(date)),
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Date',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.calendar_today,
          size: 18,
          color: colorScheme.primary, // accent color
        ),
      ),
      onTap: onDateChanged == null
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDateChanged!(picked);
            },
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt / invoice number field — always empty on new sale.
// ---------------------------------------------------------------------------
class _ReceiptField extends StatelessWidget {
  const _ReceiptField({required this.receiptNumber, this.onChanged});

  final String receiptNumber;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // key on the value so Flutter rebuilds + re-initialises when cleared.
      key: ValueKey(receiptNumber.isEmpty ? '__empty__' : receiptNumber),
      initialValue: receiptNumber.isEmpty ? null : receiptNumber,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Receipt / Invoice #',
        hintText: 'Enter receipt or invoice number',
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Customer autocomplete field — person icon in accent color.
// ---------------------------------------------------------------------------
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
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _showSuggestions = false;
  var _selectedIndex = 0;
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    if (!widget.selectedCustomer.isWalkIn) {
      _controller.text = widget.selectedCustomer.name;
    }
  }

  @override
  void didUpdateWidget(_CustomerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      if (!widget.selectedCustomer.isWalkIn) {
        _controller.text = widget.selectedCustomer.name;
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers.where((c) {
          final nameMatch = c.name.toLowerCase().contains(query.toLowerCase());
          final phoneMatch = c.phone.contains(query);
          return nameMatch || phoneMatch;
        }).toList();
      }
      _selectedIndex = 0;
    });
  }

  void _selectCustomer(Customer customer) {
    _controller.text = customer.name;
    widget.onCustomerChanged(customer);
    setState(() {
      _showSuggestions = false;
      _selectedIndex = 0;
    });
  }

  void _handleKey(KeyEvent event) {
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
        KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Customer',
              hintText: 'Search by name or phone',
              border: const OutlineInputBorder(),
              // Person icon in accent (primary) color.
              prefixIcon: Icon(
                Icons.person_outline,
                color: colorScheme.primary,
              ),
              suffixIcon: widget.selectedCustomer.isWalkIn
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        widget.onCustomerChanged(Customer.walkIn);
                      },
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
