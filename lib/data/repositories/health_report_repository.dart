import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_report.dart';
import '../models/health_indicator.dart';

/// Repository for HealthReport data using Hive
class HealthReportRepository {
  static const String _boxName = 'healthReports';
  static const String _indicatorBoxName = 'healthIndicators';

  Box<HealthReport> get _box => Hive.box<HealthReport>(_boxName);
  Box<HealthIndicator> get _indicatorBox =>
      Hive.box<HealthIndicator>(_indicatorBoxName);

  /// Create or update a report
  Future<int> save(HealthReport report) async {
    if (report.id == 0) {
      final newId = _box.isEmpty
          ? 1
          : _box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
      final newReport = HealthReport(
        id: newId,
        personId: report.personId,
        reportDate: report.reportDate,
        source: report.source,
        pdfPath: report.pdfPath,
      );
      await _box.put(newId, newReport);
      return newId;
    } else {
      await _box.put(report.id, report);
      return report.id;
    }
  }

  /// Get all reports sorted by date (newest first)
  List<HealthReport> getAll() {
    final reports = _box.values.toList();
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return reports;
  }

  /// Get report by ID
  HealthReport? getById(int id) {
    return _box.get(id);
  }

  /// Get reports by person ID
  List<HealthReport> getByPersonId(int personId) {
    final reports = _box.values.where((r) => r.personId == personId).toList();
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return reports;
  }

  /// Delete a report (cascade delete indicators)
  Future<void> delete(int id) async {
    // Delete associated indicators
    final indicatorsToDelete = _indicatorBox.values
        .where((i) => i.reportId == id)
        .map((i) => i.id)
        .toList();
    for (final indicatorId in indicatorsToDelete) {
      await _indicatorBox.delete(indicatorId);
    }
    // Delete the report
    await _box.delete(id);
  }

  /// Count reports by person ID
  int countByPersonId(int personId) {
    return _box.values.where((r) => r.personId == personId).length;
  }

  /// Get indicators for a report
  List<HealthIndicator> getIndicators(int reportId) {
    return _indicatorBox.values.where((i) => i.reportId == reportId).toList();
  }

  /// Save an indicator
  Future<int> saveIndicator(HealthIndicator indicator) async {
    if (indicator.id == 0) {
      final newId = _indicatorBox.isEmpty
          ? 1
          : _indicatorBox.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
      final newIndicator = HealthIndicator(
        id: newId,
        reportId: indicator.reportId,
        type: indicator.type,
        value: indicator.value,
        secondValue: indicator.secondValue,
        unit: indicator.unit,
        isAbnormal: indicator.isAbnormal,
      );
      await _indicatorBox.put(newId, newIndicator);
      return newId;
    } else {
      await _indicatorBox.put(indicator.id, indicator);
      return indicator.id;
    }
  }
}
