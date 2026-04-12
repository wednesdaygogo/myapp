import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/person.dart';

const String personsBoxName = 'persons';

/// Persons state notifier - manages the list of persons with Hive persistence
class PersonsNotifier extends StateNotifier<List<Person>> {
  int _nextId = 1;

  PersonsNotifier() : super([]) {
    _loadFromHive();
  }

  /// Load persons from Hive on initialization
  Future<void> _loadFromHive() async {
    try {
      final box = Hive.box<Person>(personsBoxName);
      final persons = box.values.toList();
      state = persons;

      // 初始化 _nextId 为最大ID + 1，避免ID重复
      if (persons.isNotEmpty) {
        final maxId = persons.map((p) => p.id).reduce((a, b) => a > b ? a : b);
        _nextId = maxId + 1;
      }
    } catch (e) {
      // Box might not be opened yet
      state = [];
    }
  }

  /// Add a new person or update existing one
  Future<int?> savePerson(Person person) async {
    try {
      final box = Hive.box<Person>(personsBoxName);

      // 如果 person.id > 0，说明是编辑，应该更新而不是新增
      if (person.id > 0) {
        await box.put(person.id, person);
        final index = state.indexWhere((p) => p.id == person.id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            person,
            ...state.sublist(index + 1),
          ];
        }
        return person.id;
      }

      // 新增：使用 _nextId 作为新ID
      final newId = _nextId++;
      final newPerson = Person(
        id: newId,
        name: person.name,
        gender: person.gender,
        birthDate: person.birthDate,
        phone: person.phone,
        photoPath: person.photoPath,
        idNumber: person.idNumber,
        relationship: person.relationship,
        fatherId: person.fatherId,
        motherId: person.motherId,
        spouseId: person.spouseId,
      );

      // 保存到 Hive
      await box.put(newId, newPerson);

      // 更新状态
      state = [...state, newPerson];
      return newId;
    } catch (e) {
      return null;
    }
  }

  /// Delete a person by ID
  Future<bool> deletePerson(int id) async {
    try {
      final box = Hive.box<Person>(personsBoxName);
      await box.delete(id);
      state = state.where((p) => p.id != id).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a person by ID
  Person? getPersonById(int id) {
    return state.where((p) => p.id == id).firstOrNull;
  }
}

/// All persons list provider
final personsProvider =
    StateNotifierProvider<PersonsNotifier, List<Person>>((ref) {
  return PersonsNotifier();
});

/// Selected person ID
final selectedPersonIdProvider = StateProvider<int?>((ref) => null);

/// Selected person
final selectedPersonProvider = Provider<Person?>((ref) {
  final id = ref.watch(selectedPersonIdProvider);
  if (id == null) return null;
  final persons = ref.watch(personsProvider);
  return persons.where((p) => p.id == id).firstOrNull;
});

/// Search/filter providers
final personSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPersonsProvider = Provider<List<Person>>((ref) {
  final query = ref.watch(personSearchQueryProvider);
  final allPersons = ref.watch(personsProvider);

  if (query.isEmpty) return allPersons;
  return allPersons
      .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
});
