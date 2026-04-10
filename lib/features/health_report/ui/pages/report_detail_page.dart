import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/health_indicator.dart';
import '../../../../data/models/health_report.dart';
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
        appBar: AppBar(
          title: const Text('报告详情'),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
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
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
        actions: [
          if (report.pdfPath != null || report.fileName != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _showPdfPreview(context, report),
              tooltip: '预览 PDF',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, report.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
                report: report, person: person, dateFormat: dateFormat),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              '健康指标',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (indicators.isEmpty)
              _buildEmptyIndicators()
            else
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    child: OutlinedButton.icon(
                      onPressed: () => _editIndicators(context, indicators),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('编辑指标'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                  ...indicators
                      .map((indicator) => _buildIndicatorCard(indicator)),
                ],
              ),
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
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
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
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person?.relationship ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 0.5),
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
                  value: report.source == 'pdf_import' ? 'PDF 导入' : '手动录入',
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
        Icon(icon, size: 18, color: AppTheme.textTertiary),
        const SizedBox(width: AppTheme.spacingSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
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
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
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
            const Text(
              '暂无健康指标',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
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
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
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
              size: 24,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              isAbnormal ? '异常' : '正常',
              style: TextStyle(
                fontSize: 12,
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
      case IndicatorType.custom:
        return '自定义';
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
      case IndicatorType.custom:
        return Icons.edit_note;
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
          context.go('/reports'); // Navigate to report list instead of pop
        }
      }
    }
  }

  void _showPdfPreview(BuildContext context, HealthReport report) {
    // Web platform or no file path - show info dialog
    if (kIsWeb || report.pdfPath == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF报告'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('文件名: ${report.fileName ?? "未知"}'),
              const SizedBox(height: AppTheme.spacingMd),
              const Text(
                'Web平台暂不支持PDF预览。\n\n'
                '如需查看原始PDF文件，建议：\n'
                '• 在移动设备上打开此报告\n'
                '• 或重新从本地上传PDF文件',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
      return;
    }

    // Mobile platform with file path - show PDF viewer
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(report.fileName ?? 'PDF预览'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: PdfViewer.file(report.pdfPath!),
            ),
          ],
        ),
      ),
    );
  }

  void _editIndicators(BuildContext context, List<HealthIndicator> indicators) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _IndicatorEditPage(
          reportId: widget.reportId,
          indicators: indicators,
        ),
      ),
    );
  }
}

/// Indicator editing page
class _IndicatorEditPage extends ConsumerStatefulWidget {
  final int reportId;
  final List<HealthIndicator> indicators;

  const _IndicatorEditPage({
    required this.reportId,
    required this.indicators,
  });

  @override
  ConsumerState<_IndicatorEditPage> createState() => _IndicatorEditPageState();
}

class _IndicatorEditPageState extends ConsumerState<_IndicatorEditPage> {
  late List<Map<String, dynamic>> _editedIndicators;

