import 'package:equatable/equatable.dart';

/// Product kind.
enum ProductKind { refill, emptyCylinder, accessory }

/// Product catalog data (no per-branch stock).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.kind,
    required this.price,
    this.brand,
    this.sizeKg,
  });

  final String id;
  final String name;
  final ProductKind kind;
  final int price;
  final String? brand;
  final double? sizeKg;

  /// Create a copy with updated fields.
  Product copyWith({
    String? id,
    String? name,
    ProductKind? kind,
    int? price,
    String? brand,
    double? sizeKg,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      sizeKg: sizeKg ?? this.sizeKg,
    );
  }

  @override
  List<Object?> get props => [id, name, kind, price, brand, sizeKg];
}
