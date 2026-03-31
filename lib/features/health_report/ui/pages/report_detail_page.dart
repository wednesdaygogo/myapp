import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/health_report_provider.dart';

class ReportDetailPage extends ConsumerStatefulWidget {
  final int reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedReportIdProvider.notifier).state = widget.reportId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(selectedReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('报告详情')),
      body: report == null
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
    );
  }
}
