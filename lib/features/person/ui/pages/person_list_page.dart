import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_avatar.dart';
import '../../providers/person_provider.dart';

class PersonListPage extends ConsumerWidget {
  const PersonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persons = ref.watch(personsProvider);

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: const Text('家人管理 🏠'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: persons.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CrayonTheme.spacingMd),
                    child: _buildPersonCard(context, person),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CrayonTheme.forestGreen,
        foregroundColor: Colors.white,
        onPressed: () => context.go('/persons/new'),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 64,
            color: CrayonTheme.forestGreen,
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text(
            '暂无家人信息',
            style: CrayonTheme.crayonTextTheme.titleMedium,
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text(
            '点击右下角按钮添加',
            style: TextStyle(
              color: CrayonTheme.darkBrown.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(BuildContext context, dynamic person) {
    return CrayonCard(
      onTap: () => context.go('/persons/${person.id}'),
      child: Row(
        children: [
          CrayonAvatar(
            presetName: person.photoPath,
            size: 48,
          ),
          const SizedBox(width: CrayonTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: CrayonTheme.crayonTextTheme.titleMedium,
                ),
                const SizedBox(height: CrayonTheme.spacingSm),
                Text(
                  '${person.relationship ?? "未知"} · ${person.age}岁',
                  style: TextStyle(
                    color: CrayonTheme.darkBrown.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: CrayonTheme.forestGreen,
          ),
        ],
      ),
    );
  }
}