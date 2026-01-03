import 'package:flutter/material.dart';
import 'package:saving_app/model/model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class ExpenseOverallView extends StatefulWidget {
  final BudgetPlan plan;

  const ExpenseOverallView({
    super.key,
    required this.plan,
  });

  @override
  State<ExpenseOverallView> createState() => _ExpenseOverallViewState();
}

class _ExpenseOverallViewState extends State<ExpenseOverallView> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  late BudgetPlan plan;

  @override
  void initState() {
    plan = widget.plan;
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  double get totalFixedExpenses {
    if (plan.fixedExpenses.isEmpty) return 0;
    return plan.fixedExpenses.fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  double get totalPeriodExpenses {
    if (plan.periodExpenses.isEmpty) return 0;
    return plan.periodExpenses.fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  double get totalDailyExpenses {
    if (plan.dailyExpenses.isEmpty) return 0;
    return plan.dailyExpenses.fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  double get totalVariableExpenses => totalPeriodExpenses + totalDailyExpenses;

  Map<ExpenseCategory, double> get categorySpending {
    final map = <ExpenseCategory, double>{};
    // Include both period and daily expenses in category breakdown
    for (final expense in [...plan.periodExpenses, ...plan.dailyExpenses]) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.totalAmount;
    }
    return map;
  }

  void _onCreateFixedExpense(ExpenseCategory category) {
    if (_formKey.currentState?.validate() ?? false) {
      final title = titleController.text.trim();
      final amount = double.parse(amountController.text);

      final expense = Expense(
        title: title,
        totalAmount: amount,
        category: category,
        type: ExpenseType.fixed,
        startDate: plan.goal.startDate,
        durationDays: plan.goal.totalDays(),
      );

      setState(() {
        plan.addExpense(expense);
      });

      titleController.clear();
      amountController.clear();
      Navigator.pop(context);
    }
  }

  void _onCreatePeriodExpense(ExpenseCategory category, int days) {
    if (_formKey.currentState?.validate() ?? false) {
      final title = titleController.text.trim();
      final amount = double.parse(amountController.text);

      final expense = Expense(
        title: title,
        totalAmount: amount,
        category: category,
        type: ExpenseType.period,
        startDate: DateTime.now(),
        durationDays: days,
      );

      setState(() {
        plan.addExpense(expense);
      });

      titleController.clear();
      amountController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddFixedExpenseModal() {
    ExpenseCategory selectedCategory = ExpenseCategory.other;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: ExpenseType.fixed.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              ExpenseType.fixed.icon,
                              color: ExpenseType.fixed.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Fixed Expense',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rent, subscriptions, bills',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category Selector
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ExpenseCategory.values.length,
                          itemBuilder: (_, i) {
                            final cat = ExpenseCategory.values[i];
                            final isSelected = cat == selectedCategory;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedCategory = cat),
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? cat.color.withOpacity(0.2) 
                                      : AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected 
                                      ? Border.all(color: cat.color, width: 2) 
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(cat.icon, color: cat.color, size: 24),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.title,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? cat.color : AppTheme.textSecondary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title Field
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          hintText: 'e.g. Rent, Netflix',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
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
                          labelText: 'Monthly Amount',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
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
                          onPressed: () => _onCreateFixedExpense(selectedCategory),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ExpenseType.fixed.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add Fixed Expense',
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
      },
    );
  }

  void _showAddPeriodExpenseModal() {
    ExpenseCategory selectedCategory = ExpenseCategory.shopping;
    int selectedDays = 7;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: ExpenseType.period.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              ExpenseType.period.icon,
                              color: ExpenseType.period.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Period Expense',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Groceries, trips, shopping',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category Selector
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ExpenseCategory.values.length,
                          itemBuilder: (_, i) {
                            final cat = ExpenseCategory.values[i];
                            final isSelected = cat == selectedCategory;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedCategory = cat),
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? cat.color.withOpacity(0.2) 
                                      : AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected 
                                      ? Border.all(color: cat.color, width: 2) 
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(cat.icon, color: cat.color, size: 24),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.title,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? cat.color : AppTheme.textSecondary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Duration Selector
                      Row(
                        children: [
                          const Text(
                            'Duration:',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [3, 7, 14, 30].map((days) {
                                  final isSelected = days == selectedDays;
                                  return GestureDetector(
                                    onTap: () => setModalState(() => selectedDays = days),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? ExpenseType.period.color.withOpacity(0.2) 
                                            : AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected 
                                            ? Border.all(color: ExpenseType.period.color, width: 2) 
                                            : null,
                                      ),
                                      child: Text(
                                        '$days days',
                                        style: TextStyle(
                                          color: isSelected ? ExpenseType.period.color : AppTheme.textSecondary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Title Field
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          hintText: 'e.g. Weekly groceries',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
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
                          labelText: 'Total Amount',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
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
                          onPressed: () => _onCreatePeriodExpense(selectedCategory, selectedDays),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ExpenseType.period.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add Period Expense',
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('overall'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(),
        const SizedBox(height: 28),
        _fixedExpensesSection(),
        const SizedBox(height: 28),
        _periodExpensesSection(),
        const SizedBox(height: 28),
        _categorySpendingSection(),
      ],
    );
  }

  Widget _summaryCard() {
    final totalSpent = totalFixedExpenses + totalVariableExpenses;
    final remaining = plan.totalSpendableBudget() - totalSpent;
    final progress = plan.totalSpendableBudget() > 0 
        ? totalSpent / plan.totalSpendableBudget()
        : 0.0;

    return GlassCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF2D1B4E), Color(0xFF1A1030)],
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
                    'Total Remaining',
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
                        '\$${remaining.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 6),
                        child: Text(
                          'of \$${plan.totalSpendableBudget().toStringAsFixed(0)}',
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
                      ? const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)])
                      : AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${plan.goal.totalDays()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'days',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedProgressBar(
            progress: progress,
            color: const Color(0xFF9B59B6),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% of budget used',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${totalSpent.toStringAsFixed(0)} spent',
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

  Widget _fixedExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fixed Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showAddFixedExpenseModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Color(0xFFE74C3C), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Color(0xFFE74C3C),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (plan.fixedExpenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.push_pin_outlined,
                  size: 40,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'No fixed expenses',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add rent, subscriptions, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ...plan.fixedExpenses.map((expense) {
                  final monthlyAmount = (expense.totalAmount / expense.durationDays) * 30;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: expense.category.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            expense.category.icon,
                            color: expense.category.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '-\$${monthlyAmount.toStringAsFixed(0)}/mo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: expense.category.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(color: Colors.white10, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Fixed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${totalFixedExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _periodExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Period Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showAddPeriodExpenseModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ExpenseType.period.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: ExpenseType.period.color, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: ExpenseType.period.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (plan.periodExpenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: 40,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'No period expenses',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add groceries, trips, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ...plan.periodExpenses.map((expense) {
                  final daysLeft = expense.startDate.add(Duration(days: expense.durationDays)).difference(DateTime.now()).inDays;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: expense.category.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            expense.category.icon,
                            color: expense.category.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${expense.durationDays} days • ${daysLeft > 0 ? '$daysLeft left' : 'ended'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${expense.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: expense.category.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(color: Colors.white10, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${totalPeriodExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _categorySpendingSection() {
    final spending = categorySpending;
    final sortedCategories = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${totalVariableExpenses.toStringAsFixed(0)} total',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sortedCategories.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 40,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'No spending yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add daily expenses to see breakdown',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ...sortedCategories.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percent = totalVariableExpenses > 0
                ? (amount / totalVariableExpenses)
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}% of spending',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(category.color),
                      minHeight: 6,
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
