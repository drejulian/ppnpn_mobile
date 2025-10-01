class BPJSModel {
  final int? id;
  final String nama;
  final String noBPJS;
  final String nik;
  final String hubunganKeluarga;
  final String tanggalLahir;
  final String namaFaskesTingkat1;
  final String status; // 'aktif', 'non-aktif', 'pending'
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  BPJSModel({
    this.id,
    required this.nama,
    required this.noBPJS,
    required this.nik,
    required this.hubunganKeluarga,
    required this.tanggalLahir,
    required this.namaFaskesTingkat1,
    this.status = 'aktif',
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_bpjs': noBPJS,
      'nik': nik,
      'hubungan_keluarga': hubunganKeluarga,
      'tanggal_lahir': tanggalLahir,
      'nama_faskes_tingkat1': namaFaskesTingkat1,
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BPJSModel.fromMap(Map<String, dynamic> map) {
    return BPJSModel(
      id: map['id']?.toInt(),
      nama: map['nama'] ?? '',
      noBPJS: map['no_bpjs'] ?? '',
      nik: map['nik'] ?? '',
      hubunganKeluarga: map['hubungan_keluarga'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      namaFaskesTingkat1: map['nama_faskes_tingkat1'] ?? '',
      status: map['status'] ?? 'aktif',
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BPJSModel copyWith({
    int? id,
    String? nama,
    String? noBPJS,
    String? nik,
    String? hubunganKeluarga,
    String? tanggalLahir,
    String? namaFaskesTingkat1,
    String? status,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BPJSModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noBPJS: noBPJS ?? this.noBPJS,
      nik: nik ?? this.nik,
      hubunganKeluarga: hubunganKeluarga ?? this.hubunganKeluarga,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      namaFaskesTingkat1: namaFaskesTingkat1 ?? this.namaFaskesTingkat1,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BPJSModel(id: $id, nama: $nama, noBPJS: $noBPJS, nik: $nik, hubunganKeluarga: $hubunganKeluarga, tanggalLahir: $tanggalLahir, namaFaskesTingkat1: $namaFaskesTingkat1, status: $status, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BPJSModel &&
        other.id == id &&
        other.nama == nama &&
        other.noBPJS == noBPJS &&
        other.nik == nik &&
        other.hubunganKeluarga == hubunganKeluarga &&
        other.tanggalLahir == tanggalLahir &&
        other.namaFaskesTingkat1 == namaFaskesTingkat1 &&
        other.status == status &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nama.hashCode ^
        noBPJS.hashCode ^
        nik.hashCode ^
        hubunganKeluarga.hashCode ^
        tanggalLahir.hashCode ^
        namaFaskesTingkat1.hashCode ^
        status.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}