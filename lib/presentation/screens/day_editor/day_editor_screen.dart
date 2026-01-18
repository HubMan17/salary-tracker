import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/day_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/day_record.dart';
import '../../providers/calendar_provider.dart';

class DayEditorScreen extends StatefulWidget {
  const DayEditorScreen({super.key});

  @override
  State<DayEditorScreen> createState() => _DayEditorScreenState();
}

class _DayEditorScreenState extends State<DayEditorScreen> {
  late DateTime _date;
  DayType _selectedType = DayType.workDay;
  final _bonusController = TextEditingController();
  bool _isInitialized = false;
  bool _isExistingBusinessTrip = false;
  int? _existingBusinessTripId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _date = ModalRoute.of(context)?.settings.arguments as DateTime? ??
          DateTime.now();
      final record = context.read<CalendarProvider>().getRecordForDate(_date);
      if (record != null) {
        _selectedType = record.type;
        if (record.bonus > 0) {
          _bonusController.text = record.bonus.toStringAsFixed(0);
        }
        if (record.type == DayType.businessTrip && record.businessTripId != null) {
          _isExistingBusinessTrip = true;
          _existingBusinessTripId = record.businessTripId;
        }
      } else if (AppDateUtils.isWeekend(_date)) {
        _selectedType = DayType.dayOff;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _bonusController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bonus = double.tryParse(_bonusController.text) ?? 0;

    if (_selectedType == DayType.businessTrip && !_isExistingBusinessTrip) {
      await Navigator.pushNamed(context, '/business-trip', arguments: _date);
      if (mounted) Navigator.pop(context);
      return;
    }

    final record = DayRecord(
      date: _date,
      type: _selectedType,
      bonus: bonus,
      businessTripId: _isExistingBusinessTrip ? _existingBusinessTripId : null,
    );

    await context.read<CalendarProvider>().updateDay(record);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await context.read<CalendarProvider>().deleteDay(_date);
    if (mounted) Navigator.pop(context);
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

  IconData _getTypeIcon(DayType type) {
    switch (type) {
      case DayType.workDay:
        return Icons.work_outline;
      case DayType.weekendWork:
        return Icons.weekend_outlined;
      case DayType.dayOff:
        return Icons.bed_outlined;
      case DayType.sickLeave:
        return Icons.local_hospital_outlined;
      case DayType.businessTrip:
        return Icons.flight_takeoff_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingRecord =
        context.read<CalendarProvider>().getRecordForDate(_date);

    return Scaffold(
      backgroundColor: context.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(existingRecord != null),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasRecord) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  AppDateUtils.formatDate(_date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasRecord)
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Удалить запись?'),
                          content: const Text(
                            'День вернётся к значению по умолчанию',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentRed,
                              ),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _delete();
                      }
                    },
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.white),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTypeCard(),
          const SizedBox(height: 16),
          _buildBonusCard(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTypeCard() {
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
                  Icons.category_outlined,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Тип дня',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...DayType.values.map((type) => _buildTypeOption(type)),
        ],
      ),
    );
  }

  Widget _buildTypeOption(DayType type) {
    final isSelected = _selectedType == type;
    final color = _getTypeColor(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getTypeIcon(type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? context.textPrimary : context.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusCard() {
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
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard_outlined,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Дополнительный бонус',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _bonusController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: context.textMuted.withValues(alpha: 0.5),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              suffixText: '₽',
              suffixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              filled: true,
              fillColor: context.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Премия, доплата или другие начисления за этот день',
            style: TextStyle(
              fontSize: 12,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _save,
          icon: Icon(
            _selectedType == DayType.businessTrip && !_isExistingBusinessTrip
                ? Icons.flight_takeoff
                : Icons.check,
            color: Colors.white,
          ),
          label: Text(
            _selectedType == DayType.businessTrip && !_isExistingBusinessTrip
                ? 'Создать командировку'
                : 'Сохранить',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
