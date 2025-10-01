import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/menuutama/cuti_model.dart';

class CutiDatabaseHelper {
  static final CutiDatabaseHelper _instance = CutiDatabaseHelper._internal();
  static Database? _database;

  CutiDatabaseHelper._internal();

  factory CutiDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cuti_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cuti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cutiId TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        tanggalMulai TEXT NOT NULL,
        tanggalSelesai TEXT NOT NULL,
        alasan TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Menunggu Persetujuan',
        fileName TEXT,
        filePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        CONSTRAINT valid_dates CHECK (tanggalSelesai >= tanggalMulai)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_cuti_status ON cuti(status)');
    await db.execute('CREATE INDEX idx_cuti_type ON cuti(type)');
    await db.execute('CREATE INDEX idx_cuti_tanggal ON cuti(tanggalMulai, tanggalSelesai)');
    await db.execute('CREATE INDEX idx_cuti_created ON cuti(createdAt DESC)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Example: Add new column in version 2
      // await db.execute('ALTER TABLE cuti ADD COLUMN newColumn TEXT');
    }
  }

  // CRUD Operations
  Future<int> insertCuti(CutiModel cuti) async {
    final db = await database;
    final validationError = cuti.validate();
    if (validationError != null) {
      throw Exception('Validation failed: $validationError');
    }
    
    try {
      return await db.insert('cuti', cuti.toMap());
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('ID cuti sudah ada. Gunakan ID yang berbeda.');
      }
      throw Exception('Gagal menyimpan data cuti: $e');
    }
  }

  Future<List<CutiModel>> getAllCuti({
    String? orderBy = 'createdAt DESC',
  }) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        orderBy: orderBy,
      );
      return List.generate(maps.length, (i) => CutiModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data cuti: $e');
    }
  }

  Future<CutiModel?> getCutiById(String cutiId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        where: 'cutiId = ?',
        whereArgs: [cutiId],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return CutiModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data cuti: $e');
    }
  }

  Future<List<CutiModel>> getCutiByStatus(CutiStatus status) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        where: 'status = ?',
        whereArgs: [status.label],
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) => CutiModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data cuti berdasarkan status: $e');
    }
  }

  Future<List<CutiModel>> getCutiByType(CutiType type) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        where: 'type = ?',
        whereArgs: [type.label],
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) => CutiModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data cuti berdasarkan jenis: $e');
    }
  }

  Future<List<CutiModel>> getCutiByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    try {
      final String startDate = start.toIso8601String();
      final String endDate = end.toIso8601String();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        where: 'tanggalMulai BETWEEN ? AND ? OR tanggalSelesai BETWEEN ? AND ?',
        whereArgs: [startDate, endDate, startDate, endDate],
        orderBy: 'tanggalMulai ASC',
      );
      return List.generate(maps.length, (i) => CutiModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data cuti berdasarkan tanggal: $e');
    }
  }

  Future<List<CutiModel>> searchCuti(String query) async {
    final db = await database;
    try {
      final String searchQuery = '%${query.toLowerCase()}%';
      final List<Map<String, dynamic>> maps = await db.query(
        'cuti',
        where: '''
          LOWER(cutiId) LIKE ? OR 
          LOWER(type) LIKE ? OR 
          LOWER(alasan) LIKE ? OR 
          LOWER(status) LIKE ?
        ''',
        whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery],
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) => CutiModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mencari data cuti: $e');
    }
  }

  Future<int> updateCuti(CutiModel cuti) async {
    final db = await database;
    final validationError = cuti.validate();
    if (validationError != null) {
      throw Exception('Validation failed: $validationError');
    }

    if (cuti.id == null) {
      throw Exception('ID database tidak boleh null untuk update');
    }
    
    try {
      return await db.update(
        'cuti',
        cuti.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [cuti.id],
      );
    } catch (e) {
      throw Exception('Gagal mengupdate data cuti: $e');
    }
  }

  Future<int> updateCutiStatus(String cutiId, CutiStatus newStatus) async {
    final db = await database;
    try {
      return await db.update(
        'cuti',
        {
          'status': newStatus.label,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'cutiId = ?',
        whereArgs: [cutiId],
      );
    } catch (e) {
      throw Exception('Gagal mengupdate status cuti: $e');
    }
  }

  Future<int> deleteCuti(String cutiId) async {
    final db = await database;
    try {
      return await db.delete(
        'cuti',
        where: 'cutiId = ?',
        whereArgs: [cutiId],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data cuti: $e');
    }
  }

  Future<int> deleteCutiById(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'cuti',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data cuti: $e');
    }
  }

  // Utility methods
  Future<int> getCutiCount() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM cuti');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung jumlah cuti: $e');
    }
  }

  Future<int> getCutiCountByStatus(CutiStatus status) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cuti WHERE status = ?',
        [status.label],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung jumlah cuti berdasarkan status: $e');
    }
  }

  Future<Map<String, int>> getCutiStatistics() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT 
          status,
          COUNT(*) as count
        FROM cuti 
        GROUP BY status
      ''');
      
      Map<String, int> stats = {};
      for (var row in result) {
        stats[row['status'] as String] = row['count'] as int;
      }
      return stats;
    } catch (e) {
      throw Exception('Gagal mengambil statistik cuti: $e');
    }
  }

  Future<bool> isCutiIdExists(String cutiId) async {
    final db = await database;
    try {
      final result = await db.query(
        'cuti',
        where: 'cutiId = ?',
        whereArgs: [cutiId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> generateUniqueCutiId() async {
    String newId;
    do {
      final now = DateTime.now();
      newId = 'C-${now.millisecondsSinceEpoch.toString().substring(8)}';
    } while (await isCutiIdExists(newId));
    return newId;
  }

  // Database maintenance
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('cuti');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('cuti');
    // Database reset - now empty and ready for new data
  }

  // Backup and restore methods
  Future<List<Map<String, dynamic>>> exportAllData() async {
    final db = await database;
    try {
      return await db.query('cuti', orderBy: 'createdAt DESC');
    } catch (e) {
      throw Exception('Gagal mengekspor data: $e');
    }
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    
    try {
      for (var item in data) {
        final cuti = CutiModel.fromMap(item);
        batch.insert('cuti', cuti.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Gagal mengimpor data: $e');
    }
  }
}