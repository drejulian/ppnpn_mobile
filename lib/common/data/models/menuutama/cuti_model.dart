import 'package:flutter/material.dart';

enum CutiStatus {
  menungguPersetujuan('Menunggu Persetujuan', Colors.orange),
  disetujui('Disetujui', Colors.green),
  ditolak('Ditolak', Colors.red);

  const CutiStatus(this.label, this.color);
  final String label;
  final Color color;

  static CutiStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return CutiStatus.disetujui;
      case 'ditolak':
        return CutiStatus.ditolak;
      case 'menunggu persetujuan':
      default:
        return CutiStatus.menungguPersetujuan;
    }
  }
}

enum CutiType {
  tahunan('Cuti Tahunan'),
  sakit('Cuti Sakit'),
  melahirkan('Cuti Melahirkan'),
  lainnya('Cuti Lainnya');

  const CutiType(this.label);
  final String label;

  static CutiType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'cuti tahunan':
        return CutiType.tahunan;
      case 'cuti sakit':
        return CutiType.sakit;
      case 'cuti melahirkan':
        return CutiType.melahirkan;
      case 'cuti lainnya':
      default:
        return CutiType.lainnya;
    }
  }
}

class CutiModel {
  final int? id;
  final String cutiId;
  final CutiType type;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String alasan;
  final CutiStatus status;
  final String? fileName;
  final String? filePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  CutiModel({
    this.id,
    required this.cutiId,
    required this.type,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    this.status = CutiStatus.menungguPersetujuan,
    this.fileName,
    this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated properties
  int get durasiHari => tanggalSelesai.difference(tanggalMulai).inDays + 1;
  
  String get formattedDuration {
    final startFormatted = _formatDate(tanggalMulai, 'dd MMM');
    final endFormatted = _formatDate(tanggalSelesai, 'dd MMM');
    return '$durasiHari hari ($startFormatted - $endFormatted)';
  }

  String get formattedTanggalMulai => _formatDate(tanggalMulai, 'dd-MM-yyyy');
  String get formattedTanggalSelesai => _formatDate(tanggalSelesai, 'dd-MM-yyyy');

  bool get canEdit => status == CutiStatus.menungguPersetujuan || status == CutiStatus.ditolak;
  bool get isLocked => status == CutiStatus.disetujui;

  String _formatDate(DateTime date, String pattern) {
    switch (pattern) {
      case 'dd-MM-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      case 'dd MMM':
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${date.day.toString().padLeft(2, '0')} ${months[date.month]}';
      default:
        return date.toString();
    }
  }

  // Convert CutiModel to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cutiId': cutiId,
      'type': type.label,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalSelesai': tanggalSelesai.toIso8601String(),
      'alasan': alasan,
      'status': status.label,
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create CutiModel from Map (database result)
  factory CutiModel.fromMap(Map<String, dynamic> map) {
    return CutiModel(
      id: map['id'],
      cutiId: map['cutiId'],
      type: CutiType.fromString(map['type']),
      tanggalMulai: DateTime.parse(map['tanggalMulai']),
      tanggalSelesai: DateTime.parse(map['tanggalSelesai']),
      alasan: map['alasan'],
      status: CutiStatus.fromString(map['status']),
      fileName: map['fileName'],
      filePath: map['filePath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Convert to legacy format for backward compatibility
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': cutiId,
      'databaseId': id,  // Tambah database ID untuk update
      'type': type.label,
      'date': tanggalMulai,
      'duration': formattedDuration,
      'reason': alasan,
      'status': status.label,
      'statusColor': status.color,
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Old format fields
      'jenis': type.label,
      'tanggal_awal': formattedTanggalMulai,
      'tanggal_akhir': formattedTanggalSelesai,
      'alasan': alasan,
    };
  }

  // Create from legacy format
  factory CutiModel.fromLegacyMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    
    // Parse dates from different possible formats
    DateTime startDate;
    DateTime endDate;
    
    if (map['date'] != null && map['date'] is DateTime) {
      startDate = map['date'];
    } else if (map['tanggal_awal'] != null) {
      startDate = _parseDate(map['tanggal_awal'].toString()) ?? now;
    } else {
      startDate = now;
    }
    
    if (map['tanggal_akhir'] != null) {
      endDate = _parseDate(map['tanggal_akhir'].toString()) ?? startDate;
    } else {
      endDate = startDate;
    }

    return CutiModel(
      cutiId: map['id']?.toString() ?? _generateId(),
      type: CutiType.fromString(map['type'] ?? map['jenis'] ?? 'Cuti Lainnya'),
      tanggalMulai: startDate,
      tanggalSelesai: endDate,
      alasan: map['reason'] ?? map['alasan'] ?? '',
      status: CutiStatus.fromString(map['status'] ?? 'Menunggu Persetujuan'),
      fileName: map['fileName'],
      createdAt: now,
      updatedAt: now,
    );
  }

  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Invalid date format
    }
    return null;
  }

  static String _generateId() {
    final now = DateTime.now();
    return 'C-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Copy with method for updates
  CutiModel copyWith({
    int? id,
    String? cutiId,
    CutiType? type,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    String? alasan,
    CutiStatus? status,
    String? fileName,
    String? filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CutiModel(
      id: id ?? this.id,
      cutiId: cutiId ?? this.cutiId,
      type: type ?? this.type,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Validation methods
  String? validate() {
    if (cutiId.isEmpty) return 'ID cuti tidak boleh kosong';
    if (alasan.trim().isEmpty) return 'Alasan cuti tidak boleh kosong';
    if (tanggalSelesai.isBefore(tanggalMulai)) return 'Tanggal selesai harus setelah tanggal mulai';
    if (durasiHari <= 0) return 'Durasi cuti harus lebih dari 0 hari';
    if (durasiHari > 365) return 'Durasi cuti terlalu panjang';
    return null; // Valid
  }

  bool get isValid => validate() == null;

  @override
  String toString() {
    return 'CutiModel{id: $id, cutiId: $cutiId, type: ${type.label}, status: ${status.label}, durasi: $durasiHari hari}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CutiModel &&
        other.cutiId == cutiId &&
        other.type == type &&
        other.tanggalMulai == tanggalMulai &&
        other.tanggalSelesai == tanggalSelesai &&
        other.alasan == alasan;
  }

  @override
  int get hashCode {
    return cutiId.hashCode ^
        type.hashCode ^
        tanggalMulai.hashCode ^
        tanggalSelesai.hashCode ^
        alasan.hashCode;
  }
}