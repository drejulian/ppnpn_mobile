import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/task_repository.dart';
import '../models/task_model.dart';

// Provider untuk TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// Provider untuk daftar semua tasks
final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksNotifier(ref.read(taskRepositoryProvider));
});

// Provider untuk tasks berdasarkan user ID
final tasksByUserProvider = StateNotifierProvider.family<TasksByUserNotifier, AsyncValue<List<TaskModel>>, int>((ref, userId) {
  return TasksByUserNotifier(ref.read(taskRepositoryProvider), userId);
});

// Provider untuk tasks berdasarkan status
final tasksByStatusProvider = StateNotifierProvider.family<TasksByStatusNotifier, AsyncValue<List<TaskModel>>, TaskStatus>((ref, status) {
  return TasksByStatusNotifier(ref.read(taskRepositoryProvider), status);
});

// Provider untuk tasks berdasarkan priority
final tasksByPriorityProvider = StateNotifierProvider.family<TasksByPriorityNotifier, AsyncValue<List<TaskModel>>, TaskPriority>((ref, priority) {
  return TasksByPriorityNotifier(ref.read(taskRepositoryProvider), priority);
});

// Provider untuk search tasks
final searchTasksProvider = StateNotifierProvider.family<SearchTasksNotifier, AsyncValue<List<TaskModel>>, String>((ref, query) {
  return SearchTasksNotifier(ref.read(taskRepositoryProvider), query);
});

// Provider untuk upcoming deadlines
final upcomingDeadlinesProvider = StateNotifierProvider<UpcomingDeadlinesNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return UpcomingDeadlinesNotifier(ref.read(taskRepositoryProvider));
});

// Provider untuk overdue tasks
final overdueTasksProvider = StateNotifierProvider<OverdueTasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return OverdueTasksNotifier(ref.read(taskRepositoryProvider));
});

// Provider untuk task statistics
final taskStatisticsProvider = StateNotifierProvider<TaskStatisticsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return TaskStatisticsNotifier(ref.read(taskRepositoryProvider));
});

// Provider untuk filtered tasks
final filteredTasksProvider = StateNotifierProvider<FilteredTasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return FilteredTasksNotifier(ref.read(taskRepositoryProvider));
});

/// StateNotifier untuk daftar semua tasks
class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  /// Load semua tasks
  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data tasks
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Tambah task baru
  Future<TaskModel> addTask(TaskModel task) async {
    try {
      final newTask = await _repository.insertTask(task);
      
      // Update state dengan menambahkan task baru
      state.whenData((tasks) {
        final updatedTasks = [newTask, ...tasks];
        state = AsyncValue.data(updatedTasks);
      });
      
      return newTask;
    } catch (e) {
      throw Exception('Gagal menambah task: $e');
    }
  }

  /// Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final updatedTask = await _repository.updateTask(task);
      
      // Update state dengan mengupdate task yang ada
      state.whenData((tasks) {
        final updatedTasks = tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
        state = AsyncValue.data(updatedTasks);
      });
      
      return updatedTask;
    } catch (e) {
      throw Exception('Gagal mengupdate task: $e');
    }
  }

  /// Update status task
  Future<void> updateTaskStatus(int taskId, TaskStatus status) async {
    try {
      await _repository.updateTaskStatus(taskId, status);
      
      // Update state
      state.whenData((tasks) {
        final updatedTasks = tasks.map((task) {
          if (task.id == taskId) {
            return task.copyWith(
              status: status,
              completedAt: status == TaskStatus.completed ? DateTime.now() : null,
            );
          }
          return task;
        }).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e) {
      throw Exception('Gagal update status task: $e');
    }
  }

  /// Update progress task
  Future<void> updateTaskProgress(int taskId, int progress) async {
    try {
      await _repository.updateTaskProgress(taskId, progress);
      
      // Update state
      state.whenData((tasks) {
        final updatedTasks = tasks.map((task) {
          if (task.id == taskId) {
            TaskStatus newStatus = task.status;
            DateTime? completedAt = task.completedAt;
            
            if (progress == 100) {
              newStatus = TaskStatus.completed;
              completedAt = DateTime.now();
            } else if (progress > 0 && task.status == TaskStatus.pending) {
              newStatus = TaskStatus.inProgress;
            }
            
            return task.copyWith(
              progress: progress,
              status: newStatus,
              completedAt: completedAt,
            );
          }
          return task;
        }).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e) {
      throw Exception('Gagal update progress task: $e');
    }
  }

  /// Hapus task
  Future<void> deleteTask(int taskId) async {
    try {
      await _repository.deleteTask(taskId);
      
      // Update state dengan menghapus task
      state.whenData((tasks) {
        final updatedTasks = tasks.where((t) => t.id != taskId).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e) {
      throw Exception('Gagal menghapus task: $e');
    }
  }

  /// Get task by ID dari state
  TaskModel? getTaskById(int id) {
    return state.whenOrNull(
      data: (tasks) => tasks.firstWhere((task) => task.id == id, orElse: () => throw Exception('Task tidak ditemukan')),
    );
  }
}

/// StateNotifier untuk tasks berdasarkan user ID
class TasksByUserNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final int _userId;

  TasksByUserNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    loadTasksByUser();
  }

  /// Load tasks berdasarkan user ID
  Future<void> loadTasksByUser() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getTasksByUserId(_userId);
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadTasksByUser();
  }
}

/// StateNotifier untuk tasks berdasarkan status
class TasksByStatusNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final TaskStatus _status;

  TasksByStatusNotifier(this._repository, this._status) : super(const AsyncValue.loading()) {
    loadTasksByStatus();
  }

  /// Load tasks berdasarkan status
  Future<void> loadTasksByStatus() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getTasksByStatus(_status);
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadTasksByStatus();
  }
}

