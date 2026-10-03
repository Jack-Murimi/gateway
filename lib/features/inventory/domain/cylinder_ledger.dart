import 'package:equatable/equatable.dart';

/// Cylinder inventory ledger entry per branch/brand/size.
class CylinderLedger extends Equatable {
  const CylinderLedger({
    required this.branchId,
    required this.brand,
    required this.sizeKg,
    required this.fullCount,
    required this.emptyCount,
  });

  final String branchId;
  final String brand;
  final double sizeKg;
  final int fullCount;
  final int emptyCount;

  CylinderLedger copyWith({
    String? branchId,
    String? brand,
    double? sizeKg,
    int? fullCount,
    int? emptyCount,
  }) {
    return CylinderLedger(
      branchId: branchId ?? this.branchId,
      brand: brand ?? this.brand,
      sizeKg: sizeKg ?? this.sizeKg,
      fullCount: fullCount ?? this.fullCount,
      emptyCount: emptyCount ?? this.emptyCount,
    );
  }

  @override
  List<Object?> get props => [branchId, brand, sizeKg, fullCount, emptyCount];
}
