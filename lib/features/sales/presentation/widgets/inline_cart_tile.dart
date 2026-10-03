import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/components/dialogs/app_dialog.dart';
import '../../domain/sales_models.dart';

/// Inline cart tile — FocusNode is owned by the tile itself (no race).
/// Qty commit fires once, only when field has focus.
class InlineCartTile extends StatefulWidget {
  const InlineCartTile({
    super.key,
    required this.item,
    required this.currency,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityEdited,
  });

  final SaleLineItem item;
  final NumberFormat currency;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuantityEdited;

  @override
  State<InlineCartTile> createState() => _InlineCartTileState();
}

class _InlineCartTileState extends State<InlineCartTile> {
  late final TextEditingController _qtyController;
  late final FocusNode _qtyFocusNode;
  var _hasCommitted = false;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.item.quantity}');
    _qtyFocusNode = FocusNode();
    _qtyFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(InlineCartTile old) {
    super.didUpdateWidget(old);
    if (old.item.quantity != widget.item.quantity) {
      final text = '${widget.item.quantity}';
      if (_qtyController.text != text) {
        _qtyController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
      _hasCommitted = false;
    }
  }

  @override
  void dispose() {
    _qtyFocusNode.removeListener(_onFocusChange);
    _qtyFocusNode.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_qtyFocusNode.hasFocus) {
      _hasCommitted = false;
    } else if (!_hasCommitted) {
      _commitQty();
    }
  }

  void _commitQty() {
    if (_hasCommitted) return;
    _hasCommitted = true;

    final parsed = int.tryParse(_qtyController.text.trim());
    if (parsed != null && parsed > 0) {
      if (parsed != widget.item.quantity) {
        widget.onQuantityEdited(parsed);
      }
    } else if (parsed != null && parsed <= 0) {
      widget.onRemove();
    }
    
    // Always resync text with actual quantity after commit
    _qtyController.text = '${widget.item.quantity}';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.item.product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await confirmDialog(
          context,
          title: 'Remove item?',
          message: 'Remove ${widget.item.product.name} from cart?',
          confirmText: 'Remove',
        );
        return confirm == true;
      },
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: spacing.xl),
        color: colorScheme.errorContainer,
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.product.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    '${widget.currency.format(widget.item.product.price)} each',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.sm),

            // Quantity controls — stepper + editable input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(spacing.sm),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: widget.item.quantity <= 1
                        ? Icons.delete_outline
                        : Icons.remove,
                    onPressed: widget.onDecrement,
                    color: widget.item.quantity <= 1 ? colorScheme.error : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _qtyController,
                      focusNode: _qtyFocusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      onSubmitted: (_) {
                        _commitQty();
                        _qtyFocusNode.unfocus();
                      },
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onPressed: widget.onIncrement,
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.md),

            // Line total
            SizedBox(
              width: 80,
              child: Text(
                widget.currency.format(widget.item.total),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.money,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity stepper button.
class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: AppSizes.iconSm),
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
