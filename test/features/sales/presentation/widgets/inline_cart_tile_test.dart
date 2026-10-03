import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/features/inventory/domain/product.dart';
import 'package:gateway/features/sales/domain/sales_models.dart';
import 'package:gateway/features/sales/presentation/widgets/inline_cart_tile.dart';
import 'package:intl/intl.dart';

void main() {
  group('InlineCartTile quantity edit bug fixes', () {
    const product = Product(id: 'p1', name: 'Test Product', kind: ProductKind.refill, price: 100);
    final currency = NumberFormat.currency(symbol: '\$');

    testWidgets('editing same value is no-op', (tester) async {
      var editCallCount = 0;
      int? lastEditedValue;

      final item = SaleLineItem(product: product, quantity: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineCartTile(
              item: item,
              currency: currency,
              onRemove: () {},
              onIncrement: () {},
              onDecrement: () {},
              onQuantityEdited: (qty) {
                editCallCount++;
                lastEditedValue = qty;
              },
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Focus, change to same value, blur
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(editCallCount, 0);
      expect(lastEditedValue, isNull);
    });

    testWidgets('clamped value resyncs text to actual quantity', (tester) async {
      int? lastEditedValue;
      var item = SaleLineItem(product: product, quantity: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return InlineCartTile(
                  item: item,
                  currency: currency,
                  onRemove: () {},
                  onIncrement: () {},
                  onDecrement: () {},
                  onQuantityEdited: (qty) {
                    lastEditedValue = qty;
                    // Simulate clamping to stock limit (5)
                    final clamped = qty > 5 ? 5 : qty;
                    setState(() {
                      item = SaleLineItem(product: product, quantity: clamped);
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);

      // User types 100, but stock is 5
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '100');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(lastEditedValue, 100);

      // Text field should show actual clamped value (5), not typed value (100)
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '5');
    });

    testWidgets('focus gain resets commit flag, allows multiple edits', (tester) async {
      var editCallCount = 0;
      final editedValues = <int>[];

      final item = SaleLineItem(product: product, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineCartTile(
              item: item,
              currency: currency,
              onRemove: () {},
              onIncrement: () {},
              onDecrement: () {},
              onQuantityEdited: (qty) {
                editCallCount++;
                editedValues.add(qty);
              },
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);

      // First edit: 1 -> 2
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(editCallCount, 1);
      expect(editedValues.last, 2);

      // Focus again, edit to 3
      await tester.tap(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(editCallCount, 2);
      expect(editedValues.last, 3);
    });
  });
}
