import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/enums/day_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/salary_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateSalary();
    });
  }

  void _recalculateSalary() {
    final calendarProvider = context.read<CalendarProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final salaryProvider = context.read<SalaryProvider>();

    salaryProvider.calculateSummary(
      year: calendarProvider.selectedMonth.year,
      month: calendarProvider.selectedMonth.month,
      records: calendarProvider.records,
      settings: settingsProvider.settings,
      tripsById: calendarProvider.tripsById,
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        )} ₽';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer3<SettingsProvider, CalendarProvider, SalaryProvider>(
        builder: (context, settings, calendar, salary, _) {
          if (settings.isLoading || calendar.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
              ),
            );
          }

          if (!settings.hasSetSalary) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              _buildHeader(salary, calendar),
              SliverToBoxAdapter(
                child: _buildContent(calendar, salary),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.hasSetSalary) return const SizedBox.shrink();
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/business-trip');
                if (mounted) {
                  context.read<CalendarProvider>().refreshCurrentMonth();
                  _recalculateSalary();
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SalaryProvider salary, CalendarProvider calendar) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Учёт зарплаты',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/settings');
                        _recalculateSalary();
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildBalanceCard(salary, calendar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(SalaryProvider salary, CalendarProvider calendar) {
    final progress = salary.expectedSalary > 0
        ? (salary.earnedToDate / salary.expectedSalary).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatMonthYear(calendar.selectedMonth),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(salary.earnedToDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'из ${_formatCurrency(salary.expectedSalary)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              _buildCircularProgress(progress),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Рабочих дней',
                  '${salary.summary?.workedDays ?? 0}',
                  Icons.work_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  'Больничных',
                  '${salary.summary?.sickDays ?? 0}',
                  Icons.local_hospital_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  'Командировок',
                  '${salary.summary?.businessTripDays ?? 0}',
                  Icons.flight_takeoff_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double progress) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(CalendarProvider calendar, SalaryProvider salary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthSelector(calendar),
          const SizedBox(height: 16),
          _buildCalendar(calendar),
          const SizedBox(height: 16),
          _buildQuickStats(salary),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(CalendarProvider calendar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: AppDecorations.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              calendar.goToPreviousMonth();
              setState(() {
                _focusedDay = calendar.selectedMonth;
              });
              _recalculateSalary();
            },
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primaryPurple,
            ),
          ),
          Text(
            AppDateUtils.formatMonthYear(calendar.selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              calendar.goToNextMonth();
              setState(() {
                _focusedDay = calendar.selectedMonth;
              });
              _recalculateSalary();
            },
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(CalendarProvider calendar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        daysOfWeekHeight: 32,
        rowHeight: 42,
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          dowTextFormatter: _formatDayOfWeek,
        ),
        onDaySelected: (selectedDay, focusedDay) async {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          await Navigator.pushNamed(
            context,
            '/day-detail',
            arguments: selectedDay,
          );
          if (mounted) {
            calendar.refreshCurrentMonth();
            _recalculateSalary();
          }
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          calendar.loadMonth(focusedDay.year, focusedDay.month);
          _recalculateSalary();
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, calendar);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, calendar, isToday: true);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, calendar, isSelected: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, calendar, isOutside: true);
          },
        ),
        headerVisible: false,
      ),
    );
  }

  static String _formatDayOfWeek(DateTime date, dynamic locale) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }

  Widget _buildDayCell(
    DateTime day,
    CalendarProvider calendar, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final dayType = calendar.getEffectiveDayType(day);
    final record = calendar.getRecordForDate(day);
    final hasBonus = record != null && record.bonus > 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(day.year, day.month, day.day);
    final isPast = dayDate.isBefore(today);
    final isFuture = dayDate.isAfter(today);

    if (isOutside) {
      return Container(
        margin: const EdgeInsets.all(2),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    Color backgroundColor;
    Color textColor = AppColors.textPrimary;
    Color? borderColor;
    double colorAlpha = isPast ? 0.25 : 0.08;

    switch (dayType) {
      case DayType.workDay:
        backgroundColor = AppColors.accentGreen.withValues(alpha: colorAlpha);
        if (isFuture) textColor = AppColors.textSecondary;
        break;
      case DayType.weekendWork:
        backgroundColor = AppColors.accentOrange.withValues(alpha: colorAlpha);
        if (isFuture) textColor = AppColors.textSecondary;
        break;
      case DayType.dayOff:
        backgroundColor = isFuture
            ? AppColors.backgroundLight
            : AppColors.textMuted.withValues(alpha: 0.08);
        textColor = AppColors.textMuted;
        break;
      case DayType.sickLeave:
        backgroundColor = AppColors.primaryBlue.withValues(alpha: colorAlpha);
        if (isFuture) textColor = AppColors.textSecondary;
        break;
      case DayType.businessTrip:
        backgroundColor = AppColors.primaryPurple.withValues(alpha: colorAlpha);
        if (isFuture) textColor = AppColors.textSecondary;
        break;
    }

    if (isSelected) {
      borderColor = AppColors.primaryPurple;
    } else if (isToday) {
      borderColor = AppColors.primaryBlue;
      backgroundColor = AppColors.primaryBlue.withValues(alpha: 0.15);
      textColor = AppColors.primaryBlue;
    } else if (hasBonus && isPast) {
      borderColor = AppColors.accentOrange;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null
            ? Border.all(color: borderColor, width: isSelected ? 2 : 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight:
                isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(SalaryProvider salary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Базовый оклад',
            _formatCurrency(salary.summary?.baseSalaryEarned ?? 0),
            Icons.payments_outlined,
            AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Бонусы',
            _formatCurrency(salary.summary?.totalBonuses ?? 0),
            Icons.card_giftcard_outlined,
            AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Укажите ваш оклад в настройках,\nчтобы начать отслеживать зарплату',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/settings');
                    _recalculateSalary();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Открыть настройки'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Главная', 0),
              _buildNavItem(
                  Icons.receipt_long_outlined, Icons.receipt_long, 'Отчёт', 1),
              const SizedBox(width: 56),
              _buildNavItem(
                  Icons.bar_chart_outlined, Icons.bar_chart, 'Статистика', 2),
              _buildNavItem(
                  Icons.settings_outlined, Icons.settings, 'Настройки', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, '/month-report').then((_) {
            _recalculateSalary();
          });
        } else if (index == 2) {
          Navigator.pushNamed(context, '/statistics').then((_) {
            _recalculateSalary();
          });
        } else if (index == 3) {
          Navigator.pushNamed(context, '/settings').then((_) {
            _recalculateSalary();
          });
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primaryPurple : AppColors.textMuted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.primaryPurple : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
