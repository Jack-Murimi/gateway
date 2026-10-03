import '../domain/product.dart';
import 'product_repository.dart';

/// Mock product repository with hardcoded catalog.
class MockProductRepository implements ProductRepository {
  static const _products = [
    // Afrigas
    Product(id: 'afrigas-13kg-refill', name: '13kg Afrigas Refill', kind: ProductKind.refill, price: 3300, brand: 'Afrigas', sizeKg: 13),
    Product(id: 'afrigas-6kg-refill', name: '6kg Afrigas Refill', kind: ProductKind.refill, price: 1800, brand: 'Afrigas', sizeKg: 6),
    Product(id: 'afrigas-13kg-empty', name: '13kg Afrigas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 5500, brand: 'Afrigas', sizeKg: 13),
    Product(id: 'afrigas-6kg-empty', name: '6kg Afrigas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 3200, brand: 'Afrigas', sizeKg: 6),
    // Progas
    Product(id: 'progas-13kg-refill', name: '13kg Progas Refill', kind: ProductKind.refill, price: 3200, brand: 'Progas', sizeKg: 13),
    Product(id: 'progas-6kg-refill', name: '6kg Progas Refill', kind: ProductKind.refill, price: 1750, brand: 'Progas', sizeKg: 6),
    Product(id: 'progas-13kg-empty', name: '13kg Progas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 5300, brand: 'Progas', sizeKg: 13),
    Product(id: 'progas-6kg-empty', name: '6kg Progas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 3100, brand: 'Progas', sizeKg: 6),
    // K-gas
    Product(id: 'kgas-13kg-refill', name: '13kg K-gas Refill', kind: ProductKind.refill, price: 3400, brand: 'K-gas', sizeKg: 13),
    Product(id: 'kgas-6kg-refill', name: '6kg K-gas Refill', kind: ProductKind.refill, price: 1850, brand: 'K-gas', sizeKg: 6),
    Product(id: 'kgas-13kg-empty', name: '13kg K-gas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 5600, brand: 'K-gas', sizeKg: 13),
    Product(id: 'kgas-6kg-empty', name: '6kg K-gas Empty Cylinder', kind: ProductKind.emptyCylinder, price: 3300, brand: 'K-gas', sizeKg: 6),
    // Totalgaz
    Product(id: 'totalgaz-13kg-refill', name: '13kg Totalgaz Refill', kind: ProductKind.refill, price: 3350, brand: 'Totalgaz', sizeKg: 13),
    Product(id: 'totalgaz-6kg-refill', name: '6kg Totalgaz Refill', kind: ProductKind.refill, price: 1820, brand: 'Totalgaz', sizeKg: 6),
    Product(id: 'totalgaz-13kg-empty', name: '13kg Totalgaz Empty Cylinder', kind: ProductKind.emptyCylinder, price: 5450, brand: 'Totalgaz', sizeKg: 13),
    Product(id: 'totalgaz-6kg-empty', name: '6kg Totalgaz Empty Cylinder', kind: ProductKind.emptyCylinder, price: 3250, brand: 'Totalgaz', sizeKg: 6),
    // Accessories
    Product(id: 'burner-kit', name: 'Burner Regulator Kit', kind: ProductKind.accessory, price: 1250),
    Product(id: 'hose-1.5m', name: 'Gas Hose 1.5m', kind: ProductKind.accessory, price: 450),
    Product(id: 'double-stove', name: 'Double Burner Stove', kind: ProductKind.accessory, price: 4800),
    Product(id: 'single-stove', name: 'Single Burner Stove', kind: ProductKind.accessory, price: 2400),
  ];

  @override
  Future<List<Product>> getProducts() async => _products;

  @override
  Future<List<Product>> searchProducts(String query) async {
    final lower = query.toLowerCase();
    return _products.where((p) => 
      p.name.toLowerCase().contains(lower) || 
      (p.brand?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }

  @override
  Future<Product?> getProduct(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
