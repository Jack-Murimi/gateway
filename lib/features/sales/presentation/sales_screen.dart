import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/money.dart';
import '../../../design_system/tokens/breakpoints.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';

import '../../sales/domain/sales_models.dart';
import '../../sales/domain/returned_cylinder.dart';
import '../../sales/application/cart_provider.dart';
import '../../sales/application/sale_providers.dart';
import '../../inventory/application/inventory_providers.dart';
import '../../inventory/domain/product.dart';
import '../../customers/application/customer_providers.dart';
import '../../customers/domain/customer.dart';
import 'widgets/sales_header.dart';
import 'widgets/return_cylinder_dialog.dart';
import 'widgets/payment_dialog.dart';
import 'widgets/product_search_bar.dart';
import 'widgets/single_column_layout.dart';

/// Complete Sales screen — single-column on all screen sizes.
/// Cart items appear inline below the search bar.
/// On large screens: keyboard shortcuts F1 (search), F2 (pay), F3 (clear),
/// and NumpadAdd / Equal (focus last item qty).
class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  static const String routePath = '/sales';

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _currency = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);
  final _scrollController = ScrollController();
  final _uuid = const Uuid();

  // UI state
  final _selectedBranchId = 'jamhuri'; // ponytail: use currentBranchProvider
  var _receiptNumber = '';
  var _selectedDate = DateTime.now();
  Customer _selectedCustomer = Customer.walkIn;
  CustomerLocation _selectedLocation = const CustomerLocation(
    id: 'default',
    address: 'Walk-in',
    isDefault: true,
  );
  var _isSaving = false;

  // Data loaded from repositories
  List<Product> _products = [];
  List<Customer> _customers = [];



  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
    // Auto-focus search on desktop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productRepo = ref.read(productRepositoryProvider);
    final customerRepo = ref.read(customerRepositoryProvider);
    final products = await productRepo.getProducts();
    final customers = await customerRepo.getCustomers();
    if (!mounted) return;
    setState(() {
      _products = products;
      _customers = customers;
    });
  }

  void _addToCart(Product product, {int quantity = 1}) async {
    final cart = ref.read(cartProvider(_selectedBranchId).notifier);
    final cartState = ref.read(cartProvider(_selectedBranchId));
    final wasNew = cartState.qtyInCart(product.id) == 0;
    final result = await cart.add(product, quantity: quantity);

    if (result.message != null) {
      _showMessage(result.message!);
    }

    _searchController.clear();
    _searchFocusNode.requestFocus();

    // Scroll to bottom only when a NEW line is added.
    if (wasNew && result.added > 0) {
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
    final cart = ref.read(cartProvider(_selectedBranchId).notifier);
    final removed = cart.removeWithUndo(index);
    if (removed == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.product.name} removed'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => cart.undoRemove(),
        ),
      ),
    );
  }

  void _updateQuantity(int index, int quantity) async {
    final cart = ref.read(cartProvider(_selectedBranchId).notifier);
    final message = await cart.updateQuantity(index, quantity);
    if (message != null) {
      _showMessage(message);
    }
  }

  Future<void> _clearCart() async {
    final cartState = ref.read(cartProvider(_selectedBranchId));
    if (cartState.items.isEmpty) return;

    final confirm = await confirmDialog(
      context,
      title: 'Clear cart?',
      message: 'Remove all ${cartState.items.length} items from the cart?',
      confirmText: 'Clear',
    );

    if (confirm == true && mounted) {
      final cart = ref.read(cartProvider(_selectedBranchId).notifier);
      cart.clear();
      setState(() {
        _receiptNumber = '';
        _selectedDate = DateTime.now();
        _selectedCustomer = Customer.walkIn;
        _selectedLocation = const CustomerLocation(
          id: 'default',
          address: 'Walk-in',
          isDefault: true,
        );
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    // Prevent double-submit
    if (_isSaving) return;
    _isSaving = true;

    try {
      final cartState = ref.read(cartProvider(_selectedBranchId));
      final saleRepo = ref.read(saleRepositoryProvider);

      // Validation: non-empty cart
      if (cartState.items.isEmpty) {
        _showMessage('Cart is empty');
        return;
      }

      // Validation: receipt number required
      if (_receiptNumber.trim().isEmpty) {
        _showMessage('Receipt number is required');
        return;
      }

      // Validation: receipt number uniqueness
      final isUsed = await saleRepo.isReceiptNumberUsed(_receiptNumber.trim(), _selectedBranchId);
      if (!mounted) return;
      if (isUsed) {
        _showMessage('Receipt number already used');
        return;
      }

      // Step 1: Cylinder return dialog (only if cart has refills)
      final hasRefills = cartState.items.any((item) => item.product.kind == ProductKind.refill);
      List<ReturnedCylinder> returnedCylinders = [];

      if (hasRefills) {
        final cylinderResult = await showReturnCylinderDialog(
          context,
          lineItems: cartState.items,
          currency: _currency,
        );

        if (cylinderResult == null || !mounted) return;

        // Convert to ReturnedCylinder list
        for (final ret in cylinderResult.returns) {
          if (ret.isReturned && ret.returnedQuantity > 0) {
            // ponytail: parse brand/size from product instead of name parsing
            returnedCylinders.add(ReturnedCylinder(
              brand: ret.cylinderType.split(' ').first,
              sizeKg: 13.0, // ponytail: extract from product.sizeKg
              count: ret.returnedQuantity,
            ));
          }
        }
      }

      // Step 2: Payment dialog
      final paymentResult = await showPaymentDialog(
        context,
        grandTotal: cartState.total,
        customer: _selectedCustomer,
      );

      if (paymentResult == null || !mounted) return;

      // Validate credit sales
      if (paymentResult.isInvoice) {
        if (_selectedCustomer.isWalkIn) {
          _showMessage('Credit not allowed for walk-in customers');
          return;
        }
        final creditLimit = _selectedCustomer.creditLimit ?? 0;
        final newBalance = _selectedCustomer.balance + cartState.total;
        if (newBalance > creditLimit) {
          _showMessage('Credit limit exceeded (limit: ${formatKes(creditLimit)})');
          return;
        }
      }

      // Extract payment info
      final now = DateTime.now();
      final payments = paymentResult.payments.map((p) => Payment(
        method: p.method,
        amount: p.amount,
        timestamp: now,
        reference: p.reference,
      )).toList();

      // Determine sale status
      final status = paymentResult.isInvoice 
          ? SaleStatus.credit 
          : SaleStatus.completed;

      // Step 3: Build Sale object
      final sale = Sale(
        id: _uuid.v4(),
        receiptNumber: _receiptNumber.trim(),
        date: _selectedDate,
        branchId: _selectedBranchId,
        customerId: _selectedCustomer.id,
        customerLocationId: _selectedLocation.id,
        lines: cartState.items.map((item) => item.toSaleLine()).toList(),
        payments: payments,
        status: status,
        returnedCylinders: returnedCylinders,
        cashierId: 'john_kamau', // ponytail: use currentUserProvider.id
        dueDate: paymentResult.dueDate,
        createdAt: now,
      );

      // Step 4: Complete sale atomically
      await saleRepo.completeSale(sale);
      if (!mounted) return;

      // Step 5: Clear cart and reset form
      final cart = ref.read(cartProvider(_selectedBranchId).notifier);
      cart.clear();
      setState(() {
        _receiptNumber = '';
        _selectedDate = DateTime.now();
        _selectedCustomer = Customer.walkIn;
        _selectedLocation = const CustomerLocation(
          id: 'default',
          address: 'Walk-in',
          isDefault: true,
        );
      });

      // Step 6: Show success + View action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sale completed successfully'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _viewSale(sale.id),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving sale: $e');
      if (!mounted) return;
      _showMessage('Unable to complete sale. Please try again.');
    } finally {
      _isSaving = false;
    }
  }

  void _viewSale(String saleId) {
    // ponytail: navigate to sale detail screen in Slice 4
    _showMessage('View sale: $saleId');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !_isMobilePlatform;
    final cartState = ref.watch(cartProvider(_selectedBranchId));

    Widget child = _buildBody(context, cartState);

    if (isDesktop) {
      child = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f1): () =>
              _searchFocusNode.requestFocus(),
          const SingleActivator(LogicalKeyboardKey.f2): () {
            if (cartState.items.isNotEmpty) _save();
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

  Widget _buildBody(BuildContext context, CartState cartState) {
    final sizeClass = context.windowSizeClass;
    final isLarge = sizeClass == WindowSizeClass.expanded ||
        sizeClass == WindowSizeClass.large;

    return SingleColumnLayout(
      header: _buildHeader(),
      searchBar: _buildSearchBar(),
      lineItems: cartState.items,
      currency: _currency,
      grandTotal: cartState.total,
      totalItems: cartState.totalItems,
      scrollController: _scrollController,
      onRemoveFromCart: _removeFromCart,
      onUpdateQuantity: _updateQuantity,
      onClearCart: _clearCart,
      onSave: cartState.items.isNotEmpty ? _save : null,
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
        if (customer.locations.isNotEmpty) {
          _selectedLocation = customer.locations.firstWhere(
            (loc) => loc.isDefault,
            orElse: () => customer.locations.first,
          );
        } else {
          _selectedLocation = const CustomerLocation(
            id: 'default',
            address: 'Walk-in',
            isDefault: true,
          );
        }
      }),
      onLocationChanged: (location) =>
          setState(() => _selectedLocation = location),
      customers: _customers,
    );
  }

  Widget _buildSearchBar() {
    final isMobile = _isMobilePlatform;

    return ProductSearchBar(
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      products: _products,
      currency: _currency,
      onAddToCart: _addToCart,
      showShortcutHint: !isMobile,
    );
  }


}
