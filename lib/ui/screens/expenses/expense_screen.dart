import 'package:flutter/material.dart';
import 'package:saving_app/ui/widgets/screen_header.dart';
import '../../../model/model.dart';
import '../../../main.dart' show dataManager;
import '../../theme/app_theme.dart';
import 'components/budget_page_view.dart';
import 'components/expense_list.dart';
import 'components/expense_modal.dart';
import 'components/quick_add_grid.dart';

class ExpenseScreen extends StatefulWidget {
  final SavingService savingService;
  final VoidCallback onExpenseChanged;

  const ExpenseScreen({
    super.key,
    required this.savingService,
    required this.onExpenseChanged,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showExpenseForm({required ExpenseCategory category,DailyExpense? expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: ExpenseForm(
          category: category,
          expense: expense,
          onSave: (newExpense) async {
            if (expense != null) {
              await dataManager.expenseRepo.updateExpense(newExpense);
            } else {
              await dataManager.expenseRepo.addExpense(newExpense);
            }
            widget.onExpenseChanged();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.savingService;
    final todayExpenses = service.findExpense(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.backgroundColor,
        title: ScreenHeader(title: 'Expense', subtitle: 'Track your daily expense here',),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BudgetPageView(
                todayRemaining: service.dailyRemaining(DateTime.now()),
                dailyLimit: service.dailyLimit,
                overallRemaining: service.overallRemaining,
                daysLeft: service.goal.daysLeft,
                currentPage: _currentPage,
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
              ),
              const SizedBox(height: 24),
              QuickAddList(
                onCategoryTap: (cat) => _showExpenseForm(category: cat),
              ),
              const SizedBox(height: 24),
              ExpenseList(
                expenses: todayExpenses,
                onEdit: (e) =>
                    _showExpenseForm(category: e.category, expense: e),
                onDelete: (e) async {
                  await dataManager.expenseRepo.removeExpense(e.id);
                  widget.onExpenseChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
