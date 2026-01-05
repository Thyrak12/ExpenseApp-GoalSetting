import 'package:flutter/material.dart';
import 'package:saving_app/ui/widgets/screen_header.dart';
import '../../../model/model.dart';
import '../../theme/app_theme.dart';
import 'components/goal_form.dart';
import 'components/goal_info.dart';

class GoalScreen extends StatefulWidget {
  final SavingService? savingService;
  final Function(SavingGoal, Income) onGoalCreated;
  final VoidCallback onGoalDeleted;

  const GoalScreen({
    super.key,
    this.savingService,
    required this.onGoalCreated,
    required this.onGoalDeleted,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Goal?'),
        content: const Text('This will delete all data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onGoalDeleted();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = widget.savingService != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.backgroundColor,
        title: ScreenHeader(title: hasGoal ? 'Your Goal' : 'Create Goal', subtitle: hasGoal? 'Your goal information' : 'Create your goal below'),
        actions: hasGoal
            ? [
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') _showDeleteConfirmation();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete Goal'),
                      ],
                    )),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: hasGoal
              ? GoalInfoPage(savingService: widget.savingService!)
              : GoalFormPage(onSave: widget.onGoalCreated),
        ),
      ),
    );
  }
}
