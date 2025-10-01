class KendaraanModel {
  final int? id;
  final String namaAnggota;
  final String nopolDinas;
  final String nopolPribadi;
  final DateTime createdAt;
  final DateTime updatedAt;

  KendaraanModel({
    this.id,
    required this.namaAnggota,
    required this.nopolDinas,
    required this.nopolPribadi,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'nopol_dinas': nopolDinas,
      'nopol_pribadi': nopolPribadi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KendaraanModel.fromMap(Map<String, dynamic> map) {
    return KendaraanModel(
      id: map['id']?.toInt(),
      namaAnggota: map['nama_anggota'] ?? '',
      nopolDinas: map['nopol_dinas'] ?? '',
      nopolPribadi: map['nopol_pribadi'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  KendaraanModel copyWith({
    int? id,
    String? namaAnggota,
    String? nopolDinas,
    String? nopolPribadi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KendaraanModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      nopolDinas: nopolDinas ?? this.nopolDinas,
      nopolPribadi: nopolPribadi ?? this.nopolPribadi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KendaraanModel(id: $id, namaAnggota: $namaAnggota, nopolDinas: $nopolDinas, nopolPribadi: $nopolPribadi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KendaraanModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}