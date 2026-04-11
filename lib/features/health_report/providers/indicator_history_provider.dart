import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/indicator_data_point.dart';
import '../../../domain/entities/indicator_query.dart';
import '../../../data/models/health_indicator.dart';
import 'health_report_provider.dart';

const String healthIndicatorsBoxName = 'healthIndicators';

/// 指标历史数据Provider
final indicatorHistoryProvider = Provider.family<List<IndicatorDataPoint>, IndicatorQuery>((ref, query) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == query.personId).toList();

  // 按日期排序
  personReports.sort((a, b) => a.reportDate.compareTo(b.reportDate));

  final dataPoints = <IndicatorDataPoint>[];
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id).toList();
    final matchingIndicator = indicators.where((i) => i.type == query.indicatorType).firstOrNull;

    if (matchingIndicator != null) {
      dataPoints.add(IndicatorDataPoint(
        date: report.reportDate,
        value: matchingIndicator.value,
        secondValue: matchingIndicator.secondValue,
        reportId: report.id,
        isAbnormal: matchingIndicator.isAbnormal,
      ));
    }
  }

  return dataPoints;
});

/// 某家人的所有指标类型列表（用于选择器）
final indicatorTypesByPersonProvider = Provider.family<List<String>, int>((ref, personId) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == personId).toList();

  final types = <String>{};
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id);
    for (final indicator in indicators) {
      types.add(indicator.type);
    }
  }

  // 固定类型排序
  final fixedTypes = ['血糖', '血压', '血脂'];
  final customTypes = types.where((t) => !fixedTypes.contains(t)).toList();

  return [...fixedTypes, ...customTypes];
});