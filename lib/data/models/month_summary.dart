class MonthSummary {
  final int year;
  final int month;
  final double baseSalaryEarned;
  final double sickLeaveAmount;
  final double businessTripAllowance;
  final double totalBonuses;
  final int workedDays;
  final int sickDays;
  final int businessTripDays;
  final int totalWorkDaysInMonth;
  final double dailyRate;

  const MonthSummary({
    required this.year,
    required this.month,
    required this.baseSalaryEarned,
    required this.sickLeaveAmount,
    required this.businessTripAllowance,
    required this.totalBonuses,
    required this.workedDays,
    required this.sickDays,
    required this.businessTripDays,
    required this.totalWorkDaysInMonth,
    required this.dailyRate,
  });

  double get totalEarned =>
      baseSalaryEarned + sickLeaveAmount + businessTripAllowance + totalBonuses;

  double get expectedSalary => dailyRate * totalWorkDaysInMonth;

  double get progressPercent {
    if (expectedSalary <= 0) return 0;
    return (totalEarned / expectedSalary * 100).clamp(0, 100);
  }

  int get daysOff {
    return totalWorkDaysInMonth - workedDays - sickDays - businessTripDays;
  }

  factory MonthSummary.empty(int year, int month) {
    return MonthSummary(
      year: year,
      month: month,
      baseSalaryEarned: 0,
      sickLeaveAmount: 0,
      businessTripAllowance: 0,
      totalBonuses: 0,
      workedDays: 0,
      sickDays: 0,
      businessTripDays: 0,
      totalWorkDaysInMonth: 0,
      dailyRate: 0,
    );
  }
}
