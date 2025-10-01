class LemburModel {
  final int? id;
  final String type;
  final DateTime date;
  final String duration;
  final String reason;
  final String status;
  final String? fileName;
  final String startTime;
  final String endTime;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LemburModel({
    this.id,
    required this.type,
    required this.date,
    required this.duration,
    required this.reason,
    required this.status,
    this.fileName,
    required this.startTime,
    required this.endTime,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Create from database map
  factory LemburModel.fromMap(Map<String, dynamic> map) {
    return LemburModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
      fileName: map['file_name'] as String?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      userId: map['user_id'] as int?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'duration': duration,
      'reason': reason,
      'status': status,
      'file_name': fileName,
      'start_time': startTime,
      'end_time': endTime,
      'user_id': userId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Validation
  static String? validateType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jenis lembur harus diisi';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Durasi lembur harus diisi';
    }
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alasan lembur harus diisi';
    }
    if (value.trim().length < 10) {
      return 'Alasan lembur minimal 10 karakter';
    }
    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Waktu harus diisi';
    }
    // Basic time validation (format: HH or HH:MM)
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3])(:([0-5][0-9]))?$');
    if (!timeRegex.hasMatch(value.trim())) {
      return 'Format waktu tidak valid (contoh: 19 atau 19:30)';
    }
    return null;
  }

  // Copy with method
  LemburModel copyWith({
    int? id,
    String? type,
    DateTime? date,
    String? duration,
    String? reason,
    String? status,
    String? fileName,
    String? startTime,
    String? endTime,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LemburModel(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory LemburModel.create({
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    required String startTime,
    required String endTime,
    String? fileName,
    int? userId,
  }) {
    final now = DateTime.now();
    return LemburModel(
      type: type.trim(),
      date: date,
      duration: duration.trim(),
      reason: reason.trim(),
      startTime: startTime.trim(),
      endTime: endTime.trim(),
      status: _mapStatusToDB('Menunggu Persetujuan'),
      fileName: fileName,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Status mapping
  String get uiStatus => _mapStatusToUI(status);

  // Convert to legacy format for UI compatibility
  Map<String, dynamic> toLegacyMap() {
    // Generate ID format like L-001
    String generateId() {
      if (id != null) {
        return 'L-${id.toString().padLeft(3, '0')}';
      }
      return 'L-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }

    return {
      'id': generateId(),
      'type': type,
      'date': date,
      'duration': duration,
      'reason': reason,
      'status': _mapStatusToUI(status),
      'fileName': fileName,
      'mulai': startTime,
      'selesai': endTime,
    };
  }

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
  static String _mapStatusToDB(String uiStatus) {
    switch (uiStatus) {
      case 'Menunggu Persetujuan': return 'menunggu_persetujuan';
      case 'Disetujui': return 'disetujui';
      case 'Ditolak': return 'ditolak';
      default: return 'menunggu_persetujuan';
    }
  }

  // Map UI status to database status (public static method)
  static String mapStatusToDB(String uiStatus) => _mapStatusToDB(uiStatus);

  // Helper method to get duration as double (in hours)
  double get durationAsHours {
    try {
      // Parse duration string to double (assuming it's in format like "4.0 jam" or "4.0")
      final cleanDuration = duration.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleanDuration) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  String toString() {
    return 'LemburModel{id: $id, type: $type, duration: $duration, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LemburModel &&
        other.id == id &&
        other.type == type &&
        other.date == date &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ date.hashCode ^ duration.hashCode;
  }
}