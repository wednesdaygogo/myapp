import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/person.dart';

/// Persons state notifier - manages the list of persons
class PersonsNotifier extends StateNotifier<List<Person>> {
  int _nextId = 1;

  PersonsNotifier() : super([]);

  /// Add a new person or update existing one
  Future<int?> savePerson(Person person) async {
    // 如果 person.id > 0，说明是编辑，应该更新而不是新增
    if (person.id > 0) {
      final index = state.indexWhere((p) => p.id == person.id);
      if (index != -1) {
        state = [
          ...state.sublist(0, index),
          person,
          ...state.sublist(index + 1),
        ];
        return person.id;
      }
    }
    // 新增
    final newPerson = Person(
      id: _nextId++,
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
    state = [...state, newPerson];
    return newPerson.id;
  }

  /// Delete a person by ID
  Future<bool> deletePerson(int id) async {
    state = state.where((p) => p.id != id).toList();
    return true;
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
