import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/database.dart';

part 'database_providers.g.dart';

/// Provides the Drift database instance.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}
