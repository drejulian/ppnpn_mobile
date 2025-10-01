import 'dart:typed_data';

class AbsensiModel {
  final int? id;
  final int userId;
  final String tanggal;
  final String type; // 'checkin' or 'checkout'
  final String jam;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  AbsensiModel({
    this.id,
    required this.userId,
    required this.tanggal,
    required this.type,
    required this.jam,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    this.imageBytes,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database result)
  factory AbsensiModel.fromMap(Map<String, dynamic> map) {
    return AbsensiModel(
      id: map['id'],
      userId: map['user_id'],
      tanggal: map['tanggal'],
      type: map['type'],
      jam: map['jam'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imagePath: map['image_path'],
      imageBytes: map['image_bytes'],
      status: map['status'],
      keterangan: map['keterangan'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Convert to Map (for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal,
      'type': type,
      'jam': jam,
      'latitude': latitude,
      'longitude': longitude,
      'image_path': imagePath,
      'image_bytes': imageBytes,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create copy with updated fields
  AbsensiModel copyWith({
    int? id,
    int? userId,
    String? tanggal,
    String? type,
    String? jam,
    double? latitude,
    double? longitude,
    String? imagePath,
    Uint8List? imageBytes,
    String? status,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AbsensiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tanggal: tanggal ?? this.tanggal,
      type: type ?? this.type,
      jam: jam ?? this.jam,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AbsensiModel(id: $id, userId: $userId, tanggal: $tanggal, type: $type, jam: $jam, status: $status)';
  }
}

// Model untuk statistik absensi per bulan
class AbsensiMonthlyStats {
  final String month;
  final String year;
  final int totalWorkingDays;
  final int presentDays;
  final int lateDays;
  final double attendancePercentage;

  AbsensiMonthlyStats({
    required this.month,
    required this.year,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.lateDays,
    required this.attendancePercentage,
  });

  factory AbsensiMonthlyStats.fromMap(Map<String, dynamic> map) {
    return AbsensiMonthlyStats(
      month: map['month'],
      year: map['year'],
      totalWorkingDays: map['total_working_days'],
      presentDays: map['present_days'],
      lateDays: map['late_days'],
      attendancePercentage: map['attendance_percentage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'total_working_days': totalWorkingDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'attendance_percentage': attendancePercentage,
    };
  }
}