import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/day_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/day_record.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/salary_provider.dart';
import '../../providers/settings_provider.dart';

class MonthReportScreen extends StatefulWidget {
  const MonthReportScreen({super.key});

  @override
  State<MonthReportScreen> createState() => _MonthReportScreenState();
}

class _MonthReportScreenState extends State<MonthReportScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = context.read<CalendarProvider>().selectedMonth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final calendarProvider = context.read<CalendarProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final salaryProvider = context.read<SalaryProvider>();

    calendarProvider.loadMonth(_selectedMonth.year, _selectedMonth.month);
    salaryProvider.calculateSummary(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
      records: calendarProvider.records,
      settings: settingsProvider.settings,
      tripsById: calendarProvider.tripsById,
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    context.read<CalendarProvider>().loadMonth(
          _selectedMonth.year,
          _selectedMonth.month,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    context.read<CalendarProvider>().loadMonth(
          _selectedMonth.year,
          _selectedMonth.month,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
          return CustomScrollView(
            slivers: [
              _buildHeader(salary),
              SliverToBoxAdapter(
                child: _buildContent(calendar, salary, settings),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SalaryProvider salary) {
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Отчёт за месяц',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMonthSelector(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Итого за месяц',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatCurrency(salary.totalEarned),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            AppDateUtils.formatMonthYear(_selectedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    CalendarProvider calendar,
    SalaryProvider salary,
    SettingsProvider settings,
  ) {
    final daysInMonth = AppDateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final List<_DayReportItem> reportItems = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final record = calendar.getRecordForDate(date);
      final dayType = calendar.getEffectiveDayType(date);
      final breakdown = salary.getDayBreakdown(
        date: date,
        record: record,
        settings: settings.settings,
        monthRecords: calendar.records,
        businessTrip: record?.businessTripId != null
            ? calendar.tripsById[record!.businessTripId]
            : null,
      );

      reportItems.add(_DayReportItem(
        date: date,
        record: record,
        dayType: dayType,
        total: breakdown?.total ?? 0,
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLegend(),
          const SizedBox(height: 16),
          _buildDaysList(reportItems),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildLegendItem('Рабочий', AppColors.accentGreen),
          _buildLegendItem('Выходной', AppColors.textMuted),
          _buildLegendItem('Больничный', AppColors.primaryBlue),
          _buildLegendItem('Командировка', AppColors.primaryPurple),
          _buildLegendItem('Работа в вых.', AppColors.accentOrange),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysList(List<_DayReportItem> items) {
    return Container(
      decoration: AppDecorations.card,
      child: Column(
        children: items.map((item) => _buildDayRow(item)).toList(),
      ),
    );
  }

  Widget _buildDayRow(_DayReportItem item) {
    final color = _getTypeColor(item.dayType);
    final isWeekend = item.date.weekday >= 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              '${item.date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isWeekend ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              _getDayOfWeekShort(item.date.weekday),
              style: TextStyle(
                fontSize: 12,
                color: isWeekend ? AppColors.accentOrange : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.dayType.displayName,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (item.record?.bonus != null && item.record!.bonus > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+бонус',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Text(
            _formatCurrency(item.total),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: item.total > 0 ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeekShort(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }

  Color _getTypeColor(DayType type) {
    switch (type) {
      case DayType.workDay:
        return AppColors.accentGreen;
      case DayType.weekendWork:
        return AppColors.accentOrange;
      case DayType.dayOff:
        return AppColors.textMuted;
      case DayType.sickLeave:
        return AppColors.primaryBlue;
      case DayType.businessTrip:
        return AppColors.primaryPurple;
    }
  }
}

class _DayReportItem {
  final DateTime date;
  final DayRecord? record;
  final DayType dayType;
  final double total;

  _DayReportItem({
    required this.date,
    required this.record,
    required this.dayType,
    required this.total,
  });
}
