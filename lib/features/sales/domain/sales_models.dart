// Re-export BranchOption from branch_selector for convenience
export '../../../design_system/components/navigation/branch_selector.dart'
    show BranchOption;

/// Customer model.
class Customer {
  /// Creates a customer.
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.isWalkIn = false,
    this.locations = const [Location.defaultLocation],
  });

  /// Customer identifier.
  final String id;

  /// Customer name.
  final String name;

  /// Customer phone number.
  final String phone;

  /// Whether this is a walk-in customer.
  final bool isWalkIn;

  /// Customer locations.
  final List<Location> locations;

  /// Walk-in customer singleton.
  static const walkIn = Customer(
    id: 'walk-in',
    name: 'Walk-in Customer',
    phone: '',
    isWalkIn: true,
  );
}

/// Customer location.
class Location {
  /// Creates a location.
  const Location({
    required this.id,
    required this.address,
    this.isDefault = false,
  });

  /// Location identifier.
  final String id;

  /// Location address.
  final String address;

  /// Whether this is the default location.
  final bool isDefault;

  /// Default location singleton.
  static const defaultLocation = Location(
    id: 'default',
    address: 'Default Location',
    isDefault: true,
  );
}

/// Product model.
class Product {
  /// Creates a product.
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.cylinderType,
  });

  /// Product identifier.
  final String id;

  /// Product name.
  final String name;

  /// Product price.
  final double price;

  /// Stock quantity at current branch.
  final int stock;

  /// Cylinder type if this is a cylinder product.
  final String? cylinderType;
}

/// Sale line item.
class SaleLineItem {
  /// Creates a sale line item.
  const SaleLineItem({required this.product, required this.quantity});

  /// The product.
  final Product product;

  /// Quantity sold.
  final int quantity;

  /// Line total (price × quantity).
  double get total => product.price * quantity;

  /// Create a copy with modified quantity.
  SaleLineItem copyWith({int? quantity}) =>
      SaleLineItem(product: product, quantity: quantity ?? this.quantity);
}
