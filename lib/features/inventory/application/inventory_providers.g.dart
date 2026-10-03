// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Product repository.

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

/// Product repository.

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  /// Product repository.
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'032cabf98ae25ba304abc049af721e8ff56aee32';

/// Stock repository.

@ProviderFor(stockRepository)
final stockRepositoryProvider = StockRepositoryProvider._();

/// Stock repository.

final class StockRepositoryProvider
    extends
        $FunctionalProvider<StockRepository, StockRepository, StockRepository>
    with $Provider<StockRepository> {
  /// Stock repository.
  StockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockRepositoryHash();

  @$internal
  @override
  $ProviderElement<StockRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StockRepository create(Ref ref) {
    return stockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StockRepository>(value),
    );
  }
}

String _$stockRepositoryHash() => r'221ddb2ebfeea67e009d3446e92a41dd6b05c6bf';

/// Products for a branch.

@ProviderFor(products)
final productsProvider = ProductsFamily._();

/// Products for a branch.

final class ProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  /// Products for a branch.
  ProductsProvider._({
    required ProductsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @override
  String toString() {
    return r'productsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as String;
    return products(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productsHash() => r'665f216507e4e5e94d5213b2dabfd3b56b41314e';

/// Products for a branch.

final class ProductsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Product>>, String> {
  ProductsFamily._()
    : super(
        retry: null,
        name: r'productsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Products for a branch.

  ProductsProvider call(String branchId) =>
      ProductsProvider._(argument: branchId, from: this);

  @override
  String toString() => r'productsProvider';
}

/// Combined product + stock for a branch.

@ProviderFor(branchInventory)
final branchInventoryProvider = BranchInventoryFamily._();

/// Combined product + stock for a branch.

final class BranchInventoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductWithStock>>,
          List<ProductWithStock>,
          FutureOr<List<ProductWithStock>>
        >
    with
        $FutureModifier<List<ProductWithStock>>,
        $FutureProvider<List<ProductWithStock>> {
  /// Combined product + stock for a branch.
  BranchInventoryProvider._({
    required BranchInventoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'branchInventoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$branchInventoryHash();

  @override
  String toString() {
    return r'branchInventoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductWithStock>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductWithStock>> create(Ref ref) {
    final argument = this.argument as String;
    return branchInventory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchInventoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchInventoryHash() => r'c3c1bf576e28f965b7d13496bf7527a016683855';

/// Combined product + stock for a branch.

final class BranchInventoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductWithStock>>, String> {
  BranchInventoryFamily._()
    : super(
        retry: null,
        name: r'branchInventoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Combined product + stock for a branch.

  BranchInventoryProvider call(String branchId) =>
      BranchInventoryProvider._(argument: branchId, from: this);

  @override
  String toString() => r'branchInventoryProvider';
}
