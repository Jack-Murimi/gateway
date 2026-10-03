import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/people/party_tiles.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../application/supplier_providers.dart';
import '../domain/supplier.dart';

/// Suppliers screen with search and details.
class SuppliersScreen extends ConsumerStatefulWidget {
  /// Creates the suppliers screen.
  const SuppliersScreen({super.key});

  /// Route path.
  static const String routePath = '/suppliers';

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierListProvider);
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return suppliersAsync.when(
      data: (suppliers) {
        final filtered = _searchQuery.isEmpty
            ? suppliers
            : suppliers.where((s) {
                return s.name.toLowerCase().contains(_searchQuery) ||
                    s.phone.contains(_searchQuery) ||
                    s.id.toLowerCase().contains(_searchQuery);
              }).toList();

        return _SuppliersContent(
          searchController: _searchController,
          suppliers: filtered,
          currency: currency,
        );
      },
      loading: () => const LoadingView(),
      error: (err, stack) => ErrorView(
        title: 'Failed to load suppliers',
        message: err.toString(),
        onRetry: () => ref.invalidate(supplierListProvider),
      ),
    );
  }
}

class _SuppliersContent extends StatelessWidget {
  const _SuppliersContent({
    required this.searchController,
    required this.suppliers,
    required this.currency,
  });

  final TextEditingController searchController;
  final List<Supplier> suppliers;
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
            title: 'Supplier Directory',
            subtitle: 'Manage supplier accounts and orders.',
          ),
          SizedBox(height: spacing.lg),
          AppSearchField(
            label: 'Search suppliers',
            controller: searchController,
            hintText: 'Name, phone, or ID',
          ),
          SizedBox(height: spacing.lg),
          if (suppliers.isEmpty)
            const EmptyView(
              title: 'No suppliers found',
              message: 'Try a different search term.',
            )
          else
            Column(
              children: suppliers.map((supplier) {
                return SupplierTile(
                  name: supplier.name,
                  subtitle: supplier.phone,
                  trailing: _BalanceChip(
                    balance: supplier.balance,
                    currency: currency,
                  ),
                  onTap: () =>
                      _showSupplierDetails(context, supplier, currency),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showSupplierDetails(
    BuildContext context,
    Supplier supplier,
    NumberFormat currency,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _SupplierDetailDialog(supplier: supplier, currency: currency),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.balance, required this.currency});

  final int balance;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final status = balance < 0
        ? AppStatus.danger
        : balance > 0
            ? AppStatus.success
            : AppStatus.neutral;

    final amountKes = balance.abs() / 100.0;
    return StatusBadge(label: currency.format(amountKes), status: status);
  }
}

class _SupplierDetailDialog extends StatelessWidget {
  const _SupplierDetailDialog({required this.supplier, required this.currency});

  final Supplier supplier;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final balanceKes = supplier.balance / 100.0;
    final balanceText = supplier.balance < 0
        ? 'We owe: ${currency.format(balanceKes.abs())}'
        : supplier.balance > 0
            ? 'They owe: ${currency.format(balanceKes)}'
            : 'Settled';

    return AppDialog(
      title: Text(supplier.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: ${supplier.phone}'),
          if (supplier.email != null) ...[
            SizedBox(height: spacing.sm),
            Text('Email: ${supplier.email}'),
          ],
          SizedBox(height: spacing.sm),
          Text('Balance: $balanceText'),
          if (supplier.lastOrderDate != null) ...[
            SizedBox(height: spacing.sm),
            Text('Last Order: ${supplier.lastOrderDate}'),
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
            label: 'New Order',
            onPressed: () {
              Navigator.of(context).pop();
              // ponytail: New order dialog (SLICE 8+)
            },
          ),
        ),
      ],
    );
  }
}
