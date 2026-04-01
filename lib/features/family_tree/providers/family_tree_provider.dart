import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../person/providers/person_provider.dart';
import '../../../data/models/person.dart';

/// Family tree graph state - contains graph data for rendering
class FamilyTreeState {
  final List<Person> persons;
  final int? selfPersonId;
  final int version;

  const FamilyTreeState({
    required this.persons,
    this.selfPersonId,
    required this.version,
  });

  bool get isEmpty => persons.isEmpty;
  bool get isNotEmpty => persons.isNotEmpty;
  bool get hasSelf => selfPersonId != null;
}

/// Family tree state provider
final familyTreeGraphProvider = Provider<FamilyTreeState>((ref) {
  final persons = ref.watch(personsProvider);
  final selfPerson = persons.where((p) => p.relationship == '本人').firstOrNull;
  final version = Object.hashAll([...persons.map((p) => p.id), persons.length]);

  return FamilyTreeState(
    persons: persons,
    selfPersonId: selfPerson?.id,
    version: version,
  );
});
