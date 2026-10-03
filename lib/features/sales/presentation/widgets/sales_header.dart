import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/breakpoints.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/radii.dart';
import '../../../../design_system/tokens/sizes.dart';

import '../../../customers/domain/customer.dart';

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
  final CustomerLocation selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<CustomerLocation> onLocationChanged;
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
  final CustomerLocation selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<CustomerLocation> onLocationChanged;
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
  final CustomerLocation selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<CustomerLocation> onLocationChanged;
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
    final textTheme = Theme.of(context).textTheme;
    final dateFormatter = DateFormat.yMd();

    return InkWell(
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
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelText: 'Date',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(
            Icons.calendar_today,
            size: AppSizes.iconMd,
            color: colorScheme.primary,
          ),
        ),
        child: Text(
          dateFormatter.format(date),
          style: textTheme.bodyLarge,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt / invoice number field — always empty on new sale.
// ---------------------------------------------------------------------------
class _ReceiptField extends StatefulWidget {
  const _ReceiptField({required this.receiptNumber, this.onChanged});

  final String receiptNumber;
  final ValueChanged<String>? onChanged;

  @override
  State<_ReceiptField> createState() => _ReceiptFieldState();
}

class _ReceiptFieldState extends State<_ReceiptField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.receiptNumber);
  }

  @override
  void didUpdateWidget(_ReceiptField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when parent changes value (e.g., cleared after sale).
    if (widget.receiptNumber != oldWidget.receiptNumber &&
        widget.receiptNumber != _controller.text) {
      _controller.text = widget.receiptNumber;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Receipt / Invoice #',
        hintText: 'Enter receipt or invoice number',
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
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
  final CustomerLocation selectedLocation;
  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<CustomerLocation> onLocationChanged;
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
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() => _showSuggestions = false);
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
    if (event is KeyDownEvent && _filteredCustomers.isNotEmpty) {
      // Max visible items is 3, so max index is min(length, 3) - 1
      final maxIndex = (_filteredCustomers.length < 3 ? _filteredCustomers.length : 3) - 1;
      
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(0, maxIndex);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(0, maxIndex);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selectedIndex < _filteredCustomers.length) {
          _selectCustomer(_filteredCustomers[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() => _showSuggestions = false);
      }
    } else if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      // Allow Escape even when no results
      setState(() => _showSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

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
          SizedBox(height: spacing.xs),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
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
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Text('CustomerLocation:', style: Theme.of(context).textTheme.labelSmall),
              SizedBox(width: spacing.sm),
              Expanded(
                child: DropdownButton<CustomerLocation>(
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
