import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/welcome_page.dart';
import 'widgets/salary_input_page.dart';
import 'widgets/thank_you_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late OnboardingProvider _onboardingProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingProvider = OnboardingProvider();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _onboardingProvider.goToPage(page);
  }

  void _nextPage() {
    if (_onboardingProvider.currentPage < 2) {
      _goToPage(_onboardingProvider.currentPage + 1);
    }
  }

  void _previousPage() {
    if (_onboardingProvider.currentPage > 0) {
      _goToPage(_onboardingProvider.currentPage - 1);
    }
  }

  Future<void> _completeOnboarding() async {
    final settingsProvider = context.read<SettingsProvider>();
    await _onboardingProvider.completeOnboarding(settingsProvider);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _onboardingProvider,
      child: Scaffold(
        body: Container(
          decoration: AppDecorations.gradientHeader,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      _onboardingProvider.goToPage(page);
                    },
                    children: [
                      WelcomePage(onNext: _nextPage),
                      Consumer<OnboardingProvider>(
                        builder: (context, provider, _) {
                          return SalaryInputPage(
                            initialSalary: provider.enteredSalary,
                            onSalaryChanged: provider.setSalary,
                            onBack: _previousPage,
                            onComplete: _nextPage,
                            canComplete: provider.canProceedFromSalary,
                            isLoading: false,
                          );
                        },
                      ),
                      Consumer<OnboardingProvider>(
                        builder: (context, provider, _) {
                          return ThankYouPage(
                            onComplete: _completeOnboarding,
                            isLoading: provider.isCompleting,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = index == provider.currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
