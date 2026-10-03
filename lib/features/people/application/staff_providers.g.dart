// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Staff repository.

@ProviderFor(staffRepository)
final staffRepositoryProvider = StaffRepositoryProvider._();

/// Staff repository.

final class StaffRepositoryProvider
    extends
        $FunctionalProvider<StaffRepository, StaffRepository, StaffRepository>
    with $Provider<StaffRepository> {
  /// Staff repository.
  StaffRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staffRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staffRepositoryHash();

  @$internal
  @override
  $ProviderElement<StaffRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StaffRepository create(Ref ref) {
    return staffRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StaffRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StaffRepository>(value),
    );
  }
}

String _$staffRepositoryHash() => r'7bcc7340a51001da55015cdee04838cbd58d0180';

/// All staff list.

@ProviderFor(staffList)
final staffListProvider = StaffListProvider._();

/// All staff list.

final class StaffListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Staff>>,
          List<Staff>,
          FutureOr<List<Staff>>
        >
    with $FutureModifier<List<Staff>>, $FutureProvider<List<Staff>> {
  /// All staff list.
  StaffListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staffListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staffListHash();

  @$internal
  @override
  $FutureProviderElement<List<Staff>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Staff>> create(Ref ref) {
    return staffList(ref);
  }
}

String _$staffListHash() => r'172f140d2088a4e702e62277d72be5ab5fa983c2';

/// Staff filtered by branch.

@ProviderFor(branchStaff)
final branchStaffProvider = BranchStaffFamily._();

/// Staff filtered by branch.

final class BranchStaffProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Staff>>,
          List<Staff>,
          FutureOr<List<Staff>>
        >
    with $FutureModifier<List<Staff>>, $FutureProvider<List<Staff>> {
  /// Staff filtered by branch.
  BranchStaffProvider._({
    required BranchStaffFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'branchStaffProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$branchStaffHash();

  @override
  String toString() {
    return r'branchStaffProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Staff>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Staff>> create(Ref ref) {
    final argument = this.argument as String;
    return branchStaff(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchStaffProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchStaffHash() => r'6161521f3f7be0340b7c32d87d2b6a04f7b92229';

/// Staff filtered by branch.

final class BranchStaffFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Staff>>, String> {
  BranchStaffFamily._()
    : super(
        retry: null,
        name: r'branchStaffProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Staff filtered by branch.

  BranchStaffProvider call(String branchId) =>
      BranchStaffProvider._(argument: branchId, from: this);

  @override
  String toString() => r'branchStaffProvider';
}
