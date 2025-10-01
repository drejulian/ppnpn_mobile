import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sihaki/kendaraan_model.dart';

class KendaraanDatabaseHelper {
  static const String _databaseName = 'kendaraan_database.db';
  static const int _databaseVersion = 1;
  
  static const String tableName = 'kendaraan';
  static const String columnId = 'id';
  static const String columnNamaAnggota = 'nama_anggota';
  static const String columnNopolDinas = 'nopol_dinas';
  static const String columnNopolPribadi = 'nopol_pribadi';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNamaAnggota TEXT NOT NULL,
        $columnNopolDinas TEXT NOT NULL,
        $columnNopolPribadi TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        UNIQUE($columnNamaAnggota)
      )
    ''');
    
    print('DEBUG: Kendaraan table created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Handle database upgrades here
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await _onCreate(db, newVersion);
    }
  }

  // Create
  Future<int> insertKendaraan(KendaraanModel kendaraan) async {
    try {
      final db = await database;
      
      // Check if record with same nama_anggota exists
      final existing = await db.query(
        tableName,
        where: '$columnNamaAnggota = ?',
        whereArgs: [kendaraan.namaAnggota],
        limit: 1,
      );
      
      if (existing.isNotEmpty) {
        // Update existing record
        final updatedKendaraan = kendaraan.copyWith(
          id: existing.first[columnId] as int,
          updatedAt: DateTime.now(),
        );
        await updateKendaraan(updatedKendaraan);
        return existing.first[columnId] as int;
      } else {
        // Insert new record
        final result = await db.insert(
          tableName,
          kendaraan.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('DEBUG: Inserted kendaraan with ID: $result');
        return result;
      }
    } catch (e) {
      print('DEBUG: Error inserting kendaraan: $e');
      rethrow;
    }
  }

  // Read
  Future<List<KendaraanModel>> getAllKendaraan({String? orderBy}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: orderBy ?? '$columnUpdatedAt DESC',
      );

      return List.generate(maps.length, (i) {
        return KendaraanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('DEBUG: Error getting all kendaraan: $e');
      return [];
    }
  }

  Future<KendaraanModel?> getKendaraanById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return KendaraanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('DEBUG: Error getting kendaraan by id: $e');
      return null;
    }
  }

  Future<KendaraanModel?> getKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnNamaAnggota = ?',
        whereArgs: [namaAnggota],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return KendaraanModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('DEBUG: Error getting kendaraan by nama anggota: $e');
      return null;
    }
  }

  // Update
  Future<int> updateKendaraan(KendaraanModel kendaraan) async {
    try {
      final db = await database;
      final result = await db.update(
        tableName,
        kendaraan.toMap(),
        where: '$columnId = ?',
        whereArgs: [kendaraan.id],
      );
      print('DEBUG: Updated kendaraan with ID: ${kendaraan.id}');
      return result;
    } catch (e) {
      print('DEBUG: Error updating kendaraan: $e');
      rethrow;
    }
  }

  // Delete
  Future<int> deleteKendaraan(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      print('DEBUG: Deleted kendaraan with ID: $id');
      return result;
    } catch (e) {
      print('DEBUG: Error deleting kendaraan: $e');
      rethrow;
    }
  }

  Future<int> deleteKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      final db = await database;
      final result = await db.delete(
        tableName,
        where: '$columnNamaAnggota = ?',
        whereArgs: [namaAnggota],
      );
      print('DEBUG: Deleted kendaraan for nama anggota: $namaAnggota');
      return result;
    } catch (e) {
      print('DEBUG: Error deleting kendaraan by nama anggota: $e');
      rethrow;
    }
  }

  // Utility
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<int> getKendaraanCount() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
      );
      return count ?? 0;
    } catch (e) {
      print('DEBUG: Error getting kendaraan count: $e');
      return 0;
    }
  }

  Future<void> clearAllKendaraan() async {
    try {
      final db = await database;
      await db.delete(tableName);
      print('DEBUG: All kendaraan data cleared');
    } catch (e) {
      print('DEBUG: Error clearing all kendaraan: $e');
      rethrow;
    }
  }
}