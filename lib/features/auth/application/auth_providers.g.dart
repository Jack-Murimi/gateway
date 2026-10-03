// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mock: always authenticated.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Mock: always authenticated.

final class AuthStateProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Mock: always authenticated.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return authState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authStateHash() => r'74b6dacfbc7e532370c10468156ca11a9e0152d1';

/// Mock: logged-in staff (salesperson at Jamhuri branch).

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Mock: logged-in staff (salesperson at Jamhuri branch).

final class CurrentUserProvider extends $FunctionalProvider<Staff, Staff, Staff>
    with $Provider<Staff> {
  /// Mock: logged-in staff (salesperson at Jamhuri branch).
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<Staff> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Staff create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Staff value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Staff>(value),
    );
  }
}

String _$currentUserHash() => r'dece6922a544940a67b2f312ee2163d401f6e987';
