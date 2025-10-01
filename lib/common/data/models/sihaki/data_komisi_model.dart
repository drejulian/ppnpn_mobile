class DataKomisiModel {
  final int? id;
  final String moduleName;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? metadata; // JSON string untuk data tambahan

  DataKomisiModel({
    this.id,
    required this.moduleName,
    required this.isCompleted,
    this.completedAt,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_name': moduleName,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Create from Map (database result)
  factory DataKomisiModel.fromMap(Map<String, dynamic> map) {
    return DataKomisiModel(
      id: map['id']?.toInt(),
      moduleName: map['module_name'] ?? '',
      isCompleted: (map['is_completed'] ?? 0) == 1,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      metadata: map['metadata'],
    );
  }

  // Copy with method for updates
  DataKomisiModel copyWith({
    int? id,
    String? moduleName,
    bool? isCompleted,
    DateTime? completedAt,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? metadata,
  }) {
    return DataKomisiModel(
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Display formatted date
  String get formattedCompletedAt {
    if (completedAt == null) return 'Belum selesai';
    return '${completedAt!.day.toString().padLeft(2, '0')}-${completedAt!.month.toString().padLeft(2, '0')}-${completedAt!.year}';
  }

  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day.toString().padLeft(2, '0')}-${updatedAt.month.toString().padLeft(2, '0')}-${updatedAt.year}';
  }

  // Module status helper
  String get statusText {
    return isCompleted ? 'Lengkap' : 'Belum Lengkap';
  }

  @override
  String toString() {
    return 'DataKomisiModel{id: $id, moduleName: $moduleName, isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataKomisiModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          moduleName == other.moduleName &&
          isCompleted == other.isCompleted &&
          userId == other.userId;

  @override
  int get hashCode =>
      id.hashCode ^
      moduleName.hashCode ^
      isCompleted.hashCode ^
      userId.hashCode;
}
