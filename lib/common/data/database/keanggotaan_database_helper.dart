import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sihaki/keanggotaan_model.dart';

class KeanggotaanDatabaseHelper {
  static final KeanggotaanDatabaseHelper _instance = KeanggotaanDatabaseHelper._internal();
  factory KeanggotaanDatabaseHelper() => _instance;
  KeanggotaanDatabaseHelper._internal();

  static Database? _database;
  static const String _tableName = 'keanggotaan';
  static const String _databaseName = 'keanggotaan.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        no_anggota TEXT NOT NULL UNIQUE,
        fraksi TEXT NOT NULL,
        dapil TEXT NOT NULL,
        area TEXT NOT NULL,
        no_rekening TEXT,
        nama_rekening TEXT NOT NULL,
        user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_keanggotaan_no_anggota ON $_tableName(no_anggota)');
    await db.execute('CREATE INDEX idx_keanggotaan_user_id ON $_tableName(user_id)');
    await db.execute('CREATE INDEX idx_keanggotaan_nama ON $_tableName(nama)');

    print('Database: Keanggotaan table created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Handle database upgrades here
      print('Database: Upgrading keanggotaan database from version $oldVersion to $newVersion');
    }
  }

  // CRUD Operations

  /// Insert new keanggotaan record
  Future<int> insertKeanggotaan(KeanggotaanModel keanggotaan) async {
    try {
      final db = await database;
      final id = await db.insert(
        _tableName,
        keanggotaan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Database: Inserted keanggotaan with ID: $id');
      return id;
    } catch (e) {
      print('Database Error: Failed to insert keanggotaan - $e');
      rethrow;
    }
  }

  /// Get all keanggotaan records
  Future<List<KeanggotaanModel>> getAllKeanggotaan({String? orderBy}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: orderBy ?? 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return KeanggotaanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Database Error: Failed to get all keanggotaan - $e');
      return [];
    }
  }

  /// Get keanggotaan by ID
  Future<KeanggotaanModel?> getKeanggotaanById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return KeanggotaanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Database Error: Failed to get keanggotaan by ID $id - $e');
      return null;
    }
  }

  /// Get keanggotaan by no anggota
  Future<KeanggotaanModel?> getKeanggotaanByNoAnggota(String noAnggota) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'no_anggota = ?',
        whereArgs: [noAnggota],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return KeanggotaanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Database Error: Failed to get keanggotaan by no anggota $noAnggota - $e');
      return null;
    }
  }

  /// Get keanggotaan by user ID
  Future<List<KeanggotaanModel>> getKeanggotaanByUserId(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return KeanggotaanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Database Error: Failed to get keanggotaan by user ID $userId - $e');
      return [];
    }
  }

  /// Update keanggotaan record
  Future<int> updateKeanggotaan(KeanggotaanModel keanggotaan) async {
    try {
      final db = await database;
      final updatedKeanggotaan = keanggotaan.copyWith(
        updatedAt: DateTime.now(),
      );

      final rowsAffected = await db.update(
        _tableName,
        updatedKeanggotaan.toMap(),
        where: 'id = ?',
        whereArgs: [keanggotaan.id],
      );
      print('Database: Updated keanggotaan ID ${keanggotaan.id}, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Database Error: Failed to update keanggotaan - $e');
      rethrow;
    }
  }

  /// Delete keanggotaan record
  Future<int> deleteKeanggotaan(int id) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Database: Deleted keanggotaan ID $id, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Database Error: Failed to delete keanggotaan - $e');
      rethrow;
    }
  }

  /// Delete all keanggotaan records for a user
  Future<int> deleteKeanggotaanByUserId(String userId) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('Database: Deleted all keanggotaan for user $userId, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Database Error: Failed to delete keanggotaan by user ID - $e');
      rethrow;
    }
  }

  /// Search keanggotaan by name or no anggota
  Future<List<KeanggotaanModel>> searchKeanggotaan(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'nama LIKE ? OR no_anggota LIKE ? OR fraksi LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'nama ASC',
      );

      return List.generate(maps.length, (i) {
        return KeanggotaanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Database Error: Failed to search keanggotaan - $e');
      return [];
    }
  }

  /// Get keanggotaan count
  Future<int> getKeanggotaanCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Database Error: Failed to get keanggotaan count - $e');
      return 0;
    }
  }

  /// Clear all keanggotaan data
  Future<void> clearAllKeanggotaan() async {
    try {
      final db = await database;
      await db.delete(_tableName);
      print('Database: Cleared all keanggotaan data');
    } catch (e) {
      print('Database Error: Failed to clear keanggotaan data - $e');
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      print('Database: Keanggotaan database connection closed');
    }
  }
}