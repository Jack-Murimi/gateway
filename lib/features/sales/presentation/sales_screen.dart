import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/tokens/breakpoints.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/navigation/branch_selector.dart';

import '../../sales/domain/sales_models.dart';
import 'widgets/sales_header.dart';
import 'widgets/cart_panel.dart';
import 'widgets/return_cylinder_dialog.dart';
import 'widgets/payment_dialog.dart';

/// Complete Sales screen with adaptive two-pane layout on tablet.
class SalesScreen extends StatefulWidget {
  /// Creates the Sales screen.
  const SalesScreen({super.key});

  /// Route path.
  static const String routePath = '/sales';

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _currency = NumberFormat.simpleCurrency(name: 'KES');

  var _selectedBranchId = 'main';
  var _receiptNumber = 'REC-2024-001';
  var _selectedDate = DateTime.now();
  var _selectedCustomer = Customer.walkIn;
  var _selectedLocation = Location.defaultLocation;
  final List<SaleLineItem> _lineItems = [];

  final _branches = const [
    BranchOption(id: 'jamhuri', name: 'Jamhuri', color: Color(0xFF2E7D32)),
    BranchOption(id: 'lavington', name: 'Lavington', color: Color(0xFF1565C0)),
    BranchOption(id: 'kileleshwa', name: 'Kileleshwa', color: Color(0xFF7B1FA2)),
    BranchOption(id: 'nextgen', name: 'Nextgen', color: Color(0xFFE65100)),
  ];

  final _customers = const [
    Customer(
      id: 'walk-in',
      name: 'Walk-in Customer',
      phone: '',
      isWalkIn: true,
    ),
    Customer(id: '1', name: 'John Doe', phone: '0712345678', isWalkIn: false),
    Customer(id: '2', name: 'Jane Smith', phone: '0723456789', isWalkIn: false),
    Customer(
      id: '3',
      name: 'ABC Restaurant',
      phone: '0734567890',
      isWalkIn: false,
    ),
  ];

  final _products = const [
    // Afrigas - 6kg & 13kg
    Product(id: 'afrigas-13kg-refill', name: '13kg Afrigas Refill', price: 3300, stock: 45, cylinderType: '13kg'),
    Product(id: 'afrigas-6kg-refill', name: '6kg Afrigas Refill', price: 1800, stock: 32, cylinderType: '6kg'),
    Product(id: 'afrigas-13kg-empty', name: '13kg Afrigas Empty Cylinder', price: 5500, stock: 12, cylinderType: '13kg'),
    Product(id: 'afrigas-6kg-empty', name: '6kg Afrigas Empty Cylinder', price: 3200, stock: 8, cylinderType: '6kg'),
    // Progas - 6kg & 13kg
    Product(id: 'progas-13kg-refill', name: '13kg Progas Refill', price: 3200, stock: 38, cylinderType: '13kg'),
    Product(id: 'progas-6kg-refill', name: '6kg Progas Refill', price: 1750, stock: 28, cylinderType: '6kg'),
    Product(id: 'progas-13kg-empty', name: '13kg Progas Empty Cylinder', price: 5300, stock: 10, cylinderType: '13kg'),
    Product(id: 'progas-6kg-empty', name: '6kg Progas Empty Cylinder', price: 3100, stock: 6, cylinderType: '6kg'),
    // K-gas - 6kg & 13kg
    Product(id: 'kgas-13kg-refill', name: '13kg K-gas Refill', price: 3400, stock: 52, cylinderType: '13kg'),
    Product(id: 'kgas-6kg-refill', name: '6kg K-gas Refill', price: 1850, stock: 35, cylinderType: '6kg'),
    Product(id: 'kgas-13kg-empty', name: '13kg K-gas Empty Cylinder', price: 5600, stock: 15, cylinderType: '13kg'),
    Product(id: 'kgas-6kg-empty', name: '6kg K-gas Empty Cylinder', price: 3300, stock: 9, cylinderType: '6kg'),
    // Totalgaz - 6kg & 13kg
    Product(id: 'totalgaz-13kg-refill', name: '13kg Totalgaz Refill', price: 3350, stock: 40, cylinderType: '13kg'),
    Product(id: 'totalgaz-6kg-refill', name: '6kg Totalgaz Refill', price: 1820, stock: 30, cylinderType: '6kg'),
    Product(id: 'totalgaz-13kg-empty', name: '13kg Totalgaz Empty Cylinder', price: 5450, stock: 11, cylinderType: '13kg'),
    Product(id: 'totalgaz-6kg-empty', name: '6kg Totalgaz Empty Cylinder', price: 3250, stock: 7, cylinderType: '6kg'),
    // Accessories
    Product(id: 'burner-kit', name: 'Burner Regulator Kit', price: 1250, stock: 8, cylinderType: null),
    Product(id: 'hose-1.5m', name: 'Gas Hose 1.5m', price: 450, stock: 67, cylinderType: null),
    Product(id: 'double-stove', name: 'Double Burner Stove', price: 4800, stock: 15, cylinderType: null),
    Product(id: 'single-stove', name: 'Single Burner Stove', price: 2400, stock: 23, cylinderType: null),
  ];

