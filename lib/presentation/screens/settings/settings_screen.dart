import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/update_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _salaryController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _salaryController.text = settings.monthlySalary > 0
        ? _formatNumber(settings.monthlySalary.toStringAsFixed(0))
        : '';
  }

  String _formatNumber(String value) {
    final digits = value.replaceAll(' ', '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _parseNumber(String value) {
    return value.replaceAll(' ', '');
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveSalary() async {
    final salary = double.tryParse(_parseNumber(_salaryController.text)) ?? 0;
    if (salary > 0) {
      await context.read<SettingsProvider>().updateSalary(salary);
      setState(() {
        _hasChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Оклад сохранён'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 32),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Настройки',
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
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSalaryCard(),
              const SizedBox(height: 16),
              _buildNotificationsCard(provider),
              const SizedBox(height: 16),
              _buildVersionCard(),
              const SizedBox(height: 16),
              _buildInfoCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
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
                  Icons.payments_outlined,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Месячный оклад',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
            ],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '80 000',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              suffixText: '₽',
              suffixStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              final cursorPos = _salaryController.selection.baseOffset;
              final digitsOnly = _parseNumber(value);
              final formatted = _formatNumber(digitsOnly);

              if (formatted != value) {
                final diff = formatted.length - value.length;
                _salaryController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                    offset: (cursorPos + diff).clamp(0, formatted.length),
                  ),
                );
              }

              setState(() {
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: _hasChanges
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppColors.textMuted.withValues(alpha: 0.3),
                          AppColors.textMuted.withValues(alpha: 0.3),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveSalary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(SettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
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
                  Icons.notifications_outlined,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Уведомления',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Напоминание о зарплате',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'За ${provider.settings.notifyDaysBefore} дня до конца месяца',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.settings.notificationsEnabled,
                  onChanged: (value) {
                    provider.updateNotificationSettings(enabled: value);
                  },
                  activeColor: AppColors.primaryPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, _) {
        final hasUpdate = updateProvider.hasUpdate;
        final isChecking = updateProvider.isChecking;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.system_update_outlined,
                      color: AppColors.accentTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Версия',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (hasUpdate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Текущая версия',
                updateProvider.currentVersion.isNotEmpty
                    ? updateProvider.currentVersion
                    : '1.0.0',
              ),
              if (hasUpdate) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Новая версия',
                  updateProvider.latestVersion,
                  valueColor: AppColors.accentGreen,
                ),
              ],
              if (hasUpdate && updateProvider.releaseNotes != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Что нового:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        updateProvider.releaseNotes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (hasUpdate)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => updateProvider.downloadUpdate(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Скачать обновление',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasUpdate) const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isChecking
                      ? null
                      : () => updateProvider.checkForUpdates(forceCheck: true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isChecking
                          ? AppColors.textMuted
                          : AppColors.primaryPurple,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryPurple,
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                  label: Text(
                    isChecking ? 'Проверка...' : 'Проверить обновления',
                    style: TextStyle(
                      color: isChecking
                          ? AppColors.textMuted
                          : AppColors.primaryPurple,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (updateProvider.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  updateProvider.error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accentRed,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
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
                  Icons.info_outline,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'О приложении',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Разработчик', 'ZholobovA'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
