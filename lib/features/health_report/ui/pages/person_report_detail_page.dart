// lib/features/health_report/ui/pages/person_report_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_button.dart';
import '../../../../core/widgets/crayon_segmented_button.dart';
import '../../../../core/widgets/indicator_trend_chart.dart';
import '../../../../core/widgets/crayon_avatar.dart';
import '../../../../domain/entities/indicator_query.dart';
import '../../../../data/models/health_indicator.dart';
import '../../../person/providers/person_provider.dart';
import '../../providers/health_report_provider.dart';
import '../../providers/indicator_history_provider.dart';

class PersonReportDetailPage extends ConsumerStatefulWidget {
  final int personId;

  const PersonReportDetailPage({super.key, required this.personId});

  @override
  ConsumerState<PersonReportDetailPage> createState() => _PersonReportDetailPageState();
}

class _PersonReportDetailPageState extends ConsumerState<PersonReportDetailPage> {
  int? _selectedReportId;
  String _selectedIndicatorType = '血糖';

  @override
  void initState() {
    super.initState();
    // 默认选择最近的报告
    Future.microtask(() {
      if (!mounted) return;
      final reports = ref.read(reportsByPersonProvider(widget.personId));
      if (reports.isNotEmpty) {
        setState(() {
          _selectedReportId = reports.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(personsProvider).where((p) => p.id == widget.personId).firstOrNull;
    final reports = ref.watch(reportsByPersonProvider(widget.personId));
    final indicatorTypes = ref.watch(indicatorTypesByPersonProvider(widget.personId));

    if (person == null) {
      return Scaffold(body: Center(child: Text('未找到家人')));
    }

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text('${person.name}的健康报告 ✨'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像和名字
              Center(
                child: Column(
                  children: [
                    CrayonAvatar(
                      presetName: person.photoPath, // 暂用photoPath存储presetName
                      size: 80,
                    ),
                    const SizedBox(height: CrayonTheme.spacingSm),
                    Text(person.name, style: CrayonTheme.crayonTextTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingLg),

              // 报告选择器
              if (reports.isNotEmpty)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('选择报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      Wrap(
                        spacing: CrayonTheme.spacingSm,
                        children: reports.map((report) {
                          final isSelected = report.id == _selectedReportId;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedReportId = report.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingMd, vertical: CrayonTheme.spacingSm),
                              decoration: BoxDecoration(
                                color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.creamWhite,
                                borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                                border: Border.all(color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM').format(report.reportDate) + (isSelected ? ' ✨' : ''),
                                style: TextStyle(color: isSelected ? Colors.white : CrayonTheme.darkBrown, fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // 当前报告指标
              if (_selectedReportId != null)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 当前指标', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      _buildIndicatorList(_selectedReportId!),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // 指标类型选择器
              if (indicatorTypes.isNotEmpty)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📈 指标趋势', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      CrayonSegmentedButton<String>(
                        options: indicatorTypes.map((type) => SegmentOption.create(type, type)).toList(),
                        selectedValue: _selectedIndicatorType,
                        onSelectionChanged: (value) => setState(() => _selectedIndicatorType = value),
                      ),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      // 趋势图
                      IndicatorTrendChart(
                        indicatorType: _selectedIndicatorType,
                        dataPoints: ref.watch(indicatorHistoryProvider(
                          IndicatorQuery(personId: widget.personId, indicatorType: _selectedIndicatorType),
                        )),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // 空状态提示
              if (reports.isEmpty)
                CrayonCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 48, color: CrayonTheme.forestGreen),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      Text('暂无体检报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      Text('点击添加报告开始记录', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6))),
                      const SizedBox(height: CrayonTheme.spacingLg),
                      CrayonButton(
                        text: '添加报告',
                        icon: Icons.add,
                        onPressed: () => context.go('/reports/import'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorList(int reportId) {
    final indicators = ref.watch(indicatorsByReportProvider(reportId));

    if (indicators.isEmpty) {
      return const Text('暂无指标数据');
    }

    return Column(
      children: indicators.map((indicator) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: CrayonTheme.spacingSm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Icon(Icons.favorite, size: 18, color: CrayonTheme.forestGreen),
              ),
              const SizedBox(width: CrayonTheme.spacingMd),
              Text(indicator.type, style: const TextStyle(color: CrayonTheme.darkBrown)),
              const Spacer(),
              Text(
                _formatIndicatorValue(indicator),
                style: TextStyle(
                  color: indicator.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.darkBrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!indicator.isAbnormal)
                const Padding(padding: EdgeInsets.only(left: 4), child: Text('⭐', style: TextStyle(fontSize: 14))),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatIndicatorValue(HealthIndicator indicator) {
    if (indicator.secondValue != null) {
      return '${indicator.value.toInt()}/${indicator.secondValue!.toInt()} ${indicator.unit}';
    }
    return '${indicator.value.toStringAsFixed(1)} ${indicator.unit}';
  }
}