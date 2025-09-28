import '../database/app_database_helper.dart';
import '../models/sihaki/dokumen_anggota_model.dart';

class DokumenAnggotaRepository {
  final AppDatabaseHelper _databaseHelper = AppDatabaseHelper();

  Future<int> addDokumenAnggota(DokumenAnggotaModel dokumen) async {
    print('🗄️ Repository: Starting addDokumenAnggota...'); // Debug log
    print('📋 Repository: Data to insert:'); // Debug log
    print('   nama_anggota: ${dokumen.namaAnggota}');
    print('   document_id: ${dokumen.documentId}');
    print('   document_title: ${dokumen.documentTitle}');
    print('   file_path: ${dokumen.filePath}');
    print('   file_name: ${dokumen.fileName}');
    print('   file_type: ${dokumen.fileType}');
    print('   file_size: ${dokumen.fileSize}');
    print('   is_required: ${dokumen.isRequired}');
    print('   uploaded_at: ${dokumen.uploadedAt}');
    print('   created_at: ${dokumen.createdAt}');
    print('   updated_at: ${dokumen.updatedAt}');

    try {
      print('🔄 Repository: Calling database insertDokumenAnggota...'); // Debug log
      final id = await _databaseHelper.insertDokumenAnggota(dokumen.toMap());
      print('✅ Repository: Dokumen anggota added successfully with ID: $id'); // Debug log
      return id;
    } catch (e) {
      print('❌ Repository Error: $e'); // Debug log
      throw Exception('Failed to add dokumen anggota: $e');
    }
  }

  Future<List<DokumenAnggotaModel>> getDokumenAnggotaByNama(String namaAnggota) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseHelper.getDokumenAnggotaByNama(namaAnggota);
      return List.generate(maps.length, (i) {
        return DokumenAnggotaModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get dokumen anggota: $e');
    }
  }

  Future<List<DokumenAnggotaModel>> getAllDokumenAnggota() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseHelper.getAllDokumenAnggota();
      return List.generate(maps.length, (i) {
        return DokumenAnggotaModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get all dokumen anggota: $e');
    }
  }

  Future<DokumenAnggotaModel?> getDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    try {
      final map = await _databaseHelper.getDokumenAnggotaByDocumentId(namaAnggota, documentId);
      if (map != null) {
        return DokumenAnggotaModel.fromMap(map);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get dokumen anggota by document ID: $e');
    }
  }

  Future<int> updateDokumenAnggota(DokumenAnggotaModel dokumen) async {
    try {
      return await _databaseHelper.updateDokumenAnggota(dokumen.id!, dokumen.toMap());
    } catch (e) {
      throw Exception('Failed to update dokumen anggota: $e');
    }
  }

  Future<int> deleteDokumenAnggota(int id) async {
    try {
      return await _databaseHelper.deleteDokumenAnggota(id);
    } catch (e) {
      throw Exception('Failed to delete dokumen anggota: $e');
    }
  }

  Future<int> deleteDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    try {
      return await _databaseHelper.deleteDokumenAnggotaByDocumentId(namaAnggota, documentId);
    } catch (e) {
      throw Exception('Failed to delete dokumen anggota by document ID: $e');
    }
  }

  Future<List<DokumenAnggotaModel>> searchDokumenAnggota(String keyword) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseHelper.searchDokumenAnggota(keyword);
      return List.generate(maps.length, (i) {
        return DokumenAnggotaModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search dokumen anggota: $e');
    }
  }
}