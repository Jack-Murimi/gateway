import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/features/inventory/application/inventory_providers.dart';
import 'package:gateway/features/inventory/data/stock_repository.dart';
import 'package:gateway/features/inventory/domain/product.dart';
import 'package:gateway/features/inventory/domain/stock_level.dart';
import 'package:gateway/features/inventory/domain/cylinder_ledger.dart';
import 'package:gateway/features/sales/application/cart_provider.dart';
import 'package:riverpod/riverpod.dart';

class MockStockRepository implements StockRepository {
  final Map<String, Map<String, int>> _stock;

  MockStockRepository(this._stock);

  @override
  Future<StockLevel?> getStockLevel(String branchId, String productId) async {
    final branchStock = _stock[branchId];
    if (branchStock == null) return null;
    final qty = branchStock[productId];
    if (qty == null) return null;
    return StockLevel(branchId: branchId, productId: productId, quantity: qty);
  }

  @override
  Future<List<StockLevel>> getBranchStock(String branchId) async {
    final branchStock = _stock[branchId] ?? {};
    return branchStock.entries
        .map((e) => StockLevel(
              branchId: branchId,
              productId: e.key,
              quantity: e.value,
            ))
        .toList();
  }

  @override
  Future<void> addStock(String branchId, String productId, int quantity) async {
    _stock[branchId] ??= {};
    _stock[branchId]![productId] = (_stock[branchId]![productId] ?? 0) + quantity;
  }

  @override
  Future<void> deductStock(String branchId, String productId, int quantity) async {
    _stock[branchId] ??= {};
    _stock[branchId]![productId] = (_stock[branchId]![productId] ?? 0) - quantity;
  }

  @override
  Future<CylinderLedger?> getCylinderLedger(String branchId, String brand, double sizeKg) async => null;

  @override
  Future<void> updateCylinderLedger(String branchId, String brand, double sizeKg, int fullDelta, int emptyDelta) async {}
}

void main() {
  const branch1 = 'branch1';
  const branch2 = 'branch2';

  const product1 = Product(
    id: 'p1',
    name: 'LPG 13kg',
    kind: ProductKind.refill,
    price: 2500,
  );

  const product2 = Product(
    id: 'p2',
    name: 'Regulator',
    kind: ProductKind.accessory,
    price: 500,
  );

  ProviderContainer makeContainer(Map<String, Map<String, int>> stock) {
    return ProviderContainer(
      overrides: [
        stockRepositoryProvider.overrideWith((ref) => MockStockRepository(stock)),
      ],
    );
  }

  group('Cart Provider', () {
    test('starts empty for a branch', () {
      final container = makeContainer({});
      final cart = container.read(cartProvider(branch1));

      expect(cart.items, isEmpty);
      expect(cart.total, 0);
      expect(cart.totalItems, 0);
    });

    test('add product creates line', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      final result = await notifier.add(product1);

      expect(result.added, 1);
      expect(result.message, isNull);

      final cart = container.read(cartProvider(branch1));
      expect(cart.items.length, 1);
      expect(cart.items[0].product.id, 'p1');
      expect(cart.items[0].quantity, 1);
      expect(cart.totalItems, 1);
    });

    test('add same product increments quantity', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 2);
      await notifier.add(product1, quantity: 3);

      final cart = container.read(cartProvider(branch1));
      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 5);
    });

    test('add enforces stock limits', () async {
      final container = makeContainer({
        branch1: {'p1': 5},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      final result = await notifier.add(product1, quantity: 10);

      expect(result.added, 5);
      expect(result.message, contains('Only 5'));
      expect(result.message, contains('stock limit reached'));

      final cart = container.read(cartProvider(branch1));
      expect(cart.items[0].quantity, 5);
    });

    test('add returns zero when no stock', () async {
      final container = makeContainer({
        branch1: {'p1': 0},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      final result = await notifier.add(product1);

      expect(result.added, 0);
      expect(result.message, contains('No more stock available'));

      final cart = container.read(cartProvider(branch1));
      expect(cart.items, isEmpty);
    });

    test('add returns zero when stock already in cart', () async {
      final container = makeContainer({
        branch1: {'p1': 5},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 5);

      final result = await notifier.add(product1);
      expect(result.added, 0);
      expect(result.message, contains('No more stock available'));

      final cart = container.read(cartProvider(branch1));
      expect(cart.items[0].quantity, 5);
    });

    test('remove item works', () async {
      final container = makeContainer({
        branch1: {'p1': 10, 'p2': 20},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1);
      await notifier.add(product2);

      final removed = notifier.removeWithUndo(0);

      expect(removed, isNotNull);
      expect(removed!.product.id, 'p1');

      final cart = container.read(cartProvider(branch1));
      expect(cart.items.length, 1);
      expect(cart.items[0].product.id, 'p2');
    });

    test('update quantity works', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 3);

      await notifier.updateQuantity(0, 5);

      final cart = container.read(cartProvider(branch1));
      expect(cart.items[0].quantity, 5);
    });

    test('update quantity enforces stock limit', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 3);

      final message = await notifier.updateQuantity(0, 20);

      expect(message, contains('Only 10'));
      expect(message, contains('in stock'));

      final cart = container.read(cartProvider(branch1));
      expect(cart.items[0].quantity, 10);
    });

    test('update quantity to zero removes item', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 3);

      await notifier.updateQuantity(0, 0);

      final cart = container.read(cartProvider(branch1));
      expect(cart.items, isEmpty);
    });

    test('clear empties cart', () async {
      final container = makeContainer({
        branch1: {'p1': 10, 'p2': 20},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1);
      await notifier.add(product2);

      notifier.clear();

      final cart = container.read(cartProvider(branch1));
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
      expect(cart.totalItems, 0);
    });

    test('cart is separate per branch', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
        branch2: {'p1': 20},
      });

      final notifier1 = container.read(cartProvider(branch1).notifier);
      final notifier2 = container.read(cartProvider(branch2).notifier);

      await notifier1.add(product1, quantity: 2);
      await notifier2.add(product1, quantity: 5);

      final cart1 = container.read(cartProvider(branch1));
      final cart2 = container.read(cartProvider(branch2));

      expect(cart1.items[0].quantity, 2);
      expect(cart2.items[0].quantity, 5);
    });

    test('cart persists when provider is re-read', () async {
      final container = makeContainer({
        branch1: {'p1': 10},
      });

      final notifier = container.read(cartProvider(branch1).notifier);
      await notifier.add(product1, quantity: 3);

      final cart1 = container.read(cartProvider(branch1));
      expect(cart1.items[0].quantity, 3);

      final cart2 = container.read(cartProvider(branch1));
      expect(cart2.items[0].quantity, 3);
      expect(cart2.items, cart1.items);
    });
  });
}
