import 'package:flutter/material.dart';
import '../../../../data/models/month_summary.dart';

class SalarySummaryCard extends StatelessWidget {
  final double earned;
  final double expected;
  final MonthSummary? summary;

  const SalarySummaryCard({
    super.key,
    required this.earned,
    required this.expected,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final percent = expected > 0 ? (earned / expected * 100).clamp(0, 100) : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Заработано',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(earned),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'из ${_formatCurrency(expected)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            if (summary != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildSummaryRow('Рабочих дней', '${summary!.workedDays}'),
              _buildSummaryRow('Больничных', '${summary!.sickDays}'),
              _buildSummaryRow('Командировок', '${summary!.businessTripDays}'),
              if (summary!.totalBonuses > 0)
                _buildSummaryRow(
                  'Бонусы',
                  _formatCurrency(summary!.totalBonuses),
                ),
              if (summary!.businessTripAllowance > 0)
                _buildSummaryRow(
                  'Суточные',
                  _formatCurrency(summary!.businessTripAllowance),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k ₽';
    }
    return '${amount.toStringAsFixed(0)} ₽';
  }
}
