import 'package:equatable/equatable.dart';

/// Returned cylinder entry (brand/size/count).
class ReturnedCylinder extends Equatable {
  const ReturnedCylinder({
    required this.brand,
    required this.sizeKg,
    required this.count,
  });

  final String brand;
  final double sizeKg;
  final int count;

  @override
  List<Object?> get props => [brand, sizeKg, count];
}
