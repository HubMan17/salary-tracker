import 'package:flutter/foundation.dart';
import '../../core/enums/day_type.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/business_trip.dart';
import '../../data/models/day_record.dart';
import '../../data/repositories/business_trip_repository.dart';
import '../../data/repositories/day_record_repository.dart';

class CalendarProvider extends ChangeNotifier {
  final DayRecordRepository _dayRecordRepository;
  final BusinessTripRepository _businessTripRepository;

  DateTime _selectedMonth = DateTime.now();
  Map<String, DayRecord> _dayRecords = {};
  List<BusinessTrip> _trips = [];
  bool _isLoading = false;

  CalendarProvider({
    DayRecordRepository? dayRecordRepository,
    BusinessTripRepository? businessTripRepository,
  })  : _dayRecordRepository = dayRecordRepository ?? DayRecordRepository(),
        _businessTripRepository =
            businessTripRepository ?? BusinessTripRepository();

  DateTime get selectedMonth => _selectedMonth;
  List<DayRecord> get records => _dayRecords.values.toList();
  List<BusinessTrip> get trips => _trips;
  bool get isLoading => _isLoading;

  Map<int, BusinessTrip> get tripsById {
    return {for (final trip in _trips) if (trip.id != null) trip.id!: trip};
  }

  Future<void> loadMonth(int year, int month) async {
    _selectedMonth = DateTime(year, month);
    _isLoading = true;
    notifyListeners();

    try {
      final recordsList = await _dayRecordRepository.getByMonth(year, month);
      _dayRecords = {
        for (final r in recordsList) _dateKey(r.date): r,
      };

      _trips = await _businessTripRepository.getByMonth(year, month);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentMonth() async {
    await loadMonth(_selectedMonth.year, _selectedMonth.month);
  }

  void goToNextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    loadMonth(next.year, next.month);
  }

  void goToPreviousMonth() {
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    loadMonth(prev.year, prev.month);
  }

  DayRecord? getRecordForDate(DateTime date) {
    return _dayRecords[_dateKey(date)];
  }

  BusinessTrip? getTripForDate(DateTime date) {
    for (final trip in _trips) {
      if (trip.containsDate(date)) {
        return trip;
      }
    }
    return null;
  }

  DayType getEffectiveDayType(DateTime date) {
    final record = getRecordForDate(date);
    if (record != null) {
      return record.type;
    }

    if (AppDateUtils.isWeekend(date)) {
      return DayType.dayOff;
    }

    return DayType.workDay;
  }

  Future<void> updateDay(DayRecord record) async {
    await _dayRecordRepository.upsert(record);
    _dayRecords[_dateKey(record.date)] = record;
    notifyListeners();
  }

  Future<void> deleteDay(DateTime date) async {
    await _dayRecordRepository.deleteByDate(date);
    _dayRecords.remove(_dateKey(date));
    notifyListeners();
  }

  Future<int> createBusinessTrip(BusinessTrip trip) async {
    final tripId = await _businessTripRepository.insert(trip);

    for (final date in trip.getAllDates()) {
      final record = DayRecord.businessTrip(date, tripId: tripId);
      await _dayRecordRepository.upsert(record);
    }

    await refreshCurrentMonth();
    return tripId;
  }

  Future<void> deleteBusinessTrip(int tripId) async {
    await _dayRecordRepository.deleteByBusinessTripId(tripId);
    await _businessTripRepository.delete(tripId);
    await refreshCurrentMonth();
  }

  String _dateKey(DateTime date) {
    return AppDateUtils.dateOnly(date).toIso8601String();
  }

  List<DayRecord> getBusinessTripRecords() {
    return records.where((r) => r.type == DayType.businessTrip).toList();
  }
}
