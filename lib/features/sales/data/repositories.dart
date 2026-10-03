import '../domain/sales_models.dart';

/// Sale repository interface.
abstract class SaleRepository {
  /// Atomically complete a sale: validate stock, save sale, deduct stock,
  /// update cylinder ledger, update customer balance for credit sales.
  /// Idempotent via client-generated UUID id.
  /// ponytail: implement transaction when database added
  Future<void> completeSale(Sale sale);
  
  /// Save a completed sale (deprecated, use completeSale).
  Future<void> saveSale(Sale sale);
  
  /// Get all sales.
  Future<List<Sale>> getSales();
  
  /// Get sale by ID.
  Future<Sale?> getSale(String id);
  
  /// Check if receipt number is already used (per branch).
  Future<bool> isReceiptNumberUsed(String receiptNumber, String branchId);
  
  /// Void sale with reason and audit.
  Future<void> voidSale(String saleId, String reason, String voidedBy);
}
