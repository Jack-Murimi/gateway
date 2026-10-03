import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../branches/application/branch_providers.dart';
import '../../sales/application/sale_providers.dart';
import '../../sales/domain/sales_models.dart';
import '../domain/date_range_preset.dart';
import '../domain/report_models.dart';

part 'report_providers.g.dart';

/// Selected date range preset.
@riverpod
class DateRangePreset extends _$DateRangePreset {
  @override
  DateRangePresetEnum build() => DateRangePresetEnum.last7Days;

  void select(DateRangePresetEnum preset) => state = preset;
}

/// Computed start date for the selected preset.
@riverpod
DateTime? startDate(Ref ref) {
  final preset = ref.watch(dateRangePresetProvider);
  return preset.getStartDate();
}

/// Report summary for the selected date range and branch.
@riverpod
Future<ReportSummary> reportSummary(Ref ref) async {
  final sales = await ref.watch(salesListProvider.future);
  final currentBranch = ref.watch(currentBranchProvider);
  final startDate = ref.watch(startDateProvider);

  final branchSales = sales.where((s) => s.branchId == currentBranch.id);
  
  // Filter by date if startDate is set
  final filteredSales = startDate == null
      ? branchSales
      : branchSales.where((s) => s.createdAt.isAfter(startDate));

  // Only count completed and credit sales
  final completedSales = filteredSales.where(
    (s) => s.status == SaleStatus.completed || s.status == SaleStatus.credit,
  ).toList();

  final totalAmount = completedSales.fold<int>(
    0,
    (sum, s) => sum + s.total,
  );

  final uniqueCustomers = completedSales
      .map((s) => s.customerId)
      .where((id) => id != null)
      .toSet()
      .length;

  final avgSale = completedSales.isEmpty ? 0 : totalAmount ~/ completedSales.length;

  return ReportSummary(
    totalSalesAmount: totalAmount,
    transactionCount: completedSales.length,
    averageSale: avgSale,
    uniqueCustomerCount: uniqueCustomers,
  );
}

/// Branch comparison for the selected date range.
@riverpod
Future<List<BranchSummary>> branchComparison(Ref ref) async {
  final sales = await ref.watch(salesListProvider.future);
  final branches = ref.watch(branchesProvider);
  final startDate = ref.watch(startDateProvider);

  // Filter by date if startDate is set
  final filteredSales = startDate == null
      ? sales
      : sales.where((s) => s.createdAt.isAfter(startDate)).toList();

  final completedSales = filteredSales.where(
    (s) => s.status == SaleStatus.completed || s.status == SaleStatus.credit,
  );

  // Group by branch
  final branchSummaries = <String, BranchSummary>{};
  for (final branch in branches) {
    final branchSales = completedSales.where((s) => s.branchId == branch.id);
    final totalAmount = branchSales.fold<int>(0, (sum, s) => sum + s.total);

    branchSummaries[branch.id] = BranchSummary(
      branchId: branch.id,
      branchName: branch.name,
      totalSalesAmount: totalAmount,
      transactionCount: branchSales.length,
    );
  }

  // Sort by totalSalesAmount descending
  final sorted = branchSummaries.values.toList()
    ..sort((a, b) => b.totalSalesAmount.compareTo(a.totalSalesAmount));

  return sorted;
}


