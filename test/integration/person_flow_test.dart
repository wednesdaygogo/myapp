import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/health_records_app.dart' as app_lib;

void main() {
  test('Person flow end-to-end (create -> list -> detail -> edit -> delete)',
      () {
    final app = app_lib.HealthRecordsApp();

    // Create
    final p = app.createPerson('Test User', DateTime(1990, 5, 5));
    expect(p.id, isNotNull);

    // List contains person
    final list = app.listPersons();
    expect(list.any((pp) => pp.id == p.id), isTrue);

    // Detail
    final detail = app.getPerson(p.id);
    expect(detail?.name, 'Test User');

    // Edit
    app.updatePerson(p.id, name: 'Test User Updated');
    expect(app.getPerson(p.id)?.name, 'Test User Updated');

    // Delete (cascade of any generated reports)
    final manual = app.manualEntry(p.id, 'Manual note');
    final reportsBefore = app.listReportsForPerson(p.id);
    expect(reportsBefore.any((r) => r.id == manual.id), true);
    app.deletePerson(p.id);
    expect(app.getPerson(p.id), isNull);
    final reportsAfter = app.listReportsForPerson(p.id);
    expect(reportsAfter, isEmpty);
  });
}
