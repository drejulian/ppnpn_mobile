import 'package:sqflite/sqflite.dart';
import '../models/sihaki/penerbangan_model.dart';
import 'app_database_helper.dart';

class PenerbanganDatabaseHelper {
  static const String tableName = 'penerbangan';
  
  // Create table query
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_anggota TEXT NOT NULL,
      nomor_passport TEXT NOT NULL,
      bandara_preferensi TEXT NOT NULL,
      maskapai_preferensi TEXT NOT NULL,
      kelas_penerbangan TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(nama_anggota)
    )
  ''';

  // Get database instance
  Future<Database> get _db async {
    return await AppDatabaseHelper.instance.database;
  }

  // Insert or update penerbangan
  Future<int> insertOrUpdatePenerbangan(PenerbanganModel penerbangan) async {
    try {
      final db = await _db;
      
      // Check if penerbangan with this nama_anggota already exists
      final existingPenerbangan = await getPenerbanganByNama(penerbangan.namaAnggota);
      
      if (existingPenerbangan != null) {
        // Update existing record
        final updatedPenerbangan = penerbangan.copyWith(
          id: existingPenerbangan.id,
          updatedAt: DateTime.now(),
        );
        
        final updatedRows = await db.update(
          tableName,
          updatedPenerbangan.toMap(),
          where: 'nama_anggota = ?',
          whereArgs: [penerbangan.namaAnggota],
        );
        
        print('PenerbanganDB: Updated $updatedRows penerbangan records for ${penerbangan.namaAnggota}');
        return existingPenerbangan.id!;
      } else {
        // Insert new record
        final id = await db.insert(
          tableName,
          penerbangan.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        print('PenerbanganDB: Inserted new penerbangan for ${penerbangan.namaAnggota} with ID: $id');
        return id;
      }
    } catch (e) {
      print('PenerbanganDB: Error inserting/updating penerbangan: $e');
      rethrow;
    }
  }

  // Get penerbangan by nama anggota
  Future<PenerbanganModel?> getPenerbanganByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final penerbangan = PenerbanganModel.fromMap(result.first);
        print('PenerbanganDB: Found penerbangan for $namaAnggota');
        return penerbangan;
      }
      
      print('PenerbanganDB: No penerbangan found for $namaAnggota');
      return null;
    } catch (e) {
      print('PenerbanganDB: Error getting penerbangan by nama: $e');
      return null;
    }
  }

  // Get all penerbangan records
  Future<List<PenerbanganModel>> getAllPenerbangan() async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        orderBy: 'updated_at DESC',
      );

      final penerbanganList = result.map((map) => PenerbanganModel.fromMap(map)).toList();
      print('PenerbanganDB: Retrieved ${penerbanganList.length} penerbangan records');
      return penerbanganList;
    } catch (e) {
      print('PenerbanganDB: Error getting all penerbangan: $e');
      return [];
    }
  }

  // Delete penerbangan by nama anggota
  Future<int> deletePenerbanganByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
      );
      
      print('PenerbanganDB: Deleted $deletedRows penerbangan records for: $namaAnggota');
      return deletedRows;
    } catch (e) {
      print('PenerbanganDB: Error deleting penerbangan: $e');
      return 0;
    }
  }

  // Delete penerbangan by ID
  Future<int> deletePenerbanganById(int id) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('PenerbanganDB: Deleted $deletedRows penerbangan records with ID: $id');
      return deletedRows;
    } catch (e) {
      print('PenerbanganDB: Error deleting penerbangan by ID: $e');
      return 0;
    }
  }

  // Clear all penerbangan data
  Future<int> clearAllPenerbangan() async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(tableName);
      print('PenerbanganDB: Cleared all penerbangan data ($deletedRows records)');
      return deletedRows;
    } catch (e) {
      print('PenerbanganDB: Error clearing penerbangan data: $e');
      return 0;
    }
  }

  // Get penerbangan count
  Future<int> getPenerbanganCount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;
      print('PenerbanganDB: Total penerbangan count: $count');
      return count;
    } catch (e) {
      print('PenerbanganDB: Error getting penerbangan count: $e');
      return 0;
    }
  }

  // Close database connection
  Future<void> close() async {
    // Database will be closed by AppDatabaseHelper
    print('PenerbanganDB: Close requested (handled by AppDatabaseHelper)');
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await AppDatabaseHelper.instance.forceRecreateDatabase();
  }
}