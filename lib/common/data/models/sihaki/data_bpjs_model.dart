class DataBPJSModel {
  final int? id;
  final String nomorBpjs;
  final String jenisBpjs; // 'kesehatan', 'ketenagakerjaan'
  final String namaPeserta;
  final String tanggalLahir;
  final String statusKepesertaan;
  final String? kelasRawat;
  final String? faskesTingkat1;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataBPJSModel({
    this.id,
    required this.nomorBpjs,
    required this.jenisBpjs,
    required this.namaPeserta,
    required this.tanggalLahir,
    required this.statusKepesertaan,
    this.kelasRawat,
    this.faskesTingkat1,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_bpjs': nomorBpjs,
      'jenis_bpjs': jenisBpjs,
      'nama_peserta': namaPeserta,
      'tanggal_lahir': tanggalLahir,
      'status_kepesertaan': statusKepesertaan,
      'kelas_rawat': kelasRawat,
      'faskes_tingkat_1': faskesTingkat1,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DataBPJSModel.fromMap(Map<String, dynamic> map) {
    return DataBPJSModel(
      id: map['id']?.toInt(),
      nomorBpjs: map['nomor_bpjs'] ?? '',
      jenisBpjs: map['jenis_bpjs'] ?? '',
      namaPeserta: map['nama_peserta'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      statusKepesertaan: map['status_kepesertaan'] ?? '',
      kelasRawat: map['kelas_rawat'],
      faskesTingkat1: map['faskes_tingkat_1'],
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  DataBPJSModel copyWith({
    int? id,
    String? nomorBpjs,
    String? jenisBpjs,
    String? namaPeserta,
    String? tanggalLahir,
    String? statusKepesertaan,
    String? kelasRawat,
    String? faskesTingkat1,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataBPJSModel(
      id: id ?? this.id,
      nomorBpjs: nomorBpjs ?? this.nomorBpjs,
      jenisBpjs: jenisBpjs ?? this.jenisBpjs,
      namaPeserta: namaPeserta ?? this.namaPeserta,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      statusKepesertaan: statusKepesertaan ?? this.statusKepesertaan,
      kelasRawat: kelasRawat ?? this.kelasRawat,
      faskesTingkat1: faskesTingkat1 ?? this.faskesTingkat1,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataBPJSModel(id: $id, nomorBpjs: $nomorBpjs, jenisBpjs: $jenisBpjs, namaPeserta: $namaPeserta, tanggalLahir: $tanggalLahir, statusKepesertaan: $statusKepesertaan, kelasRawat: $kelasRawat, faskesTingkat1: $faskesTingkat1, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataBPJSModel &&
        other.id == id &&
        other.nomorBpjs == nomorBpjs &&
        other.jenisBpjs == jenisBpjs &&
        other.namaPeserta == namaPeserta &&
        other.tanggalLahir == tanggalLahir &&
        other.statusKepesertaan == statusKepesertaan &&
        other.kelasRawat == kelasRawat &&
        other.faskesTingkat1 == faskesTingkat1 &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nomorBpjs.hashCode ^
        jenisBpjs.hashCode ^
        namaPeserta.hashCode ^
        tanggalLahir.hashCode ^
        statusKepesertaan.hashCode ^
        kelasRawat.hashCode ^
        faskesTingkat1.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}