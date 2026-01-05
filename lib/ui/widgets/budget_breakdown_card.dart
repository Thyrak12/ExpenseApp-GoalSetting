import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetBreakdownCard extends StatelessWidget {
  final int daysLeft;
  final double saveTarget;
  final double dailyLimit;
  final double totalSpendable;

  const BudgetBreakdownCard({
    super.key,
    required this.daysLeft,
    required this.saveTarget,
    required this.dailyLimit,
    required this.totalSpendable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          BudgetBreakdownItem(
            icon: Icons.timer_outlined,
            label: 'Days Left',
            value: '$daysLeft days',
            color: AppTheme.primaryColor,
          ),
          BudgetBreakdownItem(
            icon: Icons.savings_outlined,
            label: 'Save Target',
            value: '\$${saveTarget.toStringAsFixed(0)}',
            color: const Color(0xFFFFB800),
          ),
          BudgetBreakdownItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Daily Limit',
            value: '\$${dailyLimit.toStringAsFixed(2)}',
            color: const Color(0xFF4ECDC4),
          ),
          BudgetBreakdownItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Spendable',
            value: '\$${totalSpendable.toStringAsFixed(0)}',
            color: const Color(0xFF9B59B6),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

/// Individual budget breakdown item row
class BudgetBreakdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool showDivider;

  const BudgetBreakdownItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showDivider ? 16 : 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
