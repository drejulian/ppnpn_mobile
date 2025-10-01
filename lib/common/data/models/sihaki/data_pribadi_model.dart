class DataPribadiModel {
  final int? id;
  final String namaAnggota;
  final String handphone;
  final String email;
  final String telponRuangan;
  final String ruangKerja;
  final String bahasaAsing;
  final String alamatRumah;
  final String keteranganDomisili;
  final String namaAyahKandung;
  final String namaIbuKandung;
  final String noRekeningMitra;
  final String namaRekeningMitra;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataPribadiModel({
    this.id,
    required this.namaAnggota,
    required this.handphone,
    required this.email,
    required this.telponRuangan,
    required this.ruangKerja,
    required this.bahasaAsing,
    required this.alamatRumah,
    required this.keteranganDomisili,
    required this.namaAyahKandung,
    required this.namaIbuKandung,
    required this.noRekeningMitra,
    required this.namaRekeningMitra,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database) to Model
  factory DataPribadiModel.fromMap(Map<String, dynamic> map) {
    return DataPribadiModel(
      id: map['id'] as int?,
      namaAnggota: map['nama_anggota'] as String,
      handphone: map['handphone'] as String,
      email: map['email'] as String,
      telponRuangan: map['telpon_ruangan'] as String,
      ruangKerja: map['ruang_kerja'] as String,
      bahasaAsing: map['bahasa_asing'] as String,
      alamatRumah: map['alamat_rumah'] as String,
      keteranganDomisili: map['keterangan_domisili'] as String,
      namaAyahKandung: map['nama_ayah_kandung'] as String,
      namaIbuKandung: map['nama_ibu_kandung'] as String,
      noRekeningMitra: map['no_rekening_mitra'] as String,
      namaRekeningMitra: map['nama_rekening_mitra'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert from Model to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'handphone': handphone,
      'email': email,
      'telpon_ruangan': telponRuangan,
      'ruang_kerja': ruangKerja,
      'bahasa_asing': bahasaAsing,
      'alamat_rumah': alamatRumah,
      'keterangan_domisili': keteranganDomisili,
      'nama_ayah_kandung': namaAyahKandung,
      'nama_ibu_kandung': namaIbuKandung,
      'no_rekening_mitra': noRekeningMitra,
      'nama_rekening_mitra': namaRekeningMitra,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  DataPribadiModel copyWith({
    int? id,
    String? namaAnggota,
    String? handphone,
    String? email,
    String? telponRuangan,
    String? ruangKerja,
    String? bahasaAsing,
    String? alamatRumah,
    String? keteranganDomisili,
    String? namaAyahKandung,
    String? namaIbuKandung,
    String? noRekeningMitra,
    String? namaRekeningMitra,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataPribadiModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      handphone: handphone ?? this.handphone,
      email: email ?? this.email,
      telponRuangan: telponRuangan ?? this.telponRuangan,
      ruangKerja: ruangKerja ?? this.ruangKerja,
      bahasaAsing: bahasaAsing ?? this.bahasaAsing,
      alamatRumah: alamatRumah ?? this.alamatRumah,
      keteranganDomisili: keteranganDomisili ?? this.keteranganDomisili,
      namaAyahKandung: namaAyahKandung ?? this.namaAyahKandung,
      namaIbuKandung: namaIbuKandung ?? this.namaIbuKandung,
      noRekeningMitra: noRekeningMitra ?? this.noRekeningMitra,
      namaRekeningMitra: namaRekeningMitra ?? this.namaRekeningMitra,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataPribadiModel{id: $id, namaAnggota: $namaAnggota, handphone: $handphone, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataPribadiModel &&
        other.id == id &&
        other.namaAnggota == namaAnggota &&
        other.handphone == handphone &&
        other.email == email &&
        other.telponRuangan == telponRuangan &&
        other.ruangKerja == ruangKerja &&
        other.bahasaAsing == bahasaAsing &&
        other.alamatRumah == alamatRumah &&
        other.keteranganDomisili == keteranganDomisili &&
        other.namaAyahKandung == namaAyahKandung &&
        other.namaIbuKandung == namaIbuKandung &&
        other.noRekeningMitra == noRekeningMitra &&
        other.namaRekeningMitra == namaRekeningMitra;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      namaAnggota,
      handphone,
      email,
      telponRuangan,
      ruangKerja,
      bahasaAsing,
      alamatRumah,
      keteranganDomisili,
      namaAyahKandung,
      namaIbuKandung,
      noRekeningMitra,
      namaRekeningMitra,
    );
  }
}