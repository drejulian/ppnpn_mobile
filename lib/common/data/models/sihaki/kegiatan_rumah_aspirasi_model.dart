class KegiatanRumahAspirasiModel {
  final int? id;
  final String namaKegiatan;
  final String tanggalKegiatan;
  final String waktuMulai;
  final String waktuSelesai;
  final String tempat;
  final String? deskripsi;
  final int jumlahPeserta;
  final String pic;
  final String? kontakPic;
  final String status; // 'direncanakan', 'berlangsung', 'selesai', 'dibatalkan'
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  KegiatanRumahAspirasiModel({
    this.id,
    required this.namaKegiatan,
    required this.tanggalKegiatan,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tempat,
    this.deskripsi,
    this.jumlahPeserta = 0,
    required this.pic,
    this.kontakPic,
    this.status = 'direncanakan',
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_kegiatan': namaKegiatan,
      'tanggal_kegiatan': tanggalKegiatan,
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'tempat': tempat,
      'deskripsi': deskripsi,
      'jumlah_peserta': jumlahPeserta,
      'pic': pic,
      'kontak_pic': kontakPic,
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KegiatanRumahAspirasiModel.fromMap(Map<String, dynamic> map) {
    return KegiatanRumahAspirasiModel(
      id: map['id']?.toInt(),
      namaKegiatan: map['nama_kegiatan'] ?? '',
      tanggalKegiatan: map['tanggal_kegiatan'] ?? '',
      waktuMulai: map['waktu_mulai'] ?? '',
      waktuSelesai: map['waktu_selesai'] ?? '',
      tempat: map['tempat'] ?? '',
      deskripsi: map['deskripsi'],
      jumlahPeserta: map['jumlah_peserta']?.toInt() ?? 0,
      pic: map['pic'] ?? '',
      kontakPic: map['kontak_pic'],
      status: map['status'] ?? 'direncanakan',
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  KegiatanRumahAspirasiModel copyWith({
    int? id,
    String? namaKegiatan,
    String? tanggalKegiatan,
    String? waktuMulai,
    String? waktuSelesai,
    String? tempat,
    String? deskripsi,
    int? jumlahPeserta,
    String? pic,
    String? kontakPic,
    String? status,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KegiatanRumahAspirasiModel(
      id: id ?? this.id,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      tanggalKegiatan: tanggalKegiatan ?? this.tanggalKegiatan,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      tempat: tempat ?? this.tempat,
      deskripsi: deskripsi ?? this.deskripsi,
      jumlahPeserta: jumlahPeserta ?? this.jumlahPeserta,
      pic: pic ?? this.pic,
      kontakPic: kontakPic ?? this.kontakPic,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KegiatanRumahAspirasiModel(id: $id, namaKegiatan: $namaKegiatan, tanggalKegiatan: $tanggalKegiatan, waktuMulai: $waktuMulai, waktuSelesai: $waktuSelesai, tempat: $tempat, deskripsi: $deskripsi, jumlahPeserta: $jumlahPeserta, pic: $pic, kontakPic: $kontakPic, status: $status, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KegiatanRumahAspirasiModel &&
        other.id == id &&
        other.namaKegiatan == namaKegiatan &&
        other.tanggalKegiatan == tanggalKegiatan &&
        other.waktuMulai == waktuMulai &&
        other.waktuSelesai == waktuSelesai &&
        other.tempat == tempat &&
        other.deskripsi == deskripsi &&
        other.jumlahPeserta == jumlahPeserta &&
        other.pic == pic &&
        other.kontakPic == kontakPic &&
        other.status == status &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        namaKegiatan.hashCode ^
        tanggalKegiatan.hashCode ^
        waktuMulai.hashCode ^
        waktuSelesai.hashCode ^
        tempat.hashCode ^
        deskripsi.hashCode ^
        jumlahPeserta.hashCode ^
        pic.hashCode ^
        kontakPic.hashCode ^
        status.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}