import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/database/storage_factory.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/calendar_provider.dart';
import 'presentation/providers/salary_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  await StorageFactory.initialize();

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
      ],
      child: const SalaryTrackerApp(),
    ),
  );
}