  @override
  void initState() {
    super.initState();
    _editedIndicators = widget.indicators
        .map((i) => {
              'id': i.id,
              'type': i.type,
              'value': i.value,
              'secondValue': i.secondValue,
              'unit': i.unit,
              'isAbnormal': i.isAbnormal,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑指标'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
        actions: [
          TextButton.icon(
            onPressed: _addNewIndicator,
            icon: const Icon(Icons.add),
            label: const Text('添加'),
          ),
        ],
      ),
      body: _editedIndicators.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Text(
                    '暂无指标',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _addNewIndicator,
                    icon: const Icon(Icons.add),
                    label: const Text('添加指标'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: _editedIndicators.length,
              itemBuilder: (context, index) {
                return _buildIndicatorEditCard(index);
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: ElevatedButton(
            onPressed: _saveIndicators,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('保存'),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorEditCard(int index) {
    final indicator = _editedIndicators[index];
    final type = indicator['type'] as String;
    final isBP = type == 'bloodPressure';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '指标 ${index + 1}: ${_getTypeName(type)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _deleteIndicator(index),
                  color: AppTheme.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: indicator['value'].toString(),
                    decoration: InputDecoration(
                      labelText: isBP ? '收缩压' : '数值',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final numValue = double.tryParse(value);
                      if (numValue != null) {
                        setState(() {
                          _editedIndicators[index]['value'] = numValue;
                          _editedIndicators[index]['isAbnormal'] =
                              _checkIfAbnormal(type, numValue,
                                  indicator['secondValue'] as double?);
                        });
                      }
                    },
                  ),
                ),
                if (isBP) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  const Text('/'),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          (indicator['secondValue'] as double?)?.toString() ??
                              '',
                      decoration: const InputDecoration(
                        labelText: '舒张压',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final numValue = double.tryParse(value);
                        if (numValue != null) {
                          setState(() {
                            _editedIndicators[index]['secondValue'] = numValue;
                            _editedIndicators[index]['isAbnormal'] =
                                _checkIfAbnormal(type,
                                    indicator['value'] as double, numValue);
                          });
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(width: AppTheme.spacingSm),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: indicator['unit'] as String,
                    decoration: const InputDecoration(
                      labelText: '单位',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingSm,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _editedIndicators[index]['unit'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'bloodGlucose':
        return '血糖';
      case 'bloodPressure':
        return '血压';
      case 'bloodLipidTC':
        return '总胆固醇';
      case 'bloodLipidTG':
        return '甘油三酯';
      case 'bloodLipidHDL':
        return '高密度脂蛋白';
      case 'bloodLipidLDL':
        return '低密度脂蛋白';
      default:
        return type;
    }
  }

  void _addNewIndicator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加指标'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('血糖'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _editedIndicators.add({
                    'id': 0,
                    'type': 'bloodGlucose',
                    'value': 5.0,
                    'secondValue': null,
                    'unit': 'mmol/L',
                    'isAbnormal': false,
                  });
                });
              },
            ),
            ListTile(
              title: const Text('血压'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _editedIndicators.add({
                    'id': 0,
                    'type': 'bloodPressure',
                    'value': 120.0,
                    'secondValue': 80.0,
                    'unit': 'mmHg',
                    'isAbnormal': false,
                  });
                });
              },
            ),
            ListTile(
              title: const Text('总胆固醇'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _editedIndicators.add({
                    'id': 0,
                    'type': 'bloodLipidTC',
                    'value': 4.5,
                    'secondValue': null,
                    'unit': 'mmol/L',
                    'isAbnormal': false,
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIndicator(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除指标'),
        content: const Text('确定要删除这个指标吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _editedIndicators.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  bool _checkIfAbnormal(String type, double value, double? secondValue) {
    switch (type) {
      case 'bloodGlucose':
        return value < 3.9 || value > 6.1;
      case 'bloodPressure':
        return value > 140 || (secondValue != null && secondValue > 90);
      case 'bloodLipidTC':
        return value > 5.2;
      case 'bloodLipidTG':
        return value > 1.7;
      case 'bloodLipidHDL':
        return value < 1.0;
      case 'bloodLipidLDL':
        return value > 3.4;
      default:
        return false;
    }
  }

  Future<void> _saveIndicators() async {
    try {
      final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);

      // Delete existing indicators
      final existingIds = widget.indicators.map((i) => i.id).toList();
      for (final id in existingIds) {
        await indicatorBox.delete(id);
      }

      // Save new indicators
      int maxId = indicatorBox.isEmpty
          ? 0
          : indicatorBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);

      for (final data in _editedIndicators) {
        maxId++;
        final indicator = HealthIndicator(
          id: maxId,
          reportId: widget.reportId,
          type: data['type'] as String,
          value: data['value'] as double,
          secondValue: data['secondValue'] as double?,
          unit: data['unit'] as String,
          isAbnormal: data['isAbnormal'] as bool,
        );
        await indicatorBox.put(maxId, indicator);
      }

      // Refresh providers
      ref.invalidate(indicatorsByReportProvider(widget.reportId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指标已保存')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
