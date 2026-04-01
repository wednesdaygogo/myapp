import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/health_indicator.dart';
import '../../../../domain/entities/indicator_entity.dart';
import '../../../person/providers/person_provider.dart';
import '../../providers/health_report_provider.dart';

class ReportDetailPage extends ConsumerStatefulWidget {
  final int reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedReportIdProvider.notifier).state = widget.reportId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(selectedReportProvider);
    final indicators = ref.watch(indicatorsByReportProvider(widget.reportId));
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('报告详情')),
        body: const Center(child: Text('未找到报告')),
      );
    }

    final person = ref
        .watch(personsProvider)
        .where((p) => p.id == report.personId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('报告详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, report.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report info card
            _buildInfoCard(
                report: report, person: person, dateFormat: dateFormat),

            const SizedBox(height: AppTheme.spacingLg),

            // Indicators section
            Text(
              '健康指标',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            if (indicators.isEmpty)
              _buildEmptyIndicators()
            else
              ...indicators.map((indicator) => _buildIndicatorCard(indicator)),

            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required report,
    required person,
    required DateFormat dateFormat,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person?.name ?? '未知',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      person?.relationship ?? '',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingXl),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: '体检日期',
                  value: dateFormat.format(report.reportDate),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.source,
                  label: '来源',
                  value: report.source == 'pdf_import' ? 'PDF导入' : '手动录入',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spacingSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyIndicators() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              '暂无健康指标',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard(HealthIndicator indicator) {
    final type = _getIndicatorType(indicator.type);
    final isAbnormal = indicator.isAbnormal;
    final color = isAbnormal ? AppTheme.errorColor : AppTheme.successColor;
    final bgColor = isAbnormal ? AppTheme.errorLight : AppTheme.successLight;

    String displayValue;
    if (indicator.secondValue != null) {
      displayValue =
          '${indicator.value}/${indicator.secondValue} ${indicator.unit}';
    } else {
      displayValue = '${indicator.value} ${indicator.unit}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              _getIndicatorIcon(type),
              color: color,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getIndicatorDisplayName(type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAbnormal ? '异常' : '正常',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IndicatorType _getIndicatorType(String typeString) {
    switch (typeString) {
      case 'bloodGlucose':
        return IndicatorType.bloodGlucose;
      case 'bloodPressure':
        return IndicatorType.bloodPressure;
      case 'bloodLipidTC':
        return IndicatorType.bloodLipidTC;
      case 'bloodLipidTG':
        return IndicatorType.bloodLipidTG;
      case 'bloodLipidHDL':
        return IndicatorType.bloodLipidHDL;
      case 'bloodLipidLDL':
        return IndicatorType.bloodLipidLDL;
      default:
        return IndicatorType.bloodGlucose;
    }
  }

  String _getIndicatorDisplayName(IndicatorType type) {
    switch (type) {
      case IndicatorType.bloodGlucose:
        return '血糖';
      case IndicatorType.bloodPressure:
        return '血压';
      case IndicatorType.bloodLipidTC:
        return '总胆固醇(TC)';
      case IndicatorType.bloodLipidTG:
        return '甘油三酯(TG)';
      case IndicatorType.bloodLipidHDL:
        return '高密度脂蛋白(HDL)';
      case IndicatorType.bloodLipidLDL:
        return '低密度脂蛋白(LDL)';
    }
  }

  IconData _getIndicatorIcon(IndicatorType type) {
    switch (type) {
      case IndicatorType.bloodGlucose:
        return Icons.bloodtype;
      case IndicatorType.bloodPressure:
        return Icons.favorite;
      case IndicatorType.bloodLipidTC:
      case IndicatorType.bloodLipidTG:
      case IndicatorType.bloodLipidHDL:
      case IndicatorType.bloodLipidLDL:
        return Icons.water_drop;
    }
  }

  Future<void> _confirmDelete(BuildContext context, int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这份体检报告吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await ref.read(healthReportsProvider.notifier).deleteReport(reportId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? '报告已删除' : '删除失败')),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }
}
