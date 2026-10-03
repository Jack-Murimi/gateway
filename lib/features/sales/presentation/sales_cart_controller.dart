import 'package:flutter/foundation.dart';
import '../../inventory/domain/product.dart';
import '../domain/sales_models.dart';

/// Result of an add operation.
class AddResult {
  const AddResult({required this.added, this.message});
  final int added;
  final String? message;
}

/// Cart state and operations for the sales screen.
/// Validates stock limits using a stock lookup function.
class SalesCartController extends ChangeNotifier {
  SalesCartController({required int Function(String productId) getStock})
      : _getStock = getStock;

  final int Function(String productId) _getStock;
  final List<SaleLineItem> _items = [];

  /// Current cart items (unmodifiable view).
  List<SaleLineItem> get items => List.unmodifiable(_items);

  /// Grand total in whole KES.
  int get total => _items.fold<int>(0, (sum, item) => sum + item.total);

  /// Total item count.
  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Quantity in cart for a given product.
  int qtyInCart(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  /// Add product to cart with stock validation.
  /// Returns [AddResult] with added qty and optional message.
  AddResult add(Product product, {int quantity = 1}) {
    // Invalidate undo if adding same product that was last removed
    if (_lastRemoved?.product.id == product.id) {
      _lastRemoved = null;
    }

    final available = _getStock(product.id);
    final inCart = qtyInCart(product.id);
    final canAdd = available - inCart;

    if (canAdd <= 0) {
      return AddResult(
        added: 0,
        message: 'No more stock available for ${product.name}',
      );
    }

    final toAdd = quantity.clamp(1, canAdd);
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + toAdd,
      );
    } else {
      _items.add(SaleLineItem(product: product, quantity: toAdd));
    }

    notifyListeners();

    if (toAdd < quantity) {
      return AddResult(
        added: toAdd,
        message: 'Only $toAdd of ${product.name} added (stock limit reached)',
      );
    }

    return AddResult(added: toAdd);
  }

  /// Update quantity at index with stock validation.
  /// Returns message if clamped, null otherwise.
  String? updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) return null;

    final item = _items[index];
    final available = _getStock(item.product.id);
    final clamped = quantity.clamp(0, available);

    String? message;
    if (clamped < quantity) {
      message = 'Only $available of ${item.product.name} in stock';
    }

    if (clamped <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: clamped);
    }

    notifyListeners();
    return message;
  }

  /// Clear all items.
  void clear() {
    _items.clear();
    _lastRemoved = null;
    notifyListeners();
  }

  /// Get last removed item (for undo). Returns null after restore or if never removed.
  SaleLineItem? _lastRemoved;

  /// Remove with undo support.
  SaleLineItem? removeWithUndo(int index) {
    if (index < 0 || index >= _items.length) return null;
    final removed = _items[index];
    _lastRemoved = removed;
    _items.removeAt(index);
    notifyListeners();
    return removed;
  }

  /// Restore last removed item.
  void undoRemove() {
    if (_lastRemoved == null) return;
    final removed = _lastRemoved!;
    _lastRemoved = null;
    add(removed.product, quantity: removed.quantity);
  }
}
