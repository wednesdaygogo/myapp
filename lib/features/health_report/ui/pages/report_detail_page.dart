import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/health_report_provider.dart';

class ReportDetailPage extends ConsumerWidget {
  final int reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(selectedReportIdProvider.notifier).state = reportId;
    final reportAsync = ref.watch(selectedReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('报告详情')),
      body: reportAsync.when(
        data: (report) => report == null
            ? const Center(child: Text('未找到'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('日期: ${report.reportDate.toString().split(' ')[0]}'),
                    Text('来源: ${report.source}'),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      ),
    );
  }
}
