import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_view.dart';
import '../../../widgets/glass_badge.dart';

class GoalCard extends StatelessWidget {
  final SavingGoal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.isCompleted;
    
    return GlassView(
      gradient: isCompleted ? AppTheme.secondaryGradient : AppTheme.primaryGradient,
      hasShadow: true,
      accentColor: Colors.white,
      leftHeader: GlassBadge(
        icon: isCompleted ? Icons.check_circle : Icons.flag,
        text: isCompleted ? 'Completed' : 'Active Goal',
        color: Colors.white,
      ),
      rightHeader: Text(
        isCompleted ? 'Goal ended' : '${goal.daysLeft} days left',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      title: goal.title,
      subtitle: 'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
    );
  }
}
