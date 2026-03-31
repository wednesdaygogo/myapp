import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/health_records_app.dart' as app_lib;

void main() {
  test('Health report flow: PDF import -> parsing -> preview -> save -> detail',
      () {
    final app = app_lib.HealthRecordsApp();
    final person = app.createPerson('Health User', DateTime(1988, 2, 2));

    // Import a valid PDF and parse
    final preview = app.importPdf(person.id, 'reports/valid_report.pdf');
    final ok = app.parsePreview(preview);
    expect(ok, isTrue);
    final report = app.savePreview(preview);
    expect(report, isNotNull);
    expect(report!.personId, person.id);
    final detail = app.detailReport(report.id);
    expect(detail?.content, 'Parsed Health Report');

    // Manual entry path when parsing fails
    final previewFail = app.importPdf(person.id, 'reports/bad_report.pdf');
    final okFail = app.parsePreview(previewFail);
    expect(okFail, isFalse);
    final manualReport =
        app.manualEntry(person.id, 'Manual content regenerated');
    expect(manualReport.content, 'Manual content regenerated');
  });
}
