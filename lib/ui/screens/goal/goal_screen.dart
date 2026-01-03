import 'package:flutter/material.dart';
import '../../../model/new_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';
import 'components/goal_form.dart';
import 'components/goal_info.dart';

class GoalScreen extends StatefulWidget {
  final SavingGoal? currentGoal;
  final Function(SavingGoal) onGoalCreated;
  final VoidCallback onGoalDeleted;

  const GoalScreen({
    super.key,
    this.currentGoal,
    required this.onGoalCreated,
    required this.onGoalDeleted,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  void _onGoalSaved(SavingGoal goal) {
    widget.onGoalCreated(goal);
  }

  String _getTitle() {
    if (widget.currentGoal != null) return 'Your Goal';
    return 'Create Goal';
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('Delete Goal?', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(
          'This will permanently delete the goal and all its expenses and progress.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onGoalDeleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = widget.currentGoal != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ScreenHeader(
                title: _getTitle(),
                subtitle: hasGoal
                    ? 'Track your progress'
                    : 'Set your saving target',
                trailing: hasGoal
                    ? PopupMenuButton(
                        color: AppTheme.surfaceColor,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: _showDeleteConfirmation,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Delete Goal',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              hasGoal
                  ? GoalInfoPage(goal: widget.currentGoal!)
                  : GoalFormPage(onSave: _onGoalSaved),
            ],
          ),
        ),
      ),
    );
  }
}
