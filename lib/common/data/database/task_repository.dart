import 'app_database_helper.dart';
import '../../models/task_model.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  final AppDatabaseHelper _dbHelper = AppDatabaseHelper();

  /// Mendapatkan semua tasks
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan daftar tasks. Error: $e');
    }
  }

  /// Mendapatkan task berdasarkan ID
  Future<TaskModel?> getTaskById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return TaskModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan task dengan ID $id. Error: $e');
    }
  }

  /// Mendapatkan tasks berdasarkan user ID (assignee)
  Future<List<TaskModel>> getTasksByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'assignedTo = ?',
        whereArgs: [userId],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan tasks untuk user $userId. Error: $e');
    }
  }

  /// Mendapatkan tasks berdasarkan status
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'status = ?',
        whereArgs: [status.toString().split('.').last],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan tasks dengan status $status. Error: $e');
    }
  }

  /// Mendapatkan tasks berdasarkan priority
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'priority = ?',
        whereArgs: [priority.toString().split('.').last],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan tasks dengan priority $priority. Error: $e');
    }
  }

  /// Mencari tasks berdasarkan judul
  Future<List<TaskModel>> searchTasksByTitle(String query) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mencari tasks dengan judul $query. Error: $e');
    }
  }

  /// Mendapatkan tasks yang hampir deadline (dalam 3 hari)
  Future<List<TaskModel>> getUpcomingDeadlines({int days = 3}) async {
    try {
      final db = await _dbHelper.database;
      final endDate = DateTime.now().add(Duration(days: days));
      
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'dueDate <= ? AND status != ?',
        whereArgs: [endDate.toIso8601String(), 'completed'],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan upcoming deadlines. Error: $e');
    }
  }

  /// Mendapatkan overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'dueDate < ? AND status != ?',
        whereArgs: [now.toIso8601String(), 'completed'],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan overdue tasks. Error: $e');
    }
  }

  /// Mendapatkan tasks dengan filter kombinasi
  Future<List<TaskModel>> getTasksWithFilters({
    int? userId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      List<String> whereConditions = [];
      List<dynamic> whereArgs = [];

      if (userId != null) {
        whereConditions.add('assignedTo = ?');
        whereArgs.add(userId);
      }

      if (status != null) {
        whereConditions.add('status = ?');
        whereArgs.add(status.toString().split('.').last);
      }

      if (priority != null) {
        whereConditions.add('priority = ?');
        whereArgs.add(priority.toString().split('.').last);
      }

      if (startDate != null) {
        whereConditions.add('dueDate >= ?');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('dueDate <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      String? whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan tasks dengan filter. Error: $e');
    }
  }

  /// Menambah task baru
  Future<TaskModel> insertTask(TaskModel task) async {
    try {
      // Validasi task
      task.validate();

      final db = await _dbHelper.database;
      final id = await db.insert('tasks', task.toMap());
      
      return task.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menambah task baru. Error: $e');
    }
  }

  /// Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      if (task.id == null) {
        throw Exception('ID task tidak boleh null untuk update');
      }

      // Validasi task
      task.validate();

      final db = await _dbHelper.database;
      final count = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      if (count == 0) {
        throw Exception('Task dengan ID ${task.id} tidak ditemukan');
      }

      return task;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate task. Error: $e');
    }
  }

  /// Update status task
  Future<void> updateTaskStatus(int taskId, TaskStatus status) async {
    try {
      final db = await _dbHelper.database;
      final updateData = {'status': status.toString().split('.').last};
      
      // Jika status completed, set completedAt
      if (status == TaskStatus.completed) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      final count = await db.update(
        'tasks',
        updateData,
        where: 'id = ?',
        whereArgs: [taskId],
      );

      if (count == 0) {
        throw Exception('Task dengan ID $taskId tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Repository: Gagal update status task. Error: $e');
    }
  }

  /// Update progress task
  Future<void> updateTaskProgress(int taskId, int progress) async {
    try {
      if (progress < 0 || progress > 100) {
        throw Exception('Progress harus antara 0-100');
      }

      final db = await _dbHelper.database;
      final updateData = <String, dynamic>{'progress': progress};
      
      // Auto update status berdasarkan progress
      if (progress == 100) {
        updateData['status'] = TaskStatus.completed.toString().split('.').last;
        updateData['completedAt'] = DateTime.now().toIso8601String();
      } else if (progress > 0) {
        updateData['status'] = TaskStatus.inProgress.toString().split('.').last;
      }

      final count = await db.update(
        'tasks',
        updateData,
        where: 'id = ?',
        whereArgs: [taskId],
      );

      if (count == 0) {
        throw Exception('Task dengan ID $taskId tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Repository: Gagal update progress task. Error: $e');
    }
  }

  /// Hapus task
  Future<void> deleteTask(int id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('Task dengan ID $id tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Repository: Gagal menghapus task. Error: $e');
    }
  }

  /// Mendapatkan statistik tasks
  Future<Map<String, dynamic>> getTaskStatistics() async {
    try {
      final db = await _dbHelper.database;
      
      // Total tasks
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
      final total = totalResult.first['count'] as int;

      // Tasks by status
      final statusResult = await db.rawQuery('''
        SELECT status, COUNT(*) as count 
        FROM tasks 
        GROUP BY status
      ''');

      Map<String, int> statusCounts = {
        'pending': 0,
        'inProgress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (var row in statusResult) {
        final status = row['status'] as String;
        final count = row['count'] as int;
        statusCounts[status] = count;
      }

      // Tasks by priority
      final priorityResult = await db.rawQuery('''
        SELECT priority, COUNT(*) as count 
        FROM tasks 
        GROUP BY priority
      ''');

      Map<String, int> priorityCounts = {
        'low': 0,
        'medium': 0,
        'high': 0,
        'urgent': 0,
      };

      for (var row in priorityResult) {
        final priority = row['priority'] as String;
        final count = row['count'] as int;
        priorityCounts[priority] = count;
      }

      // Overdue tasks
      final overdueResult = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM tasks 
        WHERE dueDate < ? AND status != ?
      ''', [DateTime.now().toIso8601String(), 'completed']);
      final overdue = overdueResult.first['count'] as int;

      // Completion rate
      final completed = statusCounts['completed'] ?? 0;
      final completionRate = total > 0 ? (completed / total * 100).round() : 0;

      return {
        'total': total,
        'statusCounts': statusCounts,
        'priorityCounts': priorityCounts,
        'overdue': overdue,
        'completionRate': completionRate,
      };
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan statistik tasks. Error: $e');
    }
  }

  /// Mendapatkan tasks yang dibuat dalam rentang waktu tertentu
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'createdAt >= ? AND createdAt <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return TaskModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan tasks by date range. Error: $e');
    }
  }
}