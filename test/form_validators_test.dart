import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/src/utils/form_validators.dart';

void main() {
  test('FormValidators.validateName', () {
    expect(FormValidators.validateName(null), 'Name is required');
    expect(FormValidators.validateName(''), 'Name is required');
    expect(FormValidators.validateName('Alice'), isNull);
  });

  test('FormValidators.validateAge', () {
    expect(FormValidators.validateAge(null), 'Invalid age');
    expect(FormValidators.validateAge(-1), 'Invalid age');
    expect(FormValidators.validateAge(0), isNull);
  });
}
