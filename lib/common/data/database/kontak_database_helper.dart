import 'package:sqflite/sqflite.dart';
import '../models/sihaki/kontak_model.dart';
import 'app_database_helper.dart';

class KontakDatabaseHelper {
  static const String tableName = 'kontak';
  
  // Create table query
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_anggota TEXT NOT NULL,
      no_kontak TEXT NOT NULL,
      nama_kontak TEXT NOT NULL,
      hubungan_kontak TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(nama_anggota)
    )
  ''';

  // Get database instance
  Future<Database> get _db async {
    return await AppDatabaseHelper.instance.database;
  }

  // Insert or update kontak
  Future<int> insertOrUpdateKontak(KontakModel kontak) async {
    try {
      final db = await _db;
      
      // Check if kontak with this nama_anggota already exists
      final existingKontak = await getKontakByNama(kontak.namaAnggota);
      
      if (existingKontak != null) {
        // Update existing record
        final updatedKontak = kontak.copyWith(
          id: existingKontak.id,
          updatedAt: DateTime.now(),
        );
        
        final updatedRows = await db.update(
          tableName,
          updatedKontak.toMap(),
          where: 'nama_anggota = ?',
          whereArgs: [kontak.namaAnggota],
        );
        
        print('KontakDB: Updated $updatedRows kontak records for ${kontak.namaAnggota}');
        return existingKontak.id!;
      } else {
        // Insert new record
        final id = await db.insert(
          tableName,
          kontak.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        print('KontakDB: Inserted new kontak for ${kontak.namaAnggota} with ID: $id');
        return id;
      }
    } catch (e) {
      print('KontakDB: Error inserting/updating kontak: $e');
      rethrow;
    }
  }

  // Get kontak by nama anggota
  Future<KontakModel?> getKontakByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final kontak = KontakModel.fromMap(result.first);
        print('KontakDB: Found kontak for $namaAnggota');
        return kontak;
      }
      
      print('KontakDB: No kontak found for $namaAnggota');
      return null;
    } catch (e) {
      print('KontakDB: Error getting kontak by nama: $e');
      return null;
    }
  }

  // Get all kontak records
  Future<List<KontakModel>> getAllKontak() async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        orderBy: 'updated_at DESC',
      );

      final kontakList = result.map((map) => KontakModel.fromMap(map)).toList();
      print('KontakDB: Retrieved ${kontakList.length} kontak records');
      return kontakList;
    } catch (e) {
      print('KontakDB: Error getting all kontak: $e');
      return [];
    }
  }

  // Delete kontak by nama anggota
  Future<int> deleteKontakByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
      );
      
      print('KontakDB: Deleted $deletedRows kontak records for: $namaAnggota');
      return deletedRows;
    } catch (e) {
      print('KontakDB: Error deleting kontak: $e');
      return 0;
    }
  }

  // Delete kontak by ID
  Future<int> deleteKontakById(int id) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('KontakDB: Deleted $deletedRows kontak records with ID: $id');
      return deletedRows;
    } catch (e) {
      print('KontakDB: Error deleting kontak by ID: $e');
      return 0;
    }
  }

  // Clear all kontak data
  Future<int> clearAllKontak() async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(tableName);
      print('KontakDB: Cleared all kontak data ($deletedRows records)');
      return deletedRows;
    } catch (e) {
      print('KontakDB: Error clearing kontak data: $e');
      return 0;
    }
  }

  // Get kontak count
  Future<int> getKontakCount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;
      print('KontakDB: Total kontak count: $count');
      return count;
    } catch (e) {
      print('KontakDB: Error getting kontak count: $e');
      return 0;
    }
  }

  // Close database connection
  Future<void> close() async {
    // Database will be closed by AppDatabaseHelper
    print('KontakDB: Close requested (handled by AppDatabaseHelper)');
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await AppDatabaseHelper.instance.forceRecreateDatabase();
  }
}