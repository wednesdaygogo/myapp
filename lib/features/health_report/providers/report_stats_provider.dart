import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/person_report_stats.dart';
import '../../../data/models/person.dart';
import '../../person/providers/person_provider.dart';
import '../providers/health_report_provider.dart';

/// 单个家人的报告统计
final personReportStatsProvider = Provider.family<PersonReportStats, int>((ref, personId) {
  final allReports = ref.watch(healthReportsProvider);
  final personReports = allReports.where((r) => r.personId == personId).toList();

  if (personReports.isEmpty) {
    return PersonReportStats(personId: personId, reportCount: 0);
  }

  // 按日期排序，取最近
  personReports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
  final latestDate = personReports.first.reportDate;

  return PersonReportStats(
    personId: personId,
    reportCount: personReports.length,
    latestReportDate: latestDate,
  );
});

/// 所有家人的报告统计列表
final personsWithReportStatsProvider = Provider<List<PersonWithStats>>((ref) {
  final allReports = ref.watch(healthReportsProvider);
  final persons = ref.watch(personsProvider);

  return persons.map((person) {
    final reports = allReports.where((r) => r.personId == person.id).toList();
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));

    return PersonWithStats(
      person: person,
      stats: PersonReportStats(
        personId: person.id,
        reportCount: reports.length,
        latestReportDate: reports.isEmpty ? null : reports.first.reportDate,
      ),
    );
  }).toList();
});

/// 家人+统计组合结构
class PersonWithStats {
  final Person person;
  final PersonReportStats stats;

  const PersonWithStats({required this.person, required this.stats});
}