import '../domain/product.dart';

/// Product catalog repository.
abstract class ProductRepository {
  /// Get all products.
  Future<List<Product>> getProducts();
  
  /// Search products by name or brand.
  Future<List<Product>> searchProducts(String query);
  
  /// Get product by ID.
  Future<Product?> getProduct(String id);
  
  /// Create a new product.
  Future<void> createProduct(Product product);
  
  /// Update an existing product.
  Future<void> updateProduct(Product product);
  
  /// Delete a product.
  Future<void> deleteProduct(String id);
}