  @override
  void initState() {
    super.initState();
    _generateReceiptNumber();
    _selectedDate = DateTime.now();
  }

  void _generateReceiptNumber() {
    final now = DateTime.now();
    _receiptNumber = 'REC-${now.year}-${now.millisecondsSinceEpoch % 10000}'
        .padRight(14, '0');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addToCart(Product product, {int quantity = 1}) {
    setState(() {
      final existing = _lineItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existing >= 0) {
        _lineItems[existing] = _lineItems[existing].copyWith(
          quantity: _lineItems[existing].quantity + quantity,
        );
      } else {
        _lineItems.add(SaleLineItem(product: product, quantity: quantity));
      }
    });
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _removeFromCart(int index) {
    setState(() => _lineItems.removeAt(index));
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _lineItems.removeAt(index);
      } else {
        _lineItems[index] = _lineItems[index].copyWith(quantity: quantity);
      }
    });
  }

  void _clearCart() {
    setState(() {
      _lineItems.clear();
      _generateReceiptNumber();
      _selectedDate = DateTime.now();
      _selectedCustomer = Customer.walkIn;
    });
  }

  double get _grandTotal => _lineItems.fold<double>(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  int get _totalItems => _lineItems.fold<int>(
    0,
    (sum, item) => sum + item.quantity,
  );

  Future<void> _save() async {
    final result = await showReturnCylinderDialog(
      context,
      lineItems: _lineItems,
      currency: _currency,
    );

    if (result == null || !mounted) return;

    final paymentResult = await showPaymentDialog(
      context,
      grandTotal: _grandTotal,
      currency: _currency,
      customer: _selectedCustomer,
    );

    if (paymentResult == null || !mounted) return;

    _clearCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sale completed successfully'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'View', onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show keyboard shortcuts on desktop platforms
    final isDesktop = !_isMobilePlatform;

    Widget child = AppScaffold(
      title: 'Sales',
      selectedIndex: 0,
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
          padding: const EdgeInsets.all(12),
          child: BranchSelector(
            branches: _branches,
            selectedBranchId: _selectedBranchId,
            onChanged: (id) =>
                setState(() => _selectedBranchId = id ?? 'main'),
          ),
        ),
      ],
      body: _buildBody(context),
    );

    if (isDesktop) {
      child = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f1): () =>
              _searchFocusNode.requestFocus(),
          const SingleActivator(LogicalKeyboardKey.f2): () {
            if (_lineItems.isNotEmpty) _save();
          },
          const SingleActivator(LogicalKeyboardKey.f3): _clearCart,
        },
        child: Focus(autofocus: true, child: child),
      );
    }

    return child;
  }

  bool get _isMobilePlatform {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS;
  }

  Widget _buildBody(BuildContext context) {
    final sizeClass = context.windowSizeClass;
    // ponytail: use_two_pane threshold — upgrade to LayoutBuilder if
    // navigation rail width starts varying.
    final useTwoPane = sizeClass == WindowSizeClass.expanded ||
        sizeClass == WindowSizeClass.large;

    if (useTwoPane) {
      return _TwoPaneLayout(
        header: _buildHeader(),
        searchBar: _buildSearchBar(),
        cart: _buildCart(showHeader: false),
      );
    }

    // Compact / medium: single column with floating cart badge
    return _SinglePaneLayout(
      header: _buildHeader(),
      searchBar: _buildSearchBar(),
      cart: _buildCart(showHeader: true),
      lineItems: _lineItems,
      grandTotal: _grandTotal,
      totalItems: _totalItems,
      currency: _currency,
      onSave: _lineItems.isNotEmpty ? _save : null,
    );
  }

  Widget _buildHeader() {
    return SalesHeader(
      date: _selectedDate,
      onDateChanged: (date) => setState(() => _selectedDate = date),
      receiptNumber: _receiptNumber,
      onReceiptNumberChanged: (value) => setState(() => _receiptNumber = value),
      selectedCustomer: _selectedCustomer,
      selectedLocation: _selectedLocation,
      onCustomerChanged: (customer) => setState(() {
        _selectedCustomer = customer;
        _selectedLocation = Location.defaultLocation;
      }),
      onLocationChanged: (location) =>
          setState(() => _selectedLocation = location),
      customers: _customers,
    );
  }

  Widget _buildSearchBar() {
    final isMobile = _isMobilePlatform;

    return _ProductSearchBar(
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      products: _products,
      currency: _currency,
      onAddToCart: _addToCart,
      showShortcutHint: !isMobile,
    );
  }

  Widget _buildCart({required bool showHeader}) {
    return CartPanel(
      lineItems: _lineItems,
      currency: _currency,
      grandTotal: _grandTotal,
      totalItems: _totalItems,
      onRemoveFromCart: _removeFromCart,
      onUpdateQuantity: _updateQuantity,
      onClearCart: _clearCart,
      onSave: _lineItems.isNotEmpty ? _save : null,
      showHeader: showHeader,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/inventory');
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

/// Two-pane layout for expanded/large screens.
/// Left: header + search + cart items. Right: cart summary.
class _TwoPaneLayout extends StatelessWidget {
  const _TwoPaneLayout({
    required this.header,
    required this.searchBar,
    required this.cart,
  });

  final Widget header;
  final Widget searchBar;
  final Widget cart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left pane: header + search
        Expanded(
          flex: 3,
          child: Column(
            children: [
              header,
              const Divider(height: 1),
              searchBar,
            ],
          ),
        ),
        VerticalDivider(
          width: 1,
          color: colorScheme.outlineVariant,
        ),
        // Right pane: cart
        Expanded(
          flex: 2,
          child: cart,
        ),
      ],
    );
  }
}

