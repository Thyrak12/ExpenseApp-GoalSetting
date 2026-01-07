import 'package:flutter/material.dart';
import 'model/model.dart';
import 'ui/screens/welcome/welcome_screen.dart';
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
  bool _showWelcome = true;

  bool get hasCompleteData => dataManager.hasCompleteData;
  bool get isCompleted => dataManager.goalRepo.goal?.isCompleted ?? false;
  SavingService? get savingService => dataManager.getSavingService();

  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    _showWelcome = !hasCompleteData;
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome && !hasCompleteData) {
      return WelcomeScreen(
        onGetStarted: () => setState(() => _showWelcome = false),
      );
    }

    if (!hasCompleteData) {
      return GoalScreen(
        savingService: null,
        onGoalCreated: (goal, income) async {
          await dataManager.goalRepo.setGoal(goal);
          await dataManager.incomeRepo.setIncome(income);
          _refresh();
        },
        onGoalDeleted: () {},
        isCompleted: false,
      );
    }

    final service = savingService!;
    final screens = isCompleted
        ? [
            GoalScreen(
              savingService: service,
              onGoalCreated: (goal, income) async {
                await dataManager.goalRepo.setGoal(goal);
                await dataManager.incomeRepo.setIncome(income);
                await dataManager.expenseRepo.clearAll();
                _refresh();
              },
              onGoalDeleted: () async {
                await dataManager.clearAll();
                setState(() => _currentIndex = 0);
              },
              onMarkCompleted: () async {
                await dataManager.goalRepo.markAsCompleted();
              },
              isCompleted: isCompleted,
            ),
            ProgressScreen(savingService: service),
          ]
        : [
            GoalScreen(
              savingService: service,
              onGoalCreated: (goal, income) async {
                await dataManager.goalRepo.setGoal(goal);
                await dataManager.incomeRepo.setIncome(income);
                await dataManager.expenseRepo.clearAll();
                _refresh();
              },
              onGoalDeleted: () async {
                await dataManager.clearAll();
                setState(() => _currentIndex = 0);
              },
              onMarkCompleted: () async {
                await dataManager.goalRepo.markAsCompleted();
              },
              isCompleted: isCompleted,
            ),
            ExpenseScreen(savingService: service, onExpenseChanged: _refresh),
            ProgressScreen(savingService: service),
          ];

    final navItems = isCompleted
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goal'),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goal'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
          ];

    final safeIndex = _currentIndex.clamp(0, screens.length - 1);
    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: navItems,
      ),
    );
  }
}
