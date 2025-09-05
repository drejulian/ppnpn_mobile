import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
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
              style: theme.typographyRegular.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showAddTaskDialog(context),
          icon: const Icon(Icons.add_circle, size: 20),
          label: Text(
            'TAMBAH TASK BARU',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.primarySwatch,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusBorderColor(task.status),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and options
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: theme.typographyRegular.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                    height: 1.3,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showTaskOptions(context, task),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          if (task.description.isNotEmpty) ...[
            Text(
              task.description,
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          
          // Priority and Due Date
          Row(
            children: [
              _buildModernBadge(task.priority, task.priorityColor, theme),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(task.dueDate),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status badge at bottom
          Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusBadge(task.status, task.statusColor, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBadge(String text, Color color, MyTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: theme.typographyRegular.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, MyTheme theme) {
    IconData icon;
    switch (status) {
      case 'Complete':
        icon = Icons.check_circle;
        break;
      case 'In Review':
        icon = Icons.visibility;
        break;
      case 'To Do':
        icon = Icons.radio_button_unchecked;
        break;
      default:
        icon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.typographyRegular.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Complete':
        return Colors.green.withOpacity(0.3);
      case 'To Do':
        return Colors.blue.withOpacity(0.3);
      case 'In Review':
        return Colors.orange.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  void _showTaskOptions(BuildContext context, TaskData task) {
    final theme = ref.watch(themeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Task Options',
                style: theme.typographyRegular.headingSmall.copyWith(
                  color: theme.primarySwatch.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Task',
                subtitle: 'Modify task details',
                onTap: () async {
                  Navigator.pop(context);
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
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Delete Task',
                subtitle: 'Remove this task',
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteTask(task);
                },
                theme: theme,
                isDestructive: true,
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                icon: Icons.share_outlined,
                title: 'Share Task',
                subtitle: 'Send task details',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Share task
                },
                theme: theme,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required MyTheme theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : theme.primarySwatch.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? Colors.red.shade600
              : theme.primarySwatch.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.typographyRegular.bodyMedium.copyWith(
          color:
              isDestructive ? Colors.red.shade700 : theme.primarySwatch.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.typographyRegular.bodySmall.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.grey[400], size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _confirmDeleteTask(TaskData task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Anda yakin ingin menghapus task ini?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(task);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
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
