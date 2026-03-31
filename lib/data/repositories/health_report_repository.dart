import 'package:isar/isar.dart';
import '../models/health_report.dart';
import '../models/health_indicator.dart';

class HealthReportRepository {
  final Isar _isar;

  HealthReportRepository(this._isar);

  Future<int> insert(HealthReport report) async {
    return await _isar.writeTxn(() => _isar.healthReports.put(report));
  }

  Future<List<HealthReport>> getAll() async {
    return await _isar.healthReports.where().sortByReportDateDesc().findAll();
  }

  Future<HealthReport?> getById(int id) async {
    return await _isar.healthReports.get(id);
  }

  Future<List<HealthReport>> getByPersonId(int personId) async {
    return await _isar.healthReports
        .filter()
        .personIdEqualTo(personId)
        .sortByReportDateDesc()
        .findAll();
  }

  Future<int> update(HealthReport report) async {
    return await _isar.writeTxn(() => _isar.healthReports.put(report));
  }

  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      await _isar.healthIndicators.filter().reportIdEqualTo(id).deleteAll();
      return await _isar.healthReports.delete(id);
    });
  }

  Future<int> countByPersonId(int personId) async {
    return await _isar.healthReports.filter().personIdEqualTo(personId).count();
  }
}
