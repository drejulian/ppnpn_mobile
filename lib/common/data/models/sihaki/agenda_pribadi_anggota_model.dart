class AgendaPribadiAnggotaModel {
  final int? id;
  final String tanggal;
  final String waktu;
  final String agenda;
  final String tempat;
  final String? keterangan;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgendaPribadiAnggotaModel({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.agenda,
    required this.tempat,
    this.keterangan,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'agenda': agenda,
      'tempat': tempat,
      'keterangan': keterangan,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AgendaPribadiAnggotaModel.fromMap(Map<String, dynamic> map) {
    return AgendaPribadiAnggotaModel(
      id: map['id']?.toInt(),
      tanggal: map['tanggal'] ?? '',
      waktu: map['waktu'] ?? '',
      agenda: map['agenda'] ?? '',
      tempat: map['tempat'] ?? '',
      keterangan: map['keterangan'],
      userId: map['user_id']?.toInt(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  AgendaPribadiAnggotaModel copyWith({
    int? id,
    String? tanggal,
    String? waktu,
    String? agenda,
    String? tempat,
    String? keterangan,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgendaPribadiAnggotaModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      agenda: agenda ?? this.agenda,
      tempat: tempat ?? this.tempat,
      keterangan: keterangan ?? this.keterangan,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AgendaPribadiAnggotaModel(id: $id, tanggal: $tanggal, waktu: $waktu, agenda: $agenda, tempat: $tempat, keterangan: $keterangan, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgendaPribadiAnggotaModel &&
        other.id == id &&
        other.tanggal == tanggal &&
        other.waktu == waktu &&
        other.agenda == agenda &&
        other.tempat == tempat &&
        other.keterangan == keterangan &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tanggal.hashCode ^
        waktu.hashCode ^
        agenda.hashCode ^
        tempat.hashCode ^
        keterangan.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}