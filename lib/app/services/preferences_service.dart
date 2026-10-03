import 'package:shared_preferences/shared_preferences.dart';

/// Local preferences storage service.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _keySelectedBranchId = 'selected_branch_id';
  static const _keyThemeMode = 'theme_mode';

  /// Gets the last selected branch ID.
  String? getSelectedBranchId() => _prefs.getString(_keySelectedBranchId);

  /// Saves the selected branch ID.
  Future<void> setSelectedBranchId(String branchId) async {
    await _prefs.setString(_keySelectedBranchId, branchId);
  }

  /// Gets the theme mode ('light', 'dark', or 'system').
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';

  /// Saves the theme mode.
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }
}
