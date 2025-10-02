/// Profile models untuk SQLite implementation
/// Menyediakan data class untuk semua jenis data profile

class EditProfileModel {
  final int? id;
  final String userId;
  final String nik;
  final String nama;
  final String pendidikan;
  final String bidangKeahlian;
  final String toefl;
  final DateTime createdAt;
  final DateTime updatedAt;

  EditProfileModel({
    this.id,
    required this.userId,
    required this.nik,
    required this.nama,
    required this.pendidikan,
    required this.bidangKeahlian,
    required this.toefl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nik': nik,
      'nama': nama,
      'pendidikan': pendidikan,
      'bidang_keahlian': bidangKeahlian,
      'toefl': toefl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EditProfileModel.fromMap(Map<String, dynamic> map) {
    return EditProfileModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      nik: map['nik'] ?? '',
      nama: map['nama'] ?? '',
      pendidikan: map['pendidikan'] ?? '',
      bidangKeahlian: map['bidang_keahlian'] ?? '',
      toefl: map['toefl'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  EditProfileModel copyWith({
    int? id,
    String? userId,
    String? nik,
    String? nama,
    String? pendidikan,
    String? bidangKeahlian,
    String? toefl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EditProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      pendidikan: pendidikan ?? this.pendidikan,
      bidangKeahlian: bidangKeahlian ?? this.bidangKeahlian,
      toefl: toefl ?? this.toefl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EditProfileModel(id: $id, userId: $userId, nik: $nik, nama: $nama, pendidikan: $pendidikan, bidangKeahlian: $bidangKeahlian, toefl: $toefl)';
  }
}

class PribadiModel {
  final int? id;
  final String userId;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String agama;
  final String statusPerkawinan;
  final String golonganDarah;
  final String statusDomisili;
  final String address;
  final String propinsi;
  final String kota;
  final String kecamatan;
  final String kelurahan;
  final String rt;
  final String rw;
  final String kodePos;
  final String teleponRumah;
  final String teleponKantor;
  final String handphone;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  PribadiModel({
    this.id,
    required this.userId,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.agama,
    required this.statusPerkawinan,
    required this.golonganDarah,
    required this.statusDomisili,
    required this.address,
    required this.propinsi,
    required this.kota,
    required this.kecamatan,
    required this.kelurahan,
    required this.rt,
    required this.rw,
    required this.kodePos,
    required this.teleponRumah,
    required this.teleponKantor,
    required this.handphone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'status_perkawinan': statusPerkawinan,
      'golongan_darah': golonganDarah,
      'status_domisili': statusDomisili,
      'address': address,
      'propinsi': propinsi,
      'kota': kota,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'rt': rt,
      'rw': rw,
      'kode_pos': kodePos,
      'telepon_rumah': teleponRumah,
      'telepon_kantor': teleponKantor,
      'handphone': handphone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PribadiModel.fromMap(Map<String, dynamic> map) {
    return PribadiModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      tempatLahir: map['tempat_lahir'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? '',
      agama: map['agama'] ?? '',
      statusPerkawinan: map['status_perkawinan'] ?? '',
      golonganDarah: map['golongan_darah'] ?? '',
      statusDomisili: map['status_domisili'] ?? '',
      address: map['address'] ?? '',
      propinsi: map['propinsi'] ?? '',
      kota: map['kota'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      kelurahan: map['kelurahan'] ?? '',
      rt: map['rt'] ?? '',
      rw: map['rw'] ?? '',
      kodePos: map['kode_pos'] ?? '',
      teleponRumah: map['telepon_rumah'] ?? '',
      teleponKantor: map['telepon_kantor'] ?? '',
      handphone: map['handphone'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  PribadiModel copyWith({
    int? id,
    String? userId,
    String? tempatLahir,
    String? tanggalLahir,
    String? jenisKelamin,
    String? agama,
    String? statusPerkawinan,
    String? golonganDarah,
    String? statusDomisili,
    String? address,
    String? propinsi,
    String? kota,
    String? kecamatan,
    String? kelurahan,
    String? rt,
    String? rw,
    String? kodePos,
    String? teleponRumah,
    String? teleponKantor,
    String? handphone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PribadiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      agama: agama ?? this.agama,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      statusDomisili: statusDomisili ?? this.statusDomisili,
      address: address ?? this.address,
      propinsi: propinsi ?? this.propinsi,
      kota: kota ?? this.kota,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      kodePos: kodePos ?? this.kodePos,
      teleponRumah: teleponRumah ?? this.teleponRumah,
      teleponKantor: teleponKantor ?? this.teleponKantor,
      handphone: handphone ?? this.handphone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PribadiModel(id: $id, userId: $userId, tempatLahir: $tempatLahir, tanggalLahir: $tanggalLahir, jenisKelamin: $jenisKelamin, agama: $agama, statusPerkawinan: $statusPerkawinan)';
  }
}

/// Model untuk data Honorarium
class HonorariumModel {
  final int? id;
  final String userId;
  final String kartuKeluarga;
  final String ktp;
  final String namaKtp;
  final String bpjsKesehatan;
  final String npwp;
  final String namaIbu;
  final String rekening;
  final String namaPemilikRek;
  final String statusPTKP;
  final String jumlahAnak;
  final DateTime createdAt;
  final DateTime updatedAt;

  HonorariumModel({
    this.id,
    required this.userId,
    required this.kartuKeluarga,
    required this.ktp,
    required this.namaKtp,
    required this.bpjsKesehatan,
    required this.npwp,
    required this.namaIbu,
    required this.rekening,
    required this.namaPemilikRek,
    required this.statusPTKP,
    required this.jumlahAnak,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'kartu_keluarga': kartuKeluarga,
      'ktp': ktp,
      'nama_ktp': namaKtp,
      'bpjs_kesehatan': bpjsKesehatan,
      'npwp': npwp,
      'nama_ibu': namaIbu,
      'rekening': rekening,
      'nama_pemilik_rek': namaPemilikRek,
      'status_ptkp': statusPTKP,
      'jumlah_anak': jumlahAnak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HonorariumModel.fromMap(Map<String, dynamic> map) {
    return HonorariumModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      kartuKeluarga: map['kartu_keluarga'] ?? '',
      ktp: map['ktp'] ?? '',
      namaKtp: map['nama_ktp'] ?? '',
      bpjsKesehatan: map['bpjs_kesehatan'] ?? '',
      npwp: map['npwp'] ?? '',
      namaIbu: map['nama_ibu'] ?? '',
      rekening: map['rekening'] ?? '',
      namaPemilikRek: map['nama_pemilik_rek'] ?? '',
      statusPTKP: map['status_ptkp'] ?? '',
      jumlahAnak: map['jumlah_anak'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  HonorariumModel copyWith({
    int? id,
    String? userId,
    String? kartuKeluarga,
    String? ktp,
    String? namaKtp,
    String? bpjsKesehatan,
    String? npwp,
    String? namaIbu,
    String? rekening,
    String? namaPemilikRek,
    String? statusPTKP,
    String? jumlahAnak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HonorariumModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kartuKeluarga: kartuKeluarga ?? this.kartuKeluarga,
      ktp: ktp ?? this.ktp,
      namaKtp: namaKtp ?? this.namaKtp,
      bpjsKesehatan: bpjsKesehatan ?? this.bpjsKesehatan,
      npwp: npwp ?? this.npwp,
      namaIbu: namaIbu ?? this.namaIbu,
      rekening: rekening ?? this.rekening,
      namaPemilikRek: namaPemilikRek ?? this.namaPemilikRek,
      statusPTKP: statusPTKP ?? this.statusPTKP,
      jumlahAnak: jumlahAnak ?? this.jumlahAnak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HonorariumModel(id: $id, userId: $userId, kartuKeluarga: $kartuKeluarga, ktp: $ktp, namaKtp: $namaKtp, npwp: $npwp)';
  }
}

/// Model untuk data ID Card
class IdCardModel {
  final int? id;
  final String userId;
  final String fotoPath;
  final bool isUploaded;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdCardModel({
    this.id,
    required this.userId,
    required this.fotoPath,
    required this.isUploaded,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'foto_path': fotoPath,
      'is_uploaded': isUploaded ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory IdCardModel.fromMap(Map<String, dynamic> map) {
    return IdCardModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      fotoPath: map['foto_path'] ?? '',
      isUploaded: (map['is_uploaded'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  IdCardModel copyWith({
    int? id,
    String? userId,
    String? fotoPath,
    bool? isUploaded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IdCardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fotoPath: fotoPath ?? this.fotoPath,
      isUploaded: isUploaded ?? this.isUploaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'IdCardModel(id: $id, userId: $userId, fotoPath: $fotoPath, isUploaded: $isUploaded)';
  }
}

/// Model untuk data Keluarga
class KeluargaModel {
  final int? id;
  final String userId;
  final String namaAyah;
  final String namaIbu;
  final String namaPasangan;
  final String namaAnak;
  final String pekerjaanAyah;
  final String pekerjaanIbu;
  final String pekerjaanPasangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  KeluargaModel({
    this.id,
    required this.userId,
    required this.namaAyah,
    required this.namaIbu,
    required this.namaPasangan,
    required this.namaAnak,
    required this.pekerjaanAyah,
    required this.pekerjaanIbu,
    required this.pekerjaanPasangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'nama_pasangan': namaPasangan,
      'nama_anak': namaAnak,
      'pekerjaan_ayah': pekerjaanAyah,
      'pekerjaan_ibu': pekerjaanIbu,
      'pekerjaan_pasangan': pekerjaanPasangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KeluargaModel.fromMap(Map<String, dynamic> map) {
    return KeluargaModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      namaAyah: map['nama_ayah'] ?? '',
      namaIbu: map['nama_ibu'] ?? '',
      namaPasangan: map['nama_pasangan'] ?? '',
      namaAnak: map['nama_anak'] ?? '',
      pekerjaanAyah: map['pekerjaan_ayah'] ?? '',
      pekerjaanIbu: map['pekerjaan_ibu'] ?? '',
      pekerjaanPasangan: map['pekerjaan_pasangan'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  KeluargaModel copyWith({
    int? id,
    String? userId,
    String? namaAyah,
    String? namaIbu,
    String? namaPasangan,
    String? namaAnak,
    String? pekerjaanAyah,
    String? pekerjaanIbu,
    String? pekerjaanPasangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KeluargaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaAyah: namaAyah ?? this.namaAyah,
      namaIbu: namaIbu ?? this.namaIbu,
      namaPasangan: namaPasangan ?? this.namaPasangan,
      namaAnak: namaAnak ?? this.namaAnak,
      pekerjaanAyah: pekerjaanAyah ?? this.pekerjaanAyah,
      pekerjaanIbu: pekerjaanIbu ?? this.pekerjaanIbu,
      pekerjaanPasangan: pekerjaanPasangan ?? this.pekerjaanPasangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KeluargaModel(id: $id, userId: $userId, namaAyah: $namaAyah, namaIbu: $namaIbu, namaPasangan: $namaPasangan)';
  }
}

/// Model untuk data Pendidikan
class PendidikanModel {
  final int? id;
  final String userId;
  final String jenjang;
  final String jurusan;
  final String institusi;
  final String kota;
  final String tahunMulai;
  final String tahunSelesai;
  final String ipk;
  final DateTime createdAt;
  final DateTime updatedAt;

  PendidikanModel({
    this.id,
    required this.userId,
    required this.jenjang,
    required this.jurusan,
    required this.institusi,
    required this.kota,
    required this.tahunMulai,
    required this.tahunSelesai,
    required this.ipk,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'jenjang': jenjang,
      'jurusan': jurusan,
      'institusi': institusi,
      'kota': kota,
      'tahun_mulai': tahunMulai,
      'tahun_selesai': tahunSelesai,
      'ipk': ipk,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PendidikanModel.fromMap(Map<String, dynamic> map) {
    return PendidikanModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      jenjang: map['jenjang'] ?? '',
      jurusan: map['jurusan'] ?? '',
      institusi: map['institusi'] ?? '',
      kota: map['kota'] ?? '',
      tahunMulai: map['tahun_mulai'] ?? '',
      tahunSelesai: map['tahun_selesai'] ?? '',
      ipk: map['ipk'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  PendidikanModel copyWith({
    int? id,
    String? userId,
    String? jenjang,
    String? jurusan,
    String? institusi,
    String? kota,
    String? tahunMulai,
    String? tahunSelesai,
    String? ipk,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PendidikanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jenjang: jenjang ?? this.jenjang,
      jurusan: jurusan ?? this.jurusan,
      institusi: institusi ?? this.institusi,
      kota: kota ?? this.kota,
      tahunMulai: tahunMulai ?? this.tahunMulai,
      tahunSelesai: tahunSelesai ?? this.tahunSelesai,
      ipk: ipk ?? this.ipk,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PendidikanModel(id: $id, userId: $userId, jenjang: $jenjang, jurusan: $jurusan, institusi: $institusi)';
  }
}
