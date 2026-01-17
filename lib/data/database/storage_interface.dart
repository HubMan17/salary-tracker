import '../models/settings.dart';
import '../models/day_record.dart';
import '../models/business_trip.dart';

abstract class StorageInterface {
  Future<void> initialize();

  Future<Settings> getSettings();
  Future<void> updateSettings(Settings settings);
  Future<void> updateSalary(double salary);

  Future<List<DayRecord>> getDayRecordsByMonth(int year, int month);
  Future<DayRecord?> getDayRecordByDate(DateTime date);
  Future<void> upsertDayRecord(DayRecord record);
  Future<void> deleteDayRecord(DateTime date);
  Future<void> deleteDayRecordsByTripId(int tripId);

  Future<List<BusinessTrip>> getBusinessTripsByMonth(int year, int month);
  Future<BusinessTrip?> getBusinessTripById(int id);
  Future<int> insertBusinessTrip(BusinessTrip trip);
  Future<void> deleteBusinessTrip(int id);
}
