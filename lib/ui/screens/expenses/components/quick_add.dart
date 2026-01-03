import 'package:flutter/material.dart';
import 'package:saving_app/model/model.dart';
import '../../../theme/app_theme.dart';

class QuickAddCard extends StatelessWidget {
  const QuickAddCard({super.key, required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, color: category.color),
          const SizedBox(height: 6),
          Text(
            category.title,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
