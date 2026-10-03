// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides receipt formatter.

@ProviderFor(receiptFormatter)
final receiptFormatterProvider = ReceiptFormatterProvider._();

/// Provides receipt formatter.

final class ReceiptFormatterProvider
    extends
        $FunctionalProvider<
          ReceiptFormatter,
          ReceiptFormatter,
          ReceiptFormatter
        >
    with $Provider<ReceiptFormatter> {
  /// Provides receipt formatter.
  ReceiptFormatterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptFormatterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptFormatterHash();

  @$internal
  @override
  $ProviderElement<ReceiptFormatter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptFormatter create(Ref ref) {
    return receiptFormatter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptFormatter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptFormatter>(value),
    );
  }
}

String _$receiptFormatterHash() => r'90fc2d7c1b616da6fd8d73a4a3abf69f34de2c48';

/// Provides receipt service.

@ProviderFor(receiptService)
final receiptServiceProvider = ReceiptServiceProvider._();

/// Provides receipt service.

final class ReceiptServiceProvider
    extends $FunctionalProvider<ReceiptService, ReceiptService, ReceiptService>
    with $Provider<ReceiptService> {
  /// Provides receipt service.
  ReceiptServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptServiceHash();

  @$internal
  @override
  $ProviderElement<ReceiptService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptService create(Ref ref) {
    return receiptService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptService>(value),
    );
  }
}

String _$receiptServiceHash() => r'ef4010f6f1f37185e3f5317f8d36771514a2a532';
