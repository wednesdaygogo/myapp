import 'package:health_records/data/models/health_indicator.dart';

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
    // Match patterns like "空腹血糖: 5.6 mmol/L" or "血糖 5.6"
    final regex = RegExp(
      r'(?:空腹|餐后)?血糖[:\s]*(\d+\.?\d*)\s*(mmol/L)?',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match != null) {
      final value = double.tryParse(match.group(1) ?? '');
      if (value != null) {
        return ParsedIndicator(
          type: IndicatorType.bloodGlucose,
          value: value,
          unit: 'mmol/L',
          isAbnormal: value < glucoseMin || value > glucoseMax,
        );
      }
    }
    return null;
  }

  /// Parse blood pressure (血压)
  ParsedIndicator? parseBloodPressure(String text) {
    // Match patterns like "血压: 120/80 mmHg"
    final regex = RegExp(
      r'血压[:\s]*(\d+)/(\d+)\s*(mmHg)?',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match != null) {
      final systolic = double.tryParse(match.group(1) ?? '');
      final diastolic = double.tryParse(match.group(2) ?? '');

      if (systolic != null && diastolic != null) {
        return ParsedIndicator(
          type: IndicatorType.bloodPressure,
          value: systolic,
          secondValue: diastolic,
          unit: 'mmHg',
          isAbnormal: systolic > bpSystolicMax || diastolic > bpDiastolicMax,
        );
      }
    }
    return null;
  }

  /// Parse blood lipids (血脂: TC, TG, HDL, LDL)
  List<ParsedIndicator> parseLipids(String text) {
    final indicators = <ParsedIndicator>[];

    // Total Cholesterol (总胆固醇/TC)
    final tcMatch = RegExp(
      r'(?:总胆固醇|TC)[:\s]*(\d+\.?\d*)\s*(mmol/L)?',
      caseSensitive: false,
    ).firstMatch(text);

    if (tcMatch != null) {
      final value = double.tryParse(tcMatch.group(1) ?? '');
      if (value != null) {
        indicators.add(ParsedIndicator(
          type: IndicatorType.bloodLipidTC,
          value: value,
          unit: 'mmol/L',
          isAbnormal: value > 5.2,
        ));
      }
    }

    // Triglycerides (甘油三酯/TG)
    final tgMatch = RegExp(
      r'(?:甘油三酯|TG)[:\s]*(\d+\.?\d*)\s*(mmol/L)?',
      caseSensitive: false,
    ).firstMatch(text);

    if (tgMatch != null) {
      final value = double.tryParse(tgMatch.group(1) ?? '');
      if (value != null) {
        indicators.add(ParsedIndicator(
          type: IndicatorType.bloodLipidTG,
          value: value,
          unit: 'mmol/L',
          isAbnormal: value > 1.7,
        ));
      }
    }

    // HDL Cholesterol (高密度脂蛋白/HDL)
    final hdlMatch = RegExp(
      r'(?:高密度脂蛋白|HDL)[^:]*[:\s]*(\d+\.?\d*)\s*(mmol/L)?',
      caseSensitive: false,
    ).firstMatch(text);

    if (hdlMatch != null) {
      final value = double.tryParse(hdlMatch.group(1) ?? '');
      if (value != null) {
        indicators.add(ParsedIndicator(
          type: IndicatorType.bloodLipidHDL,
          value: value,
          unit: 'mmol/L',
          isAbnormal: value < 1.0, // Low HDL is abnormal
        ));
      }
    }

    // LDL Cholesterol (低密度脂蛋白/LDL)
    final ldlMatch = RegExp(
      r'(?:低密度脂蛋白|LDL)[^:]*[:\s]*(\d+\.?\d*)\s*(mmol/L)?',
      caseSensitive: false,
    ).firstMatch(text);

    if (ldlMatch != null) {
      final value = double.tryParse(ldlMatch.group(1) ?? '');
      if (value != null) {
        indicators.add(ParsedIndicator(
          type: IndicatorType.bloodLipidLDL,
          value: value,
          unit: 'mmol/L',
          isAbnormal: value > 3.4,
        ));
      }
    }

    return indicators;
  }
}
