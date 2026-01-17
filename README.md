# DayPay

**Real-time salary tracking app for employees with fixed monthly salaries**

## About

Many salaried employees don't know exactly how much they've earned by any given day of the month. DayPay solves this problem by calculating your daily rate from your monthly salary and showing your accumulated earnings in real-time.

## Features

- **Daily Rate Calculation**: Your salary is divided by the number of working days in the month, giving you a precise daily rate
- **Real-time Earnings**: See exactly how much you've earned up to today
- **Day Types**: Track different day types - regular work, weekends, sick days, business trips, working on weekends - each calculated differently
- **Business Trips**: Automatic calculation of per diem allowances (daily allowances for travel)
- **Sick Leave**: First 3 days at 100%, subsequent days at 50% of daily rate
- **Bonuses**: Add extra payments for any day (overtime, night shifts, bonuses)
- **Visual Calendar**: Color-coded days showing past (earned) vs future days
- **Statistics & Reports**: Monthly breakdowns with income structure charts

## Who Is It For

For employees with fixed monthly salaries who want to:
- Know their exact earnings on any day of the month
- Track business trips and per diem allowances
- Plan finances by seeing salary accumulation progress
- Keep monthly earnings history

## Tech Stack

- **Framework**: Flutter (Dart)
- **Platform**: Android (APK)
- **Local Storage**: SQLite
- **State Management**: Provider

## Development

### Prerequisites

- Flutter SDK
- Android SDK
- Java JDK 17

### Running the app

```bash
# For development (Chrome)
flutter run -d chrome

# Build Android APK
flutter build apk --release
```

### Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # App configuration & routing
├── core/                  # Theme, constants, utilities
├── data/                  # Models, repositories, database
├── domain/                # Business logic & services
└── presentation/          # UI screens & providers
```

## Screenshots

*Coming soon*

## License

MIT License

## Author

**ZholobovA**
