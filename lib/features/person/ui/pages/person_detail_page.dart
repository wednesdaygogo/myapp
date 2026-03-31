import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/person_provider.dart';

class PersonDetailPage extends ConsumerStatefulWidget {
  final int personId;
  const PersonDetailPage({super.key, required this.personId});

  @override
  ConsumerState<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends ConsumerState<PersonDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedPersonIdProvider.notifier).state = widget.personId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(selectedPersonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家人详情'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/persons/${widget.personId}/edit')),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除此家人吗？'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('删除')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(personNotifierProvider.notifier)
                      .deletePerson(widget.personId);
                  if (context.mounted) context.go('/persons');
                }
              }),
        ],
      ),
      body: person == null
          ? const Center(child: Text('未找到'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('姓名: ${person.name}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('性别: ${person.gender ?? "未填写"}'),
                  Text(
                      '出生日期: ${person.birthDate?.toString().split(' ')[0] ?? "未填写"}'),
                  Text('年龄: ${person.age}岁'),
                  Text('电话: ${person.phone ?? "未填写"}'),
                  Text('关系: ${person.relationship ?? "未填写"}'),
                ],
              ),
            ),
    );
  }
}
