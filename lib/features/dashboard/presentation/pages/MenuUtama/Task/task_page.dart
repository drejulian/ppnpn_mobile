import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'task_data.dart';
import 'edit_task_page.dart';
import 'tambah_task_page.dart';

// Import database and model
import '../../../../../../common/data/models/menuutama/task_model.dart';
import '../../../../../../common/data/database/app_database_helper.dart';

// Provider untuk task list menggunakan database
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskData>>>((ref) {
  return TaskListNotifier();
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<TaskData>>> {
  TaskListNotifier() : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final db = AppDatabaseHelper.instance;
      final database = await db.database;
      
      final List<Map<String, dynamic>> maps = await database.query(
        'tasks',
        orderBy: 'created_at DESC',
      );
      
      // Convert TaskModel to TaskData
      final tasks = maps.map((map) {
        final taskModel = TaskModel.fromMap(map);
        return _convertTaskModelToTaskData(taskModel);
      }).toList();
      
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      debugPrint('Error loading tasks: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  TaskData _convertTaskModelToTaskData(TaskModel taskModel) {
    return TaskData(
      title: taskModel.title,
      description: taskModel.description ?? '',
      dueDate: taskModel.dueDate ?? DateTime.now().add(const Duration(days: 7)),
      priority: _mapPriority(taskModel.priority),
      status: _mapStatus(taskModel.status),
      assignees: [], // Database doesn't have assignees, use empty list
      commentsCount: 0, // Default value
      filesCount: 0, // Default value
      priorityColor: _getPriorityColor(taskModel.priority),
      statusColor: _getStatusColor(taskModel.status),
    );
  }

  String _mapPriority(String dbPriority) {
    switch (dbPriority) {
      case 'low': return 'Low';
      case 'medium': return 'Medium';
      case 'high': return 'High';
      case 'urgent': return 'High'; // Map urgent to High for UI compatibility
      default: return 'Medium';
    }
  }

  String _mapStatus(String dbStatus) {
    switch (dbStatus) {
      case 'pending': return 'To Do';
      case 'in_progress': return 'In Review';
      case 'completed': return 'Complete';
      case 'cancelled': return 'To Do';
      default: return 'To Do';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> addTask(TaskData taskData) async {
    try {
      final db = AppDatabaseHelper.instance;
      final database = await db.database;
      
      // Convert TaskData to TaskModel
      final taskModel = TaskModel.create(
        title: taskData.title,
        description: taskData.description.isNotEmpty ? taskData.description : null,
        priority: _mapPriorityToDb(taskData.priority),
        dueDate: taskData.dueDate,
      );
      
      await database.insert('tasks', taskModel.toMap());
      await _loadTasks(); // Refresh the list
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskData taskData, int? taskId) async {
    try {
      if (taskId == null) return;
      
      final db = AppDatabaseHelper.instance;
      final database = await db.database;
      
      // Get existing task first
      final existing = await database.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
        limit: 1,
      );
      
      if (existing.isEmpty) return;
      
      final existingTask = TaskModel.fromMap(existing.first);
      final updatedTask = existingTask.copyWith(
        title: taskData.title,
        description: taskData.description.isNotEmpty ? taskData.description : null,
        priority: _mapPriorityToDb(taskData.priority),
        status: _mapStatusToDb(taskData.status),
        dueDate: taskData.dueDate,
        updatedAt: DateTime.now(),
      );
      
      await database.update(
        'tasks',
        updatedTask.toMap(),
        where: 'id = ?',
        whereArgs: [taskId],
      );
      
      await _loadTasks(); // Refresh the list
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final db = AppDatabaseHelper.instance;
      final database = await db.database;
      
      await database.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
      
      await _loadTasks(); // Refresh the list
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  String _mapPriorityToDb(String uiPriority) {
    switch (uiPriority) {
      case 'Low': return 'low';
      case 'Medium': return 'medium';
      case 'High': return 'high';
      default: return 'medium';
    }
  }

  String _mapStatusToDb(String uiStatus) {
    switch (uiStatus) {
      case 'To Do': return 'pending';
      case 'In Review': return 'in_progress';
      case 'Complete': return 'completed';
      default: return 'pending';
    }
  }

  void refresh() {
    _loadTasks();
  }
}

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  String _selectedFilter = 'To Do';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final taskListAsync = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      body: taskListAsync.when(
        data: (tasks) => Column(
          children: [
            const SizedBox(height: 20),
            
            // Add Task Button
            _buildAddTaskButton(theme),
            
            const SizedBox(height: 20),
            
            // Filter Tabs
            _buildFilterTabs(theme, tasks),
            
            // Task List
            Expanded(
              child: _buildTaskList(theme, tasks),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: TextStyle(fontSize: 18, color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(taskListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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

  Widget _buildFilterTabs(MyTheme theme, List<TaskData> allTasks) {
    final filters = [
      {'label': 'To Do'},
      {'label': 'In Review'},
      {'label': 'Complete'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.primarySwatch.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
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

  Widget _buildTaskList(MyTheme theme, List<TaskData> allTasks) {
    final filteredTasks = allTasks.where((task) => task.status == _selectedFilter).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedFilter.toLowerCase()} tasks',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks will appear here when you add them',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(taskListProvider.notifier).refresh();
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return _buildTaskCard(task, theme, index);
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskData task, MyTheme theme, int index) {
    return AppListCard(
      onTap: () => _showTaskDetailDialog(context, task, index),
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

  void _editTask(TaskData task, int taskIndex) async {
    final updatedTask = await Navigator.push<TaskData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          taskData: task,
          onTaskUpdated: (updatedTask) {
            // Update will be handled by the database
          },
        ),
      ),
    );
    
    if (updatedTask != null) {
      try {
        // Get task ID from database by matching title and other fields
        final db = AppDatabaseHelper.instance;
        final database = await db.database;
        final existing = await database.query(
          'tasks',
          where: 'title = ? AND created_at IS NOT NULL',
          whereArgs: [task.title],
          orderBy: 'created_at DESC',
          limit: 1,
        );
        
        if (existing.isNotEmpty) {
          final taskId = existing.first['id'] as int;
          await ref.read(taskListProvider.notifier).updateTask(updatedTask, taskId);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating task: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showTaskDetailDialog(BuildContext context, TaskData task, int taskIndex) {
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
            _editTask(task, taskIndex);
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

  void _deleteTask(TaskData task) async {
    try {
      // Find and delete task from database
      final db = AppDatabaseHelper.instance;
      final database = await db.database;
      final existing = await database.query(
        'tasks',
        where: 'title = ? AND created_at IS NOT NULL',
        whereArgs: [task.title],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      
      if (existing.isNotEmpty) {
        final taskId = existing.first['id'] as int;
        await ref.read(taskListProvider.notifier).deleteTask(taskId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddTaskDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahTaskPage(),
      ),
    );

    // If a new task was returned, add it to the database
    if (result != null && result is TaskData) {
      try {
        await ref.read(taskListProvider.notifier).addTask(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding task: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}