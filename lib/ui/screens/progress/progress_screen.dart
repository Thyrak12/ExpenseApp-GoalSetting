import 'package:flutter/material.dart';
import 'package:saving_app/ui/widgets/screen_header.dart';
import '../../../model/model.dart';
import '../../theme/app_theme.dart';
import 'components/expense_history.dart';
import 'components/savings_card.dart';
import 'components/stats_row.dart';

class ProgressScreen extends StatelessWidget {
  final SavingService savingService;

  const ProgressScreen({super.key, required this.savingService});

  @override
  Widget build(BuildContext context) {
    final goal = savingService.goal;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.backgroundColor,
        title: ScreenHeader(title: 'Progress', subtitle: 'Track your journey'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SavingsCard(
                currentSaved: savingService.currentSaved,
                targetAmount: goal.targetAmount,
                progress: savingService.savingProgress,
                daysLeft: goal.daysLeft,
              ),
              const SizedBox(height: 20),
              StatsRow(
                daysElapsed: goal.daysElapsed,
                dailySave: goal.dailySave,
                totalSpent: savingService.totalSpent,
              ),
              const SizedBox(height: 24),
              ExpenseHistory(expenses: savingService.expensesByDate),
            ],
          ),
        ),
      ),
    );
  }
}
