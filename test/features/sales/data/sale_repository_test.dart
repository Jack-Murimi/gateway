import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/features/sales/domain/sales_models.dart';
import 'package:gateway/features/sales/domain/returned_cylinder.dart';
import 'package:gateway/features/sales/data/mock_repositories.dart';
import 'package:gateway/features/inventory/data/mock_stock_repository.dart';
import 'package:gateway/features/customers/data/mock_customer_repository.dart';

void main() {
  group('MockSaleRepository', () {
    late MockStockRepository stockRepo;
    late MockCustomerRepository customerRepo;
    late MockSaleRepository saleRepo;

    setUp(() {
      stockRepo = MockStockRepository();
      customerRepo = MockCustomerRepository();
      saleRepo = MockSaleRepository(stockRepo: stockRepo, customerRepo: customerRepo);
    });

    test('completeSale deducts stock', () async {
      final sale = Sale(
        id: 'sale1',
        receiptNumber: 'R001',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 2,
            unitPrice: 3300,
          ),
        ],
        payments: [
          Payment(
            method: PaymentMethod.cash,
            amount: 6600,
            timestamp: DateTime.now(),
          ),
        ],
        status: SaleStatus.completed,
        returnedCylinders: [],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      final stockBefore = await stockRepo.getStockLevel('jamhuri', 'afrigas-13kg-refill');
      expect(stockBefore?.quantity, 45);

      await saleRepo.completeSale(sale);

      final stockAfter = await stockRepo.getStockLevel('jamhuri', 'afrigas-13kg-refill');
      expect(stockAfter?.quantity, 43);
    });

    test('completeSale updates cylinder ledger', () async {
      // Initialize ledger with stock
      await stockRepo.updateCylinderLedger('jamhuri', 'Afrigas', 13, 45, 0);

      final sale = Sale(
        id: 'sale2',
        receiptNumber: 'R002',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 1,
            unitPrice: 3300,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 3300, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [
          ReturnedCylinder(brand: 'Afrigas', sizeKg: 13, count: 1),
        ],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      await saleRepo.completeSale(sale);

      final ledger = await stockRepo.getCylinderLedger('jamhuri', 'Afrigas', 13);
      expect(ledger?.fullCount, 44); // 45 - 1 (sold)
      expect(ledger?.emptyCount, 1);  // +1 (returned)
    });

    test('completeSale updates customer balance for credit', () async {
      final sale = Sale(
        id: 'sale3',
        receiptNumber: 'R003',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'cust-mama-lucy',
        customerLocationId: 'loc1',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 1,
            unitPrice: 3300,
          ),
        ],
        payments: [],
        status: SaleStatus.credit,
        returnedCylinders: [],
        cashierId: 'john',
        dueDate: DateTime(2026, 10, 5),
        createdAt: DateTime.now(),
      );

      final customerBefore = await customerRepo.getCustomer('cust-mama-lucy');
      expect(customerBefore?.balance, 450);

      await saleRepo.completeSale(sale);

      final customerAfter = await customerRepo.getCustomer('cust-mama-lucy');
      expect(customerAfter?.balance, 3750); // 450 + 3300
    });

    test('completeSale updates customer emptiesOwed', () async {
      final sale = Sale(
        id: 'sale4',
        receiptNumber: 'R004',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'cust-mama-lucy',
        customerLocationId: 'loc1',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 3,
            unitPrice: 3300,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 9900, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [
          ReturnedCylinder(brand: 'Afrigas', sizeKg: 13, count: 1), // only 1 returned, 2 owed
        ],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      final customerBefore = await customerRepo.getCustomer('cust-mama-lucy');
      expect(customerBefore?.emptiesOwed, 0);

      await saleRepo.completeSale(sale);

      final customerAfter = await customerRepo.getCustomer('cust-mama-lucy');
      expect(customerAfter?.emptiesOwed, 2); // 3 sold - 1 returned = 2 owed
    });

    test('completeSale enforces stock availability', () async {
      final sale = Sale(
        id: 'sale5',
        receiptNumber: 'R005',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 100, // exceeds stock (45)
            unitPrice: 3300,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 330000, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      expect(
        () => saleRepo.completeSale(sale),
        throwsA(isA<Exception>()),
      );
    });

    test('isReceiptNumberUsed checks per branch', () async {
      final sale1 = Sale(
        id: 'sale6',
        receiptNumber: 'R100',
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

      await saleRepo.completeSale(sale1);

      expect(await saleRepo.isReceiptNumberUsed('R100', 'jamhuri'), true);
      expect(await saleRepo.isReceiptNumberUsed('R100', 'lavington'), false); // different branch
      expect(await saleRepo.isReceiptNumberUsed('R999', 'jamhuri'), false); // different number
    });

    test('completeSale is idempotent with same sale ID', () async {
      final sale = Sale(
        id: 'idempotent-test',
        receiptNumber: 'R200',
        date: DateTime(2026, 10, 2),
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'none',
        lines: [
          SaleLine(
            productId: 'afrigas-13kg-refill',
            productName: '13kg Afrigas',
            quantity: 1,
            unitPrice: 3300,
          ),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 3300, timestamp: DateTime.now())],
        status: SaleStatus.completed,
        returnedCylinders: [],
        cashierId: 'john',
        createdAt: DateTime.now(),
      );

      final stockBefore = await stockRepo.getStockLevel('jamhuri', 'afrigas-13kg-refill');
      
      await saleRepo.completeSale(sale);
      await saleRepo.completeSale(sale); // duplicate call

      final stockAfter = await stockRepo.getStockLevel('jamhuri', 'afrigas-13kg-refill');
      expect(stockAfter?.quantity, stockBefore!.quantity - 1); // only deducted once
      
      final allSales = await saleRepo.getSales();
      expect(allSales.where((s) => s.id == 'idempotent-test').length, 1); // only saved once
    });
  });
}
