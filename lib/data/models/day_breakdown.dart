class DayBreakdown {
  final DateTime date;
  final String typeName;
  final double baseSalary;
  final double sickLeaveAmount;
  final double businessTripAllowance;
  final double bonus;

  const DayBreakdown({
    required this.date,
    required this.typeName,
    required this.baseSalary,
    this.sickLeaveAmount = 0,
    this.businessTripAllowance = 0,
    this.bonus = 0,
  });

  double get total => baseSalary + sickLeaveAmount + businessTripAllowance + bonus;

  List<BreakdownItem> get items {
    final result = <BreakdownItem>[];

    if (baseSalary > 0) {
      result.add(BreakdownItem(name: 'Оклад за день', amount: baseSalary));
    }

    if (sickLeaveAmount > 0) {
      result.add(BreakdownItem(name: 'Больничный', amount: sickLeaveAmount));
    }

    if (businessTripAllowance > 0) {
      result.add(BreakdownItem(name: 'Суточные', amount: businessTripAllowance));
    }

    if (bonus > 0) {
      result.add(BreakdownItem(name: 'Бонус', amount: bonus));
    }

    return result;
  }
}

class BreakdownItem {
  final String name;
  final double amount;

  const BreakdownItem({
    required this.name,
    required this.amount,
  });
}
