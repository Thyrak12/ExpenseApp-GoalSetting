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
  final Future<void> Function()? onMarkCompleted;
  final bool isCompleted;

  const GoalScreen({
    super.key,
    this.savingService,
    required this.onGoalCreated,
    required this.onGoalDeleted,
    this.onMarkCompleted,
    required this.isCompleted,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  bool _showNewGoalForm = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Goal?'),
        content: const Text('This will delete all data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.onGoalDeleted();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateNewGoal() async {
    if (widget.onMarkCompleted != null) {
      await widget.onMarkCompleted!();
    }
    setState(() => _showNewGoalForm = true);
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = widget.savingService != null;
    final showForm = !hasGoal || _showNewGoalForm;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.backgroundColor,
        leading: _showNewGoalForm
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showNewGoalForm = false),
              )
            : null,
        title: ScreenHeader(
          title: showForm ? 'Create Goal' : 'Your Goal',
          subtitle: showForm ? 'Create your goal below' : 'Your goal information',
        ),
        actions: hasGoal && !_showNewGoalForm
            ? [
                PopupMenuButton<String>(
                  onSelected: (ctx) {
                    if (widget.isCompleted) {
                      _handleCreateNewGoal();
                    } else {
                      _showDeleteConfirmation();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'action',
                      child: Row(
                        children: widget.isCompleted
                            ? [
                                Icon(Icons.create, color: AppTheme.primaryColor, size: 20),
                                const SizedBox(width: 8),
                                const Text('Create New Goal'),
                              ]
                            : const [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete Goal'),
                              ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: showForm
              ? GoalFormPage(onSave: (goal, income) {
                  widget.onGoalCreated(goal, income);
                  setState(() => _showNewGoalForm = false);
                })
              : GoalInfoPage(savingService: widget.savingService!),
        ),
      ),
    );
  }
}
