import 'package:flutter/material.dart';
import 'package:saving_app/model/model.dart';
import '../../../theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  final SavingGoal goal;

  const StatsRow({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_rounded,
            label: 'Days Elapsed',
            value: '${goal.daysElapsed}',
            color: const Color(0xFF9B59B6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            label: 'Daily Save',
            value: '\$${goal.dailySave.toStringAsFixed(0)}',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_rounded,
            label: 'Total Spent',
            value: '\$${goal.totalSpent.toStringAsFixed(0)}',
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
