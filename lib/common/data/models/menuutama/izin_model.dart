import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IzinModel {
  final int? id;
  final String type;
  final DateTime date;
  final String duration;
  final String reason;
  final String status;
  final String? fileName;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IzinModel({
    this.id,
    required this.type,
    required this.date,
    required this.duration,
    required this.reason,
    required this.status,
    this.fileName,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Create from database map
  factory IzinModel.fromMap(Map<String, dynamic> map) {
    return IzinModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
      fileName: map['file_name'] as String?,
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
      'user_id': userId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Validation
  static String? validateType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jenis izin harus diisi';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Durasi izin harus diisi';
    }
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alasan izin harus diisi';
    }
    if (value.trim().length < 10) {
      return 'Alasan izin minimal 10 karakter';
    }
    return null;
  }

  // Copy with method
  IzinModel copyWith({
    int? id,
    String? type,
    DateTime? date,
    String? duration,
    String? reason,
    String? status,
    String? fileName,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IzinModel(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory IzinModel.create({
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? fileName,
    int? userId,
  }) {
    final now = DateTime.now();
    return IzinModel(
      type: type.trim(),
      date: date,
      duration: duration.trim(),
      reason: reason.trim(),
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
    // Generate ID format like I-001
    String generateId() {
      if (id != null) {
        return 'I-${id.toString().padLeft(3, '0')}';
      }
      return 'I-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }

    return {
      'id': generateId(),
      'type': type,
      'date': date,
      'duration': duration,
      'reason': reason,
      'status': _mapStatusToUI(status),
      'fileName': fileName,
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

  // UI-friendly status getter with color
  Color get statusColor {
    switch (status) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Check if izin can be edited
  bool get canEdit {
    return status == 'menunggu_persetujuan' || status == 'ditolak';
  }

  // Check if izin is locked (approved and cannot be edited)
  bool get isLocked {
    return status == 'disetujui';
  }

  // Formatted date for display
  String get formattedDate {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  String toString() {
    return 'IzinModel{id: $id, type: $type, duration: $duration, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IzinModel &&
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