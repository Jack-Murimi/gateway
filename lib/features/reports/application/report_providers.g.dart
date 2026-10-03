// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected date range preset.

@ProviderFor(DateRangePreset)
final dateRangePresetProvider = DateRangePresetProvider._();

/// Selected date range preset.
final class DateRangePresetProvider
    extends $NotifierProvider<DateRangePreset, DateRangePresetEnum> {
  /// Selected date range preset.
  DateRangePresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dateRangePresetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dateRangePresetHash();

  @$internal
  @override
  DateRangePreset create() => DateRangePreset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRangePresetEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRangePresetEnum>(value),
    );
  }
}

String _$dateRangePresetHash() => r'6f7cb6c4e4a1c67a10bb39a90234192a8f2dddd2';

/// Selected date range preset.

abstract class _$DateRangePreset extends $Notifier<DateRangePresetEnum> {
  DateRangePresetEnum build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateRangePresetEnum, DateRangePresetEnum>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateRangePresetEnum, DateRangePresetEnum>,
              DateRangePresetEnum,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Computed start date for the selected preset.

@ProviderFor(startDate)
final startDateProvider = StartDateProvider._();

/// Computed start date for the selected preset.

final class StartDateProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Computed start date for the selected preset.
  StartDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startDateHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return startDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$startDateHash() => r'c39a899f8a12ac14b06a72e7022334d14d19cb89';

/// Report summary for the selected date range and branch.

@ProviderFor(reportSummary)
final reportSummaryProvider = ReportSummaryProvider._();

/// Report summary for the selected date range and branch.

final class ReportSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportSummary>,
          ReportSummary,
          FutureOr<ReportSummary>
        >
    with $FutureModifier<ReportSummary>, $FutureProvider<ReportSummary> {
  /// Report summary for the selected date range and branch.
  ReportSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportSummaryHash();

  @$internal
  @override
  $FutureProviderElement<ReportSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportSummary> create(Ref ref) {
    return reportSummary(ref);
  }
}

String _$reportSummaryHash() => r'b158adaeac851303022b52c567c54ad90f1b5512';

/// Branch comparison for the selected date range.

@ProviderFor(branchComparison)
final branchComparisonProvider = BranchComparisonProvider._();

/// Branch comparison for the selected date range.

final class BranchComparisonProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BranchSummary>>,
          List<BranchSummary>,
          FutureOr<List<BranchSummary>>
        >
    with
        $FutureModifier<List<BranchSummary>>,
        $FutureProvider<List<BranchSummary>> {
  /// Branch comparison for the selected date range.
  BranchComparisonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchComparisonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchComparisonHash();

  @$internal
  @override
  $FutureProviderElement<List<BranchSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BranchSummary>> create(Ref ref) {
    return branchComparison(ref);
  }
}

String _$branchComparisonHash() => r'e374f8776ae8f6026b0226dc2e92a4acc42e1d9e';
