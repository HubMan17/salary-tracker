import 'package:flutter/foundation.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/salary_calculator.dart';
import '../../data/models/business_trip.dart';
import '../../data/models/day_breakdown.dart';
import '../../data/models/day_record.dart';
import '../../data/models/month_summary.dart';
import '../../data/models/settings.dart';

class SalaryProvider extends ChangeNotifier {
  MonthSummary? _currentMonthSummary;
  double _earnedToDate = 0;

  MonthSummary? get summary => _currentMonthSummary;
  double get earnedToDate => _earnedToDate;
  double get expectedSalary => _currentMonthSummary?.expectedSalary ?? 0;
  double get totalEarned => _currentMonthSummary?.totalEarned ?? 0;

  void calculateSummary({
    required int year,
    required int month,
    required List<DayRecord> records,
    required Settings settings,
    required Map<int, BusinessTrip> tripsById,
  }) {
    _currentMonthSummary = SalaryCalculator.calculateMonthSummary(
      year: year,
      month: month,
      records: records,
      settings: settings,
      tripsById: tripsById,
    );

    final now = DateTime.now();
    if (year == now.year && month == now.month) {
      _earnedToDate = SalaryCalculator.calculateEarnedToDate(
        now: now,
        monthRecords: records,
        settings: settings,
        tripsById: tripsById,
      );
    } else if (DateTime(year, month).isBefore(DateTime(now.year, now.month))) {
      _earnedToDate = _currentMonthSummary!.totalEarned;
    } else {
      _earnedToDate = 0;
    }

    notifyListeners();
  }

  DayBreakdown? getDayBreakdown({
    required DateTime date,
    required DayRecord? record,
    required Settings settings,
    required List<DayRecord> monthRecords,
    required BusinessTrip? businessTrip,
  }) {
    if (record == null) {
      if (AppDateUtils.isWeekend(date)) {
        return DayBreakdown(
          date: date,
          typeName: 'Выходной',
          baseSalary: 0,
        );
      }

      final workDays = AppDateUtils.getWorkDaysInMonth(date.year, date.month);
      final dailyRate = settings.getDailyRate(workDays);

      return DayBreakdown(
        date: date,
        typeName: 'Рабочий день',
        baseSalary: dailyRate,
      );
    }

    final workDays = AppDateUtils.getWorkDaysInMonth(date.year, date.month);
    final dailyRate = settings.getDailyRate(workDays);
    final sickDayNumber = SalaryCalculator.getSickDayNumber(date, monthRecords);

    return SalaryCalculator.calculateDayBreakdown(
      date: date,
      type: record.type,
      dailyRate: dailyRate,
      sickDayNumberInMonth: sickDayNumber,
      businessTrip: businessTrip,
      bonus: record.bonus,
    );
  }
}
