import '../domain/customer.dart';
import 'customer_repository.dart';

/// Mock customer repository with hardcoded data.
class MockCustomerRepository implements CustomerRepository {
  final _customers = <Customer>[
    Customer.walkIn,
    const Customer(id: '1', name: 'John Doe', phones: ['0712345678']),
    const Customer(id: '2', name: 'Jane Smith', phones: ['0723456789']),
    const Customer(id: '3', name: 'ABC Restaurant', phones: ['0734567890']),
    const Customer(id: 'cust-mama-lucy', name: 'Mama Lucy', phones: ['0745123456'], balance: 450, creditLimit: 50000),
  ];

  @override
  Future<List<Customer>> getCustomers() async => _customers;

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final lower = query.toLowerCase();
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.phones.any((p) => p.contains(query)))
        .toList();
  }

  @override
  Future<Customer?> getCustomer(String id) async {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateBalance(String customerId, int newBalance) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;
    final old = _customers[idx];
    _customers[idx] = Customer(
      id: old.id,
      name: old.name,
      phones: old.phones,
      locations: old.locations,
      balance: newBalance,
      creditLimit: old.creditLimit,
      emptiesOwed: old.emptiesOwed,
    );
  }

  @override
  Future<void> updateEmptiesOwed(String customerId, int newEmptiesOwed) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;
    final old = _customers[idx];
    _customers[idx] = Customer(
      id: old.id,
      name: old.name,
      phones: old.phones,
      locations: old.locations,
      balance: old.balance,
      creditLimit: old.creditLimit,
      emptiesOwed: newEmptiesOwed,
    );
  }
}
