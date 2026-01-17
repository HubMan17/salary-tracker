enum DayType {
  workDay,
  weekendWork,
  dayOff,
  sickLeave,
  businessTrip,
}

extension DayTypeExtension on DayType {
  String get displayName {
    switch (this) {
      case DayType.workDay:
        return 'Рабочий день';
      case DayType.weekendWork:
        return 'Работа в выходной';
      case DayType.dayOff:
        return 'Выходной/Пропуск';
      case DayType.sickLeave:
        return 'Больничный';
      case DayType.businessTrip:
        return 'Командировка';
    }
  }

  String get shortName {
    switch (this) {
      case DayType.workDay:
        return 'Р';
      case DayType.weekendWork:
        return 'РВ';
      case DayType.dayOff:
        return 'В';
      case DayType.sickLeave:
        return 'Б';
      case DayType.businessTrip:
        return 'К';
    }
  }
}
