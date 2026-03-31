import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/health_report.dart';
import '../../../data/models/health_indicator.dart';

// In-memory storage
final _reports = <HealthReport>[];
final _indicators = <HealthIndicator>[];
int _nextReportId = 1;
int _nextIndicatorId = 1;

// All reports list
final reportsProvider = StateProvider<List<HealthReport>>((ref) => _reports);

// Reports for a specific person
final reportsByPersonProvider =
    Provider.family<List<HealthReport>, int>((ref, personId) {
  return _reports.where((r) => r.personId == personId).toList();
});

// Selected report
final selectedReportIdProvider = StateProvider<int?>((ref) => null);

final selectedReportProvider = Provider<HealthReport?>((ref) {
  final id = ref.watch(selectedReportIdProvider);
  if (id == null) return null;
  return _reports.firstWhere((r) => r.id == id,
      orElse: () => HealthReport(personId: 0, reportDate: DateTime.now()));
});

// Report CRUD notifier
class ReportNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReportNotifier(this._ref) : super(const AsyncData(null));

  Future<int?> createReport(
      HealthReport report, List<HealthIndicator> indicators) async {
    state = const AsyncLoading();
    try {
      report.id = _nextReportId++;
      _reports.add(report);
      for (final indicator in indicators) {
        indicator.id = _nextIndicatorId++;
        indicator.reportId = report.id;
        _indicators.add(indicator);
      }
      _ref.invalidate(reportsProvider);
      _ref.invalidate(reportsByPersonProvider(report.personId));
      state = const AsyncData(null);
      return report.id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> deleteReport(int id, int personId) async {
    state = const AsyncLoading();
    try {
      _reports.removeWhere((r) => r.id == id);
      _indicators.removeWhere((i) => i.reportId == id);
      _ref.invalidate(reportsProvider);
      _ref.invalidate(reportsByPersonProvider(personId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final reportNotifierProvider =
    StateNotifierProvider<ReportNotifier, AsyncValue<void>>((ref) {
  return ReportNotifier(ref);
});

// Selected person for filtering reports
final selectedPersonFilterProvider = StateProvider<int?>((ref) => null);

final filteredReportsProvider = Provider<List<HealthReport>>((ref) {
  final personId = ref.watch(selectedPersonFilterProvider);
  final allReports = ref.watch(reportsProvider);

  if (personId == null) return allReports;
  return allReports.where((r) => r.personId == personId).toList();
});

// Get indicators for a report
final indicatorsByReportProvider =
    Provider.family<List<HealthIndicator>, int>((ref, reportId) {
  return _indicators.where((i) => i.reportId == reportId).toList();
});
