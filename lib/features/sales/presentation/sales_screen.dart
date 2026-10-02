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
import 'widgets/return_cylinder_dialog.dart';
import 'widgets/payment_dialog.dart';

/// Complete Sales screen — single-column on all screen sizes.
/// Cart items appear inline below the search bar.
/// On large screens: keyboard shortcuts F1 (search), F2 (pay), F3 (clear),
/// and NumpadAdd / Equal (focus last item qty).
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  static const String routePath = '/sales';

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  // en_KE locale for Kenyan Shilling formatting.
  final _currency = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);
  final _scrollController = ScrollController();

  // Default branch is now 'jamhuri' (first in the list).
  var _selectedBranchId = 'jamhuri';
  var _receiptNumber = '';
  var _selectedDate = DateTime.now();
  var _selectedCustomer = Customer.walkIn;
  var _selectedLocation = Location.defaultLocation;
  final List<SaleLineItem> _lineItems = [];

  // Track the last removed item for undo.
  SaleLineItem? _lastRemoved;
  int? _lastRemovedIndex;

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
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Stock available for a given product (mock — current branch stock).
  int _availableStock(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    return product.stock;
  }

  /// Current qty in cart for a given product.
  int _qtyInCart(String productId) {
    final existing = _lineItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => SaleLineItem(product: _products.first, quantity: 0),
    );
    return existing.quantity;
  }

  void _addToCart(Product product, {int quantity = 1}) {
    final available = _availableStock(product.id);
    final inCart = _qtyInCart(product.id);
    final canAdd = available - inCart;

    if (canAdd <= 0) {
      _showStockMessage('No more stock available for ${product.name}');
      return;
    }

    final toAdd = quantity.clamp(1, canAdd);
    final wasNew = inCart == 0;

    setState(() {
      final existing = _lineItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existing >= 0) {
        _lineItems[existing] = _lineItems[existing].copyWith(
          quantity: _lineItems[existing].quantity + toAdd,
        );
      } else {
        _lineItems.add(SaleLineItem(product: product, quantity: toAdd));
      }
    });

    if (toAdd < quantity) {
      _showStockMessage(
        'Only $toAdd of ${product.name} added (stock limit reached)',
      );
    }

    _searchController.clear();
    _searchFocusNode.requestFocus();

    // Scroll to bottom only when a NEW line is added (not qty update).
    if (wasNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removeFromCart(int index) {
    if (index < 0 || index >= _lineItems.length) return;

    final removed = _lineItems[index];
    setState(() {
      _lastRemoved = removed;
      _lastRemovedIndex = index;
      _lineItems.removeAt(index);
    });

    // Show undo snackbar.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.product.name} removed'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _undoRemove,
        ),
      ),
    );
  }

  void _undoRemove() {
    if (_lastRemoved == null || _lastRemovedIndex == null) return;
    setState(() {
      final index = _lastRemovedIndex!.clamp(0, _lineItems.length);
      _lineItems.insert(index, _lastRemoved!);
      _lastRemoved = null;
      _lastRemovedIndex = null;
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _lineItems.length) return;

    final item = _lineItems[index];
    final available = _availableStock(item.product.id);
    final clamped = quantity.clamp(0, available);

    if (clamped < quantity) {
      _showStockMessage(
        'Only $available of ${item.product.name} in stock',
      );
    }

    setState(() {
      if (clamped <= 0) {
        _lineItems.removeAt(index);
      } else {
        _lineItems[index] = item.copyWith(quantity: clamped);
      }
    });
  }

  Future<void> _clearCart() async {
    if (_lineItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: Text('Remove all ${_lineItems.length} items from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _lineItems.clear();
        _receiptNumber = '';
        _selectedDate = DateTime.now();
        _selectedCustomer = Customer.walkIn;
        _lastRemoved = null;
        _lastRemovedIndex = null;
      });
    }
  }

  void _showStockMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int get _grandTotal => _lineItems.fold<int>(
    0,
    (sum, item) => sum + item.total,
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

    setState(() {
      _lineItems.clear();
      _receiptNumber = '';
      _selectedDate = DateTime.now();
      _selectedCustomer = Customer.walkIn;
      _lastRemoved = null;
      _lastRemovedIndex = null;
    });

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
                setState(() => _selectedBranchId = id ?? 'jamhuri'),
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
    final isLarge = sizeClass == WindowSizeClass.expanded ||
        sizeClass == WindowSizeClass.large;

    return _SingleColumnLayout(
      header: _buildHeader(),
      searchBar: _buildSearchBar(),
      lineItems: _lineItems,
      currency: _currency,
      grandTotal: _grandTotal,
      totalItems: _totalItems,
      scrollController: _scrollController,
      onRemoveFromCart: _removeFromCart,
      onUpdateQuantity: _updateQuantity,
      onClearCart: _clearCart,
      onSave: _lineItems.isNotEmpty ? _save : null,
      showFloatingBar: !isLarge,
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

// ---------------------------------------------------------------------------
// Single-column layout — used on ALL screen sizes.
// Cart items live inline (no right panel). Footer pinned to bottom.
// ---------------------------------------------------------------------------
class _SingleColumnLayout extends StatelessWidget {
  const _SingleColumnLayout({
    required this.header,
    required this.searchBar,
    required this.lineItems,
    required this.currency,
    required this.grandTotal,
    required this.totalItems,
    required this.scrollController,
    required this.onRemoveFromCart,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.onSave,
    required this.showFloatingBar,
  });

  final Widget header;
  final Widget searchBar;
  final List<SaleLineItem> lineItems;
  final NumberFormat currency;
  final int grandTotal;
  final int totalItems;
  final ScrollController scrollController;
  final ValueChanged<int> onRemoveFromCart;
  final void Function(int index, int quantity) onUpdateQuantity;
  final VoidCallback onClearCart;
  final VoidCallback? onSave;
  final bool showFloatingBar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // On large screens the footer is constrained + right-aligned.
    final isLarge = !showFloatingBar;
    final footerMaxWidth = isLarge ? 420.0 : double.infinity;

    return Column(
      children: [
        // Scrollable content: header + search + cart items
        Expanded(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header + search
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    header,
                    const Divider(height: 1),
                    searchBar,
                  ],
                ),
              ),

              // Inline cart items
              if (lineItems.isNotEmpty) ...[
                // Cart section header
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.lg,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      border: Border(
                        bottom: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'Cart',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Badge(
                          label: Text('$totalItems'),
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: onClearCart,
                          icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cart line items
                SliverList.builder(
                  itemCount: lineItems.length,
                  itemBuilder: (context, index) {
                    final item = lineItems[index];
                    return _InlineCartTile(
                      item: item,
                      currency: currency,
                      onRemove: () => onRemoveFromCart(index),
                      onIncrement: () => onUpdateQuantity(index, item.quantity + 1),
                      onDecrement: () => onUpdateQuantity(index, item.quantity - 1),
                      onQuantityEdited: (qty) => onUpdateQuantity(index, qty),
                    );
                  },
                ),
              ],
            ],
          ),
        ),

        // Pinned footer at the bottom
        if (lineItems.isNotEmpty)
          Align(
            alignment: isLarge ? Alignment.bottomRight : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: footerMaxWidth.isInfinite ? screenWidth : footerMaxWidth,
              ),
              child: _InlineCartFooter(
                grandTotal: grandTotal,
                totalItems: totalItems,
                currency: currency,
                onSave: onSave,
                elevated: isLarge,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inline cart tile — FocusNode is owned by the tile itself (no race).
// Qty commit fires once, only when field has focus.
// ---------------------------------------------------------------------------
class _InlineCartTile extends StatefulWidget {
  const _InlineCartTile({
    required this.item,
    required this.currency,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityEdited,
  });

  final SaleLineItem item;
  final NumberFormat currency;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuantityEdited;

  @override
  State<_InlineCartTile> createState() => _InlineCartTileState();
}

class _InlineCartTileState extends State<_InlineCartTile> {
  late final TextEditingController _qtyController;
  late final FocusNode _qtyFocusNode;
  var _hasCommitted = false;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.item.quantity}');
    _qtyFocusNode = FocusNode();
    _qtyFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_InlineCartTile old) {
    super.didUpdateWidget(old);
    if (old.item.quantity != widget.item.quantity) {
      final text = '${widget.item.quantity}';
      if (_qtyController.text != text) {
        _qtyController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
      _hasCommitted = false;
    }
  }

  @override
  void dispose() {
    _qtyFocusNode.removeListener(_onFocusChange);
    _qtyFocusNode.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_qtyFocusNode.hasFocus && !_hasCommitted) {
      _commitQty();
    }
  }

  void _commitQty() {
    if (_hasCommitted) return;
    _hasCommitted = true;

    final parsed = int.tryParse(_qtyController.text.trim());
    if (parsed != null && parsed > 0) {
      widget.onQuantityEdited(parsed);
    } else if (parsed != null && parsed <= 0) {
      widget.onRemove();
    } else {
      // Reset to current valid value.
      _qtyController.text = '${widget.item.quantity}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.item.product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove item?'),
            content: Text('Remove ${widget.item.product.name} from cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        return confirm == true;
      },
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: spacing.xl),
        color: colorScheme.errorContainer,
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.product.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    '${widget.currency.format(widget.item.product.price)} each',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.sm),

            // Quantity controls — stepper + editable input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(spacing.sm),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: widget.item.quantity <= 1
                        ? Icons.delete_outline
                        : Icons.remove,
                    onPressed: widget.onDecrement,
                    color: widget.item.quantity <= 1 ? colorScheme.error : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _qtyController,
                      focusNode: _qtyFocusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      onSubmitted: (_) {
                        _commitQty();
                        _qtyFocusNode.unfocus();
                      },
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onPressed: widget.onIncrement,
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.md),

            // Line total
            SizedBox(
              width: 80,
              child: Text(
                widget.currency.format(widget.item.total),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity stepper button.
class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Pinned cart footer — sits at the bottom of the screen.
/// On large screens: constrained width, elevated card style, right-aligned.
/// On compact: full-width bar flush to the bottom.
class _InlineCartFooter extends StatelessWidget {
  const _InlineCartFooter({
    required this.grandTotal,
    required this.totalItems,
    required this.currency,
    required this.onSave,
    this.elevated = false,
  });

  final int grandTotal;
  final int totalItems;
  final NumberFormat currency;
  final VoidCallback? onSave;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    final content = SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalItems item${totalItems == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  currency.format(grandTotal),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.payment, size: 20),
              label: Text('Pay ${currency.format(grandTotal)}'),
            ),
          ],
        ),
      ),
    );

    if (elevated) {
      return Material(
        elevation: 8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: colorScheme.surfaceContainerLow,
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Product search bar with inline autocomplete.
// ---------------------------------------------------------------------------
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
