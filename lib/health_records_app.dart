// Lightweight in-memory health records app to support integration tests

class HealthRecordsApp {
  int _nextPersonId = 1;
  int _nextReportId = 1;

  final Map<int, _Person> _persons = {};
  final Map<int, _HealthReport> _reports = {};

  // Person workflow
  _Person createPerson(String name, DateTime birthDate) {
    final person = _Person(_nextPersonId++, name, birthDate);
    _persons[person.id] = person;
    return person;
  }

  List<_Person> listPersons() => _persons.values.toList();

  _Person? getPerson(int id) => _persons[id];

  bool updatePerson(int id, {String? name, DateTime? birthDate}) {
    final p = _persons[id];
    if (p == null) return false;
    if (name != null) p.name = name;
    if (birthDate != null) p.birthDate = birthDate;
    return true;
  }

  bool deletePerson(int id) {
    if (!_persons.containsKey(id)) return false;
    // Cascade delete their health reports
    _reports.removeWhere((_, r) => r.personId == id);
    _persons.remove(id);
    return true;
  }

  // Health report flow (PDF import -> parse -> save -> detail)
  PreviewHealthReport importPdf(int personId, String pdfPath) {
    return PreviewHealthReport(personId: personId, pdfPath: pdfPath);
  }

  bool parsePreview(PreviewHealthReport preview) {
    // Simple deterministic parse: if file path contains "valid" it's parsed
    if (preview.pdfPath.toLowerCase().contains('valid')) {
      preview.parsedContent = 'Parsed Health Report';
      return true;
    }
    return false;
  }

  _HealthReport? savePreview(PreviewHealthReport preview) {
    if (preview.parsedContent == null) return null;
    final hr = _HealthReport(_nextReportId++, preview.personId, preview.pdfPath,
        preview.parsedContent ?? '');
    _reports[hr.id] = hr;
    return hr;
  }

  _HealthReport? detailReport(int reportId) => _reports[reportId];

  // Manual entry path when parsing fails
  _HealthReport manualEntry(int personId, String content) {
    final hr = _HealthReport(_nextReportId++, personId, null, content);
    _reports[hr.id] = hr;
    return hr;
  }

  List<_HealthReport> listReportsForPerson(int personId) =>
      _reports.values.where((r) => r.personId == personId).toList();
}

// Internal domain models used by the in-memory app
class _Person {
  final int id;
  String name;
  DateTime birthDate;
  _Person(this.id, this.name, this.birthDate);
}

class _HealthReport {
  final int id;
  final int personId;
  final String? pdfPath;
  final String content;
  _HealthReport(this.id, this.personId, this.pdfPath, this.content);
}

class PreviewHealthReport {
  final int personId;
  final String pdfPath;
  String? parsedContent;
  PreviewHealthReport({required this.personId, required this.pdfPath});
}
