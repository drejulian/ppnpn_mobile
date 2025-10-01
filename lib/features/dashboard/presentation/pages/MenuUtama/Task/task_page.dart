import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

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

// Search and filter providers
final taskSearchProvider = StateProvider<String>((ref) => '');
final taskStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredTaskProvider = Provider<List<TaskData>>((ref) {
  final taskList = ref.watch(taskListProvider);
  final searchQuery = ref.watch(taskSearchProvider).toLowerCase().trim();
  final statusFilter = ref.watch(taskStatusFilterProvider);

  return taskList.when(
    data: (tasks) {
      return tasks.where((task) {
        final matchesSearch = searchQuery.isEmpty ||
            task.title.toLowerCase().contains(searchQuery) ||
            task.description.toLowerCase().contains(searchQuery);

        final matchesStatus = statusFilter == 'Semua' || task.status == statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    },
    loading: () => <TaskData>[],
    error: (_, __) => <TaskData>[],
  );
});

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredTasks = ref.watch(filteredTaskProvider);
    final currentFilter = ref.watch(taskStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Task',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Column(
        children: [
          // Search Section with Filter - sama seperti daftar cuti
          Container(
            child: AppSearchBar(
              controller: searchController,
              hintText: 'Cari judul task atau deskripsi...',
              margin: const EdgeInsets.all(16),
              hasActiveFilters: currentFilter != 'Semua',
              onChanged: (value) {
                ref.read(taskSearchProvider.notifier).state = value;
              },
              onFilterReset: () {
                searchController.clear();
                ref.read(taskSearchProvider.notifier).state = '';
                ref.read(taskStatusFilterProvider.notifier).state = 'Semua';
              },
              filterSection: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Status',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        ['Semua', 'To Do', 'In Review', 'Complete']
                            .map(
                              (status) => FilterChip(
                                label: Text(status),
                                selected: currentFilter == status,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              taskStatusFilterProvider.notifier,
                                            )
                                            .state = status,
                                selectedColor: theme.primarySwatch.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: theme.primarySwatch,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Tambah Task button - sama seperti daftar cuti
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          ),

          // List Section - sama seperti daftar cuti
          Expanded(
            child:
                filteredTasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data task',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return AppListCard(
                          title: task.title,
                          subtitle: task.description,
                          leading: CircleAvatar(
                            backgroundColor: theme.primarySwatch.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.task_alt,
                              color: theme.primarySwatch,
                              size: 20,
                            ),
                          ),
                          trailing: AppStatusChip(
                            label: task.status,
                            color: task.statusColor,
                          ),
                          chips: [
                            AppPillChip(
                              icon: Icons.calendar_today,
                              label:
                                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                            ),
                            AppPillChip(
                              icon: Icons.priority_high,
                              label: task.priority,
                            ),
                          ],
                          actions: [
                            AppViewDetailButton(
                              onPressed:
                                  () => _showTaskDetailDialog(context, task, index),
                              tooltip: 'Lihat Detail',
                            ),
                          ],
                          onTap: () => _showTaskDetailDialog(context, task, index),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _editTask(TaskData task) async {
    final updatedTask = await Navigator.push<TaskData>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditTaskPage(
              taskData: task,
              onTaskUpdated: (updatedTask) {
                // Task will be automatically updated via provider refresh
                ref.read(taskListProvider.notifier).refresh();
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
        SIHAKIDialogField(
          label: 'Due Date',
          value: DateFormat('dd MMM yyyy').format(task.dueDate),
        ),
        SIHAKIDialogField(label: 'Priority', value: task.priority),
        SIHAKIDialogField(label: 'Status', value: task.status),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Ubah Task',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editTask(task);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Task',
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDeleteTaskWithSIHAKI(task);
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
      MaterialPageRoute(builder: (context) => const TambahTaskPage()),
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