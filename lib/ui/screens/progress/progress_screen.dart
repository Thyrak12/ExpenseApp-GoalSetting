import 'package:flutter/material.dart';
import 'package:saving_app/model/model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';
import 'components/savings_card.dart';
import 'components/stats_row.dart';
import 'components/expense_history.dart';

class ProgressScreen extends StatelessWidget {
  final SavingGoal goal;

  const ProgressScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const ScreenHeader(
                    title: 'Progress',
                    subtitle: 'Track your saving journey',
                  ),
                  const SizedBox(height: 24),
                  SavingsCard(goal: goal),
                  const SizedBox(height: 24),
                  StatsRow(goal: goal),
                  const SizedBox(height: 28),
                  ExpenseHistoryHeader(totalExpenses: goal.expenses.length),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            ExpenseHistoryList(expenses: goal.expensesByDate),
          ],
        ),
      ),
    );
  }
}
