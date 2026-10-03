/// Date range presets for reports.
enum DateRangePresetEnum {
  /// Today only.
  today,

  /// Last 7 days.
  last7Days,

  /// Last 30 days.
  last30Days,

  /// Custom date range.
  custom,
}

extension DateRangePresetExtension on DateRangePresetEnum {
  /// Human-readable label.
  String get label {
    switch (this) {
      case DateRangePresetEnum.today:
        return 'Today';
      case DateRangePresetEnum.last7Days:
        return 'Last 7 days';
      case DateRangePresetEnum.last30Days:
        return 'Last 30 days';
      case DateRangePresetEnum.custom:
        return 'Custom range';
    }
  }

  /// Computes the start date for this preset.
  /// Returns null for custom (user must specify).
  DateTime? getStartDate() {
    final now = DateTime.now();
    switch (this) {
      case DateRangePresetEnum.today:
        return DateTime(now.year, now.month, now.day);
      case DateRangePresetEnum.last7Days:
        return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
      case DateRangePresetEnum.last30Days:
        return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
      case DateRangePresetEnum.custom:
        return null;
    }
  }
}
