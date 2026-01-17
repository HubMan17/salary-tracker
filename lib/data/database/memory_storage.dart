import '../../core/utils/date_utils.dart';
import '../models/settings.dart';
import '../models/day_record.dart';
import '../models/business_trip.dart';
import 'storage_interface.dart';

class MemoryStorage implements StorageInterface {
  static final MemoryStorage instance = MemoryStorage._();
  MemoryStorage._();

  Settings _settings = const Settings(monthlySalary: 0);
  final Map<String, DayRecord> _dayRecords = {};
  final Map<int, BusinessTrip> _businessTrips = {};
  int _tripIdCounter = 1;
  int _recordIdCounter = 1;

  @override
  Future<void> initialize() async {}

  @override
  Future<Settings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(Settings settings) async {
    _settings = settings.copyWith(id: 1);
  }

  @override
  Future<void> updateSalary(double salary) async {
    _settings = _settings.copyWith(monthlySalary: salary);
  }

  @override
  Future<List<DayRecord>> getDayRecordsByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    return _dayRecords.values.where((r) {
      final date = AppDateUtils.dateOnly(r.date);
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<DayRecord?> getDayRecordByDate(DateTime date) async {
    return _dayRecords[_dateKey(date)];
  }

  @override
  Future<void> upsertDayRecord(DayRecord record) async {
    final key = _dateKey(record.date);
    final existing = _dayRecords[key];
    if (existing != null) {
      _dayRecords[key] = record.copyWith(id: existing.id);
    } else {
      _dayRecords[key] = record.copyWith(id: _recordIdCounter++);
    }
  }

  @override
  Future<void> deleteDayRecord(DateTime date) async {
    _dayRecords.remove(_dateKey(date));
  }

  @override
  Future<void> deleteDayRecordsByTripId(int tripId) async {
    _dayRecords.removeWhere((_, r) => r.businessTripId == tripId);
  }

  @override
  Future<List<BusinessTrip>> getBusinessTripsByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);

    return _businessTrips.values.where((trip) {
      return (trip.startDate.isBefore(endOfMonth) ||
              AppDateUtils.isSameDay(trip.startDate, endOfMonth)) &&
             (trip.endDate.isAfter(startOfMonth) ||
              AppDateUtils.isSameDay(trip.endDate, startOfMonth));
    }).toList();
  }

  @override
  Future<BusinessTrip?> getBusinessTripById(int id) async {
    return _businessTrips[id];
  }

  @override
  Future<int> insertBusinessTrip(BusinessTrip trip) async {
    final id = _tripIdCounter++;
    _businessTrips[id] = trip.copyWith(id: id);
    return id;
  }

  @override
  Future<void> deleteBusinessTrip(int id) async {
    _businessTrips.remove(id);
  }

  String _dateKey(DateTime date) {
    return AppDateUtils.dateOnly(date).toIso8601String();
  }
}
