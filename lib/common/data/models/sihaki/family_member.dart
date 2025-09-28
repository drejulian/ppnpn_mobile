class FamilyMemberDto {
  final String id;
  final String nama;
  final String hubungan;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String pekerjaan;
  final DateTime? tanggalMenikah;

  FamilyMemberDto({
    required this.id,
    required this.nama,
    required this.hubungan,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.pekerjaan,
    this.tanggalMenikah,
  });

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v) => (v ?? '').toString();
    DateTime _parseDate(dynamic v) {
      final s = _s(v);
      try {
        return DateTime.parse(s);
      } catch (_) {
        return DateTime(2000, 1, 1);
      }
    }

    DateTime? _parseDateOpt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return FamilyMemberDto(
      id: _s(json['id'] ?? json['memberId']),
      nama: _s(json['nama'] ?? json['name']),
      hubungan: _s(json['hubungan'] ?? json['relation']),
      tempatLahir: _s(json['tempat_lahir'] ?? json['birthPlace']),
      tanggalLahir: _parseDate(json['tanggal_lahir'] ?? json['birthDate']),
      jenisKelamin: _s(json['jenis_kelamin'] ?? json['gender']),
      pekerjaan: _s(json['pekerjaan'] ?? json['occupation']),
      tanggalMenikah: _parseDateOpt(
        json['tanggal_menikah'] ?? json['marriedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'hubungan': hubungan,
    'tempat_lahir': tempatLahir,
    'tanggal_lahir': tanggalLahir.toIso8601String(),
    'jenis_kelamin': jenisKelamin,
    'pekerjaan': pekerjaan,
    if (tanggalMenikah != null)
      'tanggal_menikah': tanggalMenikah!.toIso8601String(),
  };
}
