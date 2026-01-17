import '../constants/app_constants.dart';
import '../enums/day_type.dart';
import '../../data/models/business_trip.dart';
import '../../data/models/day_breakdown.dart';
import '../../data/models/day_record.dart';
import '../../data/models/month_summary.dart';
import '../../data/models/settings.dart';
import 'date_utils.dart';

class SalaryCalculator {
  SalaryCalculator._();

  static DayBreakdown calculateDayBreakdown({
    required DateTime date,
    required DayType type,
    required double dailyRate,
    required int sickDayNumberInMonth,
    BusinessTrip? businessTrip,
    double bonus = 0,
  }) {
    double baseSalary = 0;
    double sickLeaveAmount = 0;
    double businessTripAllowance = 0;

    switch (type) {
      case DayType.workDay:
      case DayType.weekendWork:
        baseSalary = dailyRate;
        break;

      case DayType.dayOff:
        break;

      case DayType.sickLeave:
        if (sickDayNumberInMonth <= AppConstants.sickLeaveFullPayDays) {
          sickLeaveAmount = dailyRate;
        } else {
          sickLeaveAmount = dailyRate * AppConstants.sickLeaveReducedRate;
        }
        break;

      case DayType.businessTrip:
        baseSalary = dailyRate;
        if (businessTrip != null) {
          businessTripAllowance = businessTrip.calculateDailyAllowance(date);
        }
        break;
    }

    return DayBreakdown(
      date: date,
      typeName: type.displayName,
      baseSalary: baseSalary,
      sickLeaveAmount: sickLeaveAmount,
      businessTripAllowance: businessTripAllowance,
      bonus: bonus,
    );
  }

  static int getSickDayNumber(
    DateTime date,
    List<DayRecord> monthRecords,
  ) {
    final sickRecords = monthRecords
        .where((r) => r.type == DayType.sickLeave)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    int number = 0;
    for (final record in sickRecords) {
      number++;
      if (AppDateUtils.isSameDay(record.date, date)) {
        return number;
      }
    }
    return number + 1;
  }

  static MonthSummary calculateMonthSummary({
    required int year,
    required int month,
    required List<DayRecord> records,
    required Settings settings,
    required Map<int, BusinessTrip> tripsById,
  }) {
    final workDaysInMonth = AppDateUtils.getWorkDaysInMonth(year, month);
    final dailyRate = settings.getDailyRate(workDaysInMonth);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrentMonth = year == now.year && month == now.month;

    double baseSalaryEarned = 0;
    double sickLeaveAmount = 0;
    double businessTripAllowance = 0;
    double totalBonuses = 0;
    int workedDays = 0;
    int sickDays = 0;
    int businessTripDays = 0;

    final recordsByDate = <String, DayRecord>{};
    for (final record in records) {
      recordsByDate[AppDateUtils.dateKey(record.date)] = record;
    }

    final sortedRecords = List<DayRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    int sickDayCounter = 0;
    for (final record in sortedRecords) {
      if (record.type == DayType.sickLeave) {
        sickDayCounter++;
      }
    }
    sickDays = sickDayCounter;

    sickDayCounter = 0;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      final dayDate = DateTime(day.year, day.month, day.day);
      final dateKey = AppDateUtils.dateKey(day);
      final record = recordsByDate[dateKey];

      if (record != null) {
        totalBonuses += record.bonus;

        switch (record.type) {
          case DayType.workDay:
          case DayType.weekendWork:
            baseSalaryEarned += dailyRate;
            workedDays++;
            break;

          case DayType.dayOff:
            break;

          case DayType.sickLeave:
            sickDayCounter++;
            if (sickDayCounter <= AppConstants.sickLeaveFullPayDays) {
              sickLeaveAmount += dailyRate;
            } else {
              sickLeaveAmount += dailyRate * AppConstants.sickLeaveReducedRate;
            }
            break;

          case DayType.businessTrip:
            baseSalaryEarned += dailyRate;
            businessTripDays++;
            if (record.businessTripId != null) {
              final trip = tripsById[record.businessTripId];
              if (trip != null) {
                businessTripAllowance +=
                    trip.calculateDailyAllowance(record.date);
              }
            }
            break;
        }
      } else {
        if (isCurrentMonth &&
            !AppDateUtils.isWeekend(day) &&
            !dayDate.isAfter(today)) {
          baseSalaryEarned += dailyRate;
          workedDays++;
        }
      }
    }

    return MonthSummary(
      year: year,
      month: month,
      baseSalaryEarned: baseSalaryEarned,
      sickLeaveAmount: sickLeaveAmount,
      businessTripAllowance: businessTripAllowance,
      totalBonuses: totalBonuses,
      workedDays: workedDays,
      sickDays: sickDays,
      businessTripDays: businessTripDays,
      totalWorkDaysInMonth: workDaysInMonth,
      dailyRate: dailyRate,
    );
  }

  static double calculateEarnedToDate({
    required DateTime now,
    required List<DayRecord> monthRecords,
    required Settings settings,
    required Map<int, BusinessTrip> tripsById,
  }) {
    final workDaysInMonth =
        AppDateUtils.getWorkDaysInMonth(now.year, now.month);
    final dailyRate = settings.getDailyRate(workDaysInMonth);
    final today = DateTime(now.year, now.month, now.day);

    double earned = 0;
    int sickDayCounter = 0;

    final recordsByDate = <String, DayRecord>{};
    for (final record in monthRecords) {
      recordsByDate[AppDateUtils.dateKey(record.date)] = record;
    }

    final sortedRecords = monthRecords
        .where((r) => !r.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final record in sortedRecords) {
      if (record.type == DayType.sickLeave) {
        sickDayCounter++;
      }
    }
    sickDayCounter = 0;

    final firstDay = DateTime(now.year, now.month, 1);

    for (var day = firstDay;
        !day.isAfter(today);
        day = day.add(const Duration(days: 1))) {
      final dateKey = AppDateUtils.dateKey(day);
      final record = recordsByDate[dateKey];

      if (record != null) {
        earned += record.bonus;

        switch (record.type) {
          case DayType.workDay:
          case DayType.weekendWork:
            earned += dailyRate;
            break;

          case DayType.dayOff:
            break;

          case DayType.sickLeave:
            sickDayCounter++;
            if (sickDayCounter <= AppConstants.sickLeaveFullPayDays) {
              earned += dailyRate;
            } else {
              earned += dailyRate * AppConstants.sickLeaveReducedRate;
            }
            break;

          case DayType.businessTrip:
            earned += dailyRate;
            if (record.businessTripId != null) {
              final trip = tripsById[record.businessTripId];
              if (trip != null) {
                earned += trip.calculateDailyAllowance(record.date);
              }
            }
            break;
        }
      } else {
        if (!AppDateUtils.isWeekend(day)) {
          earned += dailyRate;
        }
      }
    }

    return earned;
  }
}
