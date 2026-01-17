import '../database/storage_factory.dart';
import '../models/settings.dart';

class SettingsRepository {
  Future<Settings> getSettings() async {
    return await StorageFactory.instance.getSettings();
  }

  Future<void> updateSettings(Settings settings) async {
    await StorageFactory.instance.updateSettings(settings);
  }

  Future<void> updateSalary(double salary) async {
    await StorageFactory.instance.updateSalary(salary);
  }

  Future<void> updateNotificationSettings({
    bool? enabled,
    int? daysBefore,
  }) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(
      notificationsEnabled: enabled ?? current.notificationsEnabled,
      notifyDaysBefore: daysBefore ?? current.notifyDaysBefore,
    ));
  }
}
