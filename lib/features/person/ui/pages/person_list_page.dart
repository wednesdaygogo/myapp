import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/person_provider.dart';

class PersonListPage extends ConsumerWidget {
  const PersonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('家人管理')),
      body: personsAsync.when(
        data: (persons) => persons.isEmpty
            ? const Center(child: Text('暂无家人信息，点击添加'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(person.name[0]),
                      ),
                      title: Text(person.name),
                      subtitle:
                          Text('${person.relationship ?? ""} · ${person.age}岁'),
                      onTap: () => context.go('/persons/${person.id}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/persons/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
