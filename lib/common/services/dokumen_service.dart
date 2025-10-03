import 'dart:io';
import '../data/repositories/dokumen_repository.dart';
import '../data/models/dokumen_model.dart';

class DokumenService {
  static final DokumenService _instance = DokumenService._internal();
  factory DokumenService() => _instance;
  DokumenService._internal();

  final DokumenRepository _repository = DokumenRepository();

  /// Get current user ID (in a real app, this would come from authentication)
  String getCurrentUserId() {
    // For now, using a default user ID
    // In a real app, this would come from authentication service
    return 'current_user';
  }

  /// Initialize documents for current user
  Future<void> initializeDocuments() async {
    try {
      final userId = getCurrentUserId();
      await _repository.initializeDefaultDocuments(userId);
    } catch (e) {
      print('DokumenService: Error initializing documents: $e');
      rethrow;
    }
  }

  /// Get all documents for current user
  Future<List<DokumenModel>> getAllDocuments() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getDokumenByUser(userId);
    } catch (e) {
      print('DokumenService: Error getting all documents: $e');
      rethrow;
    }
  }

  /// Get document by type
  Future<DokumenModel?> getDocumentByType(String documentType) async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getDokumenByUserAndType(userId, documentType);
    } catch (e) {
      print('DokumenService: Error getting document by type: $e');
      return null;
    }
  }

  /// Upload document
  Future<bool> uploadDocument(
    String documentType, 
    File file, {
    String? customTitle,
  }) async {
    try {
      final userId = getCurrentUserId();
      
      // Get file information
      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final fileSize = await file.length();
      final fileSizeString = _formatFileSize(fileSize);
      
      // Validate file type
      if (!_isValidFileType(fileExtension)) {
        throw Exception('Format file tidak didukung. Hanya JPG, JPEG, dan PDF yang diperbolehkan.');
      }
      
      // Validate file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar. Maksimal 5MB.');
      }

      // Check if document exists
      final existingDoc = await _repository.getDokumenByUserAndType(userId, documentType);
      
      if (existingDoc != null) {
        // Update existing document
        final updatedDoc = existingDoc.copyWith(
          documentTitle: customTitle ?? existingDoc.documentTitle,
          filePath: file.path,
          fileName: fileName,
          fileType: fileExtension.toUpperCase(),
          fileSize: fileSizeString,
          isUploaded: true,
          uploadedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final result = await _repository.insertOrUpdateDokumen(updatedDoc);
        return result > 0;
      } else {
        // Create new document
        final newDoc = DokumenModel(
          userId: userId,
          documentId: documentType,
          documentTitle: customTitle ?? _getDocumentTitleByType(documentType),
          filePath: file.path,
          fileName: fileName,
          fileType: fileExtension.toUpperCase(),
          fileSize: fileSizeString,
          isRequired: _isRequiredDocument(documentType),
          isUploaded: true,
          uploadedAt: DateTime.now(),
        );
        
        final result = await _repository.insertOrUpdateDokumen(newDoc);
        return result > 0;
      }
    } catch (e) {
      print('DokumenService: Error uploading document: $e');
      rethrow;
    }
  }

  /// Remove document upload
  Future<bool> removeDocumentUpload(String documentType) async {
    try {
      final userId = getCurrentUserId();
      return await _repository.markAsNotUploaded(userId, documentType);
    } catch (e) {
      print('DokumenService: Error removing document upload: $e');
      return false;
    }
  }

  /// Check if document is uploaded
  Future<bool> isDocumentUploaded(String documentType) async {
    try {
      final doc = await getDocumentByType(documentType);
      return doc?.isUploaded ?? false;
    } catch (e) {
      print('DokumenService: Error checking document upload status: $e');
      return false;
    }
  }

  /// Get uploaded documents count
  Future<int> getUploadedDocumentsCount() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getUploadedDokumenCount(userId);
    } catch (e) {
      print('DokumenService: Error getting uploaded documents count: $e');
      return 0;
    }
  }

  /// Get total documents count
  Future<int> getTotalDocumentsCount() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getDokumenCount(userId);
    } catch (e) {
      print('DokumenService: Error getting total documents count: $e');
      return 0;
    }
  }

  /// Get completion percentage
  Future<double> getCompletionPercentage() async {
    try {
      final total = await getTotalDocumentsCount();
      if (total == 0) return 0.0;
      
      final uploaded = await getUploadedDocumentsCount();
      return uploaded / total;
    } catch (e) {
      print('DokumenService: Error getting completion percentage: $e');
      return 0.0;
    }
  }

  /// Search documents
  Future<List<DokumenModel>> searchDocuments(String keyword) async {
    try {
      final userId = getCurrentUserId();
      return await _repository.searchDokumen(keyword, userId: userId);
    } catch (e) {
      print('DokumenService: Error searching documents: $e');
      return [];
    }
  }

  /// Get document file if exists
  File? getDocumentFile(String documentType) {
    // This would be implemented based on your file storage strategy
    // For now, returning null as files are handled differently in the UI
    return null;
  }

  /// Validate file type
  bool _isValidFileType(String extension) {
    const validTypes = ['jpg', 'jpeg', 'pdf'];
    return validTypes.contains(extension);
  }

  /// Format file size to human readable string
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get document title by type
  String _getDocumentTitleByType(String documentType) {
    switch (documentType) {
      case 'ktp':
        return 'KTP (ID Card)';
      case 'kk':
        return 'KK (Family Card)';
      case 'npwp':
        return 'NPWP (Tax ID)';
      case 'norek':
        return 'Norek (Account Number)';
      case 'skck':
        return 'SKCK (Police Clearance Certificate)';
      case 'ijazah':
        return 'Ijazah (Diploma)';
      case 'transkrip':
        return 'Transkrip Nilai (Academic Transcript)';
      case 'bebas_narkoba':
        return 'Surat Bebas Narkoba (Drug-Free Certificate)';
      case 'sehat':
        return 'Surat Sehat (Health Certificate)';
      case 'pengalaman_kerja':
        return 'Surat Pengalaman Kerja (TAA/SP) (Work Experience Letter)';
      case 'toefl':
        return 'TOEFL (TAA/SA)';
      case 'penyetaraan':
        return 'Surat Penyetaraan Ijazah/GAB (Ijazah luar negeri) (Diploma Equivalency Certificate/GAB (Overseas Diploma))';
      case 'bpjs_kesehatan':
        return 'BPJS Kesehatan (Health BPJS)';
      case 'bpjs_ketenagakerjaan':
        return 'BPJS Ketenagakerjaan (Employment BPJS)';
      case 'lainnya':
        return 'Lain-lain (Others)';
      case 'cv':
        return 'CV (Curriculum Vitae)';
      case 'surat_lamaran':
        return 'Surat Lamaran (Application Letter)';
      case 'foto':
        return 'Pas Foto (Passport Photo)';
      case 'sertifikat':
        return 'Sertifikat (Certificate)';
      default:
        return documentType.toUpperCase();
    }
  }

  /// Check if document type is required
  bool _isRequiredDocument(String documentType) {
    const requiredDocs = [
      'ktp', 'kk', 'npwp', 'norek', 'skck', 'ijazah', 'transkrip',
      'bebas_narkoba', 'sehat', 'bpjs_kesehatan', 'bpjs_ketenagakerjaan'
    ];
    return requiredDocs.contains(documentType);
  }
}