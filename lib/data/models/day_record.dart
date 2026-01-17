import '../../core/enums/day_type.dart';
import '../../core/utils/date_utils.dart';

class DayRecord {
  final int? id;
  final DateTime date;
  final DayType type;
  final double bonus;
  final int? businessTripId;

  const DayRecord({
    this.id,
    required this.date,
    required this.type,
    this.bonus = 0,
    this.businessTripId,
  });

  DateTime get dateOnly => AppDateUtils.dateOnly(date);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': AppDateUtils.dateOnly(date).toIso8601String(),
      'type': type.index,
      'bonus': bonus,
      'business_trip_id': businessTripId,
    };
  }

  factory DayRecord.fromMap(Map<String, dynamic> map) {
    return DayRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      type: DayType.values[map['type'] as int],
      bonus: (map['bonus'] as num?)?.toDouble() ?? 0,
      businessTripId: map['business_trip_id'] as int?,
    );
  }

  DayRecord copyWith({
    int? id,
    DateTime? date,
    DayType? type,
    double? bonus,
    int? businessTripId,
  }) {
    return DayRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      bonus: bonus ?? this.bonus,
      businessTripId: businessTripId ?? this.businessTripId,
    );
  }

  factory DayRecord.workDay(DateTime date, {double bonus = 0}) {
    return DayRecord(
      date: date,
      type: DayType.workDay,
      bonus: bonus,
    );
  }

  factory DayRecord.dayOff(DateTime date) {
    return DayRecord(
      date: date,
      type: DayType.dayOff,
    );
  }

  factory DayRecord.sickLeave(DateTime date, {double bonus = 0}) {
    return DayRecord(
      date: date,
      type: DayType.sickLeave,
      bonus: bonus,
    );
  }

  factory DayRecord.businessTrip(
    DateTime date, {
    required int tripId,
    double bonus = 0,
  }) {
    return DayRecord(
      date: date,
      type: DayType.businessTrip,
      businessTripId: tripId,
      bonus: bonus,
    );
  }
}
