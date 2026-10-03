import '../domain/stock_level.dart';
import '../domain/cylinder_ledger.dart';
import 'stock_repository.dart';

/// Mock stock repository with mutable in-memory stock.
class MockStockRepository implements StockRepository {
  final _stock = <String, Map<String, int>>{
    'jamhuri': {
      'afrigas-13kg-refill': 45, 'afrigas-6kg-refill': 32, 'afrigas-13kg-empty': 12, 'afrigas-6kg-empty': 8,
      'progas-13kg-refill': 38, 'progas-6kg-refill': 28, 'progas-13kg-empty': 10, 'progas-6kg-empty': 6,
      'kgas-13kg-refill': 52, 'kgas-6kg-refill': 35, 'kgas-13kg-empty': 15, 'kgas-6kg-empty': 9,
      'totalgaz-13kg-refill': 40, 'totalgaz-6kg-refill': 30, 'totalgaz-13kg-empty': 11, 'totalgaz-6kg-empty': 7,
      'burner-kit': 8, 'hose-1.5m': 67, 'double-stove': 15, 'single-stove': 23,
    },
  };

  final _cylinderLedgers = <String, CylinderLedger>{};

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
    final branchStock = _stock[branchId];
    if (branchStock == null) return [];
    return branchStock.entries
        .map((e) => StockLevel(branchId: branchId, productId: e.key, quantity: e.value))
        .toList();
  }

  @override
  Future<void> deductStock(String branchId, String productId, int quantity) async {
    final branchStock = _stock.putIfAbsent(branchId, () => {});
    final current = branchStock[productId] ?? 0;
    branchStock[productId] = (current - quantity).clamp(0, 9999);
  }

  @override
  Future<void> addStock(String branchId, String productId, int quantity) async {
    final branchStock = _stock.putIfAbsent(branchId, () => {});
    final current = branchStock[productId] ?? 0;
    branchStock[productId] = (current + quantity).clamp(0, 9999);
  }

  @override
  Future<CylinderLedger?> getCylinderLedger(String branchId, String brand, double sizeKg) async {
    final key = '$branchId:$brand:$sizeKg';
    return _cylinderLedgers[key];
  }

  @override
  Future<void> updateCylinderLedger(String branchId, String brand, double sizeKg, int fullDelta, int emptyDelta) async {
    final key = '$branchId:$brand:$sizeKg';
    final current = _cylinderLedgers[key];
    if (current == null) {
      _cylinderLedgers[key] = CylinderLedger(
        branchId: branchId,
        brand: brand,
        sizeKg: sizeKg,
        fullCount: fullDelta.clamp(0, 9999),
        emptyCount: emptyDelta.clamp(0, 9999),
      );
    } else {
      _cylinderLedgers[key] = current.copyWith(
        fullCount: (current.fullCount + fullDelta).clamp(0, 9999),
        emptyCount: (current.emptyCount + emptyDelta).clamp(0, 9999),
      );
    }
  }
}
