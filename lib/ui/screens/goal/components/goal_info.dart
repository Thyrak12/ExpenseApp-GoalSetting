import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../widgets/budget_breakdown_card.dart';
import 'active_goal_card.dart';

class GoalInfoPage extends StatelessWidget {
  final SavingGoal goal;

  const GoalInfoPage({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        ActiveGoalCard(goal: goal),
        const SizedBox(height: 24),
        BudgetBreakdownCard(
          daysLeft: goal.daysLeft,
          saveTarget: goal.dailySave,
          dailyLimit: goal.dailyLimit,
          totalSpendable: goal.durationLimit,
        ),
      ],
    );
  }
}
