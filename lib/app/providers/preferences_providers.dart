import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/preferences_service.dart';

part 'preferences_providers.g.dart';

/// Provides SharedPreferences instance.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Provides PreferencesService.
@Riverpod(keepAlive: true)
Future<PreferencesService> preferencesService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return PreferencesService(prefs);
}
