import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/health_report.dart';
import '../../../data/models/health_indicator.dart';
import '../../../data/models/person.dart';
import '../../person/providers/person_provider.dart';

/// Hive box names
const String healthReportsBoxName = 'healthReports';
const String healthIndicatorsBoxName = 'healthIndicators';

/// Health reports notifier - manages reports with Hive persistence
class HealthReportsNotifier extends StateNotifier<List<HealthReport>> {
  final Ref _ref;

  HealthReportsNotifier(this._ref) : super([]) {
    _loadFromHive();
  }

  /// Load reports from Hive on initialization
  Future<void> _loadFromHive() async {
    try {
      final box = Hive.box<HealthReport>(healthReportsBoxName);
      state = box.values.toList();
    } catch (e) {
      // Box might not be opened yet
      state = [];
    }
  }

  /// Create a new health report with indicators
  Future<int?> createReport({
    required int personId,
    required DateTime reportDate,
    String? pdfPath,
    String source = 'pdf_import',
    List<HealthIndicator>? indicators,
  }) async {
    try {
      final box = Hive.box<HealthReport>(healthReportsBoxName);
      final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

      // Generate new ID
      final newId = box.isEmpty
          ? 1
          : box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;

      // Create report
      final report = HealthReport(
        id: newId,
        personId: personId,
        reportDate: reportDate,
        source: source,
        pdfPath: pdfPath,
      );

      // Save report to Hive
      await box.put(newId, report);

      // Save indicators if provided
      if (indicators != null && indicators.isNotEmpty) {
        final maxIndicatorId = indicatorBox.isEmpty
            ? 0
            : indicatorBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
        for (int i = 0; i < indicators.length; i++) {
          final indicator = indicators[i];
          final newIndicatorId = maxIndicatorId + i + 1;
          final newIndicator = HealthIndicator(
            id: newIndicatorId,
            reportId: newId,
            type: indicator.type,
            value: indicator.value,
            secondValue: indicator.secondValue,
            unit: indicator.unit,
            isAbnormal: indicator.isAbnormal,
          );
          await indicatorBox.put(newIndicatorId, newIndicator);
        }
      }

      // Update state
      state = box.values.toList();

      return newId;
    } catch (e) {
      return null;
    }
  }

  /// Delete a health report and its indicators
  Future<bool> deleteReport(int reportId) async {
    try {
      final box = Hive.box<HealthReport>(healthReportsBoxName);
      final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

      // Delete associated indicators
      final indicatorsToDelete = indicatorBox.values
          .where((i) => i.reportId == reportId)
          .map((i) => i.id)
          .toList();
      for (final id in indicatorsToDelete) {
        await indicatorBox.delete(id);
      }

      // Delete report
      await box.delete(reportId);

      // Update state
      state = box.values.toList();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get reports for a specific person
  List<HealthReport> getReportsByPersonId(int personId) {
    return state.where((r) => r.personId == personId).toList();
  }

  /// Get report by ID
  HealthReport? getReportById(int id) {
    return state.where((r) => r.id == id).firstOrNull;
  }
}

/// All health reports provider
final healthReportsProvider =
    StateNotifierProvider<HealthReportsNotifier, List<HealthReport>>((ref) {
  return HealthReportsNotifier(ref);
});

/// Reports for a specific person
final reportsByPersonProvider =
    Provider.family<List<HealthReport>, int>((ref, personId) {
  final allReports = ref.watch(healthReportsProvider);
  return allReports.where((r) => r.personId == personId).toList();
});

/// Selected report ID
final selectedReportIdProvider = StateProvider<int?>((ref) => null);

/// Selected report
final selectedReportProvider = Provider<HealthReport?>((ref) {
  final id = ref.watch(selectedReportIdProvider);
  if (id == null) return null;
  final reports = ref.watch(healthReportsProvider);
  return reports.where((r) => r.id == id).firstOrNull;
});

/// Get indicators for a report
final indicatorsByReportProvider =
    Provider.family<List<HealthIndicator>, int>((ref, reportId) {
  try {
    final box = Hive.box<HealthIndicator>(healthIndicatorsBoxName);
    return box.values.where((i) => i.reportId == reportId).toList();
  } catch (e) {
    return [];
  }
});

/// Selected person for filtering reports
final selectedPersonFilterProvider = StateProvider<int?>((ref) => null);

/// Filtered reports by selected person
final filteredReportsProvider = Provider<List<HealthReport>>((ref) {
  final personId = ref.watch(selectedPersonFilterProvider);
  final allReports = ref.watch(healthReportsProvider);

  if (personId == null) return allReports;
  return allReports.where((r) => r.personId == personId).toList();
});

/// Report with person info for display
class ReportWithPerson {
  final HealthReport report;
  final Person? person;

  ReportWithPerson({required this.report, this.person});
}

/// Reports with person info provider
final reportsWithPersonProvider = Provider<List<ReportWithPerson>>((ref) {
  final reports = ref.watch(healthReportsProvider);
  final persons = ref.watch(personsProvider);

  return reports.map((report) {
    final person = persons.where((p) => p.id == report.personId).firstOrNull;
    return ReportWithPerson(report: report, person: person);
  }).toList();
});
