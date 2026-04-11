import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/features/health_report/providers/report_stats_provider.dart';
import 'package:health_records/features/health_report/providers/health_report_provider.dart';
import 'package:health_records/features/person/providers/person_provider.dart';

void main() {
  group('personReportStatsProvider', () {
    test('returns zero count and null date when no reports', () {
      final container = ProviderContainer();

      // Without any reports, stats should be empty
      final stats = container.read(personReportStatsProvider(1));
      expect(stats.reportCount, equals(0));
      expect(stats.latestReportDate, isNull);
      expect(stats.latestReportDateText, equals(''));
    });

    test('personsWithReportStatsProvider combines person and stats', () {
      final container = ProviderContainer();

      final personsWithStats = container.read(personsWithReportStatsProvider);

      // Returns list of PersonWithStats
      expect(personsWithStats, isA<List<PersonWithStats>>());
    });
  });
}