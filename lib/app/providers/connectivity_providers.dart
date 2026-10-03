import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_providers.g.dart';

/// Provides Connectivity instance.
@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

/// Stream of connectivity status changes.
@riverpod
Stream<bool> connectivityStatus(Ref ref) {
  final connectivity = ref.watch(connectivityProvider);
  
  return connectivity.onConnectivityChanged.map((results) {
    // Online if any connection type is available (wifi, mobile, ethernet)
    return results.isNotEmpty && 
           !results.every((r) => r == ConnectivityResult.none);
  });
}

/// Current connectivity state (true = online, false = offline).
@riverpod
class IsOnline extends _$IsOnline {
  @override
  Future<bool> build() async {
    final connectivity = ref.watch(connectivityProvider);
    
    // Watch the stream and update state
    ref.listen(connectivityStatusProvider, (_, next) {
      next.whenData((isOnline) => state = AsyncValue.data(isOnline));
    });
    
    // Get initial state
    final results = await connectivity.checkConnectivity();
    return results.isNotEmpty && 
           !results.every((r) => r == ConnectivityResult.none);
  }
}
