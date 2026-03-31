import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/src/domain/person_entity.dart';

void main() {
  test('PersonEntity age calculation', () {
    final birth = DateTime(2000, 1, 15);
    final person = PersonEntity(id: 1, name: 'Test', birthDate: birth);
    final now = DateTime.now();
    int expected = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      expected--;
    }
    expect(person.age, equals(expected));
  });
}
