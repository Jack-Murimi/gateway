// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All branches.

@ProviderFor(branches)
final branchesProvider = BranchesProvider._();

/// All branches.

final class BranchesProvider
    extends $FunctionalProvider<List<Branch>, List<Branch>, List<Branch>>
    with $Provider<List<Branch>> {
  /// All branches.
  BranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchesHash();

  @$internal
  @override
  $ProviderElement<List<Branch>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Branch> create(Ref ref) {
    return branches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Branch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Branch>>(value),
    );
  }
}

String _$branchesHash() => r'5d5845e3425b7c5a7d87981b56ac704ead60dccf';

/// Branches user can access (ponytail: mock returns all, filter by user role when auth ready).

@ProviderFor(userBranches)
final userBranchesProvider = UserBranchesProvider._();

/// Branches user can access (ponytail: mock returns all, filter by user role when auth ready).

final class UserBranchesProvider
    extends $FunctionalProvider<List<Branch>, List<Branch>, List<Branch>>
    with $Provider<List<Branch>> {
  /// Branches user can access (ponytail: mock returns all, filter by user role when auth ready).
  UserBranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userBranchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userBranchesHash();

  @$internal
  @override
  $ProviderElement<List<Branch>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Branch> create(Ref ref) {
    return userBranches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Branch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Branch>>(value),
    );
  }
}

String _$userBranchesHash() => r'cc820b60eac666eb2716df740143d6202013c766';

/// Current selected branch (restores last selection from prefs).

@ProviderFor(CurrentBranch)
final currentBranchProvider = CurrentBranchProvider._();

/// Current selected branch (restores last selection from prefs).
final class CurrentBranchProvider
    extends $NotifierProvider<CurrentBranch, Branch> {
  /// Current selected branch (restores last selection from prefs).
  CurrentBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBranchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBranchHash();

  @$internal
  @override
  CurrentBranch create() => CurrentBranch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Branch value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Branch>(value),
    );
  }
}

String _$currentBranchHash() => r'20b5e77527a0a5d785e39eff39e87ee34ea1b4ce';

/// Current selected branch (restores last selection from prefs).

abstract class _$CurrentBranch extends $Notifier<Branch> {
  Branch build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Branch, Branch>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Branch, Branch>,
              Branch,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
