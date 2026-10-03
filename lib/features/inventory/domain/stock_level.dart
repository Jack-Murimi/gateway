import 'package:equatable/equatable.dart';

/// Per-branch stock level.
class StockLevel extends Equatable {
  const StockLevel({
    required this.branchId,
    required this.productId,
    required this.quantity,
  });

  final String branchId;
  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [branchId, productId, quantity];
}
