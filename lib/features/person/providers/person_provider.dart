import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/person.dart';

// In-memory storage
final _persons = <Person>[];
int _nextId = 1;

// All persons list
final personsProvider = StateProvider<List<Person>>((ref) => _persons);

// Selected person ID
final selectedPersonIdProvider = StateProvider<int?>((ref) => null);

// Selected person
final selectedPersonProvider = Provider<Person?>((ref) {
  final id = ref.watch(selectedPersonIdProvider);
  if (id == null) return null;
  return _persons.firstWhere((p) => p.id == id, orElse: () => Person(name: ''));
});

// Person CRUD notifier
class PersonNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PersonNotifier(this._ref) : super(const AsyncData(null));

  Future<int?> createPerson(Person person) async {
    state = const AsyncLoading();
    try {
      person.id = _nextId++;
      _persons.add(person);
      _ref.invalidate(personsProvider);
      state = const AsyncData(null);
      return person.id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> updatePerson(Person person) async {
    state = const AsyncLoading();
    try {
      final index = _persons.indexWhere((p) => p.id == person.id);
      if (index != -1) {
        _persons[index] = person;
      }
      _ref.invalidate(personsProvider);
      _ref.invalidate(selectedPersonProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deletePerson(int id) async {
    state = const AsyncLoading();
    try {
      _persons.removeWhere((p) => p.id == id);
      _ref.invalidate(personsProvider);
      _ref.invalidate(selectedPersonProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final personNotifierProvider =
    StateNotifierProvider<PersonNotifier, AsyncValue<void>>((ref) {
  return PersonNotifier(ref);
});

// Search/filter providers
final personSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPersonsProvider = Provider<List<Person>>((ref) {
  final query = ref.watch(personSearchQueryProvider);
  final allPersons = ref.watch(personsProvider);

  if (query.isEmpty) return allPersons;
  return allPersons
      .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
});
