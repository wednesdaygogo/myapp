import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/person.dart';
import '../../../main.dart' show hiveReadyProvider;

const String personsBoxName = 'persons';

/// Persons state notifier - manages the list of persons with Hive persistence
class PersonsNotifier extends StateNotifier<List<Person>> {
  int _nextId = 1;
  final Ref _ref;

  PersonsNotifier(this._ref) : super([]) {
    // 不在构造函数中加载，等待Hive准备好
    _waitForHive();
  }

  /// 等待Hive初始化完成后再加载
  void _waitForHive() {
    _ref.listen<bool>(hiveReadyProvider, (previous, next) {
      if (next) {
        _loadFromHive();
      }
    });

    // 如果已经准备好了，直接加载
    if (_ref.read(hiveReadyProvider)) {
      _loadFromHive();
    }
  }

  /// Load persons from Hive on initialization
  void _loadFromHive() {
    try {
      // Hive boxes 已经在 main() 中打开
      final box = Hive.box<Person>(personsBoxName);
      final persons = box.values.toList();
      state = persons;

      // 初始化 _nextId 为最大ID + 1，避免ID重复
      if (persons.isNotEmpty) {
        final maxId = persons.map((p) => p.id).reduce((a, b) => a > b ? a : b);
        _nextId = maxId + 1;
      }

      debugPrint('PersonsNotifier: Loaded ${persons.length} persons, nextId = $_nextId');
    } catch (e, stackTrace) {
      debugPrint('PersonsNotifier: Error loading from Hive: $e');
      debugPrint('StackTrace: $stackTrace');
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
  return PersonsNotifier(ref);
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
