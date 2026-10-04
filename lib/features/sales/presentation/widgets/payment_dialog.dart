import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/money.dart';
import '../../../../design_system/components/buttons/app_button.dart';
import '../../../../design_system/components/dialogs/app_dialog.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../../design_system/tokens/radii.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../customers/domain/customer.dart';
import '../../domain/sales_models.dart';

/// Result from the payment dialog.
class PaymentResult {
  /// Creates a payment result.
  const PaymentResult({
    required this.payments,
    required this.isInvoice,
    required this.dueDate,
  });

  /// List of payments made.
  final List<PaymentEntry> payments;

  /// Whether this was marked as invoice (credit/unpaid).
  final bool isInvoice;

  /// Due date for credit invoice (null if not invoice).
  final DateTime? dueDate;
}

/// Single payment entry.
class PaymentEntry {
  /// Creates a payment entry.
  const PaymentEntry({
    required this.method,
    required this.amount,
    this.reference,
  });

  /// Payment method.
  final PaymentMethod method;

  /// Amount paid in whole KES.
  final int amount;

  /// Optional reference (e.g., M-Pesa code).
  final String? reference;
}

/// Shows the payment dialog.
Future<PaymentResult?> showPaymentDialog(
  BuildContext context, {
  required int grandTotal,
  required Customer customer,
}) async {
  return showDialog<PaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PaymentDialog(
      grandTotal: grandTotal,
      customer: customer,
    ),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.grandTotal,
    required this.customer,
  });

  final int grandTotal;
  final Customer customer;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late List<PaymentEntry> _payments;
  var _selectedMethod = PaymentMethod.mpesa;
  var _isInvoice = false;
  // Default credit due date is now + 3 days per fixed business rules
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  String? _referenceError;

  int get _paidAmount =>
      _payments.fold<int>(0, (sum, p) => sum + p.amount);
  int get _remainingBalance => widget.grandTotal - _paidAmount;

  @override
  void initState() {
    super.initState();
    _payments = [];
    _amountController.text = widget.grandTotal.toString();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addPayment() {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    // Validate M-Pesa reference
    if (_selectedMethod == PaymentMethod.mpesa) {
      final ref = _referenceController.text.trim().toUpperCase();
      if (ref.isEmpty) {
        setState(() => _referenceError = 'M-Pesa code required');
        return;
      }
      if (!_isValidMpesaCode(ref)) {
        setState(() => _referenceError = 'Invalid format (10 alphanumeric chars)');
        return;
      }
    }

    setState(() {
      _referenceError = null;
      _payments.add(
        PaymentEntry(
          method: _selectedMethod,
          amount: amount,
          reference: _referenceController.text.trim().isNotEmpty
              ? _referenceController.text.trim().toUpperCase()
              : null,
        ),
      );
      _referenceController.clear();
      _amountController.text = _remainingBalance > 0
          ? _remainingBalance.toString()
          : '';
    });
  }

  bool _isValidMpesaCode(String code) {
    return RegExp(r'^[A-Z0-9]{10}$').hasMatch(code);
  }

  void _removePayment(int index) {
    setState(() {
      _payments.removeAt(index);
      _amountController.text = _remainingBalance > 0
          ? _remainingBalance.toString()
          : '';
    });
  }

  void _markAsInvoice() {
    setState(() => _isInvoice = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: const Text('Payment'),
      content: SizedBox(
        width: 500,
        child: _isInvoice
            ? _buildInvoiceForm(context)
            : _buildPaymentForm(context),
      ),
      actions: _isInvoice
          ? _buildInvoiceActions(context)
          : _buildPaymentActions(context),
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total and balance
          Container(
            padding: spacing.page,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      formatKes(widget.grandTotal),
                      style: Theme.of(context).textTheme.money?.copyWith(
                        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _remainingBalance < 0 ? 'Change Due' : 'Remaining',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      formatKes(_remainingBalance.abs()),
                      style: Theme.of(context).textTheme.money?.copyWith(
                        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                        color: _remainingBalance > 0
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Existing payments
          if (_payments.isNotEmpty) ...[
            SizedBox(height: spacing.lg),
            Text('Payments', style: Theme.of(context).textTheme.labelMedium),
            SizedBox(height: spacing.sm),
            ..._payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              return _PaymentTile(
                payment: payment,
                onRemove: () => _removePayment(index),
              );
            }),
          ],

          SizedBox(height: spacing.lg),

          // Add payment section
          if (_remainingBalance > 0) ...[
            Text('Add Payment', style: Theme.of(context).textTheme.labelMedium),
            SizedBox(height: spacing.sm),

            // Method selector
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: PaymentMethod.values.map((method) {
                final selected = _selectedMethod == method;
                return ChoiceChip(
                  label: Text(_getMethodLabel(method)),
                  selected: selected,
                  onSelected: (value) {
                    if (value) setState(() => _selectedMethod = method);
                  },
                );
              }).toList(),
            ),

            SizedBox(height: spacing.md),

            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            // Reference field (for M-Pesa)
            if (_selectedMethod == PaymentMethod.mpesa) ...[
              SizedBox(height: spacing.md),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Code',
                  hintText: 'e.g., QHN3XYZ789',
                  border: const OutlineInputBorder(),
                  errorText: _referenceError,
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                onChanged: (_) {
                  if (_referenceError != null) {
                    setState(() => _referenceError = null);
                  }
                },
              ),
            ],

            SizedBox(height: spacing.md),

            // Add button
            AppButton(
              label: 'Add Payment',
              onPressed: _addPayment,
              icon: Icons.add,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceForm(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Save as Credit Invoice',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: spacing.sm),
        Text(
          'The entire amount of ${formatKes(widget.grandTotal)} will be recorded as credit owed by ${widget.customer.name}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: spacing.lg),

        // Customer info
        Text('Customer', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: spacing.xs),
        Text(
          widget.customer.name,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: spacing.lg),

        // Due date
        Text('Due Date (Staff reminder to follow up)', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: spacing.sm),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dueDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _dueDate = date);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: AppSizes.iconMd),
                SizedBox(width: spacing.md),
                Text(DateFormat.yMd().format(_dueDate)),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      if (!widget.customer.isWalkIn)
        TextButton(
          onPressed: _markAsInvoice,
          child: const Text('Save as Credit'),
        ),
      if (_remainingBalance <= 0)
        AppButton(
          label: 'Complete',
          onPressed: () {
            final result = PaymentResult(
              payments: _payments,
              isInvoice: false,
              dueDate: null,
            );
            Navigator.of(context).pop(result);
          },
        ),
    ];
  }

  List<Widget> _buildInvoiceActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => setState(() => _isInvoice = false),
        child: const Text('Back'),
      ),
      AppButton(
        label: 'Confirm Credit',
        onPressed: () {
          final result = PaymentResult(
            payments: _payments,
            isInvoice: true,
            dueDate: _dueDate,
          );
          Navigator.of(context).pop(result);
        },
      ),
    ];
  }

  String _getMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bank:
        return 'Bank';
    }
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.onRemove,
  });

  final PaymentEntry payment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
      ),
      child: Row(
        children: [
          Icon(_getMethodIcon(payment.method), size: AppSizes.iconLg),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getMethodLabel(payment.method)),
                if (payment.reference != null)
                  Text(
                    payment.reference!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Text(
            formatKes(payment.amount),
            style: Theme.of(context).textTheme.money,
          ),
          IconButton(
            icon: Icon(Icons.close, size: AppSizes.iconMd),
            onPressed: onRemove,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.bank:
        return Icons.account_balance;
    }
  }

  String _getMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bank:
        return 'Bank';
    }
  }
}
