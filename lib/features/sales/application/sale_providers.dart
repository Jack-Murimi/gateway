import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mock_repositories.dart';
import '../data/repositories.dart';
import '../domain/sales_models.dart';
import '../../inventory/application/inventory_providers.dart';
import '../../customers/application/customer_providers.dart';

part 'sale_providers.g.dart';

/// Sale repository.
@riverpod
SaleRepository saleRepository(Ref ref) {
  return MockSaleRepository(
    stockRepo: ref.watch(stockRepositoryProvider),
    customerRepo: ref.watch(customerRepositoryProvider),
  );
}

/// All sales list.
@riverpod
Future<List<Sale>> salesList(Ref ref) async {
  final repo = ref.watch(saleRepositoryProvider);
  return repo.getSales();
}

/// Sales filtered by branch.
@riverpod
Future<List<Sale>> branchSales(Ref ref, String branchId) async {
  final allSales = await ref.watch(salesListProvider.future);
  return allSales.where((s) => s.branchId == branchId).toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // newest first
}
