import 'package:equatable/equatable.dart';

/// Summary statistics for a date range.
class ReportSummary extends Equatable {
  /// Creates a report summary.
  const ReportSummary({
    required this.totalSalesAmount,
    required this.transactionCount,
    required this.averageSale,
    required this.uniqueCustomerCount,
  });

  /// Total sales in KES minor units (cents).
  final int totalSalesAmount;

  /// Number of completed sales.
  final int transactionCount;

  /// Average sale amount in KES minor units.
  final int averageSale;

  /// Number of unique customers.
  final int uniqueCustomerCount;

  @override
  List<Object?> get props => [
        totalSalesAmount,
        transactionCount,
        averageSale,
        uniqueCustomerCount,
      ];
}

/// Branch performance summary.
class BranchSummary extends Equatable {
  /// Creates a branch summary.
  const BranchSummary({
    required this.branchId,
    required this.branchName,
    required this.totalSalesAmount,
    required this.transactionCount,
  });

  /// Branch identifier.
  final String branchId;

  /// Branch display name.
  final String branchName;

  /// Total sales in KES minor units.
  final int totalSalesAmount;

  /// Number of transactions.
  final int transactionCount;

  @override
  List<Object?> get props => [
        branchId,
        branchName,
        totalSalesAmount,
        transactionCount,
      ];
}
