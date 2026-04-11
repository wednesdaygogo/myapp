import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_avatar.dart';
import '../../providers/report_stats_provider.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsWithStats = ref.watch(personsWithReportStatsProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: const Text('体检报告 📋'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: personsWithStats.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                itemCount: personsWithStats.length,
                itemBuilder: (context, index) {
                  final item = personsWithStats[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CrayonTheme.spacingMd),
                    child: _buildFamilyCard(
                      context: context,
                      item: item,
                      dateFormat: dateFormat,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CrayonTheme.forestGreen,
        foregroundColor: Colors.white,
        onPressed: () => context.go('/reports/import'),
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
            Icons.description_outlined,
            size: 64,
            color: CrayonTheme.forestGreen,
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text(
            '暂无体检报告',
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

  Widget _buildFamilyCard({
    required BuildContext context,
    required PersonWithStats item,
    required DateFormat dateFormat,
  }) {
    final person = item.person;
    final stats = item.stats;

    return CrayonCard(
      onTap: () => context.go('/reports/person/${person.id}'),
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
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 16,
                      color: CrayonTheme.mustardYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.reportCount}份报告',
                      style: TextStyle(
                        color: CrayonTheme.darkBrown.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    if (stats.latestReportDate != null) ...[
                      const SizedBox(width: CrayonTheme.spacingMd),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: CrayonTheme.forestGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(stats.latestReportDate!),
                        style: TextStyle(
                          color: CrayonTheme.darkBrown.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
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