class AgendaItem {
  final String id;
  final String judul;
  final String deskripsi;
  final String tanggal;
  final String waktu;

  AgendaItem({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    required this.waktu,
  });

  // Tambahkan factory constructor untuk konversi dari Map
  factory AgendaItem.fromMap(Map<String, dynamic> map) {
    return AgendaItem(
      id: map['id'] ?? '',
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tanggal: map['tanggal'] ?? '',
      waktu: map['waktu'] ?? '',
    );
  }

  // Tambahkan method untuk konversi ke Map (opsional)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'waktu': waktu,
    };
  }
}