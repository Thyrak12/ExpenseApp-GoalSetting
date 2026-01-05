import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/model.dart';

abstract class BaseJsonRepository<T> {
  final String fileName;
  
  BaseJsonRepository(this.fileName);

  /// Get the path to the JSON file
  String get _filePath {
    // Get the directory where the app is running
    final currentDir = Directory.current.path;
    return path.join(currentDir, 'lib', 'data', 'json', fileName);
  }

  /// Ensure the JSON directory exists
  Future<void> _ensureDirectoryExists() async {
    final dir = Directory(path.dirname(_filePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Read JSON file and return as dynamic
  Future<dynamic> readJsonFile() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        return null;
      }
      final content = await file.readAsString();
      if (content.isEmpty) return null;
      return json.decode(content);
    } catch (e) {
      print('Error reading $fileName: $e');
      return null;
    }
  }

  /// Write data to JSON file
  Future<void> writeJsonFile(dynamic data) async {
    try {
      await _ensureDirectoryExists();
      final file = File(_filePath);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));
    } catch (e) {
      print('Error writing $fileName: $e');
    }
  }

  /// Clear the JSON file
  Future<void> clearFile() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        await file.writeAsString('{}');
      }
    } catch (e) {
      print('Error clearing $fileName: $e');
    }
  }
}

/// ===============================
/// Saving Goal Repository
/// ===============================
class SavingGoalRepository extends BaseJsonRepository<SavingGoal> {
  SavingGoal? goal;

  SavingGoalRepository() : super('saving_goal.json');

  /// Load goal from JSON file
  Future<void> load() async {
    try {
      final data = await readJsonFile();
      if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
        goal = SavingGoal.fromJson(data);
      } else {
        goal = null;
      }
    } catch (e) {
      print('Error loading goal: $e');
      goal = null;
    }
  }

  /// Save goal to JSON file
  Future<void> save() async {
    if (goal == null) {
      await clearFile();
    } else {
      await writeJsonFile(goal!.toJson());
    }
  }

  /// Set or update the goal
  Future<void> setGoal(SavingGoal newGoal) async {
    goal = newGoal;
    await save();
  }

  /// Clear the goal
  Future<void> clearGoal() async {
    goal = null;
    await clearFile();
  }

  /// Export as formatted JSON string
  String? exportJson() {
    if (goal == null) return null;
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(goal!.toJson());
  }
}

/// ===============================
/// Income Repository
/// ===============================
class IncomeRepository extends BaseJsonRepository<Income> {
  Income? income;

  IncomeRepository() : super('income.json');

  /// Load income from JSON file
  Future<void> load() async {
    try {
      final data = await readJsonFile();
      if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
        income = Income.fromJson(data);
      } else {
        income = null;
      }
    } catch (e) {
      print('Error loading income: $e');
      income = null;
    }
  }

  /// Save income to JSON file
  Future<void> save() async {
    if (income == null) {
      await clearFile();
    } else {
      await writeJsonFile(income!.toJson());
    }
  }

  /// Set or update income
  Future<void> setIncome(Income newIncome) async {
    income = newIncome;
    await save();
  }

  /// Clear income
  Future<void> clearIncome() async {
    income = null;
    await clearFile();
  }

  /// Get daily income value
  double get dailyIncome => income?.dailyValue() ?? 0.0;

  /// Export as formatted JSON string
  String? exportJson() {
    if (income == null) return null;
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(income!.toJson());
  }
}

/// ===============================
/// Expense Repository
/// ===============================
class ExpenseRepository extends BaseJsonRepository<DailyExpense> {
  List<DailyExpense> expenses = [];

  ExpenseRepository() : super('daily_expense.json');

  /// Load expenses from JSON file
  Future<void> load() async {
    try {
      final data = await readJsonFile();
      if (data != null && data is List) {
        expenses = data.map((e) => DailyExpense.fromJson(e)).toList();
      } else {
        expenses = [];
      }
    } catch (e) {
      print('Error loading expenses: $e');
      expenses = [];
    }
  }

  /// Save expenses to JSON file
  Future<void> save() async {
    final data = expenses.map((e) => e.toJson()).toList();
    await writeJsonFile(data);
  }

  /// Add new expense
  Future<void> addExpense(DailyExpense expense) async {
    expenses.add(expense);
    await save();
  }

  /// Update expense
  Future<void> updateExpense(DailyExpense expense) async {
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await save();
    }
  }

  /// Remove expense by ID
  Future<void> removeExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    await save();
  }

  /// Get expense by ID
  DailyExpense? getExpenseById(String id) {
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get expenses by date
  List<DailyExpense> getExpensesByDate(DateTime date) {
    return expenses.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();
  }

  /// Get expenses by date range
  List<DailyExpense> getExpensesByDateRange(DateTime start, DateTime end) {
    return expenses.where((e) =>
        e.date.isAfter(start.subtract(const Duration(days: 1))) &&
        e.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  /// Get expenses by category
  List<DailyExpense> getExpensesByCategory(ExpenseCategory category) {
    return expenses.where((e) => e.category == category).toList();
  }

  /// Get total spent
  double get totalSpent {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get total spent for date
  double totalSpentForDate(DateTime date) {
    return getExpensesByDate(date).fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get total spent by category
  double totalSpentByCategory(ExpenseCategory category) {
    return getExpensesByCategory(category).fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get expenses sorted by date (newest first)
  List<DailyExpense> get expensesByDate {
    final sorted = List<DailyExpense>.from(expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Clear all expenses
  Future<void> clearAll() async {
    expenses = [];
    await writeJsonFile([]);
  }

  /// Export as formatted JSON string
  String exportJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(expenses.map((e) => e.toJson()).toList());
  }
}

/// ===============================
/// Data Manager - Singleton to manage all repositories
/// ===============================
class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final SavingGoalRepository goalRepo = SavingGoalRepository();
  final IncomeRepository incomeRepo = IncomeRepository();
  final ExpenseRepository expenseRepo = ExpenseRepository();

  bool _isInitialized = false;

  /// Initialize all repositories
  Future<void> init() async {
    if (_isInitialized) return;
    
    await Future.wait([
      goalRepo.load(),
      incomeRepo.load(),
      expenseRepo.load(),
    ]);
    
    _isInitialized = true;
  }

  /// Reload all data
  Future<void> reload() async {
    await Future.wait([
      goalRepo.load(),
      incomeRepo.load(),
      expenseRepo.load(),
    ]);
  }

  /// Save all data
  Future<void> saveAll() async {
    await Future.wait([
      goalRepo.save(),
      incomeRepo.save(),
      expenseRepo.save(),
    ]);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await Future.wait([
      goalRepo.clearGoal(),
      incomeRepo.clearIncome(),
      expenseRepo.clearAll(),
    ]);
  }

  /// Check if we have complete data (goal + income)
  bool get hasCompleteData => goalRepo.goal != null && incomeRepo.income != null;

  /// Create SavingService from current data
  /// Returns null if goal or income is missing
  SavingService? getSavingService() {
    if (goalRepo.goal == null || incomeRepo.income == null) return null;
    return SavingService(
      goal: goalRepo.goal!,
      income: incomeRepo.income!,
      expenses: expenseRepo.expenses,
    );
  }
}


