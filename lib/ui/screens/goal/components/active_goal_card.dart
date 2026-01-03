import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class ActiveGoalCard extends StatelessWidget {
  final SavingGoal goal;

  const ActiveGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalDays = goal.endDate.difference(today).inDays;
    final daysLeft = totalDays <= 0 ? 0 : totalDays;

    return GlassView(
      gradient: AppTheme.primaryGradient,
      padding: const EdgeInsets.all(24),
      hasShadow: true,
      accentColor: Colors.white,
      leftHeader: const GlassBadge(
        icon: Icons.flag_rounded,
        text: 'Active Goal',
        color: Colors.white,
      ),
      rightHeader: Text(
        '$daysLeft days left',
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
      ),
      title: goal.title,
      subtitle: 'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
    );
  }
}
