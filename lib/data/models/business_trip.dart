import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class BusinessTrip {
  final int? id;
  final DateTime startDate;
  final DateTime endDate;
  final String? destination;
  final String? description;

  const BusinessTrip({
    this.id,
    required this.startDate,
    required this.endDate,
    this.destination,
    this.description,
  });

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  double calculateDailyAllowance(DateTime day) {
    return AppConstants.dailyAllowance;
  }

  bool containsDate(DateTime date) {
    final dayOnly = AppDateUtils.dateOnly(date);
    final startOnly = AppDateUtils.dateOnly(startDate);
    final endOnly = AppDateUtils.dateOnly(endDate);

    return !dayOnly.isBefore(startOnly) && !dayOnly.isAfter(endOnly);
  }

  List<DateTime> getAllDates() {
    final dates = <DateTime>[];
    var current = AppDateUtils.dateOnly(startDate);
    final end = AppDateUtils.dateOnly(endDate);

    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  double get totalAllowance {
    double total = 0;
    for (final date in getAllDates()) {
      total += calculateDailyAllowance(date);
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'destination': destination,
      'description': description,
    };
  }

  factory BusinessTrip.fromMap(Map<String, dynamic> map) {
    return BusinessTrip(
      id: map['id'] as int?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      destination: map['destination'] as String?,
      description: map['description'] as String?,
    );
  }

  BusinessTrip copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? description,
  }) {
    return BusinessTrip(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      description: description ?? this.description,
    );
  }
}
