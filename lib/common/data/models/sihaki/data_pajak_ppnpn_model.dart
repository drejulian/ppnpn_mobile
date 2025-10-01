class DataPajakPPNPNModel {
  final int? id;
  final String nip;
  final String namaPpnpn;
  final String jabatan;
  final String unitKerja;
  final double gajiPokok;
  final double tunjangan;
  final double potonganPajak;
  final int bulanPajak;
  final int tahunPajak;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataPajakPPNPNModel({
    this.id,
    required this.nip,
    required this.namaPpnpn,
    required this.jabatan,
    required this.unitKerja,
    required this.gajiPokok,
    this.tunjangan = 0,
    required this.potonganPajak,
    required this.bulanPajak,
    required this.tahunPajak,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nip': nip,
      'nama_ppnpn': namaPpnpn,
      'jabatan': jabatan,
      'unit_kerja': unitKerja,
      'gaji_pokok': gajiPokok,
      'tunjangan': tunjangan,
      'potongan_pajak': potonganPajak,
      'bulan_pajak': bulanPajak,
      'tahun_pajak': tahunPajak,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DataPajakPPNPNModel.fromMap(Map<String, dynamic> map) {
    return DataPajakPPNPNModel(
      id: map['id']?.toInt(),
      nip: map['nip'] ?? '',
      namaPpnpn: map['nama_ppnpn'] ?? '',
      jabatan: map['jabatan'] ?? '',
      unitKerja: map['unit_kerja'] ?? '',
      gajiPokok: map['gaji_pokok']?.toDouble() ?? 0.0,
      tunjangan: map['tunjangan']?.toDouble() ?? 0.0,
      potonganPajak: map['potongan_pajak']?.toDouble() ?? 0.0,
      bulanPajak: map['bulan_pajak']?.toInt() ?? DateTime.now().month,
      tahunPajak: map['tahun_pajak']?.toInt() ?? DateTime.now().year,
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  DataPajakPPNPNModel copyWith({
    int? id,
    String? nip,
    String? namaPpnpn,
    String? jabatan,
    String? unitKerja,
    double? gajiPokok,
    double? tunjangan,
    double? potonganPajak,
    int? bulanPajak,
    int? tahunPajak,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataPajakPPNPNModel(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      namaPpnpn: namaPpnpn ?? this.namaPpnpn,
      jabatan: jabatan ?? this.jabatan,
      unitKerja: unitKerja ?? this.unitKerja,
      gajiPokok: gajiPokok ?? this.gajiPokok,
      tunjangan: tunjangan ?? this.tunjangan,
      potonganPajak: potonganPajak ?? this.potonganPajak,
      bulanPajak: bulanPajak ?? this.bulanPajak,
      tahunPajak: tahunPajak ?? this.tahunPajak,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataPajakPPNPNModel(id: $id, nip: $nip, namaPpnpn: $namaPpnpn, jabatan: $jabatan, unitKerja: $unitKerja, gajiPokok: $gajiPokok, tunjangan: $tunjangan, potonganPajak: $potonganPajak, bulanPajak: $bulanPajak, tahunPajak: $tahunPajak, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataPajakPPNPNModel &&
        other.id == id &&
        other.nip == nip &&
        other.namaPpnpn == namaPpnpn &&
        other.jabatan == jabatan &&
        other.unitKerja == unitKerja &&
        other.gajiPokok == gajiPokok &&
        other.tunjangan == tunjangan &&
        other.potonganPajak == potonganPajak &&
        other.bulanPajak == bulanPajak &&
        other.tahunPajak == tahunPajak &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nip.hashCode ^
        namaPpnpn.hashCode ^
        jabatan.hashCode ^
        unitKerja.hashCode ^
        gajiPokok.hashCode ^
        tunjangan.hashCode ^
        potonganPajak.hashCode ^
        bulanPajak.hashCode ^
        tahunPajak.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}