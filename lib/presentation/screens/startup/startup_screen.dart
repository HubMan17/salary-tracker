import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/services/onboarding_service.dart';
import '../../providers/settings_provider.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineRoute();
    });
  }

  Future<void> _determineRoute() async {
    final settingsProvider = context.read<SettingsProvider>();

    while (settingsProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final onboardingService = OnboardingService();
    final shouldShow = await onboardingService.shouldShowOnboarding(
      settingsProvider.monthlySalary,
    );

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        shouldShow ? '/onboarding' : '/',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientHeader,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
