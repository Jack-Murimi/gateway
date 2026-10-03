import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/features/inventory/domain/product.dart';
import 'package:gateway/features/sales/presentation/sales_cart_controller.dart';

void main() {
  group('SalesCartController', () {
    late SalesCartController cart;
    late Map<String, int> stock;

    const product1 = Product(id: 'p1', name: 'Product 1', kind: ProductKind.refill, price: 100);
    const product2 = Product(id: 'p2', name: 'Product 2', kind: ProductKind.accessory, price: 200);
    const product3 = Product(id: 'p3', name: 'Product 3', kind: ProductKind.refill, price: 300);

    setUp(() {
      stock = {'p1': 10, 'p2': 5, 'p3': 0};
      cart = SalesCartController(getStock: (id) => stock[id] ?? 0);
    });

    tearDown(() {
      cart.dispose();
    });

    test('starts empty', () {
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
      expect(cart.totalItems, 0);
    });

    test('add product creates new line', () {
      final result = cart.add(product1, quantity: 2);
      expect(result.added, 2);
      expect(result.message, isNull);
      expect(cart.items.length, 1);
      expect(cart.items[0].product.id, 'p1');
      expect(cart.items[0].quantity, 2);
      expect(cart.total, 200);
      expect(cart.totalItems, 2);
    });

    test('add same product increments quantity', () {
      cart.add(product1, quantity: 2);
      cart.add(product1, quantity: 3);
      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 5);
      expect(cart.total, 500);
    });

    test('add enforces stock limit', () {
      final result = cart.add(product1, quantity: 15);
      expect(result.added, 10);
      expect(result.message, contains('stock limit'));
      expect(cart.items[0].quantity, 10);
    });

    test('add when no stock returns zero', () {
      final result = cart.add(product3);
      expect(result.added, 0);
      expect(result.message, contains('No more stock'));
      expect(cart.items, isEmpty);
    });

    test('add respects qty already in cart', () {
      cart.add(product2, quantity: 3);
      final result = cart.add(product2, quantity: 5);
      expect(result.added, 2);
      expect(result.message, contains('stock limit'));
      expect(cart.items[0].quantity, 5);
    });

    test('removeWithUndo deletes line', () {
      cart.add(product1);
      cart.add(product2);
      cart.removeWithUndo(0);
      expect(cart.items.length, 1);
      expect(cart.items[0].product.id, 'p2');
    });

    test('removeWithUndo returns removed item', () {
      cart.add(product1);
      final removed = cart.removeWithUndo(0);
      expect(removed, isNotNull);
      expect(removed!.product.id, 'p1');
      expect(cart.items, isEmpty);
    });

    test('undoRemove restores item via add', () {
      cart.add(product1);
      cart.add(product2);
      cart.removeWithUndo(0);
      cart.undoRemove();
      expect(cart.items.length, 2);
      // undo uses add(), so p1 merges with existing or appends
      expect(cart.items.map((i) => i.product.id), contains('p1'));
      expect(cart.items.map((i) => i.product.id), contains('p2'));
    });

    test('updateQuantity clamps to stock', () {
      cart.add(product2, quantity: 2);
      final message = cart.updateQuantity(0, 10);
      expect(message, contains('Only 5'));
      expect(cart.items[0].quantity, 5);
    });

    test('updateQuantity to zero removes line', () {
      cart.add(product1);
      cart.updateQuantity(0, 0);
      expect(cart.items, isEmpty);
    });

    test('updateQuantity negative removes line', () {
      cart.add(product1);
      cart.updateQuantity(0, -5);
      expect(cart.items, isEmpty);
    });

    test('clear empties cart', () {
      cart.add(product1);
      cart.add(product2);
      cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
    });

    test('qtyInCart returns correct value', () {
      cart.add(product1, quantity: 3);
      expect(cart.qtyInCart('p1'), 3);
      expect(cart.qtyInCart('p2'), 0);
    });

    test('notifies listeners on changes', () {
      var notified = 0;
      cart.addListener(() => notified++);

      cart.add(product1);
      expect(notified, 1);

      cart.updateQuantity(0, 5);
      expect(notified, 2);

      cart.removeWithUndo(0);
      expect(notified, 3);

      cart.add(product2);
      cart.clear();
      expect(notified, 5);
    });

    test('calculates total correctly', () {
      cart.add(product1, quantity: 2); // 200
      cart.add(product2, quantity: 3); // 600
      expect(cart.total, 800);
    });

    test('calculates totalItems correctly', () {
      cart.add(product1, quantity: 2);
      cart.add(product2, quantity: 3);
      expect(cart.totalItems, 5);
    });

    test('undo after re-adding different product works', () {
      cart.add(product1, quantity: 3);
      cart.removeWithUndo(0);
      expect(cart.items, isEmpty);
      
      cart.add(product2, quantity: 2);
      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 2);
      
      cart.undoRemove();
      expect(cart.items.length, 2);
      expect(cart.items.any((i) => i.product.id == 'p1' && i.quantity == 3), isTrue);
      expect(cart.items.any((i) => i.product.id == 'p2' && i.quantity == 2), isTrue);
    });

    test('undo invalidated after clear', () {
      cart.add(product1, quantity: 3);
      cart.removeWithUndo(0);
      expect(cart.items, isEmpty);
      
      cart.clear();
      cart.undoRemove();
      expect(cart.items, isEmpty); // undo should do nothing
    });

    test('undo invalidated when same product added', () {
      cart.add(product1, quantity: 3);
      cart.removeWithUndo(0);
      expect(cart.items, isEmpty);
      
      cart.add(product1, quantity: 2);
      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 2);
      
      cart.undoRemove();
      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 2); // undo should do nothing
    });
  });
}
