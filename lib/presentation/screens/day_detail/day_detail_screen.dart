import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/salary_provider.dart';

class DayDetailScreen extends StatelessWidget {
  const DayDetailScreen({super.key});

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        )} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)?.settings.arguments as DateTime?;
    if (date == null) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(child: Text('Дата не указана', style: TextStyle(color: context.textPrimary))),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      body: Consumer3<CalendarProvider, SettingsProvider, SalaryProvider>(
        builder: (context, calendar, settings, salary, _) {
          final record = calendar.getRecordForDate(date);
          final businessTrip = calendar.getTripForDate(date);
          final breakdown = salary.getDayBreakdown(
            date: date,
            record: record,
            settings: settings.settings,
            monthRecords: calendar.records,
            businessTrip: businessTrip,
          );

          return CustomScrollView(
            slivers: [
              _buildHeader(context, date, breakdown?.total ?? 0),
              SliverToBoxAdapter(
                child: _buildContent(context, date, breakdown, businessTrip),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime date, double total) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      AppDateUtils.formatDate(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/day-editor',
                          arguments: date,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _formatCurrency(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Заработано за день',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DateTime date,
    dynamic breakdown,
    dynamic businessTrip,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (breakdown != null) ...[
            _buildTypeCard(context, breakdown),
            const SizedBox(height: 16),
            _buildDetailsCard(context, breakdown),
          ],
          if (businessTrip != null) ...[
            const SizedBox(height: 16),
            _buildTripCard(context, businessTrip),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeCard(BuildContext context, dynamic breakdown) {
    Color accentColor;
    IconData icon;

    switch (breakdown.typeName) {
      case 'Рабочий день':
        accentColor = AppColors.accentGreen;
        icon = Icons.work_outline;
        break;
      case 'Работа в выходной':
        accentColor = AppColors.accentOrange;
        icon = Icons.weekend_outlined;
        break;
      case 'Выходной':
        accentColor = context.textMuted;
        icon = Icons.bed_outlined;
        break;
      case 'Больничный':
        accentColor = AppColors.primaryBlue;
        icon = Icons.local_hospital_outlined;
        break;
      case 'Командировка':
        accentColor = AppColors.primaryPurple;
        icon = Icons.flight_takeoff_outlined;
        break;
      default:
        accentColor = context.textSecondary;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тип дня',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  breakdown.typeName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, dynamic breakdown) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Детализация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (breakdown.items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: context.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Нет начислений за этот день',
                    style: TextStyle(color: context.textMuted),
                  ),
                ],
              ),
            )
          else
            ...breakdown.items.map<Widget>((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        _formatCurrency(item.amount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого за день',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatCurrency(breakdown.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, dynamic businessTrip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff_outlined,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Командировка',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTripInfoRow(
            context,
            Icons.date_range_outlined,
            'Период',
            '${AppDateUtils.formatDate(businessTrip.startDate)} — ${AppDateUtils.formatDate(businessTrip.endDate)}',
          ),
          if (businessTrip.destination != null)
            _buildTripInfoRow(
              context,
              Icons.location_on_outlined,
              'Направление',
              businessTrip.destination!,
            ),
          _buildTripInfoRow(
            context,
            Icons.calendar_today_outlined,
            'Всего дней',
            '${businessTrip.totalDays}',
          ),
          _buildTripInfoRow(
            context,
            Icons.payments_outlined,
            'Суточные',
            _formatCurrency(businessTrip.totalAllowance),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
