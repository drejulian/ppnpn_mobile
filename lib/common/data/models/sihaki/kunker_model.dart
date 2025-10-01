class KunkerModel {
  final int? id;
  final String noSurat;
  final String jenisPerjadin;
  final String tanggalSurat;
  final String tanggalAwal;
  final String tanggalAkhir;
  final String masaPersidangan;
  final String tahunSidang;
  final String anggota;
  final String noAnggota;
  final String nikAnggota;
  final String fraksi;
  final String dapil;
  final String rekAnggota;
  final String namaRekAnggota;
  final String kodeBankAnggota;
  final String namaBankAnggota;
  final String ta;
  final String noTa;
  final String nikTa;
  final String hpTa;
  final String emailTa;
  final String rekTa;
  final String namaRekTa;
  final String kodeBankTa;
  final String namaBankTa;
  final String moda;
  final String negara;
  final String provinsi;
  final String kota;
  final String statusPengajuan;
  final String statusPencairan;
  final String createdAt;
  final String? updatedAt;

  KunkerModel({
    this.id,
    required this.noSurat,
    required this.jenisPerjadin,
    required this.tanggalSurat,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.masaPersidangan,
    required this.tahunSidang,
    required this.anggota,
    required this.noAnggota,
    required this.nikAnggota,
    required this.fraksi,
    required this.dapil,
    required this.rekAnggota,
    required this.namaRekAnggota,
    required this.kodeBankAnggota,
    required this.namaBankAnggota,
    required this.ta,
    required this.noTa,
    required this.nikTa,
    required this.hpTa,
    required this.emailTa,
    required this.rekTa,
    required this.namaRekTa,
    required this.kodeBankTa,
    required this.namaBankTa,
    required this.moda,
    required this.negara,
    required this.provinsi,
    required this.kota,
    required this.statusPengajuan,
    required this.statusPencairan,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_surat': noSurat,
      'jenis_perjadin': jenisPerjadin,
      'tanggal_surat': tanggalSurat,
      'tanggal_awal': tanggalAwal,
      'tanggal_akhir': tanggalAkhir,
      'masa_persidangan': masaPersidangan,
      'tahun_sidang': tahunSidang,
      'anggota': anggota,
      'no_anggota': noAnggota,
      'nik_anggota': nikAnggota,
      'fraksi': fraksi,
      'dapil': dapil,
      'rek_anggota': rekAnggota,
      'nama_rek_anggota': namaRekAnggota,
      'kode_bank_anggota': kodeBankAnggota,
      'nama_bank_anggota': namaBankAnggota,
      'ta': ta,
      'no_ta': noTa,
      'nik_ta': nikTa,
      'hp_ta': hpTa,
      'email_ta': emailTa,
      'rek_ta': rekTa,
      'nama_rek_ta': namaRekTa,
      'kode_bank_ta': kodeBankTa,
      'nama_bank_ta': namaBankTa,
      'moda': moda,
      'negara': negara,
      'provinsi': provinsi,
      'kota': kota,
      'status_pengajuan': statusPengajuan,
      'status_pencairan': statusPencairan,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory KunkerModel.fromMap(Map<String, dynamic> map) {
    return KunkerModel(
      id: map['id'],
      noSurat: map['no_surat'] ?? '',
      jenisPerjadin: map['jenis_perjadin'] ?? '',
      tanggalSurat: map['tanggal_surat'] ?? '',
      tanggalAwal: map['tanggal_awal'] ?? '',
      tanggalAkhir: map['tanggal_akhir'] ?? '',
      masaPersidangan: map['masa_persidangan'] ?? '',
      tahunSidang: map['tahun_sidang'] ?? '',
      anggota: map['anggota'] ?? '',
      noAnggota: map['no_anggota'] ?? '',
      nikAnggota: map['nik_anggota'] ?? '',
      fraksi: map['fraksi'] ?? '',
      dapil: map['dapil'] ?? '',
      rekAnggota: map['rek_anggota'] ?? '',
      namaRekAnggota: map['nama_rek_anggota'] ?? '',
      kodeBankAnggota: map['kode_bank_anggota'] ?? '',
      namaBankAnggota: map['nama_bank_anggota'] ?? '',
      ta: map['ta'] ?? '',
      noTa: map['no_ta'] ?? '',
      nikTa: map['nik_ta'] ?? '',
      hpTa: map['hp_ta'] ?? '',
      emailTa: map['email_ta'] ?? '',
      rekTa: map['rek_ta'] ?? '',
      namaRekTa: map['nama_rek_ta'] ?? '',
      kodeBankTa: map['kode_bank_ta'] ?? '',
      namaBankTa: map['nama_bank_ta'] ?? '',
      moda: map['moda'] ?? '',
      negara: map['negara'] ?? '',
      provinsi: map['provinsi'] ?? '',
      kota: map['kota'] ?? '',
      statusPengajuan: map['status_pengajuan'] ?? '',
      statusPencairan: map['status_pencairan'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'],
    );
  }

  // Convenience method to convert to the format used by existing UI
  Map<String, dynamic> toUIMap() {
    return {
      'no_surat': noSurat,
      'jenis_perjadin': jenisPerjadin,
      'tanggal_surat': tanggalSurat,
      'tanggal_awal': tanggalAwal,
      'tanggal_akhir': tanggalAkhir,
      'anggota': anggota,
      'tenaga_ahli': ta,
      'dapil': dapil,
      'status_pengajuan': statusPengajuan,
      'status_pencairan': statusPencairan,
      // Include all other fields for complete data
      'masa_persidangan': masaPersidangan,
      'tahun_sidang': tahunSidang,
      'no_anggota': noAnggota,
      'nik_anggota': nikAnggota,
      'fraksi': fraksi,
      'rek_anggota': rekAnggota,
      'nama_rek_anggota': namaRekAnggota,
      'kode_bank_anggota': kodeBankAnggota,
      'nama_bank_anggota': namaBankAnggota,
      'no_ta': noTa,
      'nik_ta': nikTa,
      'hp_ta': hpTa,
      'email_ta': emailTa,
      'rek_ta': rekTa,
      'nama_rek_ta': namaRekTa,
      'kode_bank_ta': kodeBankTa,
      'nama_bank_ta': namaBankTa,
      'moda': moda,
      'negara': negara,
      'provinsi': provinsi,
      'kota': kota,
    };
  }

  // Create from UI map format
  factory KunkerModel.fromUIMap(Map<String, dynamic> map) {
    final now = DateTime.now().toIso8601String();
    return KunkerModel(
      noSurat: map['no_surat'] ?? '',
      jenisPerjadin: map['jenis_perjadin'] ?? '',
      tanggalSurat: map['tanggal_surat'] ?? '',
      tanggalAwal: map['tanggal_awal'] ?? '',
      tanggalAkhir: map['tanggal_akhir'] ?? '',
      masaPersidangan: map['masa_persidangan'] ?? '',
      tahunSidang: map['tahun_sidang'] ?? '',
      anggota: map['anggota'] ?? '',
      noAnggota: map['no_anggota'] ?? '',
      nikAnggota: map['nik_anggota'] ?? '',
      fraksi: map['fraksi'] ?? '',
      dapil: map['dapil'] ?? '',
      rekAnggota: map['rek_anggota'] ?? '',
      namaRekAnggota: map['nama_rek_anggota'] ?? '',
      kodeBankAnggota: map['kode_bank_anggota'] ?? '',
      namaBankAnggota: map['nama_bank_anggota'] ?? '',
      ta: map['ta'] ?? map['tenaga_ahli'] ?? '',
      noTa: map['no_ta'] ?? '',
      nikTa: map['nik_ta'] ?? '',
      hpTa: map['hp_ta'] ?? '',
      emailTa: map['email_ta'] ?? '',
      rekTa: map['rek_ta'] ?? '',
      namaRekTa: map['nama_rek_ta'] ?? '',
      kodeBankTa: map['kode_bank_ta'] ?? '',
      namaBankTa: map['nama_bank_ta'] ?? '',
      moda: map['moda'] ?? '',
      negara: map['negara'] ?? '',
      provinsi: map['provinsi'] ?? '',
      kota: map['kota'] ?? '',
      statusPengajuan: map['status_pengajuan'] ?? 'Menunggu Konfirmasi',
      statusPencairan: map['status_pencairan'] ?? '-',
      createdAt: now,
      updatedAt: map['updated_at'],
    );
  }

  KunkerModel copyWith({
    int? id,
    String? noSurat,
    String? jenisPerjadin,
    String? tanggalSurat,
    String? tanggalAwal,
    String? tanggalAkhir,
    String? masaPersidangan,
    String? tahunSidang,
    String? anggota,
    String? noAnggota,
    String? nikAnggota,
    String? fraksi,
    String? dapil,
    String? rekAnggota,
    String? namaRekAnggota,
    String? kodeBankAnggota,
    String? namaBankAnggota,
    String? ta,
    String? noTa,
    String? nikTa,
    String? hpTa,
    String? emailTa,
    String? rekTa,
    String? namaRekTa,
    String? kodeBankTa,
    String? namaBankTa,
    String? moda,
    String? negara,
    String? provinsi,
    String? kota,
    String? statusPengajuan,
    String? statusPencairan,
    String? createdAt,
    String? updatedAt,
  }) {
    return KunkerModel(
      id: id ?? this.id,
      noSurat: noSurat ?? this.noSurat,
      jenisPerjadin: jenisPerjadin ?? this.jenisPerjadin,
      tanggalSurat: tanggalSurat ?? this.tanggalSurat,
      tanggalAwal: tanggalAwal ?? this.tanggalAwal,
      tanggalAkhir: tanggalAkhir ?? this.tanggalAkhir,
      masaPersidangan: masaPersidangan ?? this.masaPersidangan,
      tahunSidang: tahunSidang ?? this.tahunSidang,
      anggota: anggota ?? this.anggota,
      noAnggota: noAnggota ?? this.noAnggota,
      nikAnggota: nikAnggota ?? this.nikAnggota,
      fraksi: fraksi ?? this.fraksi,
      dapil: dapil ?? this.dapil,
      rekAnggota: rekAnggota ?? this.rekAnggota,
      namaRekAnggota: namaRekAnggota ?? this.namaRekAnggota,
      kodeBankAnggota: kodeBankAnggota ?? this.kodeBankAnggota,
      namaBankAnggota: namaBankAnggota ?? this.namaBankAnggota,
      ta: ta ?? this.ta,
      noTa: noTa ?? this.noTa,
      nikTa: nikTa ?? this.nikTa,
      hpTa: hpTa ?? this.hpTa,
      emailTa: emailTa ?? this.emailTa,
      rekTa: rekTa ?? this.rekTa,
      namaRekTa: namaRekTa ?? this.namaRekTa,
      kodeBankTa: kodeBankTa ?? this.kodeBankTa,
      namaBankTa: namaBankTa ?? this.namaBankTa,
      moda: moda ?? this.moda,
      negara: negara ?? this.negara,
      provinsi: provinsi ?? this.provinsi,
      kota: kota ?? this.kota,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      statusPencairan: statusPencairan ?? this.statusPencairan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KunkerModel{id: $id, noSurat: $noSurat, anggota: $anggota, ta: $ta, statusPengajuan: $statusPengajuan}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KunkerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          noSurat == other.noSurat;

  @override
  int get hashCode => id.hashCode ^ noSurat.hashCode;
}