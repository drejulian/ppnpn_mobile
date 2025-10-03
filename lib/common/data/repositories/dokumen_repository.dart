import 'package:sqflite/sqflite.dart';
import '../database/app_database_helper.dart';
import '../models/dokumen_model.dart';

class DokumenRepository {
  static final DokumenRepository _instance = DokumenRepository._internal();
  factory DokumenRepository() => _instance;
  DokumenRepository._internal();

  final AppDatabaseHelper _dbHelper = AppDatabaseHelper();

  // Table name (using existing dokumen_anggota table)
  static const String tableName = 'dokumen_anggota';

  /// Get database instance
  Future<Database> get _database async {
    return await _dbHelper.database;
  }

  /// Insert or update dokumen
  Future<int> insertOrUpdateDokumen(DokumenModel dokumen) async {
    try {
      final db = await _database;
      
      // Check if document already exists for this user and document type
      final existing = await getDokumenByUserAndType(
        dokumen.userId, 
        dokumen.documentId
      );
      
      if (existing != null) {
        // Update existing document
        final updatedDokumen = dokumen.copyWith(
          id: existing.id,
          updatedAt: DateTime.now(),
        );
        
        await db.update(
          tableName,
          _mapToDatabase(updatedDokumen.toMap()),
          where: 'id = ?',
          whereArgs: [existing.id],
        );
        
        print('DokumenRepository: Updated document ${dokumen.documentId} for user ${dokumen.userId}');
        return existing.id!;
      } else {
        // Insert new document
        final newDokumen = dokumen.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final id = await db.insert(
          tableName, 
          _mapToDatabase(newDokumen.toMap()),
        );
        
        print('DokumenRepository: Inserted new document ${dokumen.documentId} for user ${dokumen.userId} with ID: $id');
        return id;
      }
    } catch (e) {
      print('DokumenRepository: Error inserting/updating dokumen: $e');
      throw Exception('Gagal menyimpan dokumen: $e');
    }
  }

  /// Get dokumen by user ID and document type
  Future<DokumenModel?> getDokumenByUserAndType(String userId, String documentId) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'nama_anggota = ? AND document_id = ?',
        whereArgs: [userId, documentId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return DokumenModel.fromMap(_mapFromDatabase(maps.first));
      }
      
      return null;
    } catch (e) {
      print('DokumenRepository: Error getting dokumen by user and type: $e');
      return null;
    }
  }

  /// Get all dokumen for a user
  Future<List<DokumenModel>> getDokumenByUser(String userId) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'nama_anggota = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return DokumenModel.fromMap(_mapFromDatabase(maps[i]));
      });
    } catch (e) {
      print('DokumenRepository: Error getting dokumen by user: $e');
      throw Exception('Gagal mengambil dokumen: $e');
    }
  }

  /// Get all uploaded dokumen for a user
  Future<List<DokumenModel>> getUploadedDokumenByUser(String userId) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'nama_anggota = ? AND is_uploaded = 1',
        whereArgs: [userId],
        orderBy: 'uploaded_at DESC',
      );

      return List.generate(maps.length, (i) {
        return DokumenModel.fromMap(_mapFromDatabase(maps[i]));
      });
    } catch (e) {
      print('DokumenRepository: Error getting uploaded dokumen: $e');
      throw Exception('Gagal mengambil dokumen yang telah diupload: $e');
    }
  }

  /// Delete dokumen
  Future<int> deleteDokumen(int id) async {
    try {
      final db = await _database;
      final result = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DokumenRepository: Deleted document with ID: $id');
      return result;
    } catch (e) {
      print('DokumenRepository: Error deleting dokumen: $e');
      throw Exception('Gagal menghapus dokumen: $e');
    }
  }

  /// Delete dokumen by user and document type
  Future<int> deleteDokumenByUserAndType(String userId, String documentId) async {
    try {
      final db = await _database;
      final result = await db.delete(
        tableName,
        where: 'nama_anggota = ? AND document_id = ?',
        whereArgs: [userId, documentId],
      );
      
      print('DokumenRepository: Deleted document $documentId for user $userId');
      return result;
    } catch (e) {
      print('DokumenRepository: Error deleting dokumen by user and type: $e');
      throw Exception('Gagal menghapus dokumen: $e');
    }
  }

  /// Get dokumen count by user
  Future<int> getDokumenCount(String userId) async {
    try {
      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE nama_anggota = ?',
        [userId]
      );
      return result.first['count'] as int;
    } catch (e) {
      print('DokumenRepository: Error getting dokumen count: $e');
      return 0;
    }
  }

  /// Get uploaded dokumen count by user
  Future<int> getUploadedDokumenCount(String userId) async {
    try {
      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE nama_anggota = ? AND is_uploaded = 1',
        [userId]
      );
      return result.first['count'] as int;
    } catch (e) {
      print('DokumenRepository: Error getting uploaded dokumen count: $e');
      return 0;
    }
  }

  /// Search dokumen
  Future<List<DokumenModel>> searchDokumen(String keyword, {String? userId}) async {
    try {
      final db = await _database;
      String whereClause = 'document_title LIKE ? OR file_name LIKE ?';
      List<dynamic> whereArgs = ['%$keyword%', '%$keyword%'];
      
      if (userId != null) {
        whereClause += ' AND nama_anggota = ?';
        whereArgs.add(userId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'updated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return DokumenModel.fromMap(_mapFromDatabase(maps[i]));
      });
    } catch (e) {
      print('DokumenRepository: Error searching dokumen: $e');
      throw Exception('Gagal mencari dokumen: $e');
    }
  }

  /// Check if dokumen exists
  Future<bool> isDokumenExists(String userId, String documentId) async {
    try {
      final dokumen = await getDokumenByUserAndType(userId, documentId);
      return dokumen != null;
    } catch (e) {
      print('DokumenRepository: Error checking dokumen existence: $e');
      return false;
    }
  }

  /// Mark dokumen as uploaded
  Future<bool> markAsUploaded(String userId, String documentId, {
    String? filePath, 
    String? fileName, 
    String? fileType, 
    String? fileSize
  }) async {
    try {
      final existing = await getDokumenByUserAndType(userId, documentId);
      if (existing == null) return false;

      final updatedDokumen = existing.copyWith(
        isUploaded: true,
        uploadedAt: DateTime.now(),
        filePath: filePath ?? existing.filePath,
        fileName: fileName ?? existing.fileName,
        fileType: fileType ?? existing.fileType,
        fileSize: fileSize ?? existing.fileSize,
        updatedAt: DateTime.now(),
      );

      final result = await insertOrUpdateDokumen(updatedDokumen);
      return result > 0;
    } catch (e) {
      print('DokumenRepository: Error marking as uploaded: $e');
      return false;
    }
  }

  /// Mark dokumen as not uploaded
  Future<bool> markAsNotUploaded(String userId, String documentId) async {
    try {
      final existing = await getDokumenByUserAndType(userId, documentId);
      if (existing == null) return false;

      final updatedDokumen = existing.copyWith(
        isUploaded: false,
        uploadedAt: null,
        filePath: null,
        fileName: null,
        fileType: null,
        fileSize: null,
        updatedAt: DateTime.now(),
      );

      final result = await insertOrUpdateDokumen(updatedDokumen);
      return result > 0;
    } catch (e) {
      print('DokumenRepository: Error marking as not uploaded: $e');
      return false;
    }
  }

  /// Initialize default documents for a user
  Future<void> initializeDefaultDocuments(String userId) async {
    try {
      final defaultDocuments = _getDefaultDocuments(userId);
      
      for (final doc in defaultDocuments) {
        final existing = await getDokumenByUserAndType(userId, doc.documentId);
        if (existing == null) {
          await insertOrUpdateDokumen(doc);
        }
      }
      
      print('DokumenRepository: Initialized default documents for user $userId');
    } catch (e) {
      print('DokumenRepository: Error initializing default documents: $e');
    }
  }

  /// Get default documents list
  List<DokumenModel> _getDefaultDocuments(String userId) {
    final now = DateTime.now();
    
    return [
      DokumenModel(
        userId: userId,
        documentId: 'ktp',
        documentTitle: 'KTP (ID Card)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'kk',
        documentTitle: 'KK (Family Card)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'npwp',
        documentTitle: 'NPWP (Tax ID)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'norek',
        documentTitle: 'Norek (Account Number)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'skck',
        documentTitle: 'SKCK (Police Clearance Certificate)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'ijazah',
        documentTitle: 'Ijazah (Diploma)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'transkrip',
        documentTitle: 'Transkrip Nilai (Academic Transcript)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'bebas_narkoba',
        documentTitle: 'Surat Bebas Narkoba (Drug-Free Certificate)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'sehat',
        documentTitle: 'Surat Sehat (Health Certificate)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'pengalaman_kerja',
        documentTitle: 'Surat Pengalaman Kerja (TAA/SP) (Work Experience Letter)',
        isRequired: false,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'toefl',
        documentTitle: 'TOEFL (TAA/SA)',
        isRequired: false,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'penyetaraan',
        documentTitle: 'Surat Penyetaraan Ijazah/GAB (Ijazah luar negeri) (Diploma Equivalency Certificate/GAB (Overseas Diploma))',
        isRequired: false,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'bpjs_kesehatan',
        documentTitle: 'BPJS Kesehatan (Health BPJS)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'bpjs_ketenagakerjaan',
        documentTitle: 'BPJS Ketenagakerjaan (Employment BPJS)',
        isRequired: true,
        createdAt: now,
        updatedAt: now,
      ),
      DokumenModel(
        userId: userId,
        documentId: 'lainnya',
        documentTitle: 'Lain-lain (Others)',
        isRequired: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Helper method to map DokumenModel fields to database schema
  Map<String, dynamic> _mapToDatabase(Map<String, dynamic> model) {
    return {
      'id': model['id'],
      'nama_anggota': model['user_id'], // Map user_id to nama_anggota
      'document_id': model['document_id'],
      'document_title': model['document_title'],
      'file_path': model['file_path'] ?? '',
      'file_name': model['file_name'] ?? '',
      'file_type': model['file_type'] ?? '',
      'file_size': model['file_size'] ?? '',
      'is_required': model['is_required'],
      'uploaded_at': model['uploaded_at'],
      'created_at': model['created_at'],
      'updated_at': model['updated_at'],
    };
  }

  /// Helper method to map database fields to DokumenModel
  Map<String, dynamic> _mapFromDatabase(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'user_id': dbData['nama_anggota'], // Map nama_anggota to user_id
      'document_id': dbData['document_id'],
      'document_title': dbData['document_title'],
      'file_path': dbData['file_path'],
      'file_name': dbData['file_name'],
      'file_type': dbData['file_type'],
      'file_size': dbData['file_size'],
      'is_required': dbData['is_required'],
      'is_uploaded': (dbData['file_path'] != null && 
                     dbData['file_path'].toString().isNotEmpty) ? 1 : 0,
      'uploaded_at': dbData['uploaded_at'],
      'created_at': dbData['created_at'],
      'updated_at': dbData['updated_at'],
    };
  }

  /// Clear all dokumen data (for testing/reset)
  Future<void> clearAllDokumen() async {
    try {
      final db = await _database;
      await db.delete(tableName);
      print('DokumenRepository: Cleared all dokumen data');
    } catch (e) {
      print('DokumenRepository: Error clearing dokumen data: $e');
    }
  }
}