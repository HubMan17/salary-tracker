import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'data/database/storage_factory.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/update_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/calendar_provider.dart';
import 'presentation/providers/salary_provider.dart';
import 'presentation/providers/update_provider.dart';

const String updateCheckTask = 'checkForUpdates';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == updateCheckTask) {
      try {
        final updateService = UpdateService();
        final info = await updateService.checkForUpdates(forceCheck: true);

        if (info.hasUpdate) {
          final notificationService = NotificationService();
          await notificationService.initialize();
          await notificationService.showUpdateNotification(
            info.latestVersion,
            info.releaseNotes,
          );
        }
      } catch (e) {
        debugPrint('Background update check failed: $e');
      }
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  await StorageFactory.initialize();

  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'updateCheckTask',
      updateCheckTask,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider()
            ..loadMonth(DateTime.now().year, DateTime.now().month),
        ),
        ChangeNotifierProvider(
          create: (_) => SalaryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UpdateProvider()..checkForUpdates(),
        ),
      ],
      child: const SalaryTrackerApp(),
    ),
  );
}
