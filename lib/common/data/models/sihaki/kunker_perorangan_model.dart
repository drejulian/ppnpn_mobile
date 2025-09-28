class KunkerPeroranganModel {
  final int? id;
  final String tujuan;
  final String negara;
  final String kota;
  final String tanggalBerangkat;
  final String tanggalKembali;
  final String keperluan;
  final double anggaran;
  final String status; // 'diajukan', 'disetujui', 'ditolak', 'selesai'
  final String? nomorSurat;
  final String? keterangan;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  KunkerPeroranganModel({
    this.id,
    required this.tujuan,
    required this.negara,
    required this.kota,
    required this.tanggalBerangkat,
    required this.tanggalKembali,
    required this.keperluan,
    required this.anggaran,
    this.status = 'diajukan',
    this.nomorSurat,
    this.keterangan,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tujuan': tujuan,
      'negara': negara,
      'kota': kota,
      'tanggal_berangkat': tanggalBerangkat,
      'tanggal_kembali': tanggalKembali,
      'keperluan': keperluan,
      'anggaran': anggaran,
      'status': status,
      'nomor_surat': nomorSurat,
      'keterangan': keterangan,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KunkerPeroranganModel.fromMap(Map<String, dynamic> map) {
    return KunkerPeroranganModel(
      id: map['id']?.toInt(),
      tujuan: map['tujuan'] ?? '',
      negara: map['negara'] ?? '',
      kota: map['kota'] ?? '',
      tanggalBerangkat: map['tanggal_berangkat'] ?? '',
      tanggalKembali: map['tanggal_kembali'] ?? '',
      keperluan: map['keperluan'] ?? '',
      anggaran: map['anggaran']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'diajukan',
      nomorSurat: map['nomor_surat'],
      keterangan: map['keterangan'],
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  KunkerPeroranganModel copyWith({
    int? id,
    String? tujuan,
    String? negara,
    String? kota,
    String? tanggalBerangkat,
    String? tanggalKembali,
    String? keperluan,
    double? anggaran,
    String? status,
    String? nomorSurat,
    String? keterangan,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KunkerPeroranganModel(
      id: id ?? this.id,
      tujuan: tujuan ?? this.tujuan,
      negara: negara ?? this.negara,
      kota: kota ?? this.kota,
      tanggalBerangkat: tanggalBerangkat ?? this.tanggalBerangkat,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      keperluan: keperluan ?? this.keperluan,
      anggaran: anggaran ?? this.anggaran,
      status: status ?? this.status,
      nomorSurat: nomorSurat ?? this.nomorSurat,
      keterangan: keterangan ?? this.keterangan,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KunkerPeroranganModel(id: $id, tujuan: $tujuan, negara: $negara, kota: $kota, tanggalBerangkat: $tanggalBerangkat, tanggalKembali: $tanggalKembali, keperluan: $keperluan, anggaran: $anggaran, status: $status, nomorSurat: $nomorSurat, keterangan: $keterangan, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KunkerPeroranganModel &&
        other.id == id &&
        other.tujuan == tujuan &&
        other.negara == negara &&
        other.kota == kota &&
        other.tanggalBerangkat == tanggalBerangkat &&
        other.tanggalKembali == tanggalKembali &&
        other.keperluan == keperluan &&
        other.anggaran == anggaran &&
        other.status == status &&
        other.nomorSurat == nomorSurat &&
        other.keterangan == keterangan &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tujuan.hashCode ^
        negara.hashCode ^
        kota.hashCode ^
        tanggalBerangkat.hashCode ^
        tanggalKembali.hashCode ^
        keperluan.hashCode ^
        anggaran.hashCode ^
        status.hashCode ^
        nomorSurat.hashCode ^
        keterangan.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}