/// Single-column layout for compact/medium screens.
/// Cart accessed via bottom sheet triggered by floating action bar.
class _SinglePaneLayout extends StatelessWidget {
  const _SinglePaneLayout({
    required this.header,
    required this.searchBar,
    required this.cart,
    required this.lineItems,
    required this.grandTotal,
    required this.totalItems,
    required this.currency,
    required this.onSave,
  });

  final Widget header;
  final Widget searchBar;
  final Widget cart;
  final List<SaleLineItem> lineItems;
  final double grandTotal;
  final int totalItems;
  final NumberFormat currency;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Stack(
      children: [
        Column(
          children: [
            header,
            const Divider(height: 1),
            searchBar,
          ],
        ),
        // Floating cart bar at bottom
        if (lineItems.isNotEmpty)
          Positioned(
            left: spacing.lg,
            right: spacing.lg,
            bottom: spacing.lg,
            child: _FloatingCartBar(
              totalItems: totalItems,
              grandTotal: grandTotal,
              currency: currency,
              onTap: () => _showCartSheet(context),
              onSave: onSave,
            ),
          ),
      ],
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => cart,
      ),
    );
  }
}

/// Floating bottom bar showing cart summary on phone.
class _FloatingCartBar extends StatelessWidget {
  const _FloatingCartBar({
    required this.totalItems,
    required this.grandTotal,
    required this.currency,
    required this.onTap,
    required this.onSave,
  });

  final int totalItems;
  final double grandTotal;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(spacing.lg),
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spacing.lg),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          child: Row(
            children: [
              Badge(
                label: Text('$totalItems'),
                child: Icon(
                  Icons.shopping_cart,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Text(
                  currency.format(grandTotal),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Pay'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.lg,
                    vertical: spacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search bar with inline autocomplete for adding products.
class _ProductSearchBar extends StatefulWidget {
  const _ProductSearchBar({
    required this.searchController,
    required this.searchFocusNode,
    required this.products,
    required this.currency,
    required this.onAddToCart,
    this.showShortcutHint = true,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final List<Product> products;
  final NumberFormat currency;
  final void Function(Product product, {int quantity}) onAddToCart;
  final bool showShortcutHint;

  @override
  State<_ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<_ProductSearchBar> {
  List<Product> _searchResults = [];
  var _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.products
            .where(
              (p) => p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.searchController,
            focusNode: widget.searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: widget.showShortcutHint
                  ? 'Search products (F1)'
                  : 'Search products',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.md,
              ),
            ),
          ),
          if (_searchResults.isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(spacing.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    final isOutOfStock = product.stock <= 0;

                    return ListTile(
                      dense: true,
                      onTap: isOutOfStock
                          ? null
                          : () {
                              widget.onAddToCart(product);
                              widget.searchController.clear();
                              _onSearchChanged('');
                            },
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: product.cylinderType != null
                            ? colorScheme.tertiaryContainer
                            : colorScheme.secondaryContainer,
                        child: Icon(
                          product.cylinderType != null
                              ? Icons.propane_tank_outlined
                              : Icons.inventory_2_outlined,
                          size: 16,
                          color: product.cylinderType != null
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onSecondaryContainer,
                        ),
                      ),
                      title: Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isOutOfStock
                              ? colorScheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        widget.currency.format(product.price),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      trailing: isOutOfStock
                          ? Text(
                              'Out of stock',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colorScheme.error),
                            )
                          : Text(
                              '${product.stock} in stock',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
