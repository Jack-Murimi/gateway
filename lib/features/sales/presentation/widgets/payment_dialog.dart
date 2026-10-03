import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/components/buttons/app_button.dart';
import '../../../../design_system/components/dialogs/app_dialog.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../../design_system/tokens/radii.dart';
import '../../../../design_system/tokens/typography.dart';

import '../../../customers/domain/customer.dart';

/// Payment method types.
enum PaymentMethod { cash, mpesa, card, bankTransfer, invoice }

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

  /// Whether this was marked as invoice (unpaid).
  final bool isInvoice;

  /// Due date for invoice (null if not invoice).
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

  /// Amount paid.
  final double amount;

  /// Optional reference (e.g., M-Pesa code).
  final String? reference;
}

/// Shows the payment dialog.
Future<PaymentResult?> showPaymentDialog(
  BuildContext context, {
  required int grandTotal,
  required NumberFormat currency,
  required Customer customer,
}) async {
  return showDialog<PaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PaymentDialog(
      grandTotal: grandTotal,
      currency: currency,
      customer: customer,
    ),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.grandTotal,
    required this.currency,
    required this.customer,
  });

  final int grandTotal;
  final NumberFormat currency;
  final Customer customer;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late List<PaymentEntry> _payments;
  var _selectedMethod = PaymentMethod.mpesa;
  var _isInvoice = false;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  String? _referenceError;

  double get _paidAmount =>
      _payments.fold<double>(0, (sum, p) => sum + p.amount);
  double get _remainingBalance => widget.grandTotal - _paidAmount;

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
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    // Validate M-Pesa reference
    if (_selectedMethod == PaymentMethod.mpesa) {
      final ref = _referenceController.text.trim();
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
          reference: _referenceController.text.isNotEmpty
              ? _referenceController.text
              : null,
        ),
      );
      _referenceController.clear();
      _amountController.text = _remainingBalance > 0
          ? _remainingBalance.toStringAsFixed(0)
          : '';
    });
  }

  bool _isValidMpesaCode(String code) {
    // M-Pesa codes: 10 alphanumeric characters
    return RegExp(r'^[A-Z0-9]{10}$').hasMatch(code);
  }

  void _removePayment(int index) {
    setState(() {
      _payments.removeAt(index);
      _amountController.text = _remainingBalance > 0
          ? _remainingBalance.toStringAsFixed(0)
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

    return Column(
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
                    widget.currency.format(widget.grandTotal),
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
                    'Remaining',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    widget.currency.format(_remainingBalance),
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
              currency: widget.currency,
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
            children: PaymentMethod.values
                .where((m) => m != PaymentMethod.invoice)
                .map((method) {
                  final selected = _selectedMethod == method;
                  return ChoiceChip(
                    label: Text(_getMethodLabel(method)),
                    selected: selected,
                    onSelected: (value) {
                      if (value) setState(() => _selectedMethod = method);
                    },
                  );
                })
                .toList(),
          ),

          SizedBox(height: spacing.md),

          // Amount field
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
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
    );
  }

  Widget _buildInvoiceForm(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: spacing.page,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.error),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark as Invoice (Unpaid)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'This sale will be recorded as unpaid and added to customer\'s balance.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spacing.lg),

        // Customer info
        if (!widget.customer.isWalkIn) ...[
          Text('Customer', style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: spacing.xs),
          Text(
            widget.customer.name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: spacing.lg),
        ],

        // Due date
        Text('Due Date', style: Theme.of(context).textTheme.labelMedium),
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
          child: const Text('Mark as Invoice'),
        ),
      if (_remainingBalance <= 0 || _payments.isNotEmpty)
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
        label: 'Save as Invoice',
        onPressed: () {
          final result = PaymentResult(
            payments: [],
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
      case PaymentMethod.bankTransfer:
        return 'Bank';
      case PaymentMethod.invoice:
        return 'Invoice';
    }
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.currency,
    required this.onRemove,
  });

  final PaymentEntry payment;
  final NumberFormat currency;
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
            currency.format(payment.amount),
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
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.invoice:
        return Icons.receipt_long;
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
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.invoice:
        return 'Invoice';
    }
  }
}
