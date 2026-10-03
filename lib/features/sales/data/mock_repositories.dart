import '../domain/sales_models.dart';
import '../domain/returned_cylinder.dart';
import '../../inventory/data/stock_repository.dart';
import '../../customers/data/customer_repository.dart';
import 'repositories.dart';

/// Mock sale repository with in-memory storage.
class MockSaleRepository implements SaleRepository {
  MockSaleRepository({
    required this._stockRepo,
    required this._customerRepo,
  }) {
    _initSampleData();
  }

  final StockRepository _stockRepo;
  final CustomerRepository _customerRepo;
  final _sales = <Sale>[];
  final _usedReceipts = <String, Set<String>>{}; // branchId -> receipt numbers

  void _initSampleData() {
    // Sample completed sales for testing
    final now = DateTime.now();
    final sale1Date = now.subtract(const Duration(hours: 2));
    final sale2Date = now.subtract(const Duration(hours: 5));
    final sale3Date = now.subtract(const Duration(days: 1));
    
    _sales.addAll([
      Sale(
        id: 'sale-001',
        receiptNumber: 'RCP-001',
        date: sale1Date,
        branchId: 'jamhuri',
        customerId: 'cust-mama-lucy',
        customerLocationId: 'loc-001',
        lines: const [
          SaleLine(productId: 'afrigas-13kg-refill', productName: 'Afrigas 13kg Refill', unitPrice: 3300, quantity: 2),
        ],
        payments: [Payment(method: PaymentMethod.cash, amount: 6600, timestamp: sale1Date)],
        status: SaleStatus.completed,
        returnedCylinders: [ReturnedCylinder(brand: 'Afrigas', sizeKg: 13, count: 2)],
        cashierId: 'john_kamau',
        createdAt: sale1Date,
      ),
      Sale(
        id: 'sale-002',
        receiptNumber: 'RCP-002',
        date: sale2Date,
        branchId: 'jamhuri',
        customerId: 'walk-in',
        customerLocationId: 'default',
        lines: const [
          SaleLine(productId: 'total-6kg-refill', productName: 'Total 6kg Refill', unitPrice: 1850, quantity: 1),
          SaleLine(productId: 'regulator-low', productName: 'Low Pressure Regulator', unitPrice: 800, quantity: 1),
        ],
        payments: [Payment(method: PaymentMethod.mpesa, amount: 2650, timestamp: sale2Date, reference: 'MPESA12345')],
        status: SaleStatus.completed,
        returnedCylinders: [ReturnedCylinder(brand: 'Total', sizeKg: 6, count: 1)],
        cashierId: 'john_kamau',
        createdAt: sale2Date,
      ),
      Sale(
        id: 'sale-003',
        receiptNumber: 'RCP-003',
        date: sale3Date,
        branchId: 'jamhuri',
        customerId: 'cust-mama-lucy',
        customerLocationId: 'loc-001',
        lines: const [
          SaleLine(productId: 'k-gas-13kg-refill', productName: 'K-Gas 13kg Refill', unitPrice: 3250, quantity: 1),
        ],
        payments: const [],
        status: SaleStatus.credit,
        returnedCylinders: [ReturnedCylinder(brand: 'K-Gas', sizeKg: 13, count: 1)],
        cashierId: 'john_kamau',
        createdAt: sale3Date,
        dueDate: now.add(const Duration(days: 13)),
      ),
    ]);
    
    // Mark receipts as used
    for (final sale in _sales) {
      _usedReceipts.putIfAbsent(sale.branchId, () => {}).add(sale.receiptNumber);
    }
  }

