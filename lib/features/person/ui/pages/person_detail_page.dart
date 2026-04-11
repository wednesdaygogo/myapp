import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_avatar.dart';
import '../../../../data/models/person.dart';
import '../../providers/person_provider.dart';
import '../../../health_report/providers/report_stats_provider.dart';

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
      if (!mounted) return;
      ref.read(selectedPersonIdProvider.notifier).state = widget.personId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(selectedPersonProvider);
    final stats = ref.watch(personReportStatsProvider(widget.personId));

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: const Text('家人详情 🌟'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
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
          : CrayonBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    _buildAvatarSection(person),
                    const SizedBox(height: CrayonTheme.spacingLg),

                    // Basic Info Card
                    CrayonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📋 基本信息', style: CrayonTheme.crayonTextTheme.titleMedium),
                          const SizedBox(height: CrayonTheme.spacingMd),
                          _buildInfoRow(Icons.badge_outlined, '姓名', person.name, isRequired: true),
                          _buildInfoRow(Icons.wc_outlined, '性别', person.gender ?? '未填写'),
                          _buildInfoRow(Icons.cake_outlined, '出生日期', person.birthDate != null
                              ? DateFormat('yyyy年MM月dd日').format(person.birthDate!)
                              : '未填写'),
                          _buildInfoRow(Icons.hourglass_empty_outlined, '年龄', '${person.age}岁'),
                        ],
                      ),
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),

                    // Contact Info Card
                    CrayonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📞 联系方式', style: CrayonTheme.crayonTextTheme.titleMedium),
                          const SizedBox(height: CrayonTheme.spacingMd),
                          _buildInfoRow(Icons.phone_outlined, '电话', person.phone ?? '未填写'),
                          _buildInfoRow(Icons.credit_card_outlined, '身份证号', person.idNumber ?? '未填写'),
                        ],
                      ),
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),

                    // Relationship Card
                    CrayonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('👨‍👩‍👧 家庭关系', style: CrayonTheme.crayonTextTheme.titleMedium),
                          const SizedBox(height: CrayonTheme.spacingMd),
                          _buildInfoRow(Icons.favorite_outline, '关系', person.relationship ?? '未填写'),
                        ],
                      ),
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),

                    // Health Report Summary
                    CrayonCard(
                      onTap: () => context.go('/reports/person/${widget.personId}'),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                            ),
                            child: const Icon(Icons.description, color: CrayonTheme.forestGreen, size: 24),
                          ),
                          const SizedBox(width: CrayonTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('健康报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                                const SizedBox(height: CrayonTheme.spacingSm),
                                Text(
                                  '${stats.reportCount}份报告 · ${stats.latestReportDateText}',
                                  style: TextStyle(
                                    color: CrayonTheme.darkBrown.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: CrayonTheme.forestGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection(Person person) {
    return Center(
      child: Column(
        children: [
          CrayonAvatar(
            presetName: person.photoPath,
            size: 100,
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text(
            person.name,
            style: CrayonTheme.crayonTextTheme.titleLarge,
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          if (person.relationship != null && person.relationship!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CrayonTheme.spacingMd,
                vertical: CrayonTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: CrayonTheme.forestGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(CrayonTheme.radiusXl),
              ),
              child: Text(
                person.relationship!,
                style: const TextStyle(
                  color: CrayonTheme.forestGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CrayonTheme.spacingSm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
            ),
            child: Icon(icon, size: 18, color: CrayonTheme.forestGreen),
          ),
          const SizedBox(width: CrayonTheme.spacingMd),
          Text(label, style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.7))),
          if (isRequired)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('✏️', style: TextStyle(fontSize: 12)),
            ),
          const Spacer(),
          Text(value, style: const TextStyle(color: CrayonTheme.darkBrown, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CrayonTheme.creamWhite,
        title: const Text('确认删除', style: TextStyle(color: CrayonTheme.darkBrown)),
        content: const Text('确定要删除此家人吗？相关健康报告也会一并删除。', style: TextStyle(color: CrayonTheme.darkBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: CrayonTheme.forestGreen)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: CrayonTheme.brickRed),
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