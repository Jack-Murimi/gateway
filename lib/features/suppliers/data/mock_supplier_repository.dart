import '../domain/supplier.dart';
import 'supplier_repository.dart';

/// Mock supplier repository with sample data.
class MockSupplierRepository implements SupplierRepository {
  MockSupplierRepository() {
    _initSampleData();
  }

  final Map<String, Supplier> _suppliers = {};

  void _initSampleData() {
    final samples = [
      const Supplier(
        id: 'supp-kenya-gas',
        name: 'Kenya Gas Ltd',
        phone: '+254720111222',
        email: 'orders@kenyagas.co.ke',
        balance: -45000, // We owe 45,000 KES
        lastOrderDate: '2024-01-15',
      ),
      const Supplier(
        id: 'supp-pro-gas',
        name: 'Pro Gas Kenya',
        phone: '+254733222333',
        email: 'sales@progas.co.ke',
        balance: 0, // Settled
        lastOrderDate: '2024-01-12',
      ),
      const Supplier(
        id: 'supp-total',
        name: 'Total Energies',
        phone: '+254744333444',
        email: 'b2b@totalenergies.co.ke',
        balance: -120000, // We owe 120,000 KES
        lastOrderDate: '2024-01-10',
      ),
      const Supplier(
        id: 'supp-hashi',
        name: 'Hashi Energy',
        phone: '+254755444555',
        balance: 25000, // They owe us 25,000 KES (overpayment/returns)
        lastOrderDate: '2024-01-08',
      ),
    ];

    for (final supplier in samples) {
      _suppliers[supplier.id] = supplier;
    }
  }

  @override
  Future<List<Supplier>> listSuppliers() async {
    return _suppliers.values.where((s) => s.isActive).toList();
  }

  @override
  Future<List<Supplier>> listAllSuppliers() async {
    return _suppliers.values.toList();
  }

  @override
  Future<Supplier?> findById(String id) async {
    return _suppliers[id];
  }

  @override
  Future<void> save(Supplier supplier) async {
    _suppliers[supplier.id] = supplier;
  }

  @override
  Future<void> delete(String id) async {
    final supplier = _suppliers[id];
    if (supplier != null) {
      _suppliers[id] = supplier.copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> permanentlyDelete(String id) async {
    _suppliers.remove(id);
  }
}