  @override
  Future<void> completeSale(Sale sale) async {
    // ponytail: wrap in transaction when database added

    // 0. Idempotency: if sale ID already exists, skip
    if (_sales.any((s) => s.id == sale.id)) {
      return;
    }

    // 1. Check receipt uniqueness per branch
    final branchReceipts = _usedReceipts.putIfAbsent(sale.branchId, () => {});
    if (branchReceipts.contains(sale.receiptNumber)) {
      throw Exception('Receipt number ${sale.receiptNumber} already used at branch ${sale.branchId}');
    }

    // 2. Validate stock levels
    for (final line in sale.lines) {
      final stock = await _stockRepo.getStockLevel(sale.branchId, line.productId);
      if (stock == null || stock.quantity < line.quantity) {
        throw Exception('Insufficient stock for ${line.productName}');
      }
    }

    // 3. Deduct stock
    for (final line in sale.lines) {
      await _stockRepo.deductStock(sale.branchId, line.productId, line.quantity);
    }

    // 4. Update cylinder ledger for refills sold
    final refillsSold = sale.lines.where((l) => l.productId.contains('-refill')).fold<int>(0, (sum, l) => sum + l.quantity);
    if (refillsSold > 0) {
      // ponytail: parse brand/size from productId instead of hardcoding
      // For now: extract from first refill line productId (e.g., 'afrigas-13kg-refill')
      final refillLine = sale.lines.firstWhere((l) => l.productId.contains('-refill'));
      final parts = refillLine.productId.split('-');
      if (parts.length >= 3) {
        final brand = parts[0][0].toUpperCase() + parts[0].substring(1); // capitalize
        final sizeStr = parts[1].replaceAll('kg', '');
        final sizeKg = double.tryParse(sizeStr) ?? 13.0;
        
        await _stockRepo.updateCylinderLedger(
          sale.branchId,
          brand,
          sizeKg,
          -refillsSold, // full cylinders out
          0,
        );
      }
    }

    // 5. Update cylinder ledger for empties returned
    for (final returned in sale.returnedCylinders) {
      await _stockRepo.updateCylinderLedger(
        sale.branchId,
        returned.brand,
        returned.sizeKg,
        0,
        returned.count, // empties in
      );
    }

    // 6. Update customer balance for credit sales
    if (sale.status == SaleStatus.credit && sale.customerId != 'walk-in') {
      final customer = await _customerRepo.getCustomer(sale.customerId);
      if (customer != null) {
        await _customerRepo.updateBalance(sale.customerId, customer.balance + sale.balance);
      }
    }

    // 7. Track empties owed (refills sold - empties returned)
    final emptiesReturned = sale.returnedCylinders.fold<int>(0, (sum, r) => sum + r.count);
    final emptiesDelta = refillsSold - emptiesReturned;
    if (emptiesDelta != 0 && sale.customerId != 'walk-in') {
      final customer = await _customerRepo.getCustomer(sale.customerId);
      if (customer != null) {
        await _customerRepo.updateEmptiesOwed(sale.customerId, customer.emptiesOwed + emptiesDelta);
      }
    }

    // 8. Save sale
    _sales.add(sale);
    branchReceipts.add(sale.receiptNumber);
  }

  @override
  Future<void> saveSale(Sale sale) async {
    // Deprecated: use completeSale for atomic operation
    // ponytail: remove after migration
    _sales.add(sale);
    final branchReceipts = _usedReceipts.putIfAbsent(sale.branchId, () => {});
    branchReceipts.add(sale.receiptNumber);
  }

  @override
  Future<List<Sale>> getSales() async => List.unmodifiable(_sales);

  @override
  Future<Sale?> getSale(String id) async {
    try {
      return _sales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isReceiptNumberUsed(String receiptNumber, String branchId) async {
    final branchReceipts = _usedReceipts[branchId];
    return branchReceipts?.contains(receiptNumber) ?? false;
  }

  @override
  Future<void> voidSale(String saleId, String reason, String voidedBy) async {
    final idx = _sales.indexWhere((s) => s.id == saleId);
    if (idx == -1) throw Exception('Sale not found: $saleId');

    final old = _sales[idx];
    if (old.status == SaleStatus.voided) {
      throw Exception('Sale already voided');
    }

    // ponytail: reverse stock/ledger/balance changes when voiding
    _sales[idx] = Sale(
      id: old.id,
      receiptNumber: old.receiptNumber,
      date: old.date,
      branchId: old.branchId,
      customerId: old.customerId,
      customerLocationId: old.customerLocationId,
      lines: old.lines,
      payments: old.payments,
      status: SaleStatus.voided,
      returnedCylinders: old.returnedCylinders,
      cashierId: old.cashierId,
      createdAt: old.createdAt,
      dueDate: old.dueDate,
      voidReason: reason,
      voidedBy: voidedBy,
      voidedAt: DateTime.now(),
    );
  }
}
