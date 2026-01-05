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
    return GlassView(
      gradient: AppTheme.primaryGradient,
      hasShadow: true,
      accentColor: Colors.white,
      leftHeader: const GlassBadge(
        icon: Icons.flag,
        text: 'Active Goal',
        color: Colors.white,
      ),
      rightHeader: Text(
        '${goal.daysLeft} days left',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      title: goal.title,
      subtitle: 'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
    );
  }
}
