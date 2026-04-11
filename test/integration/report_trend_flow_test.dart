import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/core/widgets/crayon_card.dart';
import 'package:health_records/core/widgets/indicator_trend_chart.dart';
import 'package:health_records/domain/entities/indicator_data_point.dart';

void main() {
  group('Report Trend Flow', () {
    testWidgets('IndicatorTrendChart shows empty state when no data', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndicatorTrendChart(
            indicatorType: '血糖',
            dataPoints: [],
          ),
        ),
      ));

      expect(find.text('暂无血糖数据'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('IndicatorTrendChart shows single point state', (tester) async {
      final dataPoint = IndicatorDataPoint(
        date: DateTime(2026, 4, 11),
        value: 5.5,
        reportId: 1,
        isAbnormal: false,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndicatorTrendChart(
            indicatorType: '血糖',
            dataPoints: [dataPoint],
            height: 200,
          ),
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);
    });

    testWidgets('IndicatorTrendChart shows chart for multiple points', (tester) async {
      final dataPoints = [
        IndicatorDataPoint(
          date: DateTime(2026, 1, 1),
          value: 5.0,
          reportId: 1,
          isAbnormal: false,
        ),
        IndicatorDataPoint(
          date: DateTime(2026, 2, 1),
          value: 5.5,
          reportId: 2,
          isAbnormal: false,
        ),
        IndicatorDataPoint(
          date: DateTime(2026, 3, 1),
          value: 6.0,
          reportId: 3,
          isAbnormal: true,
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 250,
            child: IndicatorTrendChart(
              indicatorType: '血糖',
              dataPoints: dataPoints,
              height: 200,
            ),
          ),
        ),
      ));

      // Chart title should show
      expect(find.textContaining('血糖 趋势'), findsOneWidget);
    });
  });
}