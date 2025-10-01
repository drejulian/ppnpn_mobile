import 'package:sqflite/sqflite.dart';
import '../models/sihaki/tata_naskah_model.dart';
import 'app_database_helper.dart';

class TataNaskahDatabaseHelper {
  static const String tableName = 'tata_naskah';
  
  // Create table query
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_anggota TEXT NOT NULL,
      document_id TEXT NOT NULL,
      document_title TEXT NOT NULL,
      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      file_type TEXT NOT NULL,
      file_size TEXT NOT NULL,
      is_required INTEGER NOT NULL,
      is_uploaded INTEGER NOT NULL,
      uploaded_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(nama_anggota, document_id)
    )
  ''';

  // Get database instance
  Future<Database> get _db async {
    return await AppDatabaseHelper.instance.database;
  }

  // Insert or update tata naskah document
  Future<int> insertOrUpdateTataNaskah(TataNaskahModel tataNaskah) async {
    try {
      final db = await _db;
      
      // Check if document with this nama_anggota and document_id already exists
      final existingDocument = await getTataNaskahByNamaAndDocId(
        tataNaskah.namaAnggota, 
        tataNaskah.documentId
      );
      
      if (existingDocument != null) {
        // Update existing record
        final updatedDocument = tataNaskah.copyWith(
          id: existingDocument.id,
          updatedAt: DateTime.now(),
        );
        
        final updatedRows = await db.update(
          tableName,
          updatedDocument.toMap(),
          where: 'nama_anggota = ? AND document_id = ?',
          whereArgs: [tataNaskah.namaAnggota, tataNaskah.documentId],
        );
        
        print('TataNaskahDB: Updated $updatedRows document records for ${tataNaskah.namaAnggota} - ${tataNaskah.documentId}');
        return existingDocument.id!;
      } else {
        // Insert new record
        final id = await db.insert(
          tableName,
          tataNaskah.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        print('TataNaskahDB: Inserted new document for ${tataNaskah.namaAnggota} - ${tataNaskah.documentId} with ID: $id');
        return id;
      }
    } catch (e) {
      print('TataNaskahDB: Error inserting/updating document: $e');
      rethrow;
    }
  }

  // Get tata naskah document by nama anggota and document ID
  Future<TataNaskahModel?> getTataNaskahByNamaAndDocId(String namaAnggota, String documentId) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ? AND document_id = ?',
        whereArgs: [namaAnggota, documentId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final document = TataNaskahModel.fromMap(result.first);
        print('TataNaskahDB: Found document for $namaAnggota - $documentId');
        return document;
      }
      
      print('TataNaskahDB: No document found for $namaAnggota - $documentId');
      return null;
    } catch (e) {
      print('TataNaskahDB: Error getting document by nama and doc ID: $e');
      return null;
    }
  }

  // Get all tata naskah documents by nama anggota
  Future<List<TataNaskahModel>> getTataNaskahByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
        orderBy: 'updated_at DESC',
      );

      final documentList = result.map((map) => TataNaskahModel.fromMap(map)).toList();
      print('TataNaskahDB: Retrieved ${documentList.length} documents for $namaAnggota');
      return documentList;
    } catch (e) {
      print('TataNaskahDB: Error getting documents by nama: $e');
      return [];
    }
  }

  // Get all tata naskah documents
  Future<List<TataNaskahModel>> getAllTataNaskah() async {
    try {
      final db = await _db;
      final result = await db.query(
        tableName,
        orderBy: 'updated_at DESC',
      );

      final documentList = result.map((map) => TataNaskahModel.fromMap(map)).toList();
      print('TataNaskahDB: Retrieved ${documentList.length} total documents');
      return documentList;
    } catch (e) {
      print('TataNaskahDB: Error getting all documents: $e');
      return [];
    }
  }

  // Delete tata naskah document by nama anggota and document ID
  Future<int> deleteTataNaskahByNamaAndDocId(String namaAnggota, String documentId) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ? AND document_id = ?',
        whereArgs: [namaAnggota, documentId],
      );
      
      print('TataNaskahDB: Deleted $deletedRows document records for: $namaAnggota - $documentId');
      return deletedRows;
    } catch (e) {
      print('TataNaskahDB: Error deleting document: $e');
      return 0;
    }
  }

  // Delete all documents by nama anggota
  Future<int> deleteTataNaskahByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [namaAnggota],
      );
      
      print('TataNaskahDB: Deleted $deletedRows document records for: $namaAnggota');
      return deletedRows;
    } catch (e) {
      print('TataNaskahDB: Error deleting documents by nama: $e');
      return 0;
    }
  }

  // Delete tata naskah document by ID
  Future<int> deleteTataNaskahById(int id) async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('TataNaskahDB: Deleted $deletedRows document records with ID: $id');
      return deletedRows;
    } catch (e) {
      print('TataNaskahDB: Error deleting document by ID: $e');
      return 0;
    }
  }

  // Clear all tata naskah data
  Future<int> clearAllTataNaskah() async {
    try {
      final db = await _db;
      final deletedRows = await db.delete(tableName);
      print('TataNaskahDB: Cleared all tata naskah data ($deletedRows records)');
      return deletedRows;
    } catch (e) {
      print('TataNaskahDB: Error clearing tata naskah data: $e');
      return 0;
    }
  }

  // Get tata naskah document count
  Future<int> getTataNaskahCount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;
      print('TataNaskahDB: Total tata naskah count: $count');
      return count;
    } catch (e) {
      print('TataNaskahDB: Error getting tata naskah count: $e');
      return 0;
    }
  }

  // Get tata naskah count by nama anggota
  Future<int> getTataNaskahCountByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE nama_anggota = ?',
        [namaAnggota]
      );
      final count = result.first['count'] as int;
      print('TataNaskahDB: Document count for $namaAnggota: $count');
      return count;
    } catch (e) {
      print('TataNaskahDB: Error getting document count by nama: $e');
      return 0;
    }
  }

  // Get uploaded documents count by nama anggota
  Future<int> getUploadedCountByNama(String namaAnggota) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE nama_anggota = ? AND is_uploaded = 1',
        [namaAnggota]
      );
      final count = result.first['count'] as int;
      print('TataNaskahDB: Uploaded document count for $namaAnggota: $count');
      return count;
    } catch (e) {
      print('TataNaskahDB: Error getting uploaded count by nama: $e');
      return 0;
    }
  }

  // Close database connection
  Future<void> close() async {
    // Database will be closed by AppDatabaseHelper
    print('TataNaskahDB: Close requested (handled by AppDatabaseHelper)');
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await AppDatabaseHelper.instance.forceRecreateDatabase();
  }
}