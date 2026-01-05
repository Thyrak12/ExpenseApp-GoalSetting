import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  final int daysElapsed;
  final double dailySave;
  final double totalSpent;

  const StatsRow({
    super.key,
    required this.daysElapsed,
    required this.dailySave,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard('Days', '$daysElapsed'),
        const SizedBox(width: 10),
        _StatCard('Daily Save', '\$${dailySave.toStringAsFixed(0)}'),
        const SizedBox(width: 10),
        _StatCard('Spent', '\$${totalSpent.toStringAsFixed(0)}'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
