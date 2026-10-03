import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_supplier_repository.dart';
import '../data/supplier_repository.dart';
import '../domain/supplier.dart';

/// Provides the supplier repository.
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return MockSupplierRepository();
});

/// Provides the list of all suppliers.
final supplierListProvider = FutureProvider<List<Supplier>>((ref) async {
  final repo = ref.watch(supplierRepositoryProvider);
  return repo.listSuppliers();
});
