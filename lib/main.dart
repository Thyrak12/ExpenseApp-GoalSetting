import 'package:flutter/material.dart';
import 'model/model.dart';
import 'ui/screens/goal/goal_screen.dart';
import 'ui/screens/expenses/expense_screen.dart';
import 'ui/screens/progress/progress_screen.dart';
import 'ui/theme/app_theme.dart';
import 'data/repo.dart';

final dataManager = DataManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dataManager.init();
  runApp(const SavingApp());
}

class SavingApp extends StatelessWidget {
  const SavingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saving App',
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  bool get hasCompleteData => dataManager.hasCompleteData;
  SavingService? get savingService => dataManager.getSavingService();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (!hasCompleteData) {
      return GoalScreen(
        savingService: null,
        onGoalCreated: (goal, income) async {
          await dataManager.goalRepo.setGoal(goal);
          await dataManager.incomeRepo.setIncome(income);
          _refresh();
        },
        onGoalDeleted: () {},
      );
    }

    final service = savingService!;

    final screens = [
      GoalScreen(
        savingService: service,
        onGoalCreated: (goal, income) async {
          await dataManager.goalRepo.setGoal(goal);
          await dataManager.incomeRepo.setIncome(income);
          _refresh();
        },
        onGoalDeleted: () async {
          await dataManager.clearAll();
          setState(() => _currentIndex = 0);
        },
      ),
      ExpenseScreen(
        savingService: service,
        onExpenseChanged: _refresh,
      ),
      ProgressScreen(savingService: service),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goal'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
        ],
      ),
    );
  }
}

