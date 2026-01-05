import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum IncomeType { daily, weekly, monthly }

class Income {
  final String id;
  final double amount;
  final IncomeType type;

  Income({String? id, required this.amount, required this.type})
      : id = id ?? uuid.v4();

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

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: IncomeType.values.firstWhere((e) => e.toString() == json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString(),
    };
  }
}

enum ExpenseCategory {
  food(title: 'Food', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
  travel(title: 'Travel', icon: Icons.directions_car, color: Color(0xFF4ECDC4)),
  entertainment(title: 'Entertainment', icon: Icons.movie, color: Color(0xFF9B59B6)),
  cafe(title: 'Cafe', icon: Icons.local_cafe, color: Color(0xFFFFB800)),
  shopping(title: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFF3498DB)),
  other(title: 'Other', icon: Icons.category, color: Color(0xFF95A5A6));

  final String title;
  final IconData icon;
  final Color color;
  const ExpenseCategory({required this.title, required this.icon, required this.color});

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere((e) => e.toString() == value);
  }

  String toJson() => toString();
}

class DailyExpense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  DailyExpense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = id ?? uuid.v4();

  factory DailyExpense.fromJson(Map<String, dynamic> json) {
    return DailyExpense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(json['category']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.toJson(),
      'date': date.toIso8601String(),
    };
  }
}

class SavingGoal {
  final String id;
  final String title;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  SavingGoal({
    String? id,
    required this.title,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  }) : id = id ?? uuid.v4();

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Basic date calculations (don't depend on external data)
  int get totalDays => endDate.difference(startDate).inDays + 1;
  int get daysLeft => (endDate.difference(DateTime.now()).inDays + 1).clamp(0, totalDays);
  int get daysElapsed => (DateTime.now().difference(startDate).inDays + 1).clamp(0, totalDays);
  double get dailySave => targetAmount / totalDays;
}

class SavingService {
  final SavingGoal goal;
  final Income income;
  final List<DailyExpense> expenses;

  SavingService({
    required this.goal,
    required this.income,
    required this.expenses,
  });

  double get dailyIncome => income.dailyValue();
  double get totalIncome => dailyIncome * goal.totalDays;

  double get durationLimit => totalIncome - goal.targetAmount;
  double get dailyLimit => durationLimit / goal.totalDays;
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get expectedSpent => dailyLimit * goal.daysElapsed;
  double get currentSaved => (expectedSpent - totalSpent + goal.dailySave * goal.daysElapsed).clamp(0.0, double.infinity);
  double get overallRemaining => durationLimit - totalSpent;
  bool get isOverBudget => overallRemaining < 0;
  double get overallProgress => durationLimit <= 0 ? 1.0 : (totalSpent / durationLimit).clamp(0.0, 1.0);
  double get savingProgress => goal.targetAmount <= 0 ? 0 : (currentSaved / goal.targetAmount).clamp(0.0, 1.0);
  double get remainingMoney => (totalIncome - totalSpent - goal.targetAmount).clamp(0.0, double.infinity);
  double get progress => goal.targetAmount == 0 ? 0 : (remainingMoney / goal.targetAmount).clamp(0.0, 1.0);


  List<DailyExpense> findExpense(DateTime date) {
    return expenses.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();
  }

  double totalSpentForDate(DateTime date) => findExpense(date).fold(0.0, (sum, e) => sum + e.amount);
  double dailyRemaining(DateTime date) => dailyLimit - totalSpentForDate(date);
  bool isOverSpent(DateTime date) => dailyRemaining(date) < 0;
  double dailyProgress(DateTime date) => dailyLimit == 0 ? 0 : (totalSpentForDate(date) / dailyLimit).clamp(0.0, 1.0);
  
  double savedToday(DateTime date) {
    final remaining = dailyRemaining(date);
    return remaining > 0 ? remaining + goal.dailySave : goal.dailySave;
  }

  List<DailyExpense> get expensesByDate {
    final sorted = List<DailyExpense>.from(expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}
