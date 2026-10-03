import '../domain/stock_level.dart';
import '../domain/cylinder_ledger.dart';

/// Stock level repository.
abstract class StockRepository {
  /// Get stock level for a product at a branch.
  Future<StockLevel?> getStockLevel(String branchId, String productId);
  
  /// Get all stock levels for a branch.
  Future<List<StockLevel>> getBranchStock(String branchId);
  
  /// Deduct stock for a product at a branch.
  Future<void> deductStock(String branchId, String productId, int quantity);
  
  /// Add stock for a product at a branch.
  Future<void> addStock(String branchId, String productId, int quantity);
  
  /// Get cylinder ledger entry for branch/brand/size.
  Future<CylinderLedger?> getCylinderLedger(String branchId, String brand, double sizeKg);
  
  /// Update cylinder ledger (full/empty counts).
  Future<void> updateCylinderLedger(String branchId, String brand, double sizeKg, int fullDelta, int emptyDelta);
}
