import '../domain/customer.dart';

/// Customer repository.
abstract class CustomerRepository {
  /// Get all customers.
  Future<List<Customer>> getCustomers();
  
  /// Search customers by name or phone.
  Future<List<Customer>> searchCustomers(String query);
  
  /// Get customer by ID.
  Future<Customer?> getCustomer(String id);
  
  /// Update customer balance (for credit sales).
  Future<void> updateBalance(String customerId, int newBalance);
  
  /// Update empties owed count.
  Future<void> updateEmptiesOwed(String customerId, int newEmptiesOwed);
}
