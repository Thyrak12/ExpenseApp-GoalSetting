import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saving_app/model/new_model.dart';
import 'ui/screens/goal/goal_screen.dart';
import 'ui/screens/expenses/expense_screen.dart';
import 'ui/screens/progress/progress_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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
  SavingGoal? currentGoal;

  @override
  Widget build(BuildContext context) {
    if (currentGoal == null) {
      return Scaffold(
        body: GoalScreen(
          currentGoal: null,
          onGoalCreated: (goal) {
            setState(() {
              currentGoal = goal;
            });
          },
          onGoalDeleted: () {},
        ),
      );
    }

    final screens = [
      GoalScreen(
        currentGoal: currentGoal,
        onGoalCreated: (goal) {
          setState(() {
            currentGoal = goal;
          });
        },
        onGoalDeleted: () {
          setState(() {
            currentGoal = null;
            _currentIndex = 0;
          });
        },
      ),
      ExpenseScreen(goal: currentGoal!),
      ProgressScreen(goal: currentGoal!),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.flag_rounded, 'Goal'),
                _buildNavItem(1, Icons.receipt_long_rounded, 'Expenses'),
                _buildNavItem(2, Icons.trending_up_rounded, 'Progress'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

