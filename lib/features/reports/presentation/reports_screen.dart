import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/cards/stat_card.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../application/report_providers.dart';
import '../domain/date_range_preset.dart';
import '../domain/report_models.dart';

/// Reports dashboard with KPIs and charts.
class ReportsScreen extends ConsumerWidget {
  /// Creates the reports screen.
  const ReportsScreen({super.key});

  /// Route path.
  static const String routePath = '/reports';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.simpleCurrency(name: 'KES');
    final summaryAsync = ref.watch(reportSummaryProvider);
    final branchComparisonAsync = ref.watch(branchComparisonProvider);
    final preset = ref.watch(dateRangePresetProvider);

    return summaryAsync.when(
      data: (summary) {
        return branchComparisonAsync.when(
          data: (branchComparison) {
            return _ReportsContent(
              currency: currency,
              summary: summary,
              branchComparison: branchComparison,
              selectedPreset: preset,
              onPresetChanged: (newPreset) {
                ref.read(dateRangePresetProvider.notifier).select(newPreset);
              },
            );
          },
          loading: () => const LoadingView(),
          error: (err, stack) => ErrorView(
            title: 'Failed to load branch comparison',
            message: err.toString(),
            onRetry: () => ref.invalidate(branchComparisonProvider),
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (err, stack) => ErrorView(
        title: 'Failed to load report',
        message: err.toString(),
        onRetry: () => ref.invalidate(reportSummaryProvider),
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({
    required this.currency,
    required this.summary,
    required this.branchComparison,
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  final NumberFormat currency;
  final ReportSummary summary;
  final List<BranchSummary> branchComparison;
  final DateRangePresetEnum selectedPreset;
  final ValueChanged<DateRangePresetEnum> onPresetChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Dashboard',
            subtitle: 'Business performance overview.',
          ),
          SizedBox(height: spacing.lg),
          PopupMenuButton<DateRangePresetEnum>(
            initialValue: selectedPreset,
            onSelected: onPresetChanged,
            itemBuilder: (context) => DateRangePresetEnum.values.map((preset) {
              return PopupMenuItem(
                value: preset,
                child: Text(preset.label),
              );
            }).toList(),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Filter by date range',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Text(selectedPreset.label),
            ),
          ),
          SizedBox(height: spacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final cardWidth = isWide
                  ? (constraints.maxWidth - spacing.lg * 3) / 4
                  : constraints.maxWidth;

              final totalKes = summary.totalSalesAmount / 100.0;
              final avgKes = summary.averageSale / 100.0;

              return Wrap(
                spacing: spacing.lg,
                runSpacing: spacing.lg,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Total Sales',
                      value: currency.format(totalKes),
                      icon: Icons.trending_up,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Transactions',
                      value: '${summary.transactionCount}',
                      icon: Icons.receipt_long,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Avg. Sale',
                      value: currency.format(avgKes),
                      icon: Icons.analytics,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: 'Customers',
                      value: '${summary.uniqueCustomerCount}',
                      icon: Icons.people,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: spacing.xl),
          const SectionHeader(
            title: 'Branch Comparison',
            subtitle: 'Performance across locations.',
          ),
          SizedBox(height: spacing.lg),
          if (branchComparison.isEmpty)
            const EmptyView(
              title: 'No data',
              message: 'No sales in this period.',
            )
          else
            _BranchComparison(
              currency: currency,
              branches: branchComparison,
            ),
        ],
      ),
    );
  }
}

class _BranchComparison extends StatelessWidget {
  const _BranchComparison({
    required this.currency,
    required this.branches,
  });

  final NumberFormat currency;
  final List<BranchSummary> branches;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    
    // Calculate total for percentage
    final grandTotal = branches.fold<int>(
      0,
      (sum, b) => sum + b.totalSalesAmount,
    );

    return Column(
      children: branches.map((branch) {
        final totalKes = branch.totalSalesAmount / 100.0;
        final percent = grandTotal > 0 
            ? branch.totalSalesAmount / grandTotal 
            : 0.0;

        return Card(
          margin: EdgeInsets.only(bottom: spacing.md),
          child: Padding(
            padding: spacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      branch.branchName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      currency.format(totalKes),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '${branch.transactionCount} transactions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: spacing.sm),
                LinearProgressIndicator(value: percent, minHeight: 8),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

