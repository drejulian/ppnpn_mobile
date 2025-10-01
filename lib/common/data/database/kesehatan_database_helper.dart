import 'package:sqflite/sqflite.dart';
import '../models/sihaki/kesehatan_model.dart';
import 'app_database_helper.dart';

class KesehatanDatabaseHelper {
  static const String tableName = 'kesehatan';
  
  // Create table query
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_anggota TEXT NOT NULL,
      berat_badan TEXT NOT NULL,
      tinggi_badan TEXT NOT NULL,
      golongan_darah TEXT NOT NULL,
      riwayat_penyakit TEXT,
      alergi TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(nama_anggota)
    )
  ''';

  // Get database instance
  Future<Database> get _db async {
    return await AppDatabaseHelper().database;
  }

  // Insert or update kesehatan data
  Future<int> insertOrUpdateKesehatan(KesehatanModel kesehatan) async {
    try {
      final db = await _db;
      
      // Check if record exists for this nama_anggota
      final existing = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [kesehatan.namaAnggota],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing record
        final updatedKesehatan = kesehatan.copyWith(
          id: existing.first['id'] as int,
          updatedAt: DateTime.now(),
        );
        
        await db.update(
          tableName,
          updatedKesehatan.toMap(),
          where: 'nama_anggota = ?',
          whereArgs: [kesehatan.namaAnggota],
        );
        
        print('KesehatanDB: Updated existing kesehatan for ${kesehatan.namaAnggota}');
        return updatedKesehatan.id!;
      } else {
        // Insert new record
        final id = await db.insert(
          tableName,
          kesehatan.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        print('KesehatanDB: Inserted new kesehatan for ${kesehatan.namaAnggota} with ID: $id');
        return id;
      }
    } catch (e) {
      print('KesehatanDB: Error inserting/updating kesehatan: $e');
      rethrow;
    }
  }

  // Get kesehatan by nama anggota
  Future<KesehatanModel?> getKesehatanByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final kesehatan = KesehatanModel.fromMap(result.first);
        print('KesehatanDB: Found kesehatan for $namaAnggota');
        return kesehatan;
      }
      
      print('KesehatanDB: No kesehatan found for $namaAnggota');
      return null;
    } catch (e) {
      print('KesehatanDB: Error getting kesehatan by nama: $e');
      return null;
    }
  }

  // Get all kesehatan records
  Future<List<KesehatanModel>> getAllKesehatan() async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        orderBy: 'updated_at DESC',
      );

      final kesehatanList = result.map((map) => KesehatanModel.fromMap(map)).toList();
      print('KesehatanDB: Retrieved ${kesehatanList.length} kesehatan records');
      return kesehatanList;
    } catch (e) {
      print('KesehatanDB: Error getting all kesehatan: $e');
      return [];
    }
  }

  // Delete kesehatan by nama anggota
  Future<int> deleteKesehatanByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
      );
      
      print('KesehatanDB: Deleted $deletedRows kesehatan records for $namaAnggota');
      return deletedRows;
    } catch (e) {
      print('KesehatanDB: Error deleting kesehatan: $e');
      return 0;
    }
  }

  // Delete kesehatan by ID
  Future<int> deleteKesehatanById(int id) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('KesehatanDB: Deleted $deletedRows kesehatan records with ID: $id');
      return deletedRows;
    } catch (e) {
      print('KesehatanDB: Error deleting kesehatan by ID: $e');
      return 0;
    }
  }

  // Clear all kesehatan data
  Future<int> clearAllKesehatan() async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(tableName);
      print('KesehatanDB: Cleared all kesehatan data ($deletedRows records)');
      return deletedRows;
    } catch (e) {
      print('KesehatanDB: Error clearing kesehatan data: $e');
      return 0;
    }
  }

  // Get kesehatan count
  Future<int> getKesehatanCount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('KesehatanDB: Total kesehatan count: $count');
      return count;
    } catch (e) {
      print('KesehatanDB: Error getting kesehatan count: $e');
      return 0;
    }
  }

  // Close database connection
  Future<void> close() async {
    // Database will be closed by AppDatabaseHelper
    print('KesehatanDB: Close requested (handled by AppDatabaseHelper)');
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await AppDatabaseHelper.instance.forceRecreateDatabase();
  }
}