class PenerbanganModel {
  final int? id;
  final String namaAnggota;
  final String nomorPassport;
  final String bandaraPreferensi;
  final String maskapaiPreferensi;
  final String kelasPenerbangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  PenerbanganModel({
    this.id,
    required this.namaAnggota,
    required this.nomorPassport,
    required this.bandaraPreferensi,
    required this.maskapaiPreferensi,
    required this.kelasPenerbangan,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database) to Model
  factory PenerbanganModel.fromMap(Map<String, dynamic> map) {
    return PenerbanganModel(
      id: map['id'] as int?,
      namaAnggota: map['nama_anggota'] as String,
      nomorPassport: map['nomor_passport'] as String,
      bandaraPreferensi: map['bandara_preferensi'] as String,
      maskapaiPreferensi: map['maskapai_preferensi'] as String,
      kelasPenerbangan: map['kelas_penerbangan'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert from Model to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'nomor_passport': nomorPassport,
      'bandara_preferensi': bandaraPreferensi,
      'maskapai_preferensi': maskapaiPreferensi,
      'kelas_penerbangan': kelasPenerbangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  PenerbanganModel copyWith({
    int? id,
    String? namaAnggota,
    String? nomorPassport,
    String? bandaraPreferensi,
    String? maskapaiPreferensi,
    String? kelasPenerbangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PenerbanganModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      nomorPassport: nomorPassport ?? this.nomorPassport,
      bandaraPreferensi: bandaraPreferensi ?? this.bandaraPreferensi,
      maskapaiPreferensi: maskapaiPreferensi ?? this.maskapaiPreferensi,
      kelasPenerbangan: kelasPenerbangan ?? this.kelasPenerbangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PenerbanganModel{id: $id, namaAnggota: $namaAnggota, nomorPassport: $nomorPassport, bandaraPreferensi: $bandaraPreferensi, maskapaiPreferensi: $maskapaiPreferensi, kelasPenerbangan: $kelasPenerbangan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PenerbanganModel &&
        other.id == id &&
        other.namaAnggota == namaAnggota &&
        other.nomorPassport == nomorPassport &&
        other.bandaraPreferensi == bandaraPreferensi &&
        other.maskapaiPreferensi == maskapaiPreferensi &&
        other.kelasPenerbangan == kelasPenerbangan;
  }

  @override
  int get hashCode {
    return Object.hash(id, namaAnggota, nomorPassport, bandaraPreferensi, maskapaiPreferensi, kelasPenerbangan);
  }
}