import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/person.dart';
import '../../../data/repositories/person_repository.dart';

// Repository provider - must be overridden with actual Isar instance
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  throw UnimplementedError('Must override with actual Isar instance');
});

// All persons list
final personsProvider = FutureProvider<List<Person>>((ref) async {
  final repository = ref.watch(personRepositoryProvider);
  return await repository.getAll();
});

// Selected person ID
final selectedPersonIdProvider = StateProvider<int?>((ref) => null);

// Selected person detail
final selectedPersonProvider = FutureProvider<Person?>((ref) async {
  final id = ref.watch(selectedPersonIdProvider);
  if (id == null) return null;
  final repository = ref.watch(personRepositoryProvider);
  return await repository.getById(id);
});

// Person CRUD notifier
class PersonNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PersonNotifier(this._ref) : super(const AsyncData(null));

  Future<int?> createPerson(Person person) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(personRepositoryProvider);
      final id = await repository.insert(person);
      _ref.invalidate(personsProvider);
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> updatePerson(Person person) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(personRepositoryProvider);
      await repository.update(person);
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
      final repository = _ref.read(personRepositoryProvider);
      await repository.delete(id);
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

final filteredPersonsProvider = FutureProvider<List<Person>>((ref) async {
  final query = ref.watch(personSearchQueryProvider);
  final repository = ref.read(personRepositoryProvider);

  if (query.isEmpty) {
    return await repository.getAll();
  }
  return await repository.searchByName(query);
});
