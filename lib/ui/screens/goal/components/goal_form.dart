import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../theme/app_theme.dart';

class GoalFormPage extends StatefulWidget {
  final Function(SavingGoal, Income) onSave;

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
      setState(() => selectedDate = date);
    }
  }

  void _onSavePressed() {
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
    );

    widget.onSave(newGoal, income);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal Name
          const Text('Goal Name', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: goalController,
            decoration: _inputDecoration('e.g. New Laptop'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Target Amount
          const Text('Target Amount', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('\$1,000'),
            validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid number' : null,
          ),
          const SizedBox(height: 16),

          // End Date
          const Text('End Date', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Income
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: incomeController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('\$3,000'),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<IncomeType>(
                      initialValue: selectedIncomeType,
                      decoration: _inputDecoration(null),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedIncomeType = v);
                      },
                      items: IncomeType.values
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onSavePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Save Goal',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
