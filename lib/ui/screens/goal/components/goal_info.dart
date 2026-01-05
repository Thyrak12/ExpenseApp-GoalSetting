import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../widgets/budget_breakdown_card.dart';
import 'goal_card.dart';

class GoalInfoPage extends StatelessWidget {
  final SavingService savingService;

  const GoalInfoPage({super.key, required this.savingService});

  @override
  Widget build(BuildContext context) {
    final goal = savingService.goal;
    
    return Column(
      children: [
        GoalCard(goal: goal),
        const SizedBox(height: 16),
        BudgetBreakdownCard(
          daysLeft: goal.daysLeft,
          saveTarget: goal.dailySave,
          dailyLimit: savingService.dailyLimit,
          totalSpendable: savingService.durationLimit,
        ),
      ],
    );
  }
}
