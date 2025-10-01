import 'dart:io';
import '../../database/tata_naskah_database_helper.dart';
import '../../models/sihaki/tata_naskah_model.dart';

class TataNaskahRepository {
  final TataNaskahDatabaseHelper _databaseHelper = TataNaskahDatabaseHelper();

  // Save or update tata naskah document
  Future<TataNaskahModel> saveTataNaskahDocument({
    required String namaAnggota,
    required String documentId,
    required String documentTitle,
    required File file,
    required bool isRequired,
    bool isUploaded = false,
    String? uploadedAt,
  }) async {
    try {
      final now = DateTime.now();
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toUpperCase();
      final fileSizeInBytes = await file.length();
      final fileSize = fileSizeInBytes < 1024 * 1024
          ? '${(fileSizeInBytes / 1024).toStringAsFixed(2)} KB'
          : '${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      
      final tataNaskah = TataNaskahModel(
        namaAnggota: namaAnggota,
        documentId: documentId,
        documentTitle: documentTitle,
        fileName: fileName,
        filePath: file.path,
        fileType: fileExtension,
        fileSize: fileSize,
        isRequired: isRequired,
        isUploaded: isUploaded,
        uploadedAt: uploadedAt,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertOrUpdateTataNaskah(tataNaskah);
      
      return tataNaskah.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan dokumen tata naskah - $e');
    }
  }

  // Update document upload status
  Future<TataNaskahModel> updateUploadStatus({
    required String namaAnggota,
    required String documentId,
    required bool isUploaded,
    String? uploadedAt,
  }) async {
    try {
      final existingDocument = await _databaseHelper.getTataNaskahByNamaAndDocId(namaAnggota, documentId);
      
      if (existingDocument == null) {
        throw Exception('Document not found for update');
      }

      final updatedDocument = existingDocument.copyWith(
        isUploaded: isUploaded,
        uploadedAt: uploadedAt,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.insertOrUpdateTataNaskah(updatedDocument);
      return updatedDocument;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate status upload dokumen - $e');
    }
  }

  // Get tata naskah document by nama anggota and document ID
  Future<TataNaskahModel?> getTataNaskahByNamaAndDocId(String namaAnggota, String documentId) async {
    try {
      return await _databaseHelper.getTataNaskahByNamaAndDocId(namaAnggota, documentId);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil dokumen tata naskah untuk $namaAnggota - $documentId - $e');
    }
  }

  // Get all tata naskah documents by nama anggota
  Future<List<TataNaskahModel>> getTataNaskahByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getTataNaskahByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil dokumen tata naskah untuk $namaAnggota - $e');
    }
  }

  // Get all tata naskah documents
  Future<List<TataNaskahModel>> getAllTataNaskah() async {
    try {
      return await _databaseHelper.getAllTataNaskah();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua dokumen tata naskah - $e');
    }
  }

  // Delete tata naskah document by nama anggota and document ID
  Future<bool> deleteTataNaskahByNamaAndDocId(String namaAnggota, String documentId) async {
    try {
      final result = await _databaseHelper.deleteTataNaskahByNamaAndDocId(namaAnggota, documentId);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus dokumen tata naskah untuk $namaAnggota - $documentId - $e');
    }
  }

  // Delete all documents by nama anggota
  Future<bool> deleteTataNaskahByNama(String namaAnggota) async {
    try {
      final result = await _databaseHelper.deleteTataNaskahByNama(namaAnggota);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus dokumen tata naskah untuk $namaAnggota - $e');
    }
  }

  // Delete tata naskah document by ID
  Future<bool> deleteTataNaskahById(int id) async {
    try {
      final result = await _databaseHelper.deleteTataNaskahById(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus dokumen tata naskah dengan ID $id - $e');
    }
  }

  // Check if document exists for nama anggota and document ID
  Future<bool> documentExists(String namaAnggota, String documentId) async {
    try {
      final document = await getTataNaskahByNamaAndDocId(namaAnggota, documentId);
      return document != null;
    } catch (e) {
      return false;
    }
  }

  // Get tata naskah document count
  Future<int> getTataNaskahCount() async {
    try {
      return await _databaseHelper.getTataNaskahCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung dokumen tata naskah - $e');
    }
  }

  // Get document count by nama anggota
  Future<int> getTataNaskahCountByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getTataNaskahCountByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal menghitung dokumen tata naskah untuk $namaAnggota - $e');
    }
  }

  // Get uploaded documents count by nama anggota
  Future<int> getUploadedCountByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getUploadedCountByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal menghitung dokumen terupload untuk $namaAnggota - $e');
    }
  }

  // Check if all required documents are uploaded for nama anggota
  Future<bool> areAllRequiredDocumentsUploaded(String namaAnggota, List<String> requiredDocumentIds) async {
    try {
      final documents = await getTataNaskahByNama(namaAnggota);
      
      for (final requiredDocId in requiredDocumentIds) {
        final doc = documents.firstWhere(
          (document) => document.documentId == requiredDocId,
          orElse: () => TataNaskahModel(
            namaAnggota: namaAnggota,
            documentId: requiredDocId,
            documentTitle: '',
            fileName: '',
            filePath: '',
            fileType: '',
            fileSize: '',
            isRequired: true,
            isUploaded: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (!doc.isUploaded) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all tata naskah data
  Future<bool> clearAllTataNaskah() async {
    try {
      final result = await _databaseHelper.clearAllTataNaskah();
      return result >= 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua dokumen tata naskah - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }

  // Get latest documents (most recently updated) by nama anggota
  Future<List<TataNaskahModel>> getLatestTataNaskahByNama(String namaAnggota) async {
    try {
      return await getTataNaskahByNama(namaAnggota); // Already ordered by updated_at DESC
    } catch (e) {
      throw Exception('Repository: Gagal mengambil dokumen tata naskah terbaru untuk $namaAnggota - $e');
    }
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await _databaseHelper.forceRecreateDatabase();
  }
}