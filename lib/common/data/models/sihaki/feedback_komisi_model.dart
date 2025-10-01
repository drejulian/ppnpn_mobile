class FeedbackKomisiModel {
  final int? id;
  final String topik;
  final String feedback;
  final String ratingKinerja;
  final String? saranPerbaikan;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackKomisiModel({
    this.id,
    required this.topik,
    required this.feedback,
    required this.ratingKinerja,
    this.saranPerbaikan,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topik': topik,
      'feedback': feedback,
      'rating_kinerja': ratingKinerja,
      'saran_perbaikan': saranPerbaikan,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory FeedbackKomisiModel.fromMap(Map<String, dynamic> map) {
    return FeedbackKomisiModel(
      id: map['id']?.toInt(),
      topik: map['topik'] ?? '',
      feedback: map['feedback'] ?? '',
      ratingKinerja: map['rating_kinerja'] ?? '',
      saranPerbaikan: map['saran_perbaikan'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method for updates
  FeedbackKomisiModel copyWith({
    int? id,
    String? topik,
    String? feedback,
    String? ratingKinerja,
    String? saranPerbaikan,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackKomisiModel(
      id: id ?? this.id,
      topik: topik ?? this.topik,
      feedback: feedback ?? this.feedback,
      ratingKinerja: ratingKinerja ?? this.ratingKinerja,
      saranPerbaikan: saranPerbaikan ?? this.saranPerbaikan,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Rating value helper
  int get ratingValue {
    if (ratingKinerja.contains('(5)')) return 5;
    if (ratingKinerja.contains('(4)')) return 4;
    if (ratingKinerja.contains('(3)')) return 3;
    if (ratingKinerja.contains('(2)')) return 2;
    if (ratingKinerja.contains('(1)')) return 1;
    return 0;
  }

  // Display formatted date
  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day.toString().padLeft(2, '0')}-${updatedAt.month.toString().padLeft(2, '0')}-${updatedAt.year}';
  }

  @override
  String toString() {
    return 'FeedbackKomisiModel{id: $id, topik: $topik, ratingKinerja: $ratingKinerja}';
  }
}