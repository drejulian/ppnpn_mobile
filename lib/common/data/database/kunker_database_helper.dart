import 'package:sqflite/sqflite.dart';
import '../models/sihaki/kunker_perorangan_model.dart';
import 'app_database_helper.dart';

class KunkerDatabaseHelper {
  static final KunkerDatabaseHelper _instance = KunkerDatabaseHelper._internal();
  factory KunkerDatabaseHelper() => _instance;
  KunkerDatabaseHelper._internal();

  final AppDatabaseHelper _dbHelper = AppDatabaseHelper();

  // Table and column names
  static const String tableName = 'kunker_perorangan';
  static const String columnId = 'id';
  static const String columnNoSurat = 'no_surat';
  static const String columnJenisPerjadin = 'jenis_perjadin';
  static const String columnTanggalSurat = 'tanggal_surat';
  static const String columnTanggalAwal = 'tanggal_awal';
  static const String columnTanggalAkhir = 'tanggal_akhir';
  static const String columnMasaPersidangan = 'masa_persidangan';
  static const String columnTahunSidang = 'tahun_sidang';
  static const String columnAnggota = 'anggota';
  static const String columnNoAnggota = 'no_anggota';
  static const String columnNikAnggota = 'nik_anggota';
  static const String columnFraksi = 'fraksi';
  static const String columnDapil = 'dapil';
  static const String columnRekAnggota = 'rek_anggota';
  static const String columnNamaRekAnggota = 'nama_rek_anggota';
  static const String columnKodeBankAnggota = 'kode_bank_anggota';
  static const String columnNamaBankAnggota = 'nama_bank_anggota';
  static const String columnTa = 'ta';
  static const String columnNoTa = 'no_ta';
  static const String columnNikTa = 'nik_ta';
  static const String columnHpTa = 'hp_ta';
  static const String columnEmailTa = 'email_ta';
  static const String columnRekTa = 'rek_ta';
  static const String columnNamaRekTa = 'nama_rek_ta';
  static const String columnKodeBankTa = 'kode_bank_ta';
  static const String columnNamaBankTa = 'nama_bank_ta';
  static const String columnModa = 'moda';
  static const String columnNegara = 'negara';
  static const String columnProvinsi = 'provinsi';
  static const String columnKota = 'kota';
  static const String columnStatusPengajuan = 'status_pengajuan';
  static const String columnStatusPencairan = 'status_pencairan';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  Future<Database> get database async {
    print('🎯 KunkerDatabaseHelper: Getting database...');
    final db = await _dbHelper.database;
    
    // Verify table structure
    try {
      final tableInfo = await db.rawQuery("PRAGMA table_info(kunker_perorangan)");
      print('🔍 KunkerDatabaseHelper - Table structure verification:');
      for (var column in tableInfo) {
        print('   - ${column['name']}: ${column['type']}');
      }
      
      // Check if no_surat column exists
      final hasNoSurat = tableInfo.any((col) => col['name'] == 'no_surat');
      print('✅ Has no_surat column: $hasNoSurat');
      
      if (!hasNoSurat) {
        print('❌ CRITICAL: no_surat column missing! Available columns: ${tableInfo.map((col) => col['name']).join(', ')}');
      }
    } catch (e) {
      print('❌ Error checking table structure: $e');
    }
    
    return db;
  }

  // Initialize sample data if table is empty
  Future<void> initializeTable() async {
    final db = await database;
    
    // Check if table has data
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final count = result.first['count'] as int;
    
    if (count == 0) {
      // Insert sample data only if table is empty
      await _insertSampleData(db);
    }
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    final sampleData = [
      KunkerModel(
        noSurat: 'DPL-01-A425-2025',
        jenisPerjadin: 'Dapil & setahun',
        tanggalSurat: '10-02-2025',
        tanggalAwal: '14-02-2025',
        tanggalAkhir: '16-02-2025',
        masaPersidangan: 'II',
        tahunSidang: '2024-2025',
        anggota: 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
        noAnggota: 'A-425',
        nikAnggota: '1234567890123456',
        fraksi: 'Fraksi Partai NasDem',
        dapil: 'Dapil SULAWESI SELATAN III',
        rekAnggota: '1234567890',
        namaRekAnggota: 'EVA STEVANY RATABA',
        kodeBankAnggota: '002',
        namaBankAnggota: 'Bank BRI',
        ta: 'Alfian Kadang, M.M. 19-0288',
        noTa: '19-0288',
        nikTa: '6543210987654321',
        hpTa: '081234567890',
        emailTa: 'alfian.kadang@dpr.go.id',
        rekTa: '0987654321',
        namaRekTa: 'Alfian Kadang',
        kodeBankTa: '002',
        namaBankTa: 'Bank BRI',
        moda: 'Pesawat',
        negara: 'Indonesia',
        provinsi: 'Sulawesi Selatan',
        kota: 'Makassar',
        statusPengajuan: 'Menunggu Konfirmasi',
        statusPencairan: '-',
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
      ),
      KunkerModel(
        noSurat: 'DPL-02-A425-2025',
        jenisPerjadin: 'Dapil & setahun',
        tanggalSurat: '01-03-2025',
        tanggalAwal: '07-03-2025',
        tanggalAkhir: '09-03-2025',
        masaPersidangan: 'II',
        tahunSidang: '2024-2025',
        anggota: 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
        noAnggota: 'A-425',
        nikAnggota: '1234567890123456',
        fraksi: 'Fraksi Partai NasDem',
        dapil: 'Dapil SULAWESI SELATAN III',
        rekAnggota: '1234567890',
        namaRekAnggota: 'EVA STEVANY RATABA',
        kodeBankAnggota: '002',
        namaBankAnggota: 'Bank BRI',
        ta: 'Frisko Pratama Satireea, M.Si 14-0547',
        noTa: '14-0547',
        nikTa: '6543210987654322',
        hpTa: '081234567891',
        emailTa: 'frisko.pratama@dpr.go.id',
        rekTa: '0987654322',
        namaRekTa: 'Frisko Pratama Satireea',
        kodeBankTa: '002',
        namaBankTa: 'Bank BRI',
        moda: 'Pesawat',
        negara: 'Indonesia',
        provinsi: 'Sulawesi Selatan',
        kota: 'Parepare',
        statusPengajuan: 'Konfirmasi',
        statusPencairan: 'Disetujui',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
      KunkerModel(
        noSurat: 'DPL-03-A425-2025',
        jenisPerjadin: 'Dapil & setahun',
        tanggalSurat: '10-03-2025',
        tanggalAwal: '14-03-2025',
        tanggalAkhir: '16-03-2025',
        masaPersidangan: 'II',
        tahunSidang: '2024-2025',
        anggota: 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
        noAnggota: 'A-425',
        nikAnggota: '1234567890123456',
        fraksi: 'Fraksi Partai NasDem',
        dapil: 'Dapil SULAWESI SELATAN III',
        rekAnggota: '1234567890',
        namaRekAnggota: 'EVA STEVANY RATABA',
        kodeBankAnggota: '002',
        namaBankAnggota: 'Bank BRI',
        ta: 'Alfian Kadang, M.M. 19-0288',
        noTa: '19-0288',
        nikTa: '6543210987654321',
        hpTa: '081234567890',
        emailTa: 'alfian.kadang@dpr.go.id',
        rekTa: '0987654321',
        namaRekTa: 'Alfian Kadang',
        kodeBankTa: '002',
        namaBankTa: 'Bank BRI',
        moda: 'Pesawat',
        negara: 'Indonesia',
        provinsi: 'Sulawesi Selatan',
        kota: 'Bone',
        statusPengajuan: 'Konfirmasi',
        statusPencairan: 'Ditolak',
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),
    ];

    for (final kunker in sampleData) {
      await db.insert(tableName, kunker.toMap());
    }
  }

  // CRUD Operations
  Future<List<KunkerModel>> getAllKunker() async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: '$columnCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => KunkerModel.fromMap(maps[i]));
  }

