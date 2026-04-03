import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
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
  Uint8List? _selectedFileBytes; // For web platform
  String? _fileName;
  String _extractedText = '';
  String? _errorMessage;

  int? _selectedPersonId;
  DateTime _reportDate = DateTime.now();
  List<ParsedIndicator> _parsedIndicators = [];

// PDF files in Documents directory
  List<File> _localPdfFiles = [];

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
    // Skip on web platform (path_provider not available)
    if (kIsWeb) return;

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
      _extractedText = '';
      _parsedIndicators = [];
    });
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Required for web platform to get bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (20MB limit)
        if (file.size > 20 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'PDF文件过大，最大支持20MB';
            _status = ImportPageStatus.error;
          });
          return;
        }

        if (kIsWeb) {
          // Web platform: use bytes directly
          if (file.bytes != null) {
            debugPrint(
                'Web平台选择文件: ${file.name}, bytes length: ${file.bytes!.length}');
            setState(() {
              _selectedFileBytes = file.bytes;
              _fileName = file.name;
              _status = ImportPageStatus.fileSelected;
              _errorMessage = null;
              _extractedText = '';
              _parsedIndicators = [];
            });
            debugPrint('状态已设置为: $_status');
          } else {
            setState(() {
              _errorMessage = '无法读取文件内容';
              _status = ImportPageStatus.error;
            });
          }
        } else {
          // Mobile platform: use path
          if (file.path != null) {
            debugPrint('移动平台选择文件: ${file.path}');
            setState(() {
              _selectedFilePath = file.path!;
              _fileName = file.name;
              _status = ImportPageStatus.fileSelected;
              _errorMessage = null;
              _extractedText = '';
              _parsedIndicators = [];
            });
            debugPrint('状态已设置为: $_status');
          }
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
      _errorMessage = null;
    });

    try {
      PdfExtractionResult result;

      if (kIsWeb && _selectedFileBytes != null) {
        // Web platform: extract from bytes
        result = await _pdfService.extractText(_selectedFileBytes!);
      } else if (_selectedFilePath != null) {
        // Mobile platform: extract from path
        result = await _pdfService.extractTextFromPath(_selectedFilePath!);
      } else {
        setState(() {
          _errorMessage = '未选择文件';
          _status = ImportPageStatus.error;
        });
        return;
      }

      setState(() {
        _extractedText = result.text;
        if (result.success) {
          _parsedIndicators = _parserService.parseAll(result.text);
          _status = ImportPageStatus.extracted;
          if (result.errorMessage != null) {
            // Show warning but continue
            _errorMessage = result.errorMessage;
          }
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

      // On web, pdfPath will be null (file not persisted to filesystem)
      final pdfPath = kIsWeb ? null : _selectedFilePath;
      final fileName = _fileName; // Save original filename

      final reportId =
          await ref.read(healthReportsProvider.notifier).createReport(
                personId: _selectedPersonId!,
                reportDate: _reportDate,
                pdfPath: pdfPath,
                source: 'pdf_import',
                indicators: indicators,
                fileName: fileName,
              );

      if (reportId != null) {
        setState(() {
          _status = ImportPageStatus.success;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('体检报告已保存')),
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

  void _editIndicator(int index) {
    final indicator = _parsedIndicators[index];
    final nameController = TextEditingController(
      text: indicator.customName.isNotEmpty
          ? indicator.customName
          : _getIndicatorDisplayName(indicator.type),
    );
    final valueController = TextEditingController(
      text: indicator.value.toString(),
    );
    final secondValueController = TextEditingController(
      text: indicator.secondValue?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑指标'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '指标名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: indicator.secondValue != null ? '收缩压' : '数值',
                  border: const OutlineInputBorder(),
                  suffixText: indicator.unit,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              if (indicator.secondValue != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: secondValueController,
                  decoration: InputDecoration(
                    labelText: '舒张压',
                    border: const OutlineInputBorder(),
                    suffixText: indicator.unit,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(valueController.text);
              final newSecondValue = indicator.secondValue != null
                  ? double.tryParse(secondValueController.text)
                  : null;

              if (newValue != null) {
                setState(() {
                  _parsedIndicators[index] = ParsedIndicator(
                    type: indicator.type,
                    value: newValue,
                    secondValue: newSecondValue,
                    unit: indicator.unit,
                    isAbnormal: _checkIfAbnormal(
                        indicator.type, newValue, newSecondValue),
                    customName: nameController.text,
                  );
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效的数值')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  bool _checkIfAbnormal(IndicatorType type, double value, double? secondValue) {
    switch (type) {
      case IndicatorType.bloodGlucose:
        return value < 3.9 || value > 6.1;
      case IndicatorType.bloodPressure:
        return value > 140 || (secondValue ?? 0) > 90;
      case IndicatorType.bloodLipidTC:
        return value > 5.2;
      case IndicatorType.bloodLipidTG:
        return value > 1.7;
      case IndicatorType.bloodLipidHDL:
        return value < 1.0;
      case IndicatorType.bloodLipidLDL:
        return value > 3.4;
    }
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
          ElevatedButton(
            onPressed: () {
              setState(() {
                _parsedIndicators.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showPdfPreviewDialog() {
    if (kIsWeb && _selectedFileBytes != null) {
      // Web: Use PdfViewer from bytes
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fileName ?? 'PDF预览',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: PdfViewer(
                    PdfDocumentRefData(
                      _selectedFileBytes!,
                      sourceName: _fileName ?? 'document.pdf',
                    ),
                    params: const PdfViewerParams(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (!kIsWeb && _selectedFilePath != null) {
      // Mobile: Use PdfViewer from file
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fileName ?? 'PDF预览',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: PdfViewer(
                    PdfDocumentRefFile(_selectedFilePath!),
                    params: const PdfViewerParams(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _addManualIndicator() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController(text: 'mmol/L');
    IndicatorType selectedType = IndicatorType.bloodGlucose;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('手动添加指标'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<IndicatorType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: '指标类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: IndicatorType.bloodGlucose,
                      child: Text('血糖'),
                    ),
                    DropdownMenuItem(
                      value: IndicatorType.bloodPressure,
                      child: Text('血压'),
                    ),
                    DropdownMenuItem(
                      value: IndicatorType.bloodLipidTC,
                      child: Text('总胆固醇(TC)'),
                    ),
                    DropdownMenuItem(
                      value: IndicatorType.bloodLipidTG,
                      child: Text('甘油三酯(TG)'),
                    ),
                    DropdownMenuItem(
                      value: IndicatorType.bloodLipidHDL,
                      child: Text('高密度脂蛋白(HDL)'),
                    ),
                    DropdownMenuItem(
                      value: IndicatorType.bloodLipidLDL,
                      child: Text('低密度脂蛋白(LDL)'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                      unitController.text =
                          selectedType == IndicatorType.bloodPressure
                              ? 'mmHg'
                              : 'mmol/L';
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '自定义名称（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: selectedType == IndicatorType.bloodPressure
                        ? '收缩压'
                        : '数值',
                    border: const OutlineInputBorder(),
                    suffixText: unitController.text,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: '单位',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(valueController.text);
                if (value != null) {
                  final newIndicator = ParsedIndicator(
                    type: selectedType,
                    value: value,
                    unit: unitController.text,
                    isAbnormal: _checkIfAbnormal(selectedType, value, null),
                    customName: nameController.text.isNotEmpty
                        ? nameController.text
                        : _getIndicatorDisplayName(selectedType),
                  );
                  setState(() {
                    _parsedIndicators.add(newIndicator);
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效的数值')),
                  );
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
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
              child: (_selectedFilePath == null && _selectedFileBytes == null)
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
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
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
                                    // Debug: 显示当前状态
                                    Text(
                                      '状态: $_status',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    if (_status == ImportPageStatus.extracting)
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                          const SizedBox(
                                              width: AppTheme.spacingSm),
                                          Text(
                                            '正在识别中...',
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    if (_status == ImportPageStatus.extracted)
                                      Text(
                                        '已提取 ${_parsedIndicators.length} 个指标',
                                        style: const TextStyle(
                                            color: AppTheme.successColor),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed:
                                    _status == ImportPageStatus.extracting
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedFilePath = null;
                                              _selectedFileBytes = null;
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
                        if (_status == ImportPageStatus.fileSelected)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppTheme.spacingMd),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                debugPrint('开始识别按钮被点击，当前状态: $_status');
                                _extractText();
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('开始识别'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        if (_status == ImportPageStatus.extracting)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppTheme.spacingMd),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: AppTheme.spacingMd),
                                  Text('正在解析PDF，请稍候...'),
                                ],
                              ),
                            ),
                          ),
                      ],
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
                      initialValue: _selectedPersonId,
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
                child: Column(
                  children: [
                    // PDF Preview and Add Manual buttons
                    if ((_selectedFileBytes != null ||
                        _selectedFilePath != null))
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showPdfPreviewDialog,
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('预览PDF'),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _addManualIndicator,
                                icon: const Icon(Icons.add),
                                label: const Text('手动添加'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Indicator list or empty state
                    _parsedIndicators.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: Column(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 48, color: AppTheme.textSecondary),
                                const SizedBox(height: AppTheme.spacingSm),
                                Text(
                                  '未从PDF中提取到健康指标',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary),
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
                  ],
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

    final index = _parsedIndicators.indexOf(indicator);

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
                  indicator.customName.isNotEmpty
                      ? indicator.customName
                      : _getIndicatorDisplayName(indicator.type),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editIndicator(index),
                tooltip: '编辑',
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.errorColor),
                onPressed: () => _deleteIndicator(index),
                tooltip: '删除',
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
