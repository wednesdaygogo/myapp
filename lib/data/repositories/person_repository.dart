import 'package:isar/isar.dart';
import '../models/person.dart';
import '../models/health_report.dart';

class PersonRepository {
  final Isar _isar;

  PersonRepository(this._isar);

  // Create
  Future<int> insert(Person person) async {
    return await _isar.writeTxn(() => _isar.persons.put(person));
  }

  // Read all
  Future<List<Person>> getAll() async {
    return await _isar.persons.where().findAll();
  }

  // Read by ID
  Future<Person?> getById(int id) async {
    return await _isar.persons.get(id);
  }

  // Update
  Future<int> update(Person person) async {
    return await _isar.writeTxn(() => _isar.persons.put(person));
  }

  // Delete with cascade to health reports
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      // Delete associated health reports first
      await _isar.healthReports.filter().personIdEqualTo(id).deleteAll();
      // Then delete the person
      return await _isar.persons.delete(id);
    });
  }

  // Search by name
  Future<List<Person>> searchByName(String query) async {
    return await _isar.persons
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  // Filter by relationship
  Future<List<Person>> filterByRelationship(String relationship) async {
    return await _isar.persons
        .filter()
        .relationshipEqualTo(relationship)
        .findAll();
  }

  // Count
  Future<int> count() async {
    return await _isar.persons.count();
  }
}
