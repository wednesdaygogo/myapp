import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportImportPage extends ConsumerStatefulWidget {
  const ReportImportPage({super.key});

  @override
  ConsumerState<ReportImportPage> createState() => _ReportImportPageState();
}

class _ReportImportPageState extends ConsumerState<ReportImportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导入报告')),
      body: const Center(child: Text('PDF导入功能 - 待实现')),
    );
  }
}
