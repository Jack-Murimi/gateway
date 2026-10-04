import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/money.dart';
import '../../../app/providers/receipt_providers.dart';
import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../../branches/application/branch_providers.dart';
import '../../customers/application/customer_providers.dart';
import '../../sales/domain/sales_models.dart';
import '../../sales/application/sale_providers.dart';

/// Sales history screen with transaction records.
class SalesHistoryScreen extends ConsumerStatefulWidget {
  /// Creates the sales history screen.
  const SalesHistoryScreen({super.key});

  /// Route path.
  static const String routePath = '/sales-history';

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  final _selectedBranchId = 'jamhuri'; // ponytail: use currentBranchProvider
  var _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(branchSalesProvider(_selectedBranchId));

    return salesAsync.when(
      data: (sales) {
        final filtered = _searchQuery.isEmpty
            ? sales
            : sales.where((s) {
                final query = _searchQuery.toLowerCase();
                return s.receiptNumber.toLowerCase().contains(query) ||
                       s.customerId.toLowerCase().contains(query) ||
                       s.id.toLowerCase().contains(query);
              }).toList();

        return _SalesHistoryContent(
          searchController: _searchController,
          sales: filtered,
          onSearchChanged: (q) => setState(() => _searchQuery = q),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        title: 'Failed to load sales',
        message: e.toString(),
      ),
    );
  }
}

class _SalesHistoryContent extends StatelessWidget {
  const _SalesHistoryContent({
    required this.searchController,
    required this.sales,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final List<Sale> sales;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Transaction History',
            subtitle: 'View past sales and receipts.',
          ),
          SizedBox(height: spacing.lg),
          AppSearchField(
            label: 'Search transactions',
            controller: searchController,
            hintText: 'Receipt, customer, or ID',
            onChanged: onSearchChanged,
          ),
          SizedBox(height: spacing.lg),
          if (sales.isEmpty)
            const EmptyView(
              title: 'No transactions',
              message: 'Sales history will appear here.',
            )
          else
            Column(
              children: sales.map((sale) {
                final total = sale.lines.fold<int>(0, (sum, l) => sum + l.total);
                
                return Card(
                  margin: EdgeInsets.only(bottom: spacing.md),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt)),
                    title: Text(sale.receiptNumber),
                    subtitle: Text('${dateFormat.format(sale.date)} • ${sale.customerId}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatKes(total),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: spacing.xs),
                        _StatusChip(status: sale.status),
                      ],
                    ),
                    onTap: () => _showSaleDetails(context, sale),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showSaleDetails(
    BuildContext context,
    Sale sale,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _SaleDetailDialog(sale: sale),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, appStatus) = switch (status) {
      SaleStatus.completed => ('Completed', AppStatus.success),
      SaleStatus.credit => ('Credit', AppStatus.warning),
      SaleStatus.voided => ('Voided', AppStatus.danger),
      SaleStatus.cancelled => ('Cancelled', AppStatus.danger),
      SaleStatus.draft => ('Draft', AppStatus.info),
    };

    return StatusBadge(label: label, status: appStatus);
  }
}

class _SaleDetailDialog extends ConsumerWidget {
  const _SaleDetailDialog({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.spacing;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final total = sale.lines.fold<int>(0, (sum, l) => sum + l.total);

    return AppDialog(
      title: Text(sale.receiptNumber),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${dateFormat.format(sale.date)}'),
          SizedBox(height: spacing.sm),
          Text('Customer: ${sale.customerId}'),
          SizedBox(height: spacing.sm),
          Text('Branch: ${sale.branchId}'),
          SizedBox(height: spacing.sm),
          Text('Items: ${sale.lines.length}'),
          SizedBox(height: spacing.sm),
          Text('Total: ${formatKes(total)}'),
          SizedBox(height: spacing.sm),
          Text('Status: ${sale.status.name}'),
          if (sale.voidReason != null) ...[
            SizedBox(height: spacing.sm),
            Text('Void Reason: ${sale.voidReason}', 
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'Print Receipt',
            onPressed: () async {
              final receiptService = ref.read(receiptServiceProvider);
              final branches = ref.read(branchesProvider);
              final customers = await ref.read(customersProvider.future);
              
              final branch = branches.firstWhere(
                (b) => b.id == sale.branchId,
                orElse: () => branches.first,
              );
              final customer = customers.firstWhere(
                (c) => c.id == sale.customerId,
                orElse: () => customers.first,
              );
              
              await receiptService.shareReceipt(
                sale,
                branchName: branch.name,
                customerName: customer.name,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt copied to clipboard')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
