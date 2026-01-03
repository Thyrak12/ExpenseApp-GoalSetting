import 'package:flutter/material.dart';
import 'package:saving_app/model/new_model.dart';
import 'package:saving_app/ui/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final SavingGoal goal;

  const MonthlyBudgetCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final remaining = goal.overallRemaining;
    final isOver = goal.isOverBudget;
    final accentColor = isOver ? const Color(0xFFFF6B6B) : Colors.white;

    return GlassView(
      gradient: AppTheme.primaryGradient,
      accentColor: accentColor,
      leftHeader: const GlassBadge(
        icon: Icons.account_balance_wallet_rounded,
        text: 'Overall Budget',
        color: Colors.white
      ),
      rightHeader: Text(
        '${goal.daysLeft} days left',
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      title: '\$${remaining.abs().toStringAsFixed(0)}',
      miniTitle: isOver ? 'over budget' : 'remaining',
      subtitle: 'Total limit: \$${goal.durationLimit.toStringAsFixed(0)} • Saved: \$${goal.currentSaved.toStringAsFixed(0)}',
      progress: goal.overallProgress,
    );
  }
}