  Future<KunkerModel?> getKunkerById(int id) async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return KunkerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<KunkerModel?> getKunkerByNoSurat(String noSurat) async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnNoSurat = ?',
      whereArgs: [noSurat],
    );
    if (maps.isNotEmpty) {
      return KunkerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<KunkerModel>> getKunkerByStatus(String status) async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnStatusPengajuan = ?',
      whereArgs: [status],
      orderBy: '$columnCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => KunkerModel.fromMap(maps[i]));
  }

  Future<List<KunkerModel>> getKunkerByAnggota(String anggota) async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAnggota LIKE ?',
      whereArgs: ['%$anggota%'],
      orderBy: '$columnCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => KunkerModel.fromMap(maps[i]));
  }

  Future<List<KunkerModel>> searchKunker(String query) async {
    await initializeTable();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '''
        $columnNoSurat LIKE ? OR 
        $columnAnggota LIKE ? OR 
        $columnTa LIKE ? OR 
        $columnDapil LIKE ? OR 
        $columnJenisPerjadin LIKE ? OR
        $columnStatusPengajuan LIKE ? OR
        $columnStatusPencairan LIKE ?
      ''',
      whereArgs: List.filled(7, '%$query%'),
      orderBy: '$columnCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => KunkerModel.fromMap(maps[i]));
  }

  Future<int> insertKunker(KunkerModel kunker) async {
    await initializeTable();
    final db = await database;
    try {
      return await db.insert(tableName, kunker.toMap());
    } catch (e) {
      // Handle unique constraint violation
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('No. Surat sudah ada');
      }
      rethrow;
    }
  }

  Future<int> updateKunker(int id, KunkerModel kunker) async {
    await initializeTable();
    final db = await database;
    return await db.update(
      tableName,
      kunker.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      ).toMap(),
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateKunkerByNoSurat(String noSurat, KunkerModel kunker) async {
    await initializeTable();
    final db = await database;
    return await db.update(
      tableName,
      kunker.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      ).toMap(),
      where: '$columnNoSurat = ?',
      whereArgs: [noSurat],
    );
  }

  Future<int> deleteKunker(int id) async {
    await initializeTable();
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteKunkerByNoSurat(String noSurat) async {
    await initializeTable();
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnNoSurat = ?',
      whereArgs: [noSurat],
    );
  }

  Future<int> getKunkerCount() async {
    await initializeTable();
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return (result.first['COUNT(*)'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getKunkerStats() async {
    await initializeTable();
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        $columnStatusPengajuan,
        COUNT(*) as count
      FROM $tableName 
      GROUP BY $columnStatusPengajuan
    ''');
  }

  Future<void> clearAllKunker() async {
    await initializeTable();
    final db = await database;
    await db.delete(tableName);
  }

  // Helper method to convert UI format to database format
  Future<int> insertKunkerFromUIMap(Map<String, dynamic> uiData) async {
    final kunker = KunkerModel.fromUIMap(uiData);
    return await insertKunker(kunker);
  }

  // Helper method to update from UI format
  Future<int> updateKunkerFromUIMap(String noSurat, Map<String, dynamic> uiData) async {
    final existing = await getKunkerByNoSurat(noSurat);
    if (existing == null) {
      throw Exception('Kunker dengan No. Surat $noSurat tidak ditemukan');
    }
    
    final updatedKunker = KunkerModel.fromUIMap(uiData).copyWith(
      id: existing.id,
      createdAt: existing.createdAt,
    );
    
    return await updateKunker(existing.id!, updatedKunker);
  }
}