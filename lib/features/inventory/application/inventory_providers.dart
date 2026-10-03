import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mock_product_repository.dart';
import '../data/mock_stock_repository.dart';
import '../data/product_repository.dart';
import '../data/stock_repository.dart';
import '../domain/product.dart';

part 'inventory_providers.g.dart';

/// Product repository.
@riverpod
ProductRepository productRepository(Ref ref) {
  return MockProductRepository();
}

/// Stock repository.
@riverpod
StockRepository stockRepository(Ref ref) {
  return MockStockRepository();
}

/// Products for a branch.
@riverpod
Future<List<Product>> products(Ref ref, String branchId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
}

/// Combined product + stock for a branch.
@riverpod
Future<List<ProductWithStock>> branchInventory(Ref ref, String branchId) async {
  final products = await ref.watch(productsProvider(branchId).future);
  final stockRepo = ref.watch(stockRepositoryProvider);
  final stockLevels = await stockRepo.getBranchStock(branchId);
  
  final stockMap = {for (var s in stockLevels) s.productId: s.quantity};
  
  return products.map((p) => ProductWithStock(
    product: p,
    quantity: stockMap[p.id] ?? 0,
  )).toList();
}

/// Product + stock display model.
class ProductWithStock {
  const ProductWithStock({required this.product, required this.quantity});
  final Product product;
  final int quantity;
}
