import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'task_data.dart';
import 'edit_task_page.dart';
import 'tambah_task_page.dart';

// Task Providers
class TaskNotifier extends StateNotifier<List<TaskData>> {
  TaskNotifier()
    : super([
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
          hasReminder: false,
        ),
        TaskData(
          title: 'Konom web application',
          description:
              'Build responsive web application for content management',
          dueDate: DateTime(2022, 11, 14),
          priority: 'Low',
          status: 'To Do',
          assignees: ['AB', 'CD'],
          commentsCount: 2,
          filesCount: 4,
          priorityColor: Colors.green,
          statusColor: Colors.orange,
          hasReminder: true,
          reminderDateTime: DateTime.now().add(Duration(days: 1)),
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
          hasReminder: false,
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
          hasReminder: false,
        ),
      ]);

  void add(TaskData task) {
    state = [...state, task];
  }

  void remove(TaskData task) {
    state = state.where((t) => t != task).toList();
  }

  void update(TaskData oldTask, TaskData newTask) {
    final index = state.indexWhere(
      (t) => t.title == oldTask.title && t.dueDate == oldTask.dueDate,
    );
    if (index != -1) {
      final newState = [...state];
      newState[index] = newTask;
      state = newState;
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskData>>(
  (ref) => TaskNotifier(),
);
final taskSearchProvider = StateProvider<String>((ref) => '');
final taskStatusFilterProvider = StateProvider<String>((ref) => 'To Do');

final filteredTaskProvider = Provider<List<TaskData>>((ref) {
  final tasks = ref.watch(taskProvider);
  final searchQuery = ref.watch(taskSearchProvider).toLowerCase().trim();
  final statusFilter = ref.watch(taskStatusFilterProvider);

  return tasks.where((task) {
    final matchesSearch =
        searchQuery.isEmpty ||
        task.title.toLowerCase().contains(searchQuery) ||
        task.description.toLowerCase().contains(searchQuery);

    final matchesStatus =
        statusFilter == 'Semua' || task.status == statusFilter;

    return matchesSearch && matchesStatus;
  }).toList();
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
                                  () => _showTaskDetailDialog(context, task),
                              tooltip: 'Lihat Detail',
                            ),
                          ],
                          onTap: () => _showTaskDetailDialog(context, task),
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
                setState(() {
                  ref.read(taskProvider.notifier).update(task, updatedTask);
                });
              },
            ),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        ref.read(taskProvider.notifier).update(task, updatedTask);
      });
    }
  }

  void _showTaskDetailDialog(BuildContext context, TaskData task) {
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

  void _shareTask(TaskData task) {
    // Implementasi share task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing task: ${task.title}'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteTask(TaskData task) {
    setState(() {
      ref.read(taskProvider.notifier).remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahTaskPage()),
    );

    // If a new task was returned, add it to the list
    if (result != null && result is TaskData) {
      setState(() {
        ref.read(taskProvider.notifier).add(result);
      });
    }
  }
}
