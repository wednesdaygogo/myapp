import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/pdf_extraction_service.dart';
import '../../../../core/services/indicator_parser_service.dart';
import '../../../../data/models/health_indicator.dart';
import '../../../person/providers/person_provider.dart';
import '../../providers/health_report_provider.dart';

/// Import state for the page
enum ImportPageStatus {
  idle,
  fileSelected,
  extracting,
  extracted,
  saving,
  success,
  error,
}

class ReportImportPage extends ConsumerStatefulWidget {
  const ReportImportPage({super.key});

  @override
  ConsumerState<ReportImportPage> createState() => _ReportImportPageState();
}

class _ReportImportPageState extends ConsumerState<ReportImportPage> {
  ImportPageStatus _status = ImportPageStatus.idle;
  String? _selectedFilePath;
  String? _fileName;
  String _extractedText = '';
  String? _errorMessage;

  int? _selectedPersonId;
  DateTime _reportDate = DateTime.now();
  List<ParsedIndicator> _parsedIndicators = [];

  // PDF files in Documents directory
  List<File> _localPdfFiles = [];
  bool _showLocalFiles = false;

  final _pdfService = PdfExtractionService();
  final _parserService = IndicatorParserService();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _reportDate = DateTime.now();
    _loadLocalPdfFiles();
  }

  Future<void> _loadLocalPdfFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory(appDir.path);
      final files = await pdfDir.list().toList();
      final pdfFiles = files.where((f) => f.path.endsWith('.pdf')).toList();
      setState(() {
        _localPdfFiles = pdfFiles.map((f) => File(f.path)).toList();
      });
    } catch (e) {
      // Ignore error
    }
  }

  void _selectLocalFile(String path, String name) {
    setState(() {
      _selectedFilePath = path;
      _fileName = name;
      _status = ImportPageStatus.fileSelected;
      _errorMessage = null;
    });
    _extractText();
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFilePath = file.path!;
            _fileName = file.name;
            _status = ImportPageStatus.fileSelected;
            _errorMessage = null;
          });
          await _extractText();
        }
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
    });

    try {
      final result = await _pdfService.extractTextFromPath(_selectedFilePath!);

      setState(() {
        _extractedText = result.text;
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

    setState(() {
      _status = ImportPageStatus.saving;
    });

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

      final reportId =
          await ref.read(healthReportsProvider.notifier).createReport(
                personId: _selectedPersonId!,
                reportDate: _reportDate,
                pdfPath: _selectedFilePath,
                source: 'pdf_import',
                indicators: indicators,
              );

      if (reportId != null) {
        setState(() {
          _status = ImportPageStatus.success;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('体检报告已保存')),
        );

        context.go('/reports');
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
      case IndicatorType.bloodGlucose:
        return 'bloodGlucose';
      case IndicatorType.bloodPressure:
        return 'bloodPressure';
      case IndicatorType.bloodLipidTC:
        return 'bloodLipidTC';
      case IndicatorType.bloodLipidTG:
        return 'bloodLipidTG';
      case IndicatorType.bloodLipidHDL:
        return 'bloodLipidHDL';
      case IndicatorType.bloodLipidLDL:
        return 'bloodLipidLDL';
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
      setState(() {
        _reportDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final persons = ref.watch(personsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('导入体检报告'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: '1. 选择PDF文件',
              child: _selectedFilePath == null
                  ? Column(
                      children: [
                        // Show local PDF files if available
                        if (_localPdfFiles.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '本地PDF文件:',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              ...(_localPdfFiles.map((file) {
                                final fileName = file.path.split('/').last;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.picture_as_pdf,
                                        color: AppTheme.primaryColor),
                                    title: Text(fileName),
                                    subtitle: Text(
                                      '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary),
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                    tileColor: AppTheme.surfaceColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                      side: BorderSide(
                                          color: AppTheme.borderColor),
                                    ),
                                    onTap: () {
                                      _selectLocalFile(file.path, fileName);
                                    },
                                  ),
                                );
                              }).toList()),
                              const Divider(),
                              const SizedBox(height: AppTheme.spacingSm),
                            ],
                          ),
                        ElevatedButton.icon(
                          onPressed: _pickPdfFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('从文件系统选择'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileName ?? 'PDF文件',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (_status == ImportPageStatus.extracting)
                                  const Text(
                                    '正在提取文本...',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedFilePath = null;
                                _fileName = null;
                                _extractedText = '';
                                _parsedIndicators = [];
                                _status = ImportPageStatus.idle;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildSectionCard(
              title: '2. 选择家庭成员',
              child: persons.isEmpty
                  ? Text(
                      '暂无家庭成员，请先添加家人',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  : DropdownButtonFormField<int>(
                      value: _selectedPersonId,
                      decoration: const InputDecoration(
                        labelText: '选择家人',
                        border: OutlineInputBorder(),
                      ),
                      items: persons.map((person) {
                        return DropdownMenuItem(
                          value: person.id,
                          child: Text(
                              '${person.name} (${person.relationship ?? "其他"})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPersonId = value;
                        });
                      },
                    ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildSectionCard(
              title: '3. 设置体检时间',
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                    horizontal: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            _dateFormat.format(_reportDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.edit, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (_status == ImportPageStatus.extracted &&
                _extractedText.isNotEmpty)
              _buildSectionCard(
                title: '提取的原始文本',
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    _extractedText.length > 500
                        ? '${_extractedText.substring(0, 500)}...'
                        : _extractedText,
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.spacingMd),
            if (_parsedIndicators.isNotEmpty ||
                _status == ImportPageStatus.extracted)
              _buildSectionCard(
                title: '4. 提取的健康指标',
                child: _parsedIndicators.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline,
                                size: 48, color: AppTheme.textSecondary),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              '未从PDF中提取到健康指标',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              '请确保PDF包含可识别的文本格式的血压、血糖或血脂数据',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: _parsedIndicators.map((indicator) {
                          return _buildIndicatorCard(indicator);
                        }).toList(),
                      ),
              ),
            const SizedBox(height: AppTheme.spacingMd),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppTheme.spacingXl),
            if (_status == ImportPageStatus.extracted)
              ElevatedButton(
                onPressed: _saveReport,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('保存报告'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          child,
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(ParsedIndicator indicator) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              _getIndicatorIcon(indicator.type),
              color: color,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getIndicatorDisplayName(indicator.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAbnormal ? '异常' : '正常',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
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
}