/// StateNotifier untuk tasks berdasarkan priority
class TasksByPriorityNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final TaskPriority _priority;

  TasksByPriorityNotifier(this._repository, this._priority) : super(const AsyncValue.loading()) {
    loadTasksByPriority();
  }

  /// Load tasks berdasarkan priority
  Future<void> loadTasksByPriority() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getTasksByPriority(_priority);
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadTasksByPriority();
  }
}

/// StateNotifier untuk search tasks
class SearchTasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final String _query;

  SearchTasksNotifier(this._repository, this._query) : super(const AsyncValue.loading()) {
    if (_query.isNotEmpty) {
      searchTasks();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  /// Search tasks berdasarkan judul
  Future<void> searchTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.searchTasksByTitle(_query);
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// StateNotifier untuk upcoming deadlines
class UpcomingDeadlinesNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;

  UpcomingDeadlinesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadUpcomingDeadlines();
  }

  /// Load upcoming deadlines
  Future<void> loadUpcomingDeadlines() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getUpcomingDeadlines();
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadUpcomingDeadlines();
  }
}

/// StateNotifier untuk overdue tasks
class OverdueTasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;

  OverdueTasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadOverdueTasks();
  }

  /// Load overdue tasks
  Future<void> loadOverdueTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getOverdueTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadOverdueTasks();
  }
}

/// StateNotifier untuk task statistics
class TaskStatisticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final TaskRepository _repository;

  TaskStatisticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStatistics();
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      state = const AsyncValue.loading();
      final stats = await _repository.getTaskStatistics();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get total tasks
  int get totalTasks {
    return state.whenOrNull(
      data: (stats) => stats['total'] as int? ?? 0,
    ) ?? 0;
  }

  /// Get completion rate
  int get completionRate {
    return state.whenOrNull(
      data: (stats) => stats['completionRate'] as int? ?? 0,
    ) ?? 0;
  }

  /// Get overdue count
  int get overdueCount {
    return state.whenOrNull(
      data: (stats) => stats['overdue'] as int? ?? 0,
    ) ?? 0;
  }

  /// Get count for specific status
  int getCountForStatus(String status) {
    return state.whenOrNull(
      data: (stats) {
        final statusCounts = stats['statusCounts'] as Map<String, int>? ?? {};
        return statusCounts[status] ?? 0;
      },
    ) ?? 0;
  }

  /// Get count for specific priority
  int getCountForPriority(String priority) {
    return state.whenOrNull(
      data: (stats) {
        final priorityCounts = stats['priorityCounts'] as Map<String, int>? ?? {};
        return priorityCounts[priority] ?? 0;
      },
    ) ?? 0;
  }
}

/// StateNotifier untuk filtered tasks dengan multiple filters
class FilteredTasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  
  // Filter parameters
  int? _userId;
  TaskStatus? _status;
  TaskPriority? _priority;
  DateTime? _startDate;
  DateTime? _endDate;

  FilteredTasksNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Apply filters
  Future<void> applyFilters({
    int? userId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _userId = userId;
      _status = status;
      _priority = priority;
      _startDate = startDate;
      _endDate = endDate;

      state = const AsyncValue.loading();
      final tasks = await _repository.getTasksWithFilters(
        userId: userId,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear filters
  void clearFilters() {
    _userId = null;
    _status = null;
    _priority = null;
    _startDate = null;
    _endDate = null;
    state = const AsyncValue.data([]);
  }

  /// Refresh with current filters
  Future<void> refresh() async {
    if (_userId != null || _status != null || _priority != null || _startDate != null || _endDate != null) {
      await applyFilters(
        userId: _userId,
        status: _status,
        priority: _priority,
        startDate: _startDate,
        endDate: _endDate,
      );
    }
  }

  /// Get current filters
  Map<String, dynamic> get currentFilters => {
    'userId': _userId,
    'status': _status,
    'priority': _priority,
    'startDate': _startDate,
    'endDate': _endDate,
  };

  /// Check if any filter is applied
  bool get hasActiveFilters => _userId != null || _status != null || _priority != null || _startDate != null || _endDate != null;
}

/// Utility providers
final totalTasksProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).totalTasks;
});

final completionRateProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).completionRate;
});

final overdueCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).overdueCount;
});

final pendingTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).getCountForStatus('pending');
});

final inProgressTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).getCountForStatus('inProgress');
});

final completedTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).getCountForStatus('completed');
});

final highPriorityTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).getCountForPriority('high');
});

final urgentTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskStatisticsProvider.notifier).getCountForPriority('urgent');
});