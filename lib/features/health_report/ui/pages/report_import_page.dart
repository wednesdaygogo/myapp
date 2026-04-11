import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_button.dart';
import '../../../../core/services/pdf_extraction_service.dart';
import '../../../../core/services/indicator_parser_service.dart';
import '../../../../data/models/health_indicator.dart';
import '../../../person/providers/person_provider.dart';
import '../../providers/health_report_provider.dart';

enum ImportPageStatus { idle, fileSelected, extracting, extracted, saving, success, error }

class ReportImportPage extends ConsumerStatefulWidget {
  const ReportImportPage({super.key});

  @override
  ConsumerState<ReportImportPage> createState() => _ReportImportPageState();
}

class _ReportImportPageState extends ConsumerState<ReportImportPage> {
  ImportPageStatus _status = ImportPageStatus.idle;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _fileName;
  String? _errorMessage;

  int? _selectedPersonId;
  DateTime _reportDate = DateTime.now();
  List<ParsedIndicator> _parsedIndicators = [];

  final _pdfService = PdfExtractionService();
  final _parserService = IndicatorParserService();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 20 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'PDF文件过大，最大支持20MB';
            _status = ImportPageStatus.error;
          });
          return;
        }

        setState(() {
          _fileName = file.name;
          _status = ImportPageStatus.fileSelected;
          _errorMessage = null;
          _parsedIndicators = [];
          if (kIsWeb) {
            _selectedFileBytes = file.bytes;
          } else {
            _selectedFilePath = file.path;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '选择文件失败: ${e.toString()}';
        _status = ImportPageStatus.error;
      });
    }
  }

  Future<void> _extractText() async {
    setState(() {
      _status = ImportPageStatus.extracting;
      _errorMessage = null;
    });

    try {
      PdfExtractionResult result;
      if (kIsWeb && _selectedFileBytes != null) {
        result = await _pdfService.extractText(_selectedFileBytes!);
      } else if (_selectedFilePath != null) {
        result = await _pdfService.extractTextFromPath(_selectedFilePath!);
      } else {
        setState(() {
          _errorMessage = '未选择文件';
          _status = ImportPageStatus.error;
        });
        return;
      }

      setState(() {
        if (result.success) {
          _parsedIndicators = _parserService.parseAll(result.text);
          _status = ImportPageStatus.extracted;
        } else {
          _errorMessage = result.errorMessage ?? '文本提取失败';
          _status = ImportPageStatus.error;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '提取失败: ${e.toString()}';
        _status = ImportPageStatus.error;
      });
    }
  }

  Future<void> _saveReport() async {
    if (_selectedPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择家庭成员')),
      );
      return;
    }

    setState(() => _status = ImportPageStatus.saving);

    try {
      final indicators = _parsedIndicators.map((parsed) {
        return HealthIndicator(
          id: 0,
          reportId: 0,
          type: _indicatorTypeToString(parsed.type),
          value: parsed.value,
          secondValue: parsed.secondValue,
          unit: parsed.unit,
          isAbnormal: parsed.isAbnormal,
        );
      }).toList();

      final reportId = await ref.read(healthReportsProvider.notifier).createReport(
        personId: _selectedPersonId!,
        reportDate: _reportDate,
        pdfPath: _selectedFilePath,
        fileName: _fileName,
        pdfBytes: _selectedFileBytes,
        source: 'pdf_import',
        indicators: indicators,
      );

      if (reportId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('体检报告已保存 ✨')),
          );
          context.go('/reports');
        }
      } else {
        setState(() {
          _errorMessage = '保存报告失败';
          _status = ImportPageStatus.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '保存失败: ${e.toString()}';
        _status = ImportPageStatus.error;
      });
    }
  }

  String _indicatorTypeToString(IndicatorType type) {
    switch (type) {
      case IndicatorType.bloodGlucose: return 'bloodGlucose';
      case IndicatorType.bloodPressure: return 'bloodPressure';
      case IndicatorType.bloodLipidTC: return 'bloodLipidTC';
      case IndicatorType.bloodLipidTG: return 'bloodLipidTG';
      case IndicatorType.bloodLipidHDL: return 'bloodLipidHDL';
      case IndicatorType.bloodLipidLDL: return 'bloodLipidLDL';
      case IndicatorType.custom: return 'custom';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() => _reportDate = picked);
    }
  }

  void _editIndicator(int index) {
    final indicator = _parsedIndicators[index];
    final nameController = TextEditingController(
      text: indicator.customName.isNotEmpty ? indicator.customName : _getIndicatorDisplayName(indicator.type),
    );
    final valueController = TextEditingController(text: indicator.value.toString());
    final secondValueController = TextEditingController(text: indicator.secondValue?.toString() ?? '');
    final unitController = TextEditingController(text: indicator.unit);
    bool isAbnormal = indicator.isAbnormal;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: CrayonTheme.creamWhite,
          title: Text('编辑指标', style: TextStyle(color: CrayonTheme.darkBrown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '指标名称')),
              const SizedBox(height: CrayonTheme.spacingSm),
              TextField(controller: valueController, decoration: const InputDecoration(labelText: '数值'), keyboardType: TextInputType.number),
              const SizedBox(height: CrayonTheme.spacingSm),
              TextField(controller: secondValueController, decoration: const InputDecoration(labelText: '第二数值'), keyboardType: TextInputType.number),
              const SizedBox(height: CrayonTheme.spacingSm),
              TextField(controller: unitController, decoration: const InputDecoration(labelText: '单位')),
              const SizedBox(height: CrayonTheme.spacingSm),
              Row(children: [const Text('是否异常：'), const Spacer(), Switch(value: isAbnormal, onChanged: (v) => setDialogState(() => isAbnormal = v))]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _parsedIndicators[index] = ParsedIndicator(
                    type: indicator.type,
                    value: double.tryParse(valueController.text) ?? 0,
                    secondValue: double.tryParse(secondValueController.text),
                    unit: unitController.text,
                    isAbnormal: isAbnormal,
                    customName: nameController.text,
                  );
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: CrayonTheme.forestGreen),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIndicator(int index) {
    setState(() => _parsedIndicators.removeAt(index));
  }

  void _addManualIndicator() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController();
    bool isAbnormal = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: CrayonTheme.creamWhite,
          title: Text('手动添加指标', style: TextStyle(color: CrayonTheme.darkBrown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '指标名称', hintText: '例如：血尿酸')),
              const SizedBox(height: CrayonTheme.spacingSm),
              TextField(controller: valueController, decoration: const InputDecoration(labelText: '数值'), keyboardType: TextInputType.number),
              const SizedBox(height: CrayonTheme.spacingSm),
              TextField(controller: unitController, decoration: const InputDecoration(labelText: '单位', hintText: '例如：mmol/L')),
              const SizedBox(height: CrayonTheme.spacingSm),
              Row(children: [const Text('是否异常：'), const Spacer(), Switch(value: isAbnormal, onChanged: (v) => setDialogState(() => isAbnormal = v))]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _parsedIndicators.add(ParsedIndicator(
                    type: IndicatorType.custom,
                    value: double.tryParse(valueController.text) ?? 0,
                    unit: unitController.text,
                    isAbnormal: isAbnormal,
                    customName: nameController.text,
                  ));
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: CrayonTheme.forestGreen),
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfPreview() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
          height: MediaQuery.of(ctx).size.height * 0.9,
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fileName ?? 'PDF预览', style: CrayonTheme.crayonTextTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: kIsWeb && _selectedFileBytes != null
                    ? PdfViewer(PdfDocumentRefData(_selectedFileBytes!, sourceName: _fileName ?? 'document.pdf'))
                    : _selectedFilePath != null
                        ? PdfViewer(PdfDocumentRefFile(_selectedFilePath!))
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final persons = ref.watch(personsProvider);

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: const Text('导入体检报告 📄'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: ListView(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          children: [
            // Step 1: Select PDF
            CrayonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1️⃣ 选择PDF文件', style: CrayonTheme.crayonTextTheme.titleMedium),
                  const SizedBox(height: CrayonTheme.spacingMd),
                  if (_fileName == null)
                    CrayonButton(text: '选择文件', icon: Icons.upload_file, onPressed: _pickPdfFile, isFullWidth: true)
                  else
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: CrayonTheme.brickRed),
                        const SizedBox(width: CrayonTheme.spacingSm),
                        Expanded(child: Text(_fileName!, style: const TextStyle(color: CrayonTheme.darkBrown))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() {
                          _fileName = null;
                          _selectedFilePath = null;
                          _selectedFileBytes = null;
                          _status = ImportPageStatus.idle;
                          _parsedIndicators = [];
                        })),
                      ],
                    ),
                  if (_status == ImportPageStatus.fileSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: CrayonTheme.spacingMd),
                      child: CrayonButton(text: '开始识别', icon: Icons.search, onPressed: _extractText, isFullWidth: true),
                    ),
                  if (_status == ImportPageStatus.extracting)
                    Padding(
                      padding: const EdgeInsets.only(top: CrayonTheme.spacingMd),
                      child: Row(children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: CrayonTheme.spacingSm),
                        Text('正在解析...', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.7))),
                      ]),
                    ),
                  if (_status == ImportPageStatus.extracted)
                    Padding(
                      padding: const EdgeInsets.only(top: CrayonTheme.spacingSm),
                      child: Text('已提取 ${_parsedIndicators.length} 个指标 ✨', style: const TextStyle(color: CrayonTheme.forestGreen)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: CrayonTheme.spacingMd),

            // Step 2: Select Person
            CrayonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('2️⃣ 选择家庭成员', style: CrayonTheme.crayonTextTheme.titleMedium),
                  const SizedBox(height: CrayonTheme.spacingMd),
                  if (persons.isEmpty)
                    Text('暂无家庭成员', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6)))
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPersonId,
                      decoration: InputDecoration(
                        labelText: '选择家人',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(CrayonTheme.radiusSm)),
                      ),
                      items: persons.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.relationship ?? "其他"})'))).toList(),
                      onChanged: (v) => setState(() => _selectedPersonId = v),
                    ),
                ],
              ),
            ),
            const SizedBox(height: CrayonTheme.spacingMd),

            // Step 3: Select Date
            CrayonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3️⃣ 设置体检时间', style: CrayonTheme.crayonTextTheme.titleMedium),
                  const SizedBox(height: CrayonTheme.spacingMd),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingMd, vertical: CrayonTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: CrayonTheme.creamWhite,
                        borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                        border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.calendar_today, color: CrayonTheme.forestGreen),
                            const SizedBox(width: CrayonTheme.spacingSm),
                            Text(_dateFormat.format(_reportDate), style: const TextStyle(color: CrayonTheme.darkBrown)),
                          ]),
                          const Icon(Icons.edit, color: CrayonTheme.forestGreen),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CrayonTheme.spacingMd),

            // Step 4: Indicators
            if (_status == ImportPageStatus.extracted)
              CrayonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4️⃣ 提取的健康指标', style: CrayonTheme.crayonTextTheme.titleMedium),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton.icon(onPressed: _showPdfPreview, icon: const Icon(Icons.picture_as_pdf), label: const Text('预览PDF'))),
                        const SizedBox(width: CrayonTheme.spacingSm),
                        Expanded(child: OutlinedButton.icon(onPressed: _addManualIndicator, icon: const Icon(Icons.add), label: const Text('手动添加'))),
                      ],
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    if (_parsedIndicators.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.all(CrayonTheme.spacingLg),
                        child: Column(children: [
                          Icon(Icons.info_outline, size: 48, color: CrayonTheme.mustardYellow),
                          const SizedBox(height: CrayonTheme.spacingSm),
                          Text('未提取到健康指标', style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6))),
                        ]),
                      ))
                    else
                      ..._parsedIndicators.asMap().entries.map((e) => _buildIndicatorItem(e.key, e.value)),
                  ],
                ),
              ),
            const SizedBox(height: CrayonTheme.spacingMd),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                decoration: BoxDecoration(
                  color: CrayonTheme.brickRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: CrayonTheme.brickRed),
                  const SizedBox(width: CrayonTheme.spacingSm),
                  Expanded(child: Text(_errorMessage!, style: TextStyle(color: CrayonTheme.brickRed))),
                ]),
              ),
            const SizedBox(height: CrayonTheme.spacingLg),

            // Save Button
            if (_status == ImportPageStatus.extracted)
              CrayonButton(text: '保存报告', icon: Icons.save, onPressed: _saveReport, isFullWidth: true),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorItem(int index, ParsedIndicator indicator) {
    final color = indicator.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.forestGreen;
    final name = indicator.customName.isNotEmpty ? indicator.customName : _getIndicatorDisplayName(indicator.type);
    final value = indicator.secondValue != null
        ? '${indicator.value}/${indicator.secondValue} ${indicator.unit}'
        : '${indicator.value} ${indicator.unit}';

    return Container(
      margin: const EdgeInsets.only(bottom: CrayonTheme.spacingSm),
      padding: const EdgeInsets.all(CrayonTheme.spacingSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
      ),
      child: Row(
        children: [
          Icon(_getIndicatorIcon(indicator.type), color: color, size: 20),
          const SizedBox(width: CrayonTheme.spacingSm),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: CrayonTheme.darkBrown, fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          )),
          IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => _editIndicator(index), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () => _deleteIndicator(index), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(CrayonTheme.radiusSm)),
            child: Text(indicator.isAbnormal ? '异常' : '正常', style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _getIndicatorDisplayName(IndicatorType type) {
    switch (type) {
      case IndicatorType.bloodGlucose: return '血糖';
      case IndicatorType.bloodPressure: return '血压';
      case IndicatorType.bloodLipidTC: return '总胆固醇';
      case IndicatorType.bloodLipidTG: return '甘油三酯';
      case IndicatorType.bloodLipidHDL: return '高密度脂蛋白';
      case IndicatorType.bloodLipidLDL: return '低密度脂蛋白';
      case IndicatorType.custom: return '自定义';
    }
  }

  IconData _getIndicatorIcon(IndicatorType type) {
    switch (type) {
      case IndicatorType.bloodGlucose: return Icons.bloodtype;
      case IndicatorType.bloodPressure: return Icons.favorite;
      case IndicatorType.bloodLipidTC: case IndicatorType.bloodLipidTG: case IndicatorType.bloodLipidHDL: case IndicatorType.bloodLipidLDL: return Icons.water_drop;
      case IndicatorType.custom: return Icons.edit_note;
    }
  }
}