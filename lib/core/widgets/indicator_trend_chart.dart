// lib/core/widgets/indicator_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/crayon_theme.dart';
import '../../domain/entities/indicator_data_point.dart';
import 'package:intl/intl.dart';

/// 指标正常范围定义
class IndicatorNormalRange {
  final double? min;
  final double? max;
  final String description;

  const IndicatorNormalRange({
    this.min,
    this.max,
    required this.description,
  });

  bool hasRange() => min != null || max != null;
}

/// 各指标的正常参考范围
const Map<String, IndicatorNormalRange> indicatorNormalRanges = {
  '血糖': IndicatorNormalRange(min: 3.9, max: 6.1, description: '空腹血糖: 3.9-6.1 mmol/L'),
  '收缩压': IndicatorNormalRange(min: 90, max: 139, description: '收缩压: 90-139 mmHg'),
  '舒张压': IndicatorNormalRange(min: 60, max: 89, description: '舒张压: 60-89 mmHg'),
  '血压': IndicatorNormalRange(min: 60, max: 139, description: '血压: 收缩压90-139/舒张压60-89 mmHg'),
  '总胆固醇': IndicatorNormalRange(min: null, max: 5.2, description: '总胆固醇: ≤5.2 mmol/L'),
  '甘油三酯': IndicatorNormalRange(min: null, max: 1.7, description: '甘油三酯: ≤1.7 mmol/L'),
  '高密度脂蛋白': IndicatorNormalRange(min: 1.0, max: null, description: '高密度脂蛋白: ≥1.0 mmol/L'),
  '低密度脂蛋白': IndicatorNormalRange(min: null, max: 3.4, description: '低密度脂蛋白: ≤3.4 mmol/L'),
};

/// 指标趋势图组件
class IndicatorTrendChart extends StatelessWidget {
  final String indicatorType;
  final List<IndicatorDataPoint> dataPoints;
  final double height;

  const IndicatorTrendChart({
    super.key,
    required this.indicatorType,
    required this.dataPoints,
    this.height = 250, // 增加高度以显示更多信息
  });

