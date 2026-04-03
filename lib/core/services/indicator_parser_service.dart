import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/entities/indicator_entity.dart';

export '../../domain/entities/indicator_entity.dart';

class ParsedIndicator {
  final IndicatorType type;
  final double value;
  final double? secondValue; // For blood pressure (systolic/diastolic)
  final String unit;
  final bool isAbnormal;
  String customName; // Allow manual editing

  ParsedIndicator({
    required this.type,
    required this.value,
    this.secondValue,
    required this.unit,
    required this.isAbnormal,
    String? customName,
  }) : customName = customName ?? '';
}

class IndicatorParserService {
  // Reference ranges for abnormal detection
  static const double glucoseMin = 3.9;
  static const double glucoseMax = 6.1;
  static const int bpSystolicMax = 140;
  static const int bpDiastolicMax = 90;

  /// Parse all indicators from text
  List<ParsedIndicator> parseAll(String text) {
    final indicators = <ParsedIndicator>[];

    // Debug: print the text being parsed
    debugPrint('=== 开始解析指标 ===');
    debugPrint('文本长度: ${text.length}');
    debugPrint(
        '文本内容（前500字符）: ${text.substring(0, text.length > 500 ? 500 : text.length)}');
    debugPrint('==================');

    // Parse blood glucose
    final glucose = parseGlucose(text);
    if (glucose != null) {
      debugPrint('✓ 血糖提取成功: ${glucose.value}');
      indicators.add(glucose);
    } else {
      debugPrint('✗ 血糖提取失败');
    }

    // Parse blood pressure
    final bp = parseBloodPressure(text);
    if (bp != null) {
      debugPrint('✓ 血压提取成功: ${bp.value}/${bp.secondValue}');
      indicators.add(bp);
    } else {
      debugPrint('✗ 血压提取失败');
    }

    // Parse blood lipids
    indicators.addAll(parseLipids(text));

    debugPrint('=== 共提取 ${indicators.length} 个指标 ===');
    return indicators;
  }

