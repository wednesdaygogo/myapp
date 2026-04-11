// lib/features/health_report/ui/pages/person_report_detail_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import '../../providers/health_report_provider.dart' hide healthIndicatorsBoxName;
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
        actions: [
          if (_selectedReportId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeleteReport(context, _selectedReportId!),
              tooltip: '删除报告',
            ),
        ],
      ),
      body: CrayonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 头像和名字
              Center(
                child: Column(
                  children: [
                    CrayonAvatar(
                      presetName: person.photoPath,
                      size: 80,
                    ),
                    const SizedBox(height: CrayonTheme.spacingSm),
                    Text(person.name, style: CrayonTheme.crayonTextTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingLg),

              // 空状态提示
              if (reports.isEmpty)
                CrayonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(CrayonTheme.spacingLg),
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
                ),

              // 报告选择器（下拉框+预览按钮）
              if (reports.isNotEmpty)
                CrayonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder, color: CrayonTheme.mustardYellow, size: 20),
                            const SizedBox(width: 8),
                            Text('选择报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: CrayonTheme.spacingMd),
                        Row(
                          children: [
                            // 下拉框选择报告（蜡笔风格）
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: CrayonTheme.spacingMd,
                                  vertical: CrayonTheme.spacingSm,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
                                  border: Border.all(
                                    color: CrayonTheme.darkBrown.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButton<int>(
                                  value: _selectedReportId,
                                  isExpanded: true,
                                  underline: const SizedBox(), // 移除默认下划线
                                  icon: Icon(Icons.arrow_drop_down, color: CrayonTheme.forestGreen),
                                  dropdownColor: Colors.white,
                                  style: TextStyle(
                                    color: CrayonTheme.darkBrown,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: reports.map((report) {
                                    return DropdownMenuItem(
                                      value: report.id,
                                      child: Row(
                                        children: [
                                          Icon(Icons.description, color: CrayonTheme.mustardYellow, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(report.reportDate),
                                            style: TextStyle(color: CrayonTheme.darkBrown),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedReportId = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            // 预览按钮在右边
                            if (_selectedReportId != null)
                              Padding(
                                padding: const EdgeInsets.only(left: CrayonTheme.spacingSm),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CrayonTheme.brickRed.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
                                    border: Border.all(
                                      color: CrayonTheme.brickRed.withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.picture_as_pdf, color: CrayonTheme.brickRed),
                                    onPressed: () => _showPdfPreview(context, reports.firstWhere((r) => r.id == _selectedReportId)),
                                    tooltip: '预览PDF',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // 当前报告指标（宽度统一）
              if (_selectedReportId != null)
                CrayonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: CrayonTheme.brickRed, size: 20),
                                const SizedBox(width: 8),
                                Text('当前指标', style: CrayonTheme.crayonTextTheme.titleMedium),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _editIndicators(context, _selectedReportId!),
                                  tooltip: '编辑指标',
                                  color: CrayonTheme.forestGreen,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () => _addIndicator(context, _selectedReportId!),
                                  tooltip: '添加指标',
                                  color: CrayonTheme.forestGreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: CrayonTheme.spacingMd),
                        _buildIndicatorList(_selectedReportId!),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // 指标趋势（宽度统一）
              if (indicatorTypes.isNotEmpty)
                CrayonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: CrayonTheme.forestGreen, size: 20),
                            const SizedBox(width: 8),
                            Text('指标趋势', style: CrayonTheme.crayonTextTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: CrayonTheme.spacingSm),
                        CrayonSegmentedButton<String>(
                          options: indicatorTypes.map((type) => SegmentOption.create(type, type)).toList(),
                          selectedValue: _selectedIndicatorType,
                          onSelectionChanged: (value) => setState(() => _selectedIndicatorType = value),
                        ),
                        const SizedBox(height: CrayonTheme.spacingMd),
                        IndicatorTrendChart(
                          indicatorType: _selectedIndicatorType,
                          dataPoints: ref.watch(indicatorHistoryProvider(
                            IndicatorQuery(personId: widget.personId, indicatorType: _selectedIndicatorType),
                          )),
                        ),
                      ],
                    ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Text('暂无指标数据', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6))),
        ),
      );
    }

    return Column(
      children: indicators.map((indicator) {
        // 转换英文类型为中文显示名
        final displayName = _getIndicatorDisplayName(indicator.type);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: CrayonTheme.spacingSm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: indicator.isAbnormal
                    ? CrayonTheme.brickRed.withValues(alpha: 0.1)
                    : CrayonTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Icon(
                  _getIndicatorIcon(indicator.type),
                  size: 18,
                  color: indicator.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.forestGreen,
                ),
              ),
              const SizedBox(width: CrayonTheme.spacingMd),
              Expanded(
                child: Text(displayName, style: const TextStyle(color: CrayonTheme.darkBrown)),
              ),
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

  /// 获取指标图标
  IconData _getIndicatorIcon(String type) {
    switch (type) {
      case 'bloodGlucose': return Icons.bloodtype;
      case 'bloodPressure': return Icons.favorite;
      case 'bloodLipidTC':
      case 'bloodLipidTG':
      case 'bloodLipidHDL':
      case 'bloodLipidLDL':
        return Icons.water_drop;
      default: return Icons.edit_note;
    }
  }

  String _formatIndicatorValue(HealthIndicator indicator) {
    if (indicator.secondValue != null) {
      return '${indicator.value.toInt()}/${indicator.secondValue!.toInt()} ${indicator.unit}';
    }
    return '${indicator.value.toStringAsFixed(1)} ${indicator.unit}';
  }

  Future<void> _confirmDeleteReport(BuildContext context, int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text('确认删除', style: TextStyle(color: CrayonTheme.darkBrown)),
        content: Text('确定要删除这份体检报告吗？此操作不可撤销。', style: TextStyle(color: CrayonTheme.darkBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消', style: TextStyle(color: CrayonTheme.darkBrown)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: CrayonTheme.brickRed),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(healthReportsProvider.notifier).deleteReport(reportId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? '报告已删除' : '删除失败')),
        );
        if (success) {
          // 更新选中的报告
          final reports = ref.read(reportsByPersonProvider(widget.personId));
          setState(() {
            _selectedReportId = reports.isNotEmpty ? reports.first.id : null;
          });
        }
      }
    }
  }

  void _showPdfPreview(BuildContext context, dynamic report) {
    if (kIsWeb || report.pdfPath == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: CrayonTheme.creamWhite,
          title: Text('PDF报告', style: TextStyle(color: CrayonTheme.darkBrown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('文件名: ${report.fileName ?? "未知"}', style: TextStyle(color: CrayonTheme.darkBrown)),
              const SizedBox(height: CrayonTheme.spacingMd),
              Text(
                'Web平台暂不支持PDF预览。',
                style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('关闭', style: TextStyle(color: CrayonTheme.forestGreen)),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: CrayonTheme.creamWhite,
              title: Text(report.fileName ?? 'PDF预览', style: TextStyle(color: CrayonTheme.darkBrown)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: CrayonTheme.darkBrown),
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

  void _editIndicators(BuildContext context, int reportId) {
    final indicators = ref.read(indicatorsByReportProvider(reportId));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _IndicatorEditPage(
          reportId: reportId,
          indicators: indicators,
          onSave: () {
            ref.invalidate(indicatorsByReportProvider(reportId));
          },
        ),
      ),
    );
  }

  void _addIndicator(BuildContext context, int reportId) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final secondValueController = TextEditingController();
    final unitController = TextEditingController(text: 'mmol/L');
    bool isAbnormal = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: CrayonTheme.creamWhite,
          title: Text('添加指标', style: TextStyle(color: CrayonTheme.darkBrown)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '指标名称',
                    hintText: '例如：血糖',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: '数值',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: secondValueController,
                  decoration: InputDecoration(
                    labelText: '第二数值（可选，如血压舒张压）',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: '单位',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                Row(
                  children: [
                    Text('是否异常：', style: TextStyle(color: CrayonTheme.darkBrown)),
                    const Spacer(),
                    Switch(
                      value: isAbnormal,
                      activeColor: CrayonTheme.brickRed,
                      onChanged: (value) {
                        setDialogState(() {
                          isAbnormal = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: CrayonTheme.darkBrown)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final value = double.tryParse(valueController.text);
                final secondValue = double.tryParse(secondValueController.text);
                final unit = unitController.text.trim();

                if (name.isEmpty || value == null || unit.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写完整信息')),
                  );
                  return;
                }

                try {
                  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);
                  int maxId = indicatorBox.isEmpty
                      ? 0
                      : indicatorBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
                  maxId++;

                  final indicator = HealthIndicator(
                    id: maxId,
                    reportId: reportId,
                    type: name,
                    value: value,
                    secondValue: secondValue,
                    unit: unit,
                    isAbnormal: isAbnormal,
                  );
                  await indicatorBox.put(maxId, indicator);

                  ref.invalidate(indicatorsByReportProvider(reportId));

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('指标已添加')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('添加失败: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CrayonTheme.forestGreen,
              ),
              child: const Text('添加', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicator editing page
class _IndicatorEditPage extends ConsumerStatefulWidget {
  final int reportId;
  final List<HealthIndicator> indicators;
  final VoidCallback? onSave;

  const _IndicatorEditPage({
    required this.reportId,
    required this.indicators,
    this.onSave,
  });

  @override
  ConsumerState<_IndicatorEditPage> createState() => _IndicatorEditPageState();
}

class _IndicatorEditPageState extends ConsumerState<_IndicatorEditPage> {
  late List<Map<String, dynamic>> _editedIndicators;

  @override
  void initState() {
    super.initState();
    _editedIndicators = widget.indicators.map((i) => {
      'id': i.id,
      'type': i.type,
      'value': i.value,
      'secondValue': i.secondValue,
      'unit': i.unit,
      'isAbnormal': i.isAbnormal,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text('编辑指标', style: TextStyle(color: CrayonTheme.darkBrown)),
        foregroundColor: CrayonTheme.darkBrown,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewIndicator,
            tooltip: '添加指标',
          ),
        ],
      ),
      body: _editedIndicators.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: CrayonTheme.forestGreen),
                  const SizedBox(height: CrayonTheme.spacingMd),
                  Text('暂无指标', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6))),
                  const SizedBox(height: CrayonTheme.spacingMd),
                  CrayonButton(
                    text: '添加指标',
                    icon: Icons.add,
                    onPressed: _addNewIndicator,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(CrayonTheme.spacingMd),
              itemCount: _editedIndicators.length,
              itemBuilder: (context, index) {
                return _buildIndicatorEditCard(index);
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: CrayonButton(
            text: '保存',
            icon: Icons.save,
            isFullWidth: true,
            onPressed: _saveIndicators,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorEditCard(int index) {
    final indicator = _editedIndicators[index];
    final type = indicator['type'] as String;
    final hasSecondValue = indicator['secondValue'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
        border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingMd, vertical: CrayonTheme.spacingSm),
            decoration: BoxDecoration(
              color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(CrayonTheme.radiusMd)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '指标 ${index + 1}: $type',
                  style: TextStyle(color: CrayonTheme.darkBrown, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: CrayonTheme.brickRed),
                  onPressed: () => _deleteIndicator(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(CrayonTheme.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: indicator['value'].toString()),
                    decoration: InputDecoration(
                      labelText: hasSecondValue ? '收缩压' : '数值',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final numValue = double.tryParse(value);
                      if (numValue != null) {
                        setState(() {
                          _editedIndicators[index]['value'] = numValue;
                        });
                      }
                    },
                  ),
                ),
                if (hasSecondValue) ...[
                  const SizedBox(width: CrayonTheme.spacingSm),
                  const Text('/', style: TextStyle(color: CrayonTheme.darkBrown)),
                  const SizedBox(width: CrayonTheme.spacingSm),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: (indicator['secondValue'] as double?)?.toString() ?? ''),
                      decoration: InputDecoration(
                        labelText: '舒张压',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final numValue = double.tryParse(value);
                        if (numValue != null) {
                          setState(() {
                            _editedIndicators[index]['secondValue'] = numValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(width: CrayonTheme.spacingSm),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: TextEditingController(text: indicator['unit'] as String),
                    decoration: InputDecoration(
                      labelText: '单位',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
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
          Padding(
            padding: const EdgeInsets.only(left: CrayonTheme.spacingMd, right: CrayonTheme.spacingMd, bottom: CrayonTheme.spacingMd),
            child: Row(
              children: [
                Text('是否异常：', style: TextStyle(color: CrayonTheme.darkBrown)),
                const Spacer(),
                Switch(
                  value: indicator['isAbnormal'] as bool,
                  activeColor: CrayonTheme.brickRed,
                  onChanged: (value) {
                    setState(() {
                      _editedIndicators[index]['isAbnormal'] = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteIndicator(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text('删除指标', style: TextStyle(color: CrayonTheme.darkBrown)),
        content: Text('确定要删除这个指标吗？', style: TextStyle(color: CrayonTheme.darkBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: CrayonTheme.darkBrown)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _editedIndicators.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: CrayonTheme.brickRed),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _addNewIndicator() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final secondValueController = TextEditingController();
    final unitController = TextEditingController(text: 'mmol/L');
    bool isAbnormal = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: CrayonTheme.creamWhite,
          title: Text('添加指标', style: TextStyle(color: CrayonTheme.darkBrown)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '指标名称',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: '数值',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: secondValueController,
                  decoration: InputDecoration(
                    labelText: '第二数值（可选）',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: '单位',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: CrayonTheme.spacingMd),
                Row(
                  children: [
                    Text('是否异常：', style: TextStyle(color: CrayonTheme.darkBrown)),
                    const Spacer(),
                    Switch(
                      value: isAbnormal,
                      activeColor: CrayonTheme.brickRed,
                      onChanged: (value) {
                        setDialogState(() {
                          isAbnormal = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: CrayonTheme.darkBrown)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final value = double.tryParse(valueController.text);
                final secondValue = double.tryParse(secondValueController.text);
                final unit = unitController.text.trim();

                if (name.isEmpty || value == null || unit.isEmpty) {
                  return;
                }

                Navigator.pop(context);
                setState(() {
                  _editedIndicators.add({
                    'id': 0,
                    'type': name,
                    'value': value,
                    'secondValue': secondValue,
                    'unit': unit,
                    'isAbnormal': isAbnormal,
                  });
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: CrayonTheme.forestGreen),
              child: const Text('添加', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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

      widget.onSave?.call();

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