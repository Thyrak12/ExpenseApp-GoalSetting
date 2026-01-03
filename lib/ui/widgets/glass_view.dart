import 'package:flutter/material.dart';

/// Reusable glass-style card used across screens
class GlassView extends StatelessWidget {
  final LinearGradient gradient;
  final EdgeInsets padding;
  final bool hasShadow;
  final Color accentColor;

  // Header
  final Widget? leftHeader;
  final Widget? rightHeader;

  // Content
  final String? title;
  final String? subtitle;
  final String? miniTitle;

  // Progress
  final double? progress;

  const GlassView({
    super.key,
    required this.gradient,
    this.padding = const EdgeInsets.all(20),
    this.hasShadow = false,
    this.accentColor = Colors.white,
    this.leftHeader,
    this.rightHeader,
    this.title,
    this.subtitle,
    this.miniTitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: hasShadow ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leftHeader != null || rightHeader != null) ...[
            _buildHeader(),
            const SizedBox(height: 16),
          ],
          if (title != null) _buildTitleRow(),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            _buildSubtitle(),
          ],
          if (progress != null) ...[
            const SizedBox(height: 16),
            _buildProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (leftHeader != null) leftHeader!,
        const Spacer(),
        if (rightHeader != null) rightHeader!,
      ],
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title!,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        if (miniTitle != null) ...[
          const SizedBox(width: 8),
          Text(
            miniTitle!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress!.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