  /// Parse blood glucose (血糖)
  ParsedIndicator? parseGlucose(String text) {
    debugPrint('搜索血糖相关文本...');

    // Split text into lines
    final lines = text.split('\n');

    // Strategy: Find lines containing glucose keywords, then search for numbers
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check if this line contains glucose keywords
      final hasGlucoseKeyword = line.contains('空腹血葡萄糖') ||
          line.contains('空腹血糖') ||
          line.contains('血糖') ||
          line.contains('GLU') ||
          line.contains('葡萄糖') ||
          line.contains('Glu');

      if (hasGlucoseKeyword) {
        debugPrint('  发现血糖行 $i: $line');

        // Try to find number in this line first
        final numbersInLine = RegExp(r'\d+\.?\d*').allMatches(line);
        for (final match in numbersInLine) {
          final value = double.tryParse(match.group(0) ?? '');
          if (value != null && value >= 2.0 && value <= 30.0) {
            // Check if this number is likely glucose (not date, not ID)
            final before = line.substring(0, match.start);
            final after = line.substring(match.end);

            // Skip if it looks like a date or ID
            if (before.contains('日期') ||
                before.contains('编号') ||
                before.contains('时间') ||
                after.startsWith('.')) {
              continue;
            }

            debugPrint('  → 提取血糖值: $value mmol/L');
            return ParsedIndicator(
              type: IndicatorType.bloodGlucose,
              value: value,
              unit: 'mmol/L',
              isAbnormal: value < glucoseMin || value > glucoseMax,
              customName: '空腹血糖',
            );
          }
        }

        // If not found in this line, check next line
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1].trim();
          debugPrint('  检查下一行: $nextLine');

          final numbersInNextLine = RegExp(r'\d+\.?\d*').allMatches(nextLine);
          for (final match in numbersInNextLine) {
            final value = double.tryParse(match.group(0) ?? '');
            if (value != null && value >= 2.0 && value <= 30.0) {
              debugPrint('  → 从下一行提取血糖值: $value mmol/L');
              return ParsedIndicator(
                type: IndicatorType.bloodGlucose,
                value: value,
                unit: 'mmol/L',
                isAbnormal: value < glucoseMin || value > glucoseMax,
                customName: '空腹血糖',
              );
            }
          }
        }
      }
    }

    debugPrint('  ✗ 血糖提取失败');
    return null;
  }

  /// Parse blood pressure (血压)
  ParsedIndicator? parseBloodPressure(String text) {
    debugPrint('搜索血压相关文本...');

    final lines = text.split('\n');

    // First, try to find combined format (收缩压/舒张压 in same area)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip explanation/note lines
      if (_isExplanationLine(line)) {
        continue;
      }

      if (line.contains('收缩压') ||
          line.contains('舒张压') ||
          line.contains('血压') ||
          line.contains('BP')) {
        debugPrint('  发现血压行 $i: $line');

        // Look in this line and next few lines for two numbers that could be BP
        // Filter out explanation lines
        final searchLines = lines
            .skip(i)
            .take(10)
            .where((l) => !_isExplanationLine(l))
            .join('\n');

        // Try slash format first (120/80)
        final slashMatch =
            RegExp(r'(\d{2,3})/(\d{2,3})').firstMatch(searchLines);
        if (slashMatch != null) {
          final sys = double.tryParse(slashMatch.group(1) ?? '');
          final dia = double.tryParse(slashMatch.group(2) ?? '');

          if (sys != null &&
              dia != null &&
              sys >= 60 &&
              sys <= 250 &&
              dia >= 40 &&
              dia <= 150 &&
              sys > dia) {
            // Systolic must be higher than diastolic
            debugPrint('  → 组合血压值: $sys/$dia');
            return ParsedIndicator(
              type: IndicatorType.bloodPressure,
              value: sys,
              secondValue: dia,
              unit: 'mmHg',
              isAbnormal: sys > bpSystolicMax || dia > bpDiastolicMax,
              customName: '血压',
            );
          }
        }

        // If no slash format, look for separate 收缩压 and 舒张压
        double? systolic;
        double? diastolic;

        // Search for 收缩压 (skip explanation lines)
        for (int j = i; j < min(i + 10, lines.length); j++) {
          if (_isExplanationLine(lines[j])) continue;

          if (lines[j].contains('收缩压') ||
              lines[j].contains('高压') ||
              lines[j].contains('SBP')) {
            debugPrint('    收缩压行 $j: ${lines[j]}');
            final numbers = RegExp(r'\d+\.?\d*').allMatches(lines[j]);
            for (final match in numbers) {
              final val = double.tryParse(match.group(0) ?? '');
              if (val != null && val >= 60 && val <= 250) {
                // Check context - avoid extracting from "低于X" or "高于X"
                final beforeNum = lines[j].substring(0, match.start);
                if (!beforeNum.contains('低于') &&
                    !beforeNum.contains('高于') &&
                    !beforeNum.contains('小于') &&
                    !beforeNum.contains('大于')) {
                  systolic = val;
                  debugPrint('      → 收缩压: $val');
                  break;
                }
              }
            }
            if (systolic != null) break;
          }
        }

        // Search for 舒张压 (skip explanation lines)
        for (int j = i; j < min(i + 10, lines.length); j++) {
          if (_isExplanationLine(lines[j])) continue;

          if (lines[j].contains('舒张压') ||
              lines[j].contains('低压') ||
              lines[j].contains('DBP')) {
            debugPrint('    舒张压行 $j: ${lines[j]}');
            final numbers = RegExp(r'\d+\.?\d*').allMatches(lines[j]);
            for (final match in numbers) {
              final val = double.tryParse(match.group(0) ?? '');
              if (val != null && val >= 40 && val <= 150) {
                // Check context - avoid extracting from "低于X" or "高于X"
                final beforeNum = lines[j].substring(0, match.start);
                if (!beforeNum.contains('低于') &&
                    !beforeNum.contains('高于') &&
                    !beforeNum.contains('小于') &&
                    !beforeNum.contains('大于')) {
                  diastolic = val;
                  debugPrint('      → 舒张压: $val');
                  break;
                }
              }
            }
            if (diastolic != null) break;
          }
        }

        if (systolic != null && diastolic != null && systolic > diastolic) {
          debugPrint('  ✓ 分离血压值: $systolic/$diastolic');
          return ParsedIndicator(
            type: IndicatorType.bloodPressure,
            value: systolic,
            secondValue: diastolic,
            unit: 'mmHg',
            isAbnormal: systolic > bpSystolicMax || diastolic > bpDiastolicMax,
            customName: '血压',
          );
        }

        // Found keyword but no values, try next occurrence
        debugPrint('  此区域未找到有效血压值');
      }
    }

    debugPrint('  ✗ 血压提取失败');
    return null;
  }

  /// Check if a line is an explanation/note line (not actual measurement data)
  bool _isExplanationLine(String line) {
    final explanationPatterns = [
      '低于',
      '高于',
      '小于',
      '大于',
      '正常',
      '异常',
      '为单纯',
      '舒张压降低',
      '收缩压正常',
      '舒张压正常',
      '收缩压降低',
      '收缩压升高',
      '舒张压升高',
      '说明',
      '注',
      '注意',
      '建议',
      '参考',
      '标准',
      '范围',
      '【1】',
      '【2】',
      '【3】',
    ];

    for (final pattern in explanationPatterns) {
      if (line.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  /// Parse blood lipids (血脂: TC, TG, HDL, LDL)
  List<ParsedIndicator> parseLipids(String text) {
    final indicators = <ParsedIndicator>[];

    // Total Cholesterol (总胆固醇/TC)
    final tcPatterns = [
      RegExp(r'(?:总胆固醇|TC|CHOL)[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
      RegExp(r'胆固醇[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
    ];
    for (final regex in tcPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0 && value < 20) {
          indicators.add(ParsedIndicator(
            type: IndicatorType.bloodLipidTC,
            value: value,
            unit: 'mmol/L',
            isAbnormal: value > 5.2,
          ));
          break;
        }
      }
    }

    // Triglycerides (甘油三酯/TG)
    final tgPatterns = [
      RegExp(r'(?:甘油三酯|TG)[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
    ];
    for (final regex in tgPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0 && value < 20) {
          indicators.add(ParsedIndicator(
            type: IndicatorType.bloodLipidTG,
            value: value,
            unit: 'mmol/L',
            isAbnormal: value > 1.7,
          ));
          break;
        }
      }
    }

    // HDL Cholesterol (高密度脂蛋白/HDL)
    final hdlPatterns = [
      RegExp(r'(?:高密度脂蛋白|HDL(?:-C)?)[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
    ];
    for (final regex in hdlPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0 && value < 5) {
          indicators.add(ParsedIndicator(
            type: IndicatorType.bloodLipidHDL,
            value: value,
            unit: 'mmol/L',
            isAbnormal: value < 1.0, // Low HDL is abnormal
          ));
          break;
        }
      }
    }

    // LDL Cholesterol (低密度脂蛋白/LDL)
    final ldlPatterns = [
      RegExp(r'(?:低密度脂蛋白|LDL(?:-C)?)[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
    ];
    for (final regex in ldlPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0 && value < 10) {
          indicators.add(ParsedIndicator(
            type: IndicatorType.bloodLipidLDL,
            value: value,
            unit: 'mmol/L',
            isAbnormal: value > 3.4,
          ));
          break;
        }
      }
    }

    return indicators;
  }
}
