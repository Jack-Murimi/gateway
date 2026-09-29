import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Sales history screen with transaction records.
class SalesHistoryScreen extends StatefulWidget {
  /// Creates the sales history screen.
  const SalesHistoryScreen({super.key});

  /// Route path.
  static const String routePath = '/sales-history';

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchController = TextEditingController();

  static const _transactions = [
    _Transaction(
      id: 'TXN001',
      date: '2024-01-15 14:32',
      customer: 'John Kamau',
      items: 3,
      total: 8500,
      status: _TxStatus.completed,
    ),
    _Transaction(
      id: 'TXN002',
      date: '2024-01-15 13:45',
      customer: 'Mary Wanjiku',
      items: 1,
      total: 3300,
      status: _TxStatus.completed,
    ),
    _Transaction(
      id: 'TXN003',
      date: '2024-01-15 12:20',
      customer: 'Walk-in',
      items: 2,
      total: 7250,
      status: _TxStatus.completed,
    ),
    _Transaction(
      id: 'TXN004',
      date: '2024-01-15 11:15',
      customer: 'Peter Ochieng',
      items: 4,
      total: 14200,
      status: _TxStatus.pending,
    ),
    _Transaction(
      id: 'TXN005',
      date: '2024-01-14 16:30',
      customer: 'Grace Muthoni',
      items: 2,
      total: 5600,
      status: _TxStatus.completed,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return AppScaffold(
      title: 'Sales History',
      selectedIndex: 0,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'History',
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
        ),
        AppNavDestination(
          label: 'Reports',
          icon: Icons.query_stats_outlined,
          selectedIcon: Icons.query_stats,
        ),
        AppNavDestination(
          label: 'Settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
        ),
      ],
      body: _SalesHistoryContent(
        searchController: _searchController,
        transactions: _transactions,
        currency: currency,
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/sales');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

class _SalesHistoryContent extends StatelessWidget {
  const _SalesHistoryContent({
    required this.searchController,
    required this.transactions,
    required this.currency,
  });

  final TextEditingController searchController;
  final List<_Transaction> transactions;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

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
            hintText: 'ID, customer, or date',
          ),
          SizedBox(height: spacing.lg),
          if (transactions.isEmpty)
            const EmptyView(
              title: 'No transactions',
              message: 'Sales history will appear here.',
            )
          else
            Column(
              children: transactions.map((tx) {
                return Card(
                  margin: EdgeInsets.only(bottom: spacing.md),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt)),
                    title: Text(tx.id),
                    subtitle: Text('${tx.date} • ${tx.customer}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currency.format(tx.total),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: spacing.xs),
                        _StatusChip(status: tx.status),
                      ],
                    ),
                    onTap: () => _showTransactionDetails(context, tx, currency),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    _Transaction tx,
    NumberFormat currency,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _TransactionDetailDialog(tx: tx, currency: currency),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _TxStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, appStatus) = switch (status) {
      _TxStatus.completed => ('Completed', AppStatus.success),
      _TxStatus.pending => ('Pending', AppStatus.warning),
      _TxStatus.cancelled => ('Cancelled', AppStatus.danger),
    };

    return StatusBadge(label: label, status: appStatus);
  }
}

class _TransactionDetailDialog extends StatelessWidget {
  const _TransactionDetailDialog({required this.tx, required this.currency});

  final _Transaction tx;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(tx.id),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${tx.date}'),
          SizedBox(height: spacing.sm),
          Text('Customer: ${tx.customer}'),
          SizedBox(height: spacing.sm),
          Text('Items: ${tx.items}'),
          SizedBox(height: spacing.sm),
          Text('Total: ${currency.format(tx.total)}'),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

enum _TxStatus { completed, pending, cancelled }

class _Transaction {
  const _Transaction({
    required this.id,
    required this.date,
    required this.customer,
    required this.items,
    required this.total,
    required this.status,
  });

  final String id;
  final String date;
  final String customer;
  final int items;
  final double total;
  final _TxStatus status;
}
