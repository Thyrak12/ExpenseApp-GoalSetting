import 'package:flutter/material.dart';
import 'package:saving_app/model/new_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class TodayBudgetCard extends StatelessWidget {
  final SavingGoal goal;

  const TodayBudgetCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final remaining = goal.dailyRemaining(today);
    final isOver = remaining < 0;
    final savedToday = goal.savedToday(today);
    final todayExpenses = goal.findExpense(today).length;
    final accentColor = isOver ? const Color(0xFFFF6B6B) : AppTheme.primaryColor;

    return GlassView(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A5F), Color(0xFF132039)],
      ),
      accentColor: accentColor,
      leftHeader: GlassBadge(
        icon: Icons.today_rounded,
        text: 'Today',
        color: accentColor,
      ),
      rightHeader: Text(
        '$todayExpenses expense${todayExpenses == 1 ? '' : 's'}',
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      title: '\$${remaining.abs().toStringAsFixed(0)}',
      miniTitle: isOver ? 'over limit' : 'left',
      subtitle: 'Limit: \$${goal.dailyLimit.toStringAsFixed(0)} • Saved today: \$${savedToday.toStringAsFixed(0)}',
      progress: goal.dailyProgress(today),
    );
  }
}
