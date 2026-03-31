import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/src/domain/indicator_entity.dart';

void main() {
  test('IndicatorEntity status calculation', () {
    expect(
        IndicatorEntity(value: 90, threshold: 80).status, IndicatorStatus.ok);
    expect(IndicatorEntity(value: 60, threshold: 80).status,
        IndicatorStatus.warning);
  });
}
