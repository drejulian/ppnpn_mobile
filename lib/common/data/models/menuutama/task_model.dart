

class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final int? assignedToId;
  final int? createdById;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final int progress; // 0-100
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.assignedToId,
    this.createdById,
    this.status = 'pending',
    this.priority = 'medium',
    this.progress = 0,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated properties
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && status != 'completed';
  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year && 
           dueDate!.month == today.month && 
           dueDate!.day == today.day;
  }
  
  int get daysUntilDue => dueDate?.difference(DateTime.now()).inDays ?? 0;
  
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1) return 'In $difference days';
    if (difference < -1) return '${difference.abs()} days ago';
    
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  bool get canEdit => status != 'completed';
  bool get isCompleted => status == 'completed';

  // Validation methods
  String? validate() {
    if (title.trim().isEmpty) return 'Judul task tidak boleh kosong';
    if (progress < 0 || progress > 100) return 'Progress harus antara 0-100';
    if (!['pending', 'in_progress', 'completed', 'cancelled'].contains(status)) {
      return 'Status tidak valid';
    }
    if (!['low', 'medium', 'high', 'urgent'].contains(priority)) {
      return 'Priority tidak valid';
    }
    return null; // Valid
  }

  bool get isValid => validate() == null;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'assigned_to_id': assignedToId,
      'created_by_id': createdById,
      'status': status,
      'priority': priority,
      'progress': progress,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      assignedToId: map['assigned_to_id'],
      createdById: map['created_by_id'],
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'medium',
      progress: map['progress'] ?? 0,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    int? assignedToId,
    int? createdById,
    String? status,
    String? priority,
    int? progress,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      createdById: createdById ?? this.createdById,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory TaskModel.create({
    required String title,
    String? description,
    int? assignedToId,
    int? createdById,
    String priority = 'medium',
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return TaskModel(
      title: title.trim(),
      description: description?.trim(),
      assignedToId: assignedToId,
      createdById: createdById,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, status: $status, priority: $priority, progress: $progress%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode;
  }
}