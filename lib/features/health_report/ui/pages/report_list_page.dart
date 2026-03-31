import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/health_report_provider.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('体检报告')),
      body: reportsAsync.when(
        data: (reports) => reports.isEmpty
            ? const Center(child: Text('暂无报告'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    child: ListTile(
                      title: Text(report.reportDate.toString().split(' ')[0]),
                      subtitle: Text('来源: ${report.source}'),
                      onTap: () => context.go('/reports/${report.id}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/reports/import'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
