import 'package:flutter/material.dart';
import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  Settings _settings = Settings.empty();
  bool _isLoading = false;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  double get monthlySalary => _settings.monthlySalary;
  bool get hasSetSalary => _settings.monthlySalary > 0;
  String get themeModeString => _settings.themeMode;

  ThemeMode get themeMode {
    switch (_settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSalary(double salary) async {
    await _repository.updateSalary(salary);
    _settings = _settings.copyWith(monthlySalary: salary);
    notifyListeners();
  }

  Future<void> updateNotificationSettings({
    bool? enabled,
    int? daysBefore,
  }) async {
    await _repository.updateNotificationSettings(
      enabled: enabled,
      daysBefore: daysBefore,
    );
    _settings = _settings.copyWith(
      notificationsEnabled: enabled ?? _settings.notificationsEnabled,
      notifyDaysBefore: daysBefore ?? _settings.notifyDaysBefore,
    );
    notifyListeners();
  }

  Future<void> updateThemeMode(String mode) async {
    await _repository.updateThemeMode(mode);
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }
}
