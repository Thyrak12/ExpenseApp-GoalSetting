import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../../model/new_model.dart';
import '../../../widgets/budget_breakdown_card.dart';

class GoalFormPage extends StatefulWidget {
  final Function(SavingGoal) onSave;

  const GoalFormPage({super.key, required this.onSave});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();

  final goalController = TextEditingController();
  final amountController = TextEditingController();
  final incomeController = TextEditingController();

  DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
  IncomeType selectedIncomeType = IncomeType.daily;

  bool showCalculation = false;
  BudgetBreakdownCard? _previewCard;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    goalController.dispose();
    amountController.dispose();
    incomeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        showCalculation = false;
      });
    }
  }

  void _resetCalculation() {
    setState(() => showCalculation = false);
  }

  void _onActionPressed() {
    if (!_formKey.currentState!.validate()) return;

    final income = Income(
      amount: double.parse(incomeController.text),
      type: selectedIncomeType,
    );

    final newGoal = SavingGoal(
      title: goalController.text.trim(),
      targetAmount: double.parse(amountController.text),
      startDate: DateTime.now(),
      endDate: selectedDate,
      income: income,
    );

    if (!showCalculation) {
      setState(() {
        showCalculation = true;
        _previewCard = BudgetBreakdownCard(
          daysLeft: newGoal.totalDays,
          saveTarget: newGoal.dailySave,
          dailyLimit: newGoal.dailyLimit,
          totalSpendable: newGoal.durationLimit,
        );
      });
    } else {
      widget.onSave(newGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Name
            const FormFieldLabel(label: 'Goal Name', icon: Icons.flag_rounded),
            const SizedBox(height: 8),
            TextFormField(
              controller: goalController,
              decoration: const InputDecoration(hintText: 'e.g. New Laptop'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              onChanged: (_) => _resetCalculation(),
            ),
            const SizedBox(height: 20),

            // Target Amount
            const FormFieldLabel(
              label: 'Target Amount',
              icon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '\$1,000'),
              validator: (v) =>
                  double.tryParse(v ?? '') == null ? 'Invalid number' : null,
              onChanged: (_) => _resetCalculation(),
            ),
            const SizedBox(height: 20),

            // End Date
            const FormFieldLabel(
              label: 'End Date',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 8),
            DatePickerField(selectedDate: selectedDate, onTap: _pickDate),
            const SizedBox(height: 20),

            // Monthly Income
            // Monthly Income + Type
            Row(
              children: [
                Expanded(
                  flex: 2, // take twice the space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormFieldLabel(
                        label: 'Income',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: incomeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '\$3,000'),
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Invalid number'
                            : null,
                        onChanged: (_) => _resetCalculation(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12), // spacing between input and dropdown
                Expanded(
                  flex: 1, // take less space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormFieldLabel(
                        label: 'Income Type',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<IncomeType>(
                        value: selectedIncomeType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (IncomeType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedIncomeType = newValue;
                              _resetCalculation();
                            });
                          }
                        },
                        items: IncomeType.values
                            .map(
                              (type) => DropdownMenuItem<IncomeType>(
                                value: type,
                                child: Text(
                                  type.name[0].toUpperCase() +
                                      type.name.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Preview Card
            if (showCalculation && _previewCard != null) _previewCard!,

            // Action Button
            GradientActionButton(
              text: showCalculation ? 'Save Goal & Start' : 'Show Calculation',
              icon: showCalculation
                  ? Icons.rocket_launch_rounded
                  : Icons.calculate_rounded,
              onPressed: _onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class FormFieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const FormFieldLabel({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Date picker field widget
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const Icon(Icons.calendar_month_rounded),
          ],
        ),
      ),
    );
  }
}

/// Gradient action button
class GradientActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const GradientActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
