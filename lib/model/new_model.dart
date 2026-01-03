import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// ===============================
/// Income
/// ===============================
enum IncomeType { daily, weekly, monthly }

class Income {
  final String id;
  final double amount;
  final IncomeType type;

  Income({String? id, required this.amount, required this.type})
    : id = id ?? uuid.v4();

  /// Convert income to daily value
  double dailyValue() {
    switch (type) {
      case IncomeType.daily:
        return amount;
      case IncomeType.weekly:
        return amount / 7;
      case IncomeType.monthly:
        return amount / 30;
    }
  }
}

/// ===============================
/// Expense Category
/// ===============================
enum ExpenseCategory {
  food(title: 'Food', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
  travel(title: 'Travel', icon: Icons.directions_car, color: Color(0xFF4ECDC4)),
  entertainment(
    title: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFF9B59B6),
  ),
  cafe(title: 'Cafe', icon: Icons.local_cafe, color: Color(0xFFFFB800)),
  shopping(
    title: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFF3498DB),
  ),
  other(title: 'Other', icon: Icons.category, color: Color(0xFF95A5A6));

  final String title;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// ===============================
/// Daily Expense
/// ===============================
class DailyExpense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date; // store directly

  DailyExpense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = id ?? uuid.v4();
}

/// ===============================
/// Saving Goal
/// ===============================
class SavingGoal {
  final String id;
  final String title;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final Income income;
  final List<DailyExpense> expenses = [];

  SavingGoal({
    String? id,
    required this.title,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    required this.income,
  }) : id = id ?? uuid.v4();

  int get totalDays {
    final days = endDate.difference(startDate).inDays + 1;
    return days <= 0 ? 1 : days;
  }

  int get daysLeft {
    final days = endDate.difference(DateTime.now()).inDays + 1;
    return days < 0 ? 0 : days;
  }

  double get dailyIncome => income.dailyValue();
  double get totalIncome => dailyIncome * totalDays;

  /// Spendable and Saving Calculations
  double get durationLimit => totalIncome - targetAmount;
  double get dailyLimit => durationLimit / totalDays;
  double get dailySave => targetAmount / totalDays;
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Days elapsed since start
  int get daysElapsed {
    final days = DateTime.now().difference(startDate).inDays + 1;
    return days.clamp(0, totalDays);
  }

  /// Expected spending up to today (based on daily limit)
  double get expectedSpent => dailyLimit * daysElapsed;

  /// Actual saved so far = what we should have spent - what we actually spent
  double get currentSaved {
    final saved = expectedSpent - totalSpent + (dailySave * daysElapsed);
    return saved < 0 ? 0 : saved;
  }

  /// Remaining overall budget (from total limit)
  double get overallRemaining => durationLimit - totalSpent;

  /// Is over budget overall
  bool get isOverBudget => overallRemaining < 0;

  /// Overall progress (spent / total limit)
  double get overallProgress {
    if (durationLimit <= 0) return 1.0;
    return (totalSpent / durationLimit).clamp(0.0, 1.0);
  }

  /// Saving progress (currentSaved / targetAmount)
  double get savingProgress {
    if (targetAmount <= 0) return 0;
    return (currentSaved / targetAmount).clamp(0.0, 1.0);
  }

  /// Remaining money after saving goal (legacy)
  double get remainingMoney {
    final remaining = totalIncome - totalSpent - targetAmount;
    return remaining > 0 ? remaining : 0;
  }

  /// Progress = remaining / target (legacy)
  double get progress {
    if (targetAmount == 0) return 0;
    return (remainingMoney / targetAmount).clamp(0, 1);
  }

  /// ===============================
  /// Expense Operations
  /// ===============================
  void addExpense(DailyExpense expense) {
    expenses.add(expense);
  }

  List<DailyExpense> findExpense(DateTime date) {
    return expenses
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .toList();
  }

  /// Work with Daily Spenf

  /// Total spent on a specific date
  double totalSpentForDate(DateTime date) {
    return expenses
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Remaining for the day
  double dailyRemaining(DateTime date) {
    return dailyLimit - totalSpentForDate(date);
  }

  /// Is overspent today
  bool isOverSpent(DateTime date) {
    return dailyRemaining(date) < 0;
  }

  double dailyProgress(DateTime date) {
    if (dailyLimit == 0) return 0;
    return (totalSpentForDate(date) / dailyLimit).clamp(0.0, 1.0);
  }

  /// Saved today = daily limit - spent + daily save goal
  double savedToday(DateTime date) {
    final remaining = dailyRemaining(date);
    return remaining > 0 ? remaining + dailySave : dailySave;
  }

  /// Get all expenses sorted by date (newest first)
  List<DailyExpense> get expensesByDate {
    final sorted = List<DailyExpense>.from(expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}
