import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'task_data.dart';
import 'edit_task_page.dart';
import 'tambah_task_page.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  String _selectedFilter = 'To Do';

  // Sample task data
  List<TaskData> _tasks = [
    TaskData(
      title: 'Dashboard design for admin',
      description: 'Create comprehensive admin dashboard with analytics',
      dueDate: DateTime(2022, 10, 14),
      priority: 'High',
      status: 'Complete',
      assignees: ['JD', 'SM'],
      commentsCount: 5,
      filesCount: 5,
      priorityColor: Colors.red,
      statusColor: Colors.green,
    ),
    TaskData(
      title: 'Konom web application',
      description: 'Build responsive web application for content management',
      dueDate: DateTime(2022, 11, 14),
      priority: 'Low',
      status: 'To Do',
      assignees: ['AB', 'CD'],
      commentsCount: 2,
      filesCount: 4,
      priorityColor: Colors.green,
      statusColor: Colors.orange,
    ),
    TaskData(
      title: 'Research and development',
      description: 'Conduct market research for new product features',
      dueDate: DateTime(2022, 10, 14),
      priority: 'Medium',
      status: 'In Review',
      assignees: ['EF', 'GH'],
      commentsCount: 6,
      filesCount: 2,
      priorityColor: Colors.orange,
      statusColor: Colors.purple,
    ),
    TaskData(
      title: 'Event booking application',
      description: 'Develop mobile application for event management',
      dueDate: DateTime(2022, 10, 14),
      priority: 'Medium',
      status: 'To Do',
      assignees: ['IJ', 'KL'],
      commentsCount: 5,
      filesCount: 5,
      priorityColor: Colors.orange,
      statusColor: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              'Task List',
              style: theme.typographyBold.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),


      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Add Task Button
          _buildAddTaskButton(theme),
          
          const SizedBox(height: 20),
          
          // Filter Tabs
          _buildFilterTabs(theme),
          
          // Task List
          Expanded(
            child: _buildTaskList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(MyTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.primarySwatch,
            theme.primarySwatch.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddTaskDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_circle_rounded, size: 22),
        label: Text(
          'TAMBAH TASK BARU',
          style: theme.typographyBold.bodyMedium.copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(MyTheme theme) {
    final filters = [
      {'label': 'To Do', 'count': 45},
      {'label': 'In Review', 'count': 3},
      {'label': 'Complete', 'count': 68},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['label'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter['label'] as String;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primarySwatch : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.primarySwatch : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.primarySwatch.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        filter['label'] as String,
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList(MyTheme theme) {
    final filteredTasks = _tasks.where((task) => task.status == _selectedFilter).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildTaskCard(task, theme);
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskData task, MyTheme theme) {
    return AppListCard(
      onTap: () => _showTaskDetailDialog(context, task),
      leftAccentColor: _getStatusBorderColor(task.status),
      title: task.title,
      subtitle: task.description,
      trailing: AppStatusChip(
        label: task.status,
        color: task.statusColor,
        icon: _getStatusIcon(task.status),
      ),
      chips: [
        AppPillChip(
          icon: Icons.flag,
          label: task.priority,
          color: task.priorityColor,
        ),
        AppPillChip(
          icon: Icons.schedule,
          label: DateFormat('dd MMM yyyy').format(task.dueDate),
          color: Colors.grey[600]!,
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Complete':
        return Icons.check_circle;
      case 'In Review':
        return Icons.visibility;
      case 'To Do':
        return Icons.radio_button_unchecked;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Complete':
        return Colors.green;
      case 'To Do':
        return Colors.blue;
      case 'In Review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _editTask(TaskData task) async {
    final updatedTask = await Navigator.push<TaskData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          taskData: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              final index = _tasks.indexWhere((t) => 
                t.title == task.title && 
                t.dueDate == task.dueDate
              );
              if (index != -1) {
                _tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
    
    if (updatedTask != null) {
      setState(() {
        final index = _tasks.indexWhere((t) => 
          t.title == task.title && 
          t.dueDate == task.dueDate
        );
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });
    }
  }

  void _showTaskDetailDialog(BuildContext context, TaskData task) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Task - ${task.title}',
      fields: [
        SIHAKIDialogField(label: 'Title', value: task.title),
        SIHAKIDialogField(label: 'Description', value: task.description),
        SIHAKIDialogField(label: 'Due Date', value: DateFormat('dd MMM yyyy').format(task.dueDate)),
        SIHAKIDialogField(label: 'Priority', value: task.priority),
        SIHAKIDialogField(label: 'Status', value: task.status),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Edit Task',
          backgroundColor: Colors.orange[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editTask(task);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Delete Task',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDeleteTaskWithSIHAKI(task);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.share_rounded,
          label: 'Share Task',
          backgroundColor: Colors.blue[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _shareTask(task);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _confirmDeleteTaskWithSIHAKI(TaskData task) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Task',
      message:
          'Apakah Anda yakin ingin menghapus task "${task.title}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        _deleteTask(task);
      },
    );
  }

  void _shareTask(TaskData task) {
    // Implementasi share task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing task: ${task.title}'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _deleteTask(TaskData task) {
    setState(() {
      _tasks.remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahTaskPage(),
      ),
    );

    // If a new task was returned, add it to the list
    if (result != null && result is TaskData) {
      setState(() {
        _tasks.add(result);
      });
    }
  }
}
