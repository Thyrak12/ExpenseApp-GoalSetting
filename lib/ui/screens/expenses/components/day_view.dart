import 'package:flutter/material.dart';
import 'package:saving_app/model/model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import 'quick_add.dart';

class ExpenseDayView extends StatefulWidget {
  final BudgetPlan plan;
  const ExpenseDayView({super.key, required this.plan});

  @override
  State<ExpenseDayView> createState() => _ExpenseDayViewState();
}

class _ExpenseDayViewState extends State<ExpenseDayView> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  late BudgetPlan plan;
  late DailyBudget dailyBudget;

  @override
  void initState() {
    super.initState();
    plan = widget.plan;
    dailyBudget = DailyBudget(
      date: DateTime.now(),
      plan: widget.plan,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void onCreate(ExpenseCategory category) {
    if (_formKey.currentState?.validate() ?? false) {
      final title = titleController.text.trim();
      final amount = double.parse(amountController.text);

      final expense = Expense(
        title: title,
        totalAmount: amount,
        category: category,
        type: ExpenseType.daily,
        startDate: DateTime.now(),
        durationDays: 1,
      );

      setState(() {
        plan.addExpense(expense);
        dailyBudget = DailyBudget(date: DateTime.now(), plan: plan);
      });

      // Clear inputs
      titleController.clear();
      amountController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddExpenseModal(ExpenseCategory category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Expense',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: category.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Title Field
                  TextFormField(
                    controller: titleController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      hintText: 'e.g. Lunch at cafe',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid number greater than 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => onCreate(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('day'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(),
        const SizedBox(height: 28),
        _quickAdd(),
        const SizedBox(height: 28),
        _expenseList(),
      ],
    );
  }

  Widget _summaryCard() {
    double progress = dailyBudget.totalSpent() / dailyBudget.dailyLimit();
    return GlassCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A5F), Color(0xFF132039)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining Today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${(dailyBudget.remaining()).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 6),
                        child: Text(
                          'of \$${dailyBudget.dailyLimit()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: progress < 0.7
                      ? AppTheme.primaryGradient
                      : AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  progress < 0.7
                      ? Icons.sentiment_satisfied_rounded
                      : Icons.sentiment_neutral_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedProgressBar(progress: progress),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% spent',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${dailyBudget.dailyLimit().toStringAsFixed(2)} used',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAdd() {
    final categories = ExpenseCategory.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _showAddExpenseModal(categories[i]),
              child: QuickAddCard(category: categories[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _expenseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${dailyBudget.expenses().length} items',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dailyBudget.expenses().isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No expenses yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a category above to add one',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ...dailyBudget.expenses().map((expense) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
                    child: Icon(
                      expense.category.icon,
                      color: expense.category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.category.title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-\$${expense.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
