import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_view.dart';
import '../../../widgets/glass_badge.dart';

class BudgetPageView extends StatelessWidget {
  final double todayRemaining;
  final double dailyLimit;
  final double overallRemaining;
  final int daysLeft;
  final int currentPage;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const BudgetPageView({
    super.key,
    required this.todayRemaining,
    required this.dailyLimit,
    required this.overallRemaining,
    required this.daysLeft,
    required this.currentPage,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView(
            controller: controller,
            onPageChanged: onPageChanged,
            children: [
              _TodayCard(remaining: todayRemaining, dailyLimit: dailyLimit),
              _OverallCard(remaining: overallRemaining, daysLeft: daysLeft),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  final double remaining;
  final double dailyLimit;

  const _TodayCard({required this.remaining, required this.dailyLimit});

  @override
  Widget build(BuildContext context) {
    final isOver = remaining < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GlassView(
        gradient: isOver ? AppTheme.errorGradient : AppTheme.primaryGradient,
        hasShadow: false,
        accentColor: Colors.white,
        leftHeader: const GlassBadge(
          icon: Icons.today,
          text: 'Today',
          color: Colors.white,
        ),
        title: '\$${remaining.abs().toStringAsFixed(0)} ${isOver ? "over" : "left"}',
        subtitle: 'Daily limit: \$${dailyLimit.toStringAsFixed(0)}',
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final double remaining;
  final int daysLeft;

  const _OverallCard({required this.remaining, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final isOver = remaining < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GlassView(
        gradient: isOver ? AppTheme.errorGradient : AppTheme.cardGradient,
        hasShadow: false,
        accentColor: isOver ? Colors.white : AppTheme.primaryColor,
        leftHeader: const GlassBadge(
          icon: Icons.account_balance_wallet,
          text: 'Overall Budget',
          color: Colors.white,
        ),
        title: '\$${remaining.abs().toStringAsFixed(0)} ${isOver ? "over" : "left"}',
        subtitle: '$daysLeft days remaining',
      ),
    );
  }
}
