import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);
  }

  Future<bool> shouldShowOnboarding(double currentSalary) async {
    final completed = await isOnboardingCompleted();
    if (completed) return false;

    if (currentSalary > 0) {
      await completeOnboarding();
      return false;
    }

    return true;
  }
}
