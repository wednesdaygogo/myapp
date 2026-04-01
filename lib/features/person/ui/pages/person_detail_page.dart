import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/person.dart';
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
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/persons/${widget.personId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: person == null
          ? const Center(child: Text('未找到'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  _buildAvatarSection(person),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Basic Info Card
                  _buildInfoCard(
                    title: '基本信息',
                    icon: Icons.person_outline,
                    items: [
                      _InfoItem(
                        icon: Icons.badge_outlined,
                        label: '姓名',
                        value: person.name,
                        isRequired: true,
                      ),
                      _InfoItem(
                        icon: Icons.wc_outlined,
                        label: '性别',
                        value: person.gender ?? '未填写',
                      ),
                      _InfoItem(
                        icon: Icons.cake_outlined,
                        label: '出生日期',
                        value: person.birthDate != null
                            ? DateFormat('yyyy年MM月dd日')
                                .format(person.birthDate!)
                            : '未填写',
                      ),
                      _InfoItem(
                        icon: Icons.hourglass_empty_outlined,
                        label: '年龄',
                        value: '${person.age}岁',
                        showBadge: person.age > 0,
                        badgeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Contact Info Card
                  _buildInfoCard(
                    title: '联系方式',
                    icon: Icons.contact_phone_outlined,
                    items: [
                      _InfoItem(
                        icon: Icons.phone_outlined,
                        label: '电话',
                        value: person.phone ?? '未填写',
                      ),
                      _InfoItem(
                        icon: Icons.credit_card_outlined,
                        label: '身份证号',
                        value: person.idNumber ?? '未填写',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Relationship Card
                  _buildInfoCard(
                    title: '家庭关系',
                    icon: Icons.family_restroom_outlined,
                    items: [
                      _InfoItem(
                        icon: Icons.favorite_outline,
                        label: '关系',
                        value: person.relationship ?? '未填写',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection(Person person) {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceVariant,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 3,
              ),
              boxShadow: AppTheme.shadowMd,
              image: person.photoPath != null && person.photoPath!.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(person.photoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: person.photoPath == null || person.photoPath!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.textTertiary,
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Name
          Text(
            person.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXs),

          // Relationship Badge
          if (person.relationship != null && person.relationship!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                person.relationship!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Divider
            const Divider(height: 1),

            // Info Items
            ...items.map((item) => _buildInfoItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItemRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              item.icon,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // Label
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          // Required indicator
          if (item.isRequired)
            Container(
              margin: const EdgeInsets.only(left: AppTheme.spacingXs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                '必填',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.errorColor,
                      fontSize: 10,
                    ),
              ),
            ),

          const Spacer(),

          // Value with optional badge
          if (item.showBadge && item.badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: item.badgeColor!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                item.value,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: item.badgeColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          else
            Text(
              item.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此家人吗？相关健康报告也会一并删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(personsProvider.notifier).deletePerson(widget.personId);
      if (mounted) context.go('/persons');
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isRequired;
  final bool showBadge;
  final Color? badgeColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isRequired = false,
    this.showBadge = false,
    this.badgeColor,
  });
}
