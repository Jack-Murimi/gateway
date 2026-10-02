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

  final String id;
  final String name;
  final String phone;
  final bool isWalkIn;
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
  const Location({
    required this.id,
    required this.address,
    this.isDefault = false,
  });

  final String id;
  final String address;
  final bool isDefault;

  static const defaultLocation = Location(
    id: 'default',
    address: 'Default Location',
    isDefault: true,
  );
}

/// Product model.
/// [price] is in whole KES (integer).
/// [stock] is the available quantity at the current branch.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.cylinderType,
  });

  final String id;
  final String name;

  /// Price in whole KES.
  final int price;

  /// Stock quantity at current branch.
  final int stock;

  /// Cylinder type if this is a cylinder product (e.g. '6kg', '13kg').
  final String? cylinderType;
}

/// Sale line item.
class SaleLineItem {
  const SaleLineItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  /// Line total in whole KES.
  int get total => product.price * quantity;

  SaleLineItem copyWith({int? quantity}) =>
      SaleLineItem(product: product, quantity: quantity ?? this.quantity);
}
