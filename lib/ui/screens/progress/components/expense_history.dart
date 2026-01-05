import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../theme/app_theme.dart';

class ExpenseHistory extends StatelessWidget {
  final List<DailyExpense> expenses;

  const ExpenseHistory({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Expense History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${expenses.length} total', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          _EmptyState()
        else
          ...expenses.map((e) => _ExpenseItem(expense: e)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, color: AppTheme.textSecondary, size: 32),
          SizedBox(height: 8),
          Text('No expenses yet', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final DailyExpense expense;

  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: expense.category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(expense.category.icon, color: expense.category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '-\$${expense.amount.toStringAsFixed(0)}',
            style: TextStyle(color: expense.category.color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
