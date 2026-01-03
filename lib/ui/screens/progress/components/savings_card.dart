import 'package:flutter/material.dart';
import 'package:saving_app/model/new_model.dart';
import 'package:saving_app/ui/theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class SavingsCard extends StatelessWidget {
  final SavingGoal goal;

  const SavingsCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.savingProgress;

    return GlassView(
      gradient: AppTheme.primaryGradient,
      accentColor: Colors.white,
      hasShadow: true,
      leftHeader: const GlassBadge(
        icon: Icons.savings_rounded,
        text: 'Current Savings',
        color: Colors.white,
      ),
      rightHeader: Text(
        '${goal.daysLeft} days left',
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      title: '\$${goal.currentSaved.toStringAsFixed(0)}',
      miniTitle: 'of \$${goal.targetAmount.toStringAsFixed(0)}',
      subtitle: 'Day ${goal.daysElapsed} of ${goal.totalDays} • ${(progress * 100).toStringAsFixed(0)}% complete',
      progress: progress,
    );
  }
}
