import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../inventory/application/inventory_providers.dart';
import '../../inventory/domain/product.dart';
import '../domain/sales_models.dart';

part 'cart_provider.g.dart';

/// Result of an add operation.
class AddResult {
  const AddResult({required this.added, this.message});
  final int added;
  final String? message;
}

/// Cart state for a branch.
class CartState {
  const CartState({this.items = const []});
  final List<SaleLineItem> items;

  int get total => items.fold<int>(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  int qtyInCart(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? items[index].quantity : 0;
  }

  CartState copyWith({List<SaleLineItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

/// Cart per branch. Survives navigation.
@riverpod
class Cart extends _$Cart {
  SaleLineItem? _lastRemoved;

  @override
  CartState build(String branchId) => const CartState();

  Future<int> _getStock(String productId) async {
    final stockRepo = ref.read(stockRepositoryProvider);
    final level = await stockRepo.getStockLevel(branchId, productId);
    return level?.quantity ?? 0;
  }

  Future<AddResult> add(Product product, {int quantity = 1}) async {
    if (_lastRemoved?.product.id == product.id) {
      _lastRemoved = null;
    }

    final available = await _getStock(product.id);
    final inCart = state.qtyInCart(product.id);
    final canAdd = available - inCart;

    if (canAdd <= 0) {
      return AddResult(
        added: 0,
        message: 'No more stock available for ${product.name}',
      );
    }

    final toAdd = quantity.clamp(1, canAdd);
    final items = List<SaleLineItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + toAdd,
      );
    } else {
      items.add(SaleLineItem(product: product, quantity: toAdd));
    }

    state = CartState(items: items);

    if (toAdd < quantity) {
      return AddResult(
        added: toAdd,
        message: 'Only $toAdd of ${product.name} added (stock limit reached)',
      );
    }

    return AddResult(added: toAdd);
  }

  Future<String?> updateQuantity(int index, int quantity) async {
    if (index < 0 || index >= state.items.length) return null;

    final items = List<SaleLineItem>.from(state.items);
    final item = items[index];
    final available = await _getStock(item.product.id);
    final clamped = quantity.clamp(0, available);

    String? message;
    if (clamped < quantity) {
      message = 'Only $available of ${item.product.name} in stock';
    }

    if (clamped <= 0) {
      items.removeAt(index);
    } else {
      items[index] = item.copyWith(quantity: clamped);
    }

    state = CartState(items: items);
    return message;
  }

  void clear() {
    state = const CartState();
    _lastRemoved = null;
  }

  SaleLineItem? removeWithUndo(int index) {
    if (index < 0 || index >= state.items.length) return null;
    final items = List<SaleLineItem>.from(state.items);
    final removed = items[index];
    _lastRemoved = removed;
    items.removeAt(index);
    state = CartState(items: items);
    return removed;
  }

  Future<void> undoRemove() async {
    if (_lastRemoved == null) return;
    final removed = _lastRemoved!;
    _lastRemoved = null;
    await add(removed.product, quantity: removed.quantity);
  }
}
