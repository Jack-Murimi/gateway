import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/features/sales/domain/sales_models.dart';
import 'package:gateway/features/sales/data/mock_repositories.dart';
import 'package:gateway/features/inventory/data/mock_stock_repository.dart';
import 'package:gateway/features/customers/data/mock_customer_repository.dart';

void main() {
  group('voidSale', () {
    late MockSaleRepository saleRepo;

    setUp(() {
      final stockRepo = MockStockRepository();
      final customerRepo = MockCustomerRepository();
      saleRepo = MockSaleRepository(stockRepo: stockRepo, customerRepo: customerRepo);
    });

    test('voidSale marks sale as voided with audit fields', () async {
      final sale = Sale(
        id: 'void-test-1',
        receiptNumber: 'R500',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'hose-1.5m',
            productName: 'Hose',
            quantity: 1,
            unitPrice: 450,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 450, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      await saleRepo.completeSale(sale);

      await saleRepo.voidSale('void-test-1', 'Duplicate entry', 'manager-alice');

      final voided = await saleRepo.getSale('void-test-1');
      expect(voided?.status, SaleStatus.voided);
      expect(voided?.voidReason, 'Duplicate entry');
      expect(voided?.voidedBy, 'manager-alice');
      expect(voided?.voidedAt, isNotNull);
    });

    test('voidSale throws if sale not found', () async {
      expect(
        () => saleRepo.voidSale('nonexistent', 'reason', 'user'),
        throwsA(isA<Exception>()),
      );
    });

    test('voidSale throws if sale already voided', () async {
      final sale = Sale(
        id: 'void-test-2',
        receiptNumber: 'R501',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'hose-1.5m',
            productName: 'Hose',
            quantity: 1,
            unitPrice: 450,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 450, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      await saleRepo.completeSale(sale);
      await saleRepo.voidSale('void-test-2', 'First void', 'user1');

      expect(
        () => saleRepo.voidSale('void-test-2', 'Second void', 'user2'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
