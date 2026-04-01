import 'package:hive_flutter/hive_flutter.dart';
import '../models/person.dart';
import '../models/health_report.dart';

/// Repository for Person data using Hive
class PersonRepository {
  static const String _boxName = 'persons';

  Box<Person> get _box => Hive.box<Person>(_boxName);

  /// Create or update a person
  Future<int> save(Person person) async {
    if (person.id == 0) {
      // Generate new ID
      final newId = _box.isEmpty
          ? 1
          : _box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
      final newPerson = Person(
        id: newId,
        name: person.name,
        gender: person.gender,
        birthDate: person.birthDate,
        idNumber: person.idNumber,
        phone: person.phone,
        photoPath: person.photoPath,
        relationship: person.relationship,
        fatherId: person.fatherId,
        motherId: person.motherId,
        spouseId: person.spouseId,
      );
      await _box.put(newId, newPerson);
      return newId;
    } else {
      await _box.put(person.id, person);
      return person.id;
    }
  }

  /// Get all persons
  List<Person> getAll() {
    return _box.values.toList();
  }

  /// Get person by ID
  Person? getById(int id) {
    return _box.get(id);
  }

  /// Delete a person (cascade delete health reports)
  Future<void> delete(int id) async {
    // Delete associated health reports
    final reportBox = Hive.box<HealthReport>('healthReports');
    final reportsToDelete = reportBox.values
        .where((r) => r.personId == id)
        .map((r) => r.id)
        .toList();
    for (final reportId in reportsToDelete) {
      await reportBox.delete(reportId);
    }
    // Delete the person
    await _box.delete(id);
  }

  /// Search by name
  List<Person> searchByName(String query) {
    return _box.values
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filter by relationship
  List<Person> filterByRelationship(String relationship) {
    return _box.values.where((p) => p.relationship == relationship).toList();
  }

  /// Count
  int count() {
    return _box.length;
  }
}
