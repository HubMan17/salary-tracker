import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/startup/startup_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/day_editor/day_editor_screen.dart';
import 'presentation/screens/business_trip/business_trip_screen.dart';
import 'presentation/screens/day_detail/day_detail_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';
import 'presentation/screens/month_report/month_report_screen.dart';

class SalaryTrackerApp extends StatelessWidget {
  const SalaryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Учёт зарплаты',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      initialRoute: '/startup',
      routes: {
        '/startup': (context) => const StartupScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/day-editor': (context) => const DayEditorScreen(),
        '/business-trip': (context) => const BusinessTripScreen(),
        '/day-detail': (context) => const DayDetailScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/month-report': (context) => const MonthReportScreen(),
      },
    );
  }
}