  /// 判断是否是血压指标（需要显示两条线）
  bool _isBloodPressure() {
    return indicatorType == '血压' || indicatorType == '收缩压' || indicatorType == '舒张压';
  }

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState();
    }

    if (dataPoints.length == 1) {
      return _buildSinglePointState();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        children: [
          // 标题行
          _buildTitle(),
          const SizedBox(height: CrayonTheme.spacingSm),
          // 图表
          Expanded(
            child: _isBloodPressure() ? _buildBloodPressureChart() : _buildSingleLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final normalRange = indicatorNormalRanges[indicatorType];

    return Row(
      children: [
        Icon(Icons.trending_up, size: 18, color: CrayonTheme.forestGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$indicatorType 趋势',
            style: const TextStyle(
              color: CrayonTheme.darkBrown,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, size: 40, color: CrayonTheme.forestGreen),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text('暂无$indicatorType数据', style: const TextStyle(color: CrayonTheme.darkBrown)),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text('添加更多体检报告可查看趋势', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSinglePointState() {
    final point = dataPoints.first;
    final normalRange = indicatorNormalRanges[indicatorType];

    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 40, color: CrayonTheme.mustardYellow),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text(
            _formatValue(point.value, point.secondValue),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: point.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.darkBrown,
            ),
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text(
            DateFormat('yyyy-MM-dd').format(point.date),
            style: TextStyle(color: CrayonTheme.forestGreen, fontSize: 12),
          ),
          if (normalRange != null)
            Padding(
              padding: const EdgeInsets.only(top: CrayonTheme.spacingSm),
              child: Text(
                normalRange.description,
                style: TextStyle(color: CrayonTheme.forestGreen.withValues(alpha: 0.8), fontSize: 11),
              ),
            ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text('仅有一份报告，添加更多可查看趋势', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }

  /// 单线图表（非血压指标）
  Widget _buildSingleLineChart() {
    final spots = dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      return FlSpot(index.toDouble(), point.value);
    }).toList();

    final values = dataPoints.map((p) => p.value).toList();
    final dataMinY = values.reduce((a, b) => a < b ? a : b);
    final dataMaxY = values.reduce((a, b) => a > b ? a : b);

    final normalRange = indicatorNormalRanges[indicatorType];

    double minY;
    double maxY;
    List<HorizontalLine> horizontalLines = [];

    if (normalRange?.hasRange() == true) {
      final rangeMin = normalRange!.min ?? dataMinY * 0.8;
      final rangeMax = normalRange.max ?? dataMaxY * 1.2;
      minY = ((dataMinY < rangeMin ? dataMinY : rangeMin) * 0.85).floorToDouble();
      maxY = ((dataMaxY > rangeMax ? dataMaxY : rangeMax) * 1.15).ceilToDouble();

      if (normalRange.max != null) {
        horizontalLines.add(HorizontalLine(
          y: normalRange.max!,
          color: CrayonTheme.forestGreen.withValues(alpha: 0.6),
          strokeWidth: 2,
          dashArray: [4, 4],
        ));
      }
      if (normalRange.min != null) {
        horizontalLines.add(HorizontalLine(
          y: normalRange.min!,
          color: CrayonTheme.forestGreen.withValues(alpha: 0.6),
          strokeWidth: 2,
          dashArray: [4, 4],
        ));
      }
    } else {
      minY = (dataMinY * 0.9).floorToDouble();
      maxY = (dataMaxY * 1.1).ceilToDouble();
    }

    final labelIndices = _getLabelIndices(dataPoints.length);

    return Stack(
      children: [
        LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: CrayonTheme.forestGreen.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: horizontalLines),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if ((value - index).abs() > 0.01) return const SizedBox();
                    if (index < 0 || index >= dataPoints.length) return const SizedBox();
                    if (!labelIndices.contains(index)) return const SizedBox();
                    final point = dataPoints[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3)),
            ),
            minX: -0.3,
            maxX: (dataPoints.length - 1) + 0.3,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: CrayonTheme.mustardYellow,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final point = dataPoints[index];
                    return FlDotCirclePainter(
                      radius: 6,
                      color: point.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.mustardYellow,
                      strokeWidth: 2,
                      strokeColor: CrayonTheme.darkBrown,
                    );
                  },
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => CrayonTheme.creamWhite,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    final point = dataPoints[index];
                    return LineTooltipItem(
                      '${_formatValue(point.value, point.secondValue)}\n${DateFormat('yyyy-MM-dd').format(point.date)}',
                      const TextStyle(color: CrayonTheme.darkBrown, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
        // 正常范围标签
        if (normalRange?.description != null)
          Positioned(
            top: 4,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                normalRange!.description,
                style: TextStyle(
                  color: CrayonTheme.forestGreen.withValues(alpha: 0.9),
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 血压双线图表（收缩压和舒张压）
  Widget _buildBloodPressureChart() {
    // 收缩压数据点
    final systolicSpots = dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      return FlSpot(index.toDouble(), point.value);
    }).toList();

    // 舒张压数据点（如果有）
    final diastolicSpots = dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      if (point.secondValue != null) {
        return FlSpot(index.toDouble(), point.secondValue!);
      }
      return null;
    }).where((spot) => spot != null).toList();

    // 计算所有值的范围（过滤掉null值）
    final systolicValues = dataPoints.map((p) => p.value).toList();
    final diastolicValues = dataPoints.map((p) => p.secondValue).whereType<double>().toList();

    // 血压正常范围
    const systolicMin = 90.0;
    const systolicMax = 139.0;
    const diastolicMin = 60.0;
    const diastolicMax = 89.0;

    // Y轴范围
    const minY = 50.0; // 血压下限设为50
    const maxY = 160.0; // 血压上限设为160

    // 正常范围线
    final horizontalLines = [
      // 收缩压上限
      HorizontalLine(
        y: systolicMax,
        color: CrayonTheme.brickRed.withValues(alpha: 0.5),
        strokeWidth: 2,
        dashArray: [4, 4],
      ),
      // 收缩压下限
      HorizontalLine(
        y: systolicMin,
        color: CrayonTheme.forestGreen.withValues(alpha: 0.5),
        strokeWidth: 2,
        dashArray: [4, 4],
      ),
      // 舒张压上限
      HorizontalLine(
        y: diastolicMax,
        color: CrayonTheme.brickRed.withValues(alpha: 0.5),
        strokeWidth: 2,
        dashArray: [4, 4],
      ),
      // 舒张压下限
      HorizontalLine(
        y: diastolicMin,
        color: CrayonTheme.forestGreen.withValues(alpha: 0.5),
        strokeWidth: 2,
        dashArray: [4, 4],
      ),
    ];

    final labelIndices = _getLabelIndices(dataPoints.length);

    return Stack(
      children: [
        LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: CrayonTheme.forestGreen.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: horizontalLines),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: 20,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if ((value - index).abs() > 0.01) return const SizedBox();
                    if (index < 0 || index >= dataPoints.length) return const SizedBox();
                    if (!labelIndices.contains(index)) return const SizedBox();
                    final point = dataPoints[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3)),
            ),
            minX: -0.3,
            maxX: (dataPoints.length - 1) + 0.3,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              // 收缩压线（红色）
              LineChartBarData(
                spots: systolicSpots.cast<FlSpot>(),
                isCurved: false,
                color: CrayonTheme.brickRed,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final point = dataPoints[index];
                    final isAbnormal = point.value > systolicMax || point.value < systolicMin;
                    return FlDotCirclePainter(
                      radius: 5,
                      color: isAbnormal ? CrayonTheme.brickRed : CrayonTheme.brickRed.withValues(alpha: 0.7),
                      strokeWidth: 2,
                      strokeColor: CrayonTheme.darkBrown,
                    );
                  },
                ),
              ),
              // 舒张压线（绿色）
              if (diastolicSpots.isNotEmpty)
                LineChartBarData(
                  spots: diastolicSpots.cast<FlSpot>(),
                  isCurved: false,
                  color: CrayonTheme.forestGreen,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final point = dataPoints[index];
                      final diastolic = point.secondValue;
                      if (diastolic == null) return FlDotCirclePainter(radius: 0);
                      final isAbnormal = diastolic > diastolicMax || diastolic < diastolicMin;
                      return FlDotCirclePainter(
                        radius: 5,
                        color: isAbnormal ? CrayonTheme.brickRed : CrayonTheme.forestGreen.withValues(alpha: 0.7),
                        strokeWidth: 2,
                        strokeColor: CrayonTheme.darkBrown,
                      );
                    },
                  ),
                ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => CrayonTheme.creamWhite,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    final point = dataPoints[index];
                    final lineIndex = spot.barIndex;
                    final label = lineIndex == 0 ? '收缩压' : '舒张压';
                    final value = lineIndex == 0 ? point.value : point.secondValue ?? 0;
                    return LineTooltipItem(
                      '$label: ${value.toInt()}\n${DateFormat('yyyy-MM-dd').format(point.date)}',
                      TextStyle(
                        color: lineIndex == 0 ? CrayonTheme.brickRed : CrayonTheme.forestGreen,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
        // 血压图例和正常范围说明
        Positioned(
          top: 4,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图例
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 3, color: CrayonTheme.brickRed),
                  const SizedBox(width: 4),
                  Text('收缩压', style: TextStyle(color: CrayonTheme.brickRed, fontSize: 10)),
                  const SizedBox(width: 8),
                  Container(width: 12, height: 3, color: CrayonTheme.forestGreen),
                  const SizedBox(width: 4),
                  Text('舒张压', style: TextStyle(color: CrayonTheme.forestGreen, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              // 正常范围
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '正常: 收缩压90-139 / 舒张压60-89 mmHg',
                  style: TextStyle(
                    color: CrayonTheme.forestGreen.withValues(alpha: 0.9),
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatValue(double value, double? secondValue) {
    if (secondValue != null) {
      return '${value.toInt()}/${secondValue.toInt()}';
    }
    return value.toStringAsFixed(1);
  }

  List<int> _getLabelIndices(int total) {
    if (total <= 3) {
      return List.generate(total, (i) => i);
    } else if (total <= 5) {
      return [0, total - 1];
    } else if (total <= 7) {
      return [0, (total ~/ 2), total - 1];
    } else {
      final step = (total - 1) ~/ 3;
      return [0, step, step * 2, total - 1];
    }
  }
}