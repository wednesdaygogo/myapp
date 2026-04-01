import '../../domain/entities/indicator_entity.dart';

export '../../domain/entities/indicator_entity.dart';

class ParsedIndicator {
  final IndicatorType type;
  final double value;
  final double? secondValue; // For blood pressure (systolic/diastolic)
  final String unit;
  final bool isAbnormal;

  ParsedIndicator({
    required this.type,
    required this.value,
    this.secondValue,
    required this.unit,
    required this.isAbnormal,
  });
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

    // Parse blood glucose
    final glucose = parseGlucose(text);
    if (glucose != null) indicators.add(glucose);

    // Parse blood pressure
    final bp = parseBloodPressure(text);
    if (bp != null) indicators.add(bp);

    // Parse blood lipids
    indicators.addAll(parseLipids(text));

    return indicators;
  }

  /// Parse blood glucose (血糖)
  ParsedIndicator? parseGlucose(String text) {
    // Match multiple patterns for blood glucose
    final patterns = [
      // Chinese patterns
      RegExp(r'(?:空腹)?血糖[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
      RegExp(r'GLU[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
      RegExp(r'葡萄糖[^\d]*[:：]?\s*(\d+\.?\d*)\s*(?:mmol/L)?',
          caseSensitive: false),
      // Pattern with result/value label
      RegExp(r'血糖.*?(\d+\.?\d*)\s*mmol/L', caseSensitive: false),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0 && value < 50) {
          // Reasonable range
          return ParsedIndicator(
            type: IndicatorType.bloodGlucose,
            value: value,
            unit: 'mmol/L',
            isAbnormal: value < glucoseMin || value > glucoseMax,
          );
        }
      }
    }
    return null;
  }

  /// Parse blood pressure (血压)
  ParsedIndicator? parseBloodPressure(String text) {
    // Match multiple patterns for blood pressure
    final patterns = [
      // Standard format: 120/80
      RegExp(r'血压[^\d]*[:：]?\s*(\d+)/(\d+)\s*(?:mmHg)?', caseSensitive: false),
      // With BP label
      RegExp(r'BP[^\d]*[:：]?\s*(\d+)/(\d+)\s*(?:mmHg)?', caseSensitive: false),
      // 收缩压/舒张压 format
      RegExp(r'(?:收缩压|高压)[^\d]*[:：]?\s*(\d+)\s*(?:mmHg)?',
          caseSensitive: false),
      RegExp(r'(?:舒张压|低压)[^\d]*[:：]?\s*(\d+)\s*(?:mmHg)?',
          caseSensitive: false),
    ];

    // Try combined patterns first (systolic/diastolic)
    for (int i = 0; i < 2; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        final systolic = double.tryParse(match.group(1) ?? '');
        final diastolic = double.tryParse(match.group(2) ?? '');

        if (systolic != null &&
            diastolic != null &&
            systolic > 60 &&
            systolic < 250 &&
            diastolic > 40 &&
            diastolic < 150) {
          return ParsedIndicator(
            type: IndicatorType.bloodPressure,
            value: systolic,
            secondValue: diastolic,
            unit: 'mmHg',
            isAbnormal: systolic > bpSystolicMax || diastolic > bpDiastolicMax,
          );
        }
      }
    }

    // Try separate systolic/diastolic patterns
    double? systolic;
    double? diastolic;

    final sysMatch = patterns[2].firstMatch(text);
    if (sysMatch != null) {
      systolic = double.tryParse(sysMatch.group(1) ?? '');
    }

    final diaMatch = patterns[3].firstMatch(text);
    if (diaMatch != null) {
      diastolic = double.tryParse(diaMatch.group(1) ?? '');
    }

    if (systolic != null && diastolic != null) {
      return ParsedIndicator(
        type: IndicatorType.bloodPressure,
        value: systolic,
        secondValue: diastolic,
        unit: 'mmHg',
        isAbnormal: systolic > bpSystolicMax || diastolic > bpDiastolicMax,
      );
    }

    return null;
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
