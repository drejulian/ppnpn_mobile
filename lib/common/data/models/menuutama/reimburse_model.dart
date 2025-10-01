class ReimburseModel {
  final int? id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String status; // 'menunggu_persetujuan', 'disetujui', 'ditolak'
  final String? fileName;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReimburseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.status = 'menunggu_persetujuan',
    this.fileName,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Validation methods
  String? validate() {
    if (category.trim().isEmpty) return 'Kategori tidak boleh kosong';
    if (amount <= 0) return 'Jumlah harus lebih dari 0';
    if (description.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
    if (!['menunggu_persetujuan', 'disetujui', 'ditolak'].contains(status)) {
      return 'Status tidak valid';
    }
    return null; // Valid
  }

  bool get isValid => validate() == null;
  bool get canEdit => status == 'menunggu_persetujuan' || status == 'ditolak';
  bool get isApproved => status == 'disetujui';
  bool get isRejected => status == 'ditolak';
  bool get isPending => status == 'menunggu_persetujuan';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'file_name': fileName,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReimburseModel.fromMap(Map<String, dynamic> map) {
    return ReimburseModel(
      id: map['id'],
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'menunggu_persetujuan',
      fileName: map['file_name'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  ReimburseModel copyWith({
    int? id,
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    String? status,
    String? fileName,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReimburseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory ReimburseModel.create({
    required String category,
    required double amount,
    required String description,
    required DateTime date,
    String? fileName,
    int? userId,
  }) {
    final now = DateTime.now();
    return ReimburseModel(
      category: category.trim(),
      amount: amount,
      description: description.trim(),
      date: date,
      fileName: fileName,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Convert to legacy format for UI compatibility
  Map<String, dynamic> toLegacyMap() {
    // Generate ID format like R-001
    String generateId() {
      if (id != null) {
        return 'R-${id.toString().padLeft(3, '0')}';
      }
      return 'R-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }

    return {
      'id': generateId(),
      'category': category,
      'amount': amount.toInt(), // Convert back to int for UI
      'description': description,
      'date': date,
      'status': _mapStatusToUI(status),
      'fileName': fileName,
    };
  }

  // Getter for UI-friendly status
  String get uiStatus => _mapStatusToUI(status);

  // Map database status to UI status
  String _mapStatusToUI(String dbStatus) {
    switch (dbStatus) {
      case 'menunggu_persetujuan': return 'Menunggu Persetujuan';
      case 'disetujui': return 'Disetujui';
      case 'ditolak': return 'Ditolak';
      default: return 'Menunggu Persetujuan';
    }
  }

  // Map UI status to database status
  static String mapStatusToDB(String uiStatus) {
    switch (uiStatus) {
      case 'Menunggu Persetujuan': return 'menunggu_persetujuan';
      case 'Disetujui': return 'disetujui';
      case 'Ditolak': return 'ditolak';
      default: return 'menunggu_persetujuan';
    }
  }

  @override
  String toString() {
    return 'ReimburseModel{id: $id, category: $category, amount: $amount, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReimburseModel &&
        other.id == id &&
        other.category == category &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ category.hashCode ^ amount.hashCode;
  }
}