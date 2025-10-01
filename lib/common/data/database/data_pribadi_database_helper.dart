import 'package:sqflite/sqflite.dart';
import '../models/sihaki/data_pribadi_model.dart';
import 'app_database_helper.dart';

class DataPribadiDatabaseHelper {
  static const String tableName = 'data_pribadi';
  
  // Create table query
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_anggota TEXT NOT NULL,
      handphone TEXT NOT NULL,
      email TEXT NOT NULL,
      telpon_ruangan TEXT NOT NULL,
      ruang_kerja TEXT NOT NULL,
      bahasa_asing TEXT NOT NULL,
      alamat_rumah TEXT NOT NULL,
      keterangan_domisili TEXT NOT NULL,
      nama_ayah_kandung TEXT NOT NULL,
      nama_ibu_kandung TEXT NOT NULL,
      no_rekening_mitra TEXT NOT NULL,
      nama_rekening_mitra TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(nama_anggota)
    )
  ''';

  // Get database instance
  Future<Database> get _db async {
    return await AppDatabaseHelper.instance.database;
  }

  // Insert or update data pribadi
  Future<int> insertOrUpdateDataPribadi(DataPribadiModel dataPribadi) async {
    try {
      final db = await _db;
      
      // Check if data pribadi with this nama_anggota already exists
      final existingDataPribadi = await getDataPribadiByNama(dataPribadi.namaAnggota);
      
      if (existingDataPribadi != null) {
        // Update existing record
        final updatedDataPribadi = dataPribadi.copyWith(
          id: existingDataPribadi.id,
          updatedAt: DateTime.now(),
        );
        
        final updatedRows = await db.update(
          tableName,
          updatedDataPribadi.toMap(),
          where: 'nama_anggota = ?',
          whereArgs: [dataPribadi.namaAnggota],
        );
        
        print('DataPribadiDB: Updated $updatedRows data pribadi records for ${dataPribadi.namaAnggota}');
        return existingDataPribadi.id!;
      } else {
        // Insert new record
        final id = await db.insert(
          tableName,
          dataPribadi.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        print('DataPribadiDB: Inserted new data pribadi for ${dataPribadi.namaAnggota} with ID: $id');
        return id;
      }
    } catch (e) {
      print('DataPribadiDB: Error inserting/updating data pribadi: $e');
      rethrow;
    }
  }

  // Get data pribadi by nama anggota
  Future<DataPribadiModel?> getDataPribadiByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final dataPribadi = DataPribadiModel.fromMap(result.first);
        print('DataPribadiDB: Found data pribadi for $namaAnggota');
        return dataPribadi;
      }
      
      print('DataPribadiDB: No data pribadi found for $namaAnggota');
      return null;
    } catch (e) {
      print('DataPribadiDB: Error getting data pribadi by nama: $e');
      return null;
    }
  }

  // Get all data pribadi records
  Future<List<DataPribadiModel>> getAllDataPribadi() async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        orderBy: 'updated_at DESC',
      );

      final dataPribadiList = result.map((map) => DataPribadiModel.fromMap(map)).toList();
      print('DataPribadiDB: Retrieved ${dataPribadiList.length} data pribadi records');
      return dataPribadiList;
    } catch (e) {
      print('DataPribadiDB: Error getting all data pribadi: $e');
      return [];
    }
  }

  // Delete data pribadi by nama anggota
  Future<int> deleteDataPribadiByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
      );
      
      print('DataPribadiDB: Deleted $deletedRows data pribadi records for: $namaAnggota');
      return deletedRows;
    } catch (e) {
      print('DataPribadiDB: Error deleting data pribadi: $e');
      return 0;
    }
  }

  // Delete data pribadi by ID
  Future<int> deleteDataPribadiById(int id) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DataPribadiDB: Deleted $deletedRows data pribadi records with ID: $id');
      return deletedRows;
    } catch (e) {
      print('DataPribadiDB: Error deleting data pribadi by ID: $e');
      return 0;
    }
  }

  // Clear all data pribadi data
  Future<int> clearAllDataPribadi() async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(tableName);
      print('DataPribadiDB: Cleared all data pribadi data ($deletedRows records)');
      return deletedRows;
    } catch (e) {
      print('DataPribadiDB: Error clearing data pribadi data: $e');
      return 0;
    }
  }

  // Get data pribadi count
  Future<int> getDataPribadiCount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;
      print('DataPribadiDB: Total data pribadi count: $count');
      return count;
    } catch (e) {
      print('DataPribadiDB: Error getting data pribadi count: $e');
      return 0;
    }
  }

  // Close database connection
  Future<void> close() async {
    // Database will be closed by AppDatabaseHelper
    print('DataPribadiDB: Close requested (handled by AppDatabaseHelper)');
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await AppDatabaseHelper.instance.forceRecreateDatabase();
  }
}