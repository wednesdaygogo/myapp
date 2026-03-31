import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/health_report.dart';
import '../../../data/repositories/health_report_repository.dart';

// Repository provider
final healthReportRepositoryProvider = Provider<HealthReportRepository>((ref) {
  throw UnimplementedError('Must override with actual Isar instance');
});

// All reports list
final reportsProvider = FutureProvider<List<HealthReport>>((ref) async {
  final repository = ref.watch(healthReportRepositoryProvider);
  return await repository.getAll();
});

// Reports for a specific person
final reportsByPersonProvider =
    FutureProvider.family<List<HealthReport>, int>((ref, personId) async {
  final repository = ref.watch(healthReportRepositoryProvider);
  return await repository.getByPersonId(personId);
});

// Selected report
final selectedReportIdProvider = StateProvider<int?>((ref) => null);

final selectedReportProvider = FutureProvider<HealthReport?>((ref) async {
  final id = ref.watch(selectedReportIdProvider);
  if (id == null) return null;
  final repository = ref.watch(healthReportRepositoryProvider);
  return await repository.getById(id);
});

// Report CRUD notifier
class ReportNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReportNotifier(this._ref) : super(const AsyncData(null));

  Future<int?> createReport(HealthReport report) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(healthReportRepositoryProvider);
      final id = await repository.insert(report);
      _ref.invalidate(reportsProvider);
      _ref.invalidate(reportsByPersonProvider(report.personId));
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> updateReport(HealthReport report) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(healthReportRepositoryProvider);
      await repository.update(report);
      _ref.invalidate(reportsProvider);
      _ref.invalidate(selectedReportProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteReport(int id, int personId) async {
    state = const AsyncLoading();
    try {
      final repository = _ref.read(healthReportRepositoryProvider);
      await repository.delete(id);
      _ref.invalidate(reportsProvider);
      _ref.invalidate(reportsByPersonProvider(personId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final reportNotifierProvider =
    StateNotifierProvider<ReportNotifier, AsyncValue<void>>((ref) {
  return ReportNotifier(ref);
});

// Selected person for filtering reports
final selectedPersonFilterProvider = StateProvider<int?>((ref) => null);

final filteredReportsProvider = FutureProvider<List<HealthReport>>((ref) async {
  final personId = ref.watch(selectedPersonFilterProvider);
  final repository = ref.read(healthReportRepositoryProvider);

  if (personId == null) {
    return await repository.getAll();
  }
  return await repository.getByPersonId(personId);
});
