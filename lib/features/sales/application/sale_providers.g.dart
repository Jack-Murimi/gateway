// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sale repository.

@ProviderFor(saleRepository)
final saleRepositoryProvider = SaleRepositoryProvider._();

/// Sale repository.

final class SaleRepositoryProvider
    extends $FunctionalProvider<SaleRepository, SaleRepository, SaleRepository>
    with $Provider<SaleRepository> {
  /// Sale repository.
  SaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleRepositoryHash();

  @$internal
  @override
  $ProviderElement<SaleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaleRepository create(Ref ref) {
    return saleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleRepository>(value),
    );
  }
}

String _$saleRepositoryHash() => r'a979ddfc4e4d6caef66f4058633cef1d31eaf33f';

/// All sales list.

@ProviderFor(salesList)
final salesListProvider = SalesListProvider._();

/// All sales list.

final class SalesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// All sales list.
  SalesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesListHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return salesList(ref);
  }
}

String _$salesListHash() => r'f3b213f9c1ffcefb5417dffde98e57cfa283635a';

/// Sales filtered by branch.

@ProviderFor(branchSales)
final branchSalesProvider = BranchSalesFamily._();

/// Sales filtered by branch.

final class BranchSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Sales filtered by branch.
  BranchSalesProvider._({
    required BranchSalesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'branchSalesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$branchSalesHash();

  @override
  String toString() {
    return r'branchSalesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    final argument = this.argument as String;
    return branchSales(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchSalesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchSalesHash() => r'4ad204467f451624f2e8702efe4ef52d9c37a1ee';

/// Sales filtered by branch.

final class BranchSalesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Sale>>, String> {
  BranchSalesFamily._()
    : super(
        retry: null,
        name: r'branchSalesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Sales filtered by branch.

  BranchSalesProvider call(String branchId) =>
      BranchSalesProvider._(argument: branchId, from: this);

  @override
  String toString() => r'branchSalesProvider';
}
