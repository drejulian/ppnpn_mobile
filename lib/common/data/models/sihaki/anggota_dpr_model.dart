class AnggotaDPRModel {
  final int? id;
  final String nip;
  final String namaLengkap;
  final String? gelarDepan;
  final String? gelarBelakang;
  final String partai;
  final String dapil;
  final String provinsi;
  final String jenisKelamin; // 'L', 'P'
  final String tempatLahir;
  final String tanggalLahir;
  final String agama;
  final String alamat;
  final String? telepon;
  final String? email;
  final String? pendidikanTerakhir;
  final String? pekerjaanSebelumnya;
  final String periodeMulai;
  final String? periodeSelesai;
  final String status; // 'aktif', 'tidak_aktif', 'pengganti'
  final String? fotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnggotaDPRModel({
    this.id,
    required this.nip,
    required this.namaLengkap,
    this.gelarDepan,
    this.gelarBelakang,
    required this.partai,
    required this.dapil,
    required this.provinsi,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.agama,
    required this.alamat,
    this.telepon,
    this.email,
    this.pendidikanTerakhir,
    this.pekerjaanSebelumnya,
    required this.periodeMulai,
    this.periodeSelesai,
    this.status = 'aktif',
    this.fotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get namaLengkapFormatted {
    String nama = '';
    if (gelarDepan != null && gelarDepan!.isNotEmpty) {
      nama += '$gelarDepan ';
    }
    nama += namaLengkap;
    if (gelarBelakang != null && gelarBelakang!.isNotEmpty) {
      nama += ', $gelarBelakang';
    }
    return nama;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nip': nip,
      'nama_lengkap': namaLengkap,
      'gelar_depan': gelarDepan,
      'gelar_belakang': gelarBelakang,
      'partai': partai,
      'dapil': dapil,
      'provinsi': provinsi,
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'agama': agama,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
      'pendidikan_terakhir': pendidikanTerakhir,
      'pekerjaan_sebelumnya': pekerjaanSebelumnya,
      'periode_mulai': periodeMulai,
      'periode_selesai': periodeSelesai,
      'status': status,
      'foto_url': fotoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AnggotaDPRModel.fromMap(Map<String, dynamic> map) {
    return AnggotaDPRModel(
      id: map['id']?.toInt(),
      nip: map['nip'] ?? '',
      namaLengkap: map['nama_lengkap'] ?? '',
      gelarDepan: map['gelar_depan'],
      gelarBelakang: map['gelar_belakang'],
      partai: map['partai'] ?? '',
      dapil: map['dapil'] ?? '',
      provinsi: map['provinsi'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? '',
      tempatLahir: map['tempat_lahir'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      agama: map['agama'] ?? '',
      alamat: map['alamat'] ?? '',
      telepon: map['telepon'],
      email: map['email'],
      pendidikanTerakhir: map['pendidikan_terakhir'],
      pekerjaanSebelumnya: map['pekerjaan_sebelumnya'],
      periodeMulai: map['periode_mulai'] ?? '',
      periodeSelesai: map['periode_selesai'],
      status: map['status'] ?? 'aktif',
      fotoUrl: map['foto_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  AnggotaDPRModel copyWith({
    int? id,
    String? nip,
    String? namaLengkap,
    String? gelarDepan,
    String? gelarBelakang,
    String? partai,
    String? dapil,
    String? provinsi,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    String? agama,
    String? alamat,
    String? telepon,
    String? email,
    String? pendidikanTerakhir,
    String? pekerjaanSebelumnya,
    String? periodeMulai,
    String? periodeSelesai,
    String? status,
    String? fotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnggotaDPRModel(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      gelarDepan: gelarDepan ?? this.gelarDepan,
      gelarBelakang: gelarBelakang ?? this.gelarBelakang,
      partai: partai ?? this.partai,
      dapil: dapil ?? this.dapil,
      provinsi: provinsi ?? this.provinsi,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      agama: agama ?? this.agama,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
      pendidikanTerakhir: pendidikanTerakhir ?? this.pendidikanTerakhir,
      pekerjaanSebelumnya: pekerjaanSebelumnya ?? this.pekerjaanSebelumnya,
      periodeMulai: periodeMulai ?? this.periodeMulai,
      periodeSelesai: periodeSelesai ?? this.periodeSelesai,
      status: status ?? this.status,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AnggotaDPRModel(id: $id, nip: $nip, namaLengkap: $namaLengkap, gelarDepan: $gelarDepan, gelarBelakang: $gelarBelakang, partai: $partai, dapil: $dapil, provinsi: $provinsi, jenisKelamin: $jenisKelamin, tempatLahir: $tempatLahir, tanggalLahir: $tanggalLahir, agama: $agama, alamat: $alamat, telepon: $telepon, email: $email, pendidikanTerakhir: $pendidikanTerakhir, pekerjaanSebelumnya: $pekerjaanSebelumnya, periodeMulai: $periodeMulai, periodeSelesai: $periodeSelesai, status: $status, fotoUrl: $fotoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnggotaDPRModel &&
        other.id == id &&
        other.nip == nip &&
        other.namaLengkap == namaLengkap &&
        other.gelarDepan == gelarDepan &&
        other.gelarBelakang == gelarBelakang &&
        other.partai == partai &&
        other.dapil == dapil &&
        other.provinsi == provinsi &&
        other.jenisKelamin == jenisKelamin &&
        other.tempatLahir == tempatLahir &&
        other.tanggalLahir == tanggalLahir &&
        other.agama == agama &&
        other.alamat == alamat &&
        other.telepon == telepon &&
        other.email == email &&
        other.pendidikanTerakhir == pendidikanTerakhir &&
        other.pekerjaanSebelumnya == pekerjaanSebelumnya &&
        other.periodeMulai == periodeMulai &&
        other.periodeSelesai == periodeSelesai &&
        other.status == status &&
        other.fotoUrl == fotoUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nip.hashCode ^
        namaLengkap.hashCode ^
        gelarDepan.hashCode ^
        gelarBelakang.hashCode ^
        partai.hashCode ^
        dapil.hashCode ^
        provinsi.hashCode ^
        jenisKelamin.hashCode ^
        tempatLahir.hashCode ^
        tanggalLahir.hashCode ^
        agama.hashCode ^
        alamat.hashCode ^
        telepon.hashCode ^
        email.hashCode ^
        pendidikanTerakhir.hashCode ^
        pekerjaanSebelumnya.hashCode ^
        periodeMulai.hashCode ^
        periodeSelesai.hashCode ^
        status.hashCode ^
        fotoUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}