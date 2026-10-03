import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/components/buttons/app_button.dart';
import '../../../../design_system/components/dialogs/app_dialog.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../../design_system/tokens/radii.dart';

import '../../../inventory/domain/product.dart';
import '../../domain/sales_models.dart';

/// Result from the return cylinder dialog.
class ReturnCylinderResult {
  /// Creates a return cylinder result.
  const ReturnCylinderResult({required this.returns});

  /// List of cylinder returns.
  final List<CylinderReturn> returns;
}

/// Single cylinder return entry.
class CylinderReturn {
  /// Creates a cylinder return.
  const CylinderReturn({
    required this.cylinderType,
    required this.soldQuantity,
    required this.returnedQuantity,
    required this.isReturned,
  });

  /// Cylinder type (e.g., '13kg', '6kg').
  final String cylinderType;

  /// Quantity sold.
  final int soldQuantity;

  /// Quantity returned.
  final int returnedQuantity;

  /// Whether this cylinder was returned.
  final bool isReturned;
}

/// Shows the return cylinder dialog.
Future<ReturnCylinderResult?> showReturnCylinderDialog(
  BuildContext context, {
  required List<SaleLineItem> lineItems,
  required NumberFormat currency,
}) async {
  return showDialog<ReturnCylinderResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _ReturnCylinderDialog(lineItems: lineItems, currency: currency),
  );
}

class _ReturnCylinderDialog extends StatefulWidget {
  const _ReturnCylinderDialog({
    required this.lineItems,
    required this.currency,
  });

  final List<SaleLineItem> lineItems;
  final NumberFormat currency;

  @override
  State<_ReturnCylinderDialog> createState() => _ReturnCylinderDialogState();
}

class _ReturnCylinderDialogState extends State<_ReturnCylinderDialog> {
  late List<_ReturnLineItem> _returnItems;

  @override
  void initState() {
    super.initState();
    _returnItems = widget.lineItems
        .where((item) => item.product.kind == ProductKind.refill || item.product.kind == ProductKind.emptyCylinder)
        .map(
          (item) => _ReturnLineItem(
            cylinderType: item.product.sizeKg != null ? '${item.product.sizeKg}kg' : item.product.name,
            soldQuantity: item.quantity,
            returnedQuantity: item.quantity,
            isReturned: false,
          ),
        )
        .toList();
  }

  void _toggleReturn(int index, bool? value) {
    setState(() {
      _returnItems[index] = _returnItems[index].copyWith(
        isReturned: value ?? false,
      );
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      _returnItems[index] = _returnItems[index].copyWith(
        returnedQuantity: quantity.clamp(0, _returnItems[index].soldQuantity),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

    return AppDialog(
      title: const Text('Return Cylinders'),
      content: SizedBox(
        width: 500,
        child: _returnItems.isEmpty
            ? Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: const Text('No cylinders in this sale.'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm returned cylinders for this sale:',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: spacing.lg),
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: AppSizes.tileIconWidth),
                        const Expanded(child: Text('Cylinder')),
                        SizedBox(
                          width: AppSizes.tileWide,
                          child: Text('Sold', textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: AppSizes.tileWide,
                          child: Text('Returning', textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: AppSizes.tileWide,
                          child: Text('Returned?', textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  // Items
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _returnItems.length,
                      itemBuilder: (context, index) {
                        final item = _returnItems[index];
                        return _ReturnLineItemTile(
                          item: item,
                          onToggle: (value) => _toggleReturn(index, value),
                          onQuantityChanged: (qty) =>
                              _updateQuantity(index, qty),
                        );
                      },
                    ),
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
          label: 'Continue',
          onPressed: () {
            final result = ReturnCylinderResult(
              returns: _returnItems
                  .map(
                    (item) => CylinderReturn(
                      cylinderType: item.cylinderType,
                      soldQuantity: item.soldQuantity,
                      returnedQuantity: item.isReturned
                          ? item.returnedQuantity
                          : 0,
                      isReturned: item.isReturned,
                    ),
                  )
                  .toList(),
            );
            Navigator.of(context).pop(result);
          },
        ),
      ],
    );
  }
}

class _ReturnLineItemTile extends StatelessWidget {
  const _ReturnLineItemTile({
    required this.item,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  final _ReturnLineItem item;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final isGreyedOut = !item.isReturned;

    return Opacity(
      opacity: isGreyedOut ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Checkbox(value: item.isReturned, onChanged: onToggle),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                item.cylinderType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isGreyedOut ? colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            SizedBox(
              width: AppSizes.tileWide,
              child: Text(
                '${item.soldQuantity}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(width: spacing.sm),
            SizedBox(
              width: AppSizes.tileWide,
              child: isGreyedOut
                  ? Text(
                      '${item.returnedQuantity}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: AppSizes.iconSm),
                          onPressed: () =>
                              onQuantityChanged(item.returnedQuantity - 1),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        Expanded(
                          child: Text(
                            '${item.returnedQuantity}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: AppSizes.iconSm),
                          onPressed: () =>
                              onQuantityChanged(item.returnedQuantity + 1),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
            ),
            SizedBox(width: spacing.sm),
            SizedBox(
              width: AppSizes.tileWide,
              child: Center(
                child: Icon(
                  item.isReturned ? Icons.check_circle : Icons.cancel_outlined,
                  color: item.isReturned
                      ? colorScheme.primary
                      : colorScheme.error,
                  size: AppSizes.iconLg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Internal model
class _ReturnLineItem {
  const _ReturnLineItem({
    required this.cylinderType,
    required this.soldQuantity,
    required this.returnedQuantity,
    required this.isReturned,
  });

  final String cylinderType;
  final int soldQuantity;
  final int returnedQuantity;
  final bool isReturned;

  _ReturnLineItem copyWith({
    String? cylinderType,
    int? soldQuantity,
    int? returnedQuantity,
    bool? isReturned,
  }) {
    return _ReturnLineItem(
      cylinderType: cylinderType ?? this.cylinderType,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      isReturned: isReturned ?? this.isReturned,
    );
  }
}
