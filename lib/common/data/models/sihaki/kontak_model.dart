class KontakModel {
  final int? id;
  final String namaAnggota;
  final String noKontak;
  final String namaKontak;
  final String hubunganKontak;
  final DateTime createdAt;
  final DateTime updatedAt;

  KontakModel({
    this.id,
    required this.namaAnggota,
    required this.noKontak,
    required this.namaKontak,
    required this.hubunganKontak,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database) to Model
  factory KontakModel.fromMap(Map<String, dynamic> map) {
    return KontakModel(
      id: map['id'] as int?,
      namaAnggota: map['nama_anggota'] as String,
      noKontak: map['no_kontak'] as String,
      namaKontak: map['nama_kontak'] as String,
      hubunganKontak: map['hubungan_kontak'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert from Model to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'no_kontak': noKontak,
      'nama_kontak': namaKontak,
      'hubungan_kontak': hubunganKontak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  KontakModel copyWith({
    int? id,
    String? namaAnggota,
    String? noKontak,
    String? namaKontak,
    String? hubunganKontak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KontakModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      noKontak: noKontak ?? this.noKontak,
      namaKontak: namaKontak ?? this.namaKontak,
      hubunganKontak: hubunganKontak ?? this.hubunganKontak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KontakModel{id: $id, namaAnggota: $namaAnggota, noKontak: $noKontak, namaKontak: $namaKontak, hubunganKontak: $hubunganKontak}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KontakModel &&
        other.id == id &&
        other.namaAnggota == namaAnggota &&
        other.noKontak == noKontak &&
        other.namaKontak == namaKontak &&
        other.hubunganKontak == hubunganKontak;
  }

  @override
  int get hashCode {
    return Object.hash(id, namaAnggota, noKontak, namaKontak, hubunganKontak);
  }
}