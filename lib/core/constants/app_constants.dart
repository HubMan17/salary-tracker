class AppConstants {
  AppConstants._();

  static const double dailyAllowanceFirstLast = 350.0;
  static const double dailyAllowanceMiddle = 700.0;

  static const int sickLeaveFullPayDays = 3;
  static const double sickLeaveReducedRate = 0.5;

  static const int defaultNotifyDaysBefore = 2;

  static const String githubRepoOwner = 'HubMan17';
  static const String githubRepoName = 'salary-tracker';
  static const String githubReleasesApiUrl =
      'https://api.github.com/repos/HubMan17/salary-tracker/releases/latest';
  static const String updateCacheKey = 'cached_update_info';
  static const String lastUpdateCheckKey = 'last_update_check';
  static const Duration updateCacheValidity = Duration(hours: 6);
}
