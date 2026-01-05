import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_view.dart';
import '../../../widgets/glass_badge.dart';

class SavingsCard extends StatelessWidget {
  final double currentSaved;
  final double targetAmount;
  final double progress;
  final int daysLeft;

  const SavingsCard({
    super.key,
    required this.currentSaved,
    required this.targetAmount,
    required this.progress,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GlassView(
      gradient: AppTheme.primaryGradient,
      hasShadow: true,
      accentColor: Colors.white,
      leftHeader: const GlassBadge(
        icon: Icons.savings,
        text: 'Current Savings',
        color: Colors.white,
      ),
      title: '\$${currentSaved.toStringAsFixed(0)}',
      miniTitle: 'of \$${targetAmount.toStringAsFixed(0)}',
      subtitle: '${(progress * 100).toStringAsFixed(0)}% complete • $daysLeft days left',
      progress: progress,
    );
  }
}
