class KesehatanModel {
  final int? id;
  final String namaAnggota;
  final String beratBadan;
  final String tinggiBadan;
  final String golonganDarah;
  final String riwayatPenyakit;
  final String alergi;
  final DateTime createdAt;
  final DateTime updatedAt;

  KesehatanModel({
    this.id,
    required this.namaAnggota,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.golonganDarah,
    this.riwayatPenyakit = '',
    this.alergi = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'golongan_darah': golonganDarah,
      'riwayat_penyakit': riwayatPenyakit,
      'alergi': alergi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (SQLite result)
  factory KesehatanModel.fromMap(Map<String, dynamic> map) {
    return KesehatanModel(
      id: map['id']?.toInt(),
      namaAnggota: map['nama_anggota'] ?? '',
      beratBadan: map['berat_badan'] ?? '',
      tinggiBadan: map['tinggi_badan'] ?? '',
      golonganDarah: map['golongan_darah'] ?? '',
      riwayatPenyakit: map['riwayat_penyakit'] ?? '',
      alergi: map['alergi'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method for updates
  KesehatanModel copyWith({
    int? id,
    String? namaAnggota,
    String? beratBadan,
    String? tinggiBadan,
    String? golonganDarah,
    String? riwayatPenyakit,
    String? alergi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KesehatanModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      riwayatPenyakit: riwayatPenyakit ?? this.riwayatPenyakit,
      alergi: alergi ?? this.alergi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KesehatanModel{id: $id, namaAnggota: $namaAnggota, beratBadan: $beratBadan, tinggiBadan: $tinggiBadan, golonganDarah: $golonganDarah}';
  }
}