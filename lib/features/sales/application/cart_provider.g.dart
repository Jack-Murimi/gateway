// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cart per branch. Survives navigation.

@ProviderFor(Cart)
final cartProvider = CartFamily._();

/// Cart per branch. Survives navigation.
final class CartProvider extends $NotifierProvider<Cart, CartState> {
  /// Cart per branch. Survives navigation.
  CartProvider._({
    required CartFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cartProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @override
  String toString() {
    return r'cartProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cartHash() => r'651dd6f11814d169625e111e69da9044dd0ef2df';

/// Cart per branch. Survives navigation.

final class CartFamily extends $Family
    with $ClassFamilyOverride<Cart, CartState, CartState, CartState, String> {
  CartFamily._()
    : super(
        retry: null,
        name: r'cartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cart per branch. Survives navigation.

  CartProvider call(String branchId) =>
      CartProvider._(argument: branchId, from: this);

  @override
  String toString() => r'cartProvider';
}

/// Cart per branch. Survives navigation.

abstract class _$Cart extends $Notifier<CartState> {
  late final _$args = ref.$arg as String;
  String get branchId => _$args;

  CartState build(String branchId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CartState, CartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CartState, CartState>,
              CartState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
