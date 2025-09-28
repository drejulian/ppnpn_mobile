enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final int? assignedTo;
  final DateTime dueDate;
  final int progress;
  final DateTime? completedAt;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.dueDate,
    this.progress = 0,
    this.completedAt,
    required this.createdAt,
  });

  /// Factory constructor dari Map (database)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      assignedTo: map['assignedTo'] as int?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      progress: map['progress'] as int? ?? 0,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Factory constructor dari form data
  factory TaskModel.fromFormData({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    int? assignedTo,
    required DateTime dueDate,
    int progress = 0,
  }) {
    return TaskModel(
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
      progress: progress,
      createdAt: DateTime.now(),
    );
  }

  /// Convert ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'progress': progress,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Copy dengan perubahan
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    int? assignedTo,
    DateTime? dueDate,
    int? progress,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validasi data task
  void validate() {
    if (title.isEmpty) throw Exception('Judul task tidak boleh kosong');
    if (title.length < 3) throw Exception('Judul task minimal 3 karakter');
    if (progress < 0 || progress > 100) throw Exception('Progress harus antara 0-100');
    if (dueDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      throw Exception('Tanggal deadline tidak boleh di masa lalu');
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case TaskStatus.pending:
        return 'Menunggu';
      case TaskStatus.inProgress:
        return 'Sedang Dikerjakan';
      case TaskStatus.completed:
        return 'Selesai';
      case TaskStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.low:
        return 'Rendah';
      case TaskPriority.medium:
        return 'Sedang';
      case TaskPriority.high:
        return 'Tinggi';
      case TaskPriority.urgent:
        return 'Mendesak';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case TaskStatus.pending:
        return '#FFA500'; // Orange
      case TaskStatus.inProgress:
        return '#2196F3'; // Blue
      case TaskStatus.completed:
        return '#4CAF50'; // Green
      case TaskStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#FF5722'; // Deep Orange
      case TaskPriority.urgent:
        return '#F44336'; // Red
    }
  }

  /// Check if task is overdue
  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status != TaskStatus.completed;
  }

  /// Get days until due date
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference;
  }

  /// Check if task is due soon (within 3 days)
  bool get isDueSoon {
    return daysUntilDue <= 3 && daysUntilDue >= 0 && status != TaskStatus.completed;
  }

  /// Get progress percentage as string
  String get progressPercentage => '$progress%';

  /// Calculate duration since created
  Duration get duration {
    final now = completedAt ?? DateTime.now();
    return now.difference(createdAt);
  }

  /// Get formatted due date
  String get formattedDueDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                   'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}