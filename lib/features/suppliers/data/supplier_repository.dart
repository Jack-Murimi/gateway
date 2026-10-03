import '../domain/supplier.dart';

/// Supplier data repository.
abstract class SupplierRepository {
  /// Lists all active suppliers (not deleted).
  Future<List<Supplier>> listSuppliers();

  /// Lists all suppliers including deleted (for audit/history).
  Future<List<Supplier>> listAllSuppliers();

  /// Finds supplier by ID (including deleted for audit trail).
  Future<Supplier?> findById(String id);

  /// Creates or updates a supplier.
  Future<void> save(Supplier supplier);

  /// Soft deletes a supplier (preserves for audit trail).
  Future<void> delete(String id);

  /// Permanently removes a supplier (use with caution).
  Future<void> permanentlyDelete(String id);
}
