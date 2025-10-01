class DataPajakAnggotaModel {
  final int? id;
  final String npwp;
  final String namaWajibPajak;
  final String alamatWp;
  final String jenisPajak;
  final int tahunPajak;
  final double jumlahPajak;
  final String statusBayar; // 'sudah_bayar', 'belum_bayar', 'terlambat'
  final String tanggalJatuhTempo;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataPajakAnggotaModel({
    this.id,
    required this.npwp,
    required this.namaWajibPajak,
    required this.alamatWp,
    required this.jenisPajak,
    required this.tahunPajak,
    required this.jumlahPajak,
    this.statusBayar = 'belum_bayar',
    required this.tanggalJatuhTempo,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'npwp': npwp,
      'nama_wajib_pajak': namaWajibPajak,
      'alamat_wp': alamatWp,
      'jenis_pajak': jenisPajak,
      'tahun_pajak': tahunPajak,
      'jumlah_pajak': jumlahPajak,
      'status_bayar': statusBayar,
      'tanggal_jatuh_tempo': tanggalJatuhTempo,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DataPajakAnggotaModel.fromMap(Map<String, dynamic> map) {
    return DataPajakAnggotaModel(
      id: map['id']?.toInt(),
      npwp: map['npwp'] ?? '',
      namaWajibPajak: map['nama_wajib_pajak'] ?? '',
      alamatWp: map['alamat_wp'] ?? '',
      jenisPajak: map['jenis_pajak'] ?? '',
      tahunPajak: map['tahun_pajak']?.toInt() ?? DateTime.now().year,
      jumlahPajak: map['jumlah_pajak']?.toDouble() ?? 0.0,
      statusBayar: map['status_bayar'] ?? 'belum_bayar',
      tanggalJatuhTempo: map['tanggal_jatuh_tempo'] ?? '',
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  DataPajakAnggotaModel copyWith({
    int? id,
    String? npwp,
    String? namaWajibPajak,
    String? alamatWp,
    String? jenisPajak,
    int? tahunPajak,
    double? jumlahPajak,
    String? statusBayar,
    String? tanggalJatuhTempo,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataPajakAnggotaModel(
      id: id ?? this.id,
      npwp: npwp ?? this.npwp,
      namaWajibPajak: namaWajibPajak ?? this.namaWajibPajak,
      alamatWp: alamatWp ?? this.alamatWp,
      jenisPajak: jenisPajak ?? this.jenisPajak,
      tahunPajak: tahunPajak ?? this.tahunPajak,
      jumlahPajak: jumlahPajak ?? this.jumlahPajak,
      statusBayar: statusBayar ?? this.statusBayar,
      tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataPajakAnggotaModel(id: $id, npwp: $npwp, namaWajibPajak: $namaWajibPajak, alamatWp: $alamatWp, jenisPajak: $jenisPajak, tahunPajak: $tahunPajak, jumlahPajak: $jumlahPajak, statusBayar: $statusBayar, tanggalJatuhTempo: $tanggalJatuhTempo, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataPajakAnggotaModel &&
        other.id == id &&
        other.npwp == npwp &&
        other.namaWajibPajak == namaWajibPajak &&
        other.alamatWp == alamatWp &&
        other.jenisPajak == jenisPajak &&
        other.tahunPajak == tahunPajak &&
        other.jumlahPajak == jumlahPajak &&
        other.statusBayar == statusBayar &&
        other.tanggalJatuhTempo == tanggalJatuhTempo &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        npwp.hashCode ^
        namaWajibPajak.hashCode ^
        alamatWp.hashCode ^
        jenisPajak.hashCode ^
        tahunPajak.hashCode ^
        jumlahPajak.hashCode ^
        statusBayar.hashCode ^
        tanggalJatuhTempo.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}