import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money.dart';
import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/components/tables/app_data_table.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../../../design_system/tokens/sizes.dart';
import '../../branches/application/branch_providers.dart';
import '../application/inventory_providers.dart';

/// Inventory screen with stock management.
class InventoryScreen extends ConsumerStatefulWidget {
  /// Creates the inventory screen.
  const InventoryScreen({super.key});

  /// Route path.
  static const String routePath = '/inventory';

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(branchInventoryProvider(ref.watch(currentBranchProvider).id));

    return inventoryAsync.when(
      data: (inventory) => _InventoryContent(
        searchController: _searchController,
        inventory: inventory,
      ),
      loading: () => const LoadingView(),
      error: (err, stack) => ErrorView(title: 'Error loading inventory', message: err.toString()),
    );
  }
}

class _InventoryContent extends StatefulWidget {
  const _InventoryContent({
    required this.searchController,
    required this.inventory,
  });

  final TextEditingController searchController;
  final List<ProductWithStock> inventory;

  @override
  State<_InventoryContent> createState() => _InventoryContentState();
}

class _InventoryContentState extends State<_InventoryContent> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = widget.searchController.text.trim().toLowerCase();
    });
  }

  List<ProductWithStock> get _filteredInventory {
    if (_searchQuery.isEmpty) return widget.inventory;
    return widget.inventory.where((item) {
      final name = item.product.name.toLowerCase();
      final brand = item.product.brand?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || brand.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final filteredInventory = _filteredInventory;
    final lowStockCount = filteredInventory.where((item) => item.quantity <= 10).length; // ponytail: hardcoded minStock=10
    final outOfStockCount = filteredInventory.where((item) => item.quantity == 0).length;

    return SingleChildScrollView(
      padding: spacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Stock Overview',
            subtitle: 'Manage inventory levels and transfers.',
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.lg,
            children: [
              _StatChip(
                label: 'Total Items',
                value: '${filteredInventory.length}',
                icon: Icons.inventory_2,
              ),
              _StatChip(
                label: 'Low Stock',
                value: '$lowStockCount',
                icon: Icons.warning_amber,
                status: lowStockCount > 0
                    ? AppStatus.warning
                    : AppStatus.success,
              ),
              _StatChip(
                label: 'Out of Stock',
                value: '$outOfStockCount',
                icon: Icons.error_outline,
                status: outOfStockCount > 0
                    ? AppStatus.danger
                    : AppStatus.success,
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          AppSearchField(
            label: 'Search inventory',
            controller: widget.searchController,
            hintText: 'Name or brand',
          ),
          SizedBox(height: spacing.lg),
          if (filteredInventory.isEmpty)
            const EmptyView(
              title: 'No products found',
              message: 'Try a different search term',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _InventoryList(inventory: filteredInventory);
                }
                return _InventoryTable(inventory: filteredInventory);
              },
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.status = AppStatus.neutral,
  });

  final String label;
  final String value;
  final IconData icon;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: spacing.chip,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: context.radii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconLg, color: colorScheme.onSurfaceVariant),
          SizedBox(width: spacing.sm),
          Text('$value $label', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.inventory});

  final List<ProductWithStock> inventory;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: inventory.map((item) {
        final status = item.quantity == 0
            ? AppStatus.danger
            : item.quantity <= 10 // ponytail: hardcoded minStock
            ? AppStatus.warning
            : AppStatus.success;

        return Card(
          margin: EdgeInsets.only(bottom: spacing.md),
          child: ListTile(
            title: Text(item.product.name),
            subtitle: Text(formatKes(item.product.price)),
            trailing: StatusBadge(
              label: item.quantity > 0 ? '${item.quantity} units' : 'Out of stock',
              status: status,
            ),
            onTap: () => _showItemDetails(context, item),
          ),
        );
      }).toList(),
    );
  }

  void _showItemDetails(BuildContext context, ProductWithStock item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailDialog(item: item),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.inventory});

  final List<ProductWithStock> inventory;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: const [
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Status')),
      ],
      rows: inventory.map((item) {
        final status = item.quantity == 0
            ? AppStatus.danger
            : item.quantity <= 10 // ponytail: hardcoded minStock
            ? AppStatus.warning
            : AppStatus.success;

        return DataRow(
          cells: [
            DataCell(Text(item.product.name)),
            DataCell(Text('${item.quantity}')),
            DataCell(Text(formatKes(item.product.price))),
            DataCell(
              StatusBadge(
                label: item.quantity > 0 ? 'In stock' : 'Out of stock',
                status: status,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _ItemDetailDialog extends StatelessWidget {
  const _ItemDetailDialog({required this.item});

  final ProductWithStock item;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AppDialog(
      title: Text(item.product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: ${formatKes(item.product.price)}'),
          SizedBox(height: spacing.sm),
          Text('Current Stock: ${item.quantity}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Expanded(
          child: AppButton(
            label: 'Adjust Stock',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock adjustment coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }
}
