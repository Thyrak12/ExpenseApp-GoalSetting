import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../theme/app_theme.dart';

class QuickAddList extends StatelessWidget {
  final ValueChanged<ExpenseCategory> onCategoryTap;

  const QuickAddList({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80, // height for each button
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ExpenseCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = ExpenseCategory.values[index];
              return _CategoryButton(
                category: cat,
                onTap: () => onCategoryTap(cat),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback onTap;

  const _CategoryButton({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: category.color, size: 25),
            const SizedBox(height: 6),
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
