import 'package:flutter/foundation.dart';

import '../../domain/services/onboarding_service.dart';
import 'settings_provider.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _service;

  int _currentPage = 0;
  double _enteredSalary = 0;
  bool _isCompleting = false;

  OnboardingProvider({OnboardingService? service})
      : _service = service ?? OnboardingService();

  int get currentPage => _currentPage;
  double get enteredSalary => _enteredSalary;
  bool get isCompleting => _isCompleting;
  bool get canProceedFromSalary => _enteredSalary > 0;

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page <= 2) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void setSalary(double salary) {
    _enteredSalary = salary;
    notifyListeners();
  }

  Future<void> completeOnboarding(SettingsProvider settingsProvider) async {
    _isCompleting = true;
    notifyListeners();

    try {
      if (_enteredSalary > 0) {
        await settingsProvider.updateSalary(_enteredSalary);
      }
      await _service.completeOnboarding();
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }
}
