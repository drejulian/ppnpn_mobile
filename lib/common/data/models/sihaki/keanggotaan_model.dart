class KeanggotaanModel {
  final int? id;
  final String nama;
  final String noAnggota;
  final String fraksi;
  final String dapil;
  final String area;
  final String? noRekening;
  final String namaRekening;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  KeanggotaanModel({
    this.id,
    required this.nama,
    required this.noAnggota,
    required this.fraksi,
    required this.dapil,
    required this.area,
    this.noRekening,
    required this.namaRekening,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_anggota': noAnggota,
      'fraksi': fraksi,
      'dapil': dapil,
      'area': area,
      'no_rekening': noRekening,
      'nama_rekening': namaRekening,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KeanggotaanModel.fromMap(Map<String, dynamic> map) {
    return KeanggotaanModel(
      id: map['id']?.toInt(),
      nama: map['nama'] ?? '',
      noAnggota: map['no_anggota'] ?? '',
      fraksi: map['fraksi'] ?? '',
      dapil: map['dapil'] ?? '',
      area: map['area'] ?? '',
      noRekening: map['no_rekening'],
      namaRekening: map['nama_rekening'] ?? '',
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  KeanggotaanModel copyWith({
    int? id,
    String? nama,
    String? noAnggota,
    String? fraksi,
    String? dapil,
    String? area,
    String? noRekening,
    String? namaRekening,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KeanggotaanModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noAnggota: noAnggota ?? this.noAnggota,
      fraksi: fraksi ?? this.fraksi,
      dapil: dapil ?? this.dapil,
      area: area ?? this.area,
      noRekening: noRekening ?? this.noRekening,
      namaRekening: namaRekening ?? this.namaRekening,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KeanggotaanModel(id: $id, nama: $nama, noAnggota: $noAnggota, fraksi: $fraksi, dapil: $dapil)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeanggotaanModel &&
        other.id == id &&
        other.nama == nama &&
        other.noAnggota == noAnggota;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nama.hashCode ^ noAnggota.hashCode;
  }
}