import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/navigation/branch_selector.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/components/tables/app_data_table.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Inventory screen with stock management.
class InventoryScreen extends StatefulWidget {
  /// Creates the inventory screen.
  const InventoryScreen({super.key});

  /// Route path.
  static const String routePath = '/inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  var _selectedBranchId = 'main';

  static const _branches = [
    BranchOption(id: 'main', name: 'Main Branch'),
    BranchOption(id: 'west', name: 'Westlands'),
  ];

  static const _inventory = [
    _InventoryItem(
      id: '1',
      name: '13kg LPG Cylinder Refill',
      sku: 'LPG-13-R',
      stock: 45,
      minStock: 10,
      price: 3300,
    ),
    _InventoryItem(
      id: '2',
      name: '6kg LPG Cylinder Refill',
      sku: 'LPG-6-R',
      stock: 32,
      minStock: 15,
      price: 1800,
    ),
    _InventoryItem(
      id: '3',
      name: 'Burner Regulator Kit',
      sku: 'REG-BRK',
      stock: 8,
      minStock: 5,
      price: 1250,
    ),
    _InventoryItem(
      id: '4',
      name: 'Gas Hose 1.5m',
      sku: 'HOS-15',
      stock: 67,
      minStock: 20,
      price: 450,
    ),
    _InventoryItem(
      id: '5',
      name: '13kg Empty Cylinder',
      sku: 'CYL-13-E',
      stock: 12,
      minStock: 8,
      price: 5500,
    ),
    _InventoryItem(
      id: '6',
      name: '6kg Empty Cylinder',
      sku: 'CYL-6-E',
      stock: 0,
      minStock: 10,
      price: 3200,
    ),
    _InventoryItem(
      id: '7',
      name: 'Double Burner Stove',
      sku: 'STV-DB',
      stock: 15,
      minStock: 5,
      price: 4800,
    ),
    _InventoryItem(
      id: '8',
      name: 'Single Burner Stove',
      sku: 'STV-SB',
      stock: 23,
      minStock: 5,
      price: 2400,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final currency = NumberFormat.simpleCurrency(name: 'KES');

    return AppScaffold(
      title: 'Inventory',
      selectedIndex: 1,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      destinations: const [
        AppNavDestination(
          label: 'Sales',
          icon: Icons.point_of_sale_outlined,
          selectedIcon: Icons.point_of_sale,
        ),
        AppNavDestination(
          label: 'Inventory',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
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
      actions: [
        Padding(
          padding: spacing.compact,
          child: BranchSelector(
            branches: _branches,
            selectedBranchId: _selectedBranchId,
            onChanged: (id) => setState(() => _selectedBranchId = id ?? 'main'),
          ),
        ),
      ],
      body: _InventoryContent(
        searchController: _searchController,
        inventory: _inventory,
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

class _InventoryContent extends StatelessWidget {
  const _InventoryContent({
    required this.searchController,
    required this.inventory,
    required this.currency,
  });

  final TextEditingController searchController;
  final List<_InventoryItem> inventory;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final lowStockCount = inventory
        .where((item) => item.stock <= item.minStock)
        .length;
    final outOfStockCount = inventory.where((item) => item.stock == 0).length;

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
                value: '${inventory.length}',
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
            controller: searchController,
            hintText: 'Name or SKU',
          ),
          SizedBox(height: spacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _InventoryList(inventory: inventory, currency: currency);
              }
              return _InventoryTable(inventory: inventory, currency: currency);
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
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          SizedBox(width: spacing.sm),
          Text('$value $label', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.inventory, required this.currency});

  final List<_InventoryItem> inventory;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: inventory.map((item) {
        final status = item.stock == 0
            ? AppStatus.danger
            : item.stock <= item.minStock
            ? AppStatus.warning
            : AppStatus.success;

        return Card(
          margin: EdgeInsets.only(bottom: spacing.md),
          child: ListTile(
            title: Text(item.name),
            subtitle: Text('SKU: ${item.sku} - ${currency.format(item.price)}'),
            trailing: StatusBadge(
              label: item.stock > 0 ? '${item.stock} units' : 'Out of stock',
              status: status,
            ),
            onTap: () => _showItemDetails(context, item),
          ),
        );
      }).toList(),
    );
  }

  void _showItemDetails(BuildContext context, _InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailDialog(item: item, currency: currency),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.inventory, required this.currency});

  final List<_InventoryItem> inventory;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: const [
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('SKU')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Status')),
      ],
      rows: inventory.map((item) {
        final status = item.stock == 0
            ? AppStatus.danger
            : item.stock <= item.minStock
            ? AppStatus.warning
            : AppStatus.success;

        return DataRow(
          cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.sku)),
            DataCell(Text('${item.stock}')),
            DataCell(Text(currency.format(item.price))),
            DataCell(
              StatusBadge(
                label: item.stock > 0 ? 'In stock' : 'Out of stock',
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
  const _ItemDetailDialog({required this.item, required this.currency});

  final _InventoryItem item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AlertDialog(
      title: Text(item.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SKU: ${item.sku}'),
          SizedBox(height: spacing.sm),
          Text('Price: ${currency.format(item.price)}'),
          SizedBox(height: spacing.sm),
          Text('Current Stock: ${item.stock}'),
          SizedBox(height: spacing.sm),
          Text('Minimum Stock: ${item.minStock}'),
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

class _InventoryItem {
  const _InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    required this.minStock,
    required this.price,
  });

  final String id;
  final String name;
  final String sku;
  final int stock;
  final int minStock;
  final double price;
}
