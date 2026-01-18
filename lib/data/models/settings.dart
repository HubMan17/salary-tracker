class Settings {
  final int? id;
  final double monthlySalary;
  final bool notificationsEnabled;
  final int notifyDaysBefore;
  final String themeMode;

  const Settings({
    this.id,
    required this.monthlySalary,
    this.notificationsEnabled = true,
    this.notifyDaysBefore = 2,
    this.themeMode = 'system',
  });

  double getDailyRate(int workDaysInMonth) {
    if (workDaysInMonth <= 0) return 0;
    return monthlySalary / workDaysInMonth;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthly_salary': monthlySalary,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'notify_days_before': notifyDaysBefore,
      'theme_mode': themeMode,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int?,
      monthlySalary: (map['monthly_salary'] as num).toDouble(),
      notificationsEnabled: map['notifications_enabled'] == 1,
      notifyDaysBefore: map['notify_days_before'] as int? ?? 2,
      themeMode: map['theme_mode'] as String? ?? 'system',
    );
  }

  Settings copyWith({
    int? id,
    double? monthlySalary,
    bool? notificationsEnabled,
    int? notifyDaysBefore,
    String? themeMode,
  }) {
    return Settings(
      id: id ?? this.id,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory Settings.empty() {
    return const Settings(monthlySalary: 0);
  }
}
