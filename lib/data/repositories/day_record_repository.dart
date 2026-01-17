import '../database/storage_factory.dart';
import '../models/day_record.dart';

class DayRecordRepository {
  Future<void> upsert(DayRecord record) async {
    await StorageFactory.instance.upsertDayRecord(record);
  }

  Future<void> deleteByDate(DateTime date) async {
    await StorageFactory.instance.deleteDayRecord(date);
  }

  Future<DayRecord?> getByDate(DateTime date) async {
    return await StorageFactory.instance.getDayRecordByDate(date);
  }

  Future<List<DayRecord>> getByMonth(int year, int month) async {
    return await StorageFactory.instance.getDayRecordsByMonth(year, month);
  }

  Future<void> deleteByBusinessTripId(int tripId) async {
    await StorageFactory.instance.deleteDayRecordsByTripId(tripId);
  }
}
