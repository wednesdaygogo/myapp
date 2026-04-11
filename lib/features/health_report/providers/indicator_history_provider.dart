import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/indicator_data_point.dart';
import '../../../domain/entities/indicator_query.dart';
import '../../../data/models/health_indicator.dart';
import 'health_report_provider.dart';

const String healthIndicatorsBoxName = 'healthIndicators';

/// 将英文指标类型转换为中文显示名
String _getIndicatorDisplayName(String type) {
  switch (type) {
    case 'bloodGlucose': return '血糖';
    case 'bloodPressure': return '血压';
    case 'bloodLipidTC': return '总胆固醇';
    case 'bloodLipidTG': return '甘油三酯';
    case 'bloodLipidHDL': return '高密度脂蛋白';
    case 'bloodLipidLDL': return '低密度脂蛋白';
    default: return type; // 自定义指标直接显示原名称
  }
}

/// 指标历史数据Provider
final indicatorHistoryProvider = Provider.family<List<IndicatorDataPoint>, IndicatorQuery>((ref, query) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == query.personId).toList();

  // 按日期排序
  personReports.sort((a, b) => a.reportDate.compareTo(b.reportDate));

  final dataPoints = <IndicatorDataPoint>[];
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

  // 将中文查询类型转换为英文进行匹配
  String queryType = query.indicatorType;
  // 如果查询的是中文，转换为英文类型
  switch (query.indicatorType) {
    case '血糖': queryType = 'bloodGlucose'; break;
    case '血压': queryType = 'bloodPressure'; break;
    case '总胆固醇': queryType = 'bloodLipidTC'; break;
    case '甘油三酯': queryType = 'bloodLipidTG'; break;
    case '高密度脂蛋白': queryType = 'bloodLipidHDL'; break;
    case '低密度脂蛋白': queryType = 'bloodLipidLDL'; break;
  }

  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id).toList();
    // 匹配英文类型或中文类型（兼容两种存储方式）
    final matchingIndicator = indicators.where((i) =>
      i.type == queryType || i.type == query.indicatorType
    ).firstOrNull;

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

/// 某家人的所有指标类型列表（用于选择器）- 返回中文显示名
final indicatorTypesByPersonProvider = Provider.family<List<String>, int>((ref, personId) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == personId).toList();

  final types = <String>{};
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id);
    for (final indicator in indicators) {
      // 转换为中文显示名
      types.add(_getIndicatorDisplayName(indicator.type));
    }
  }

  // 固定类型排序（中文）
  final fixedTypes = ['血糖', '血压', '总胆固醇', '甘油三酯', '高密度脂蛋白', '低密度脂蛋白'];
  final customTypes = types.where((t) => !fixedTypes.contains(t)).toList();

  return [...fixedTypes.where((t) => types.contains(t)), ...customTypes];
});