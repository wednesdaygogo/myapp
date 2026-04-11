// lib/core/widgets/indicator_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/crayon_theme.dart';
import '../../domain/entities/indicator_data_point.dart';
import 'package:intl/intl.dart';

/// 指标趋势图组件
class IndicatorTrendChart extends StatelessWidget {
  final String indicatorType;
  final List<IndicatorDataPoint> dataPoints;
  final double height;

  const IndicatorTrendChart({
    super.key,
    required this.indicatorType,
    required this.dataPoints,
    this.height = 200,
  });

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
          // 标题
          Text(
            '📈 $indicatorType 趋势',
            style: const TextStyle(
              color: CrayonTheme.darkBrown,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          // 图表
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: CrayonTheme.darkBrown),
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text(
            DateFormat('yyyy-MM').format(point.date),
            style: TextStyle(color: CrayonTheme.forestGreen, fontSize: 12),
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text('仅有一份报告，添加更多可查看趋势', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = dataPoints.map((point) {
      final x = point.date.millisecondsSinceEpoch.toDouble();
      final y = point.value;
      return FlSpot(x, y);
    }).toList();

    // 计算Y轴范围
    final values = dataPoints.map((p) => p.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.9).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: CrayonTheme.forestGreen.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  DateFormat('MM/dd').format(date),
                  style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
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
        minX: spots.first.x,
        maxX: spots.last.x,
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
    );
  }

  String _formatValue(double value, double? secondValue) {
    if (secondValue != null) {
      return '${value.toInt()}/${secondValue.toInt()}';
    }
    return value.toStringAsFixed(1);
  }
}