import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/models/sihaki/dokumen_anggota_model.dart';
import '../../../../../common/data/repositories/dokumen_anggota_repository.dart';

// Repository Provider
final dokumenAnggotaRepositoryProvider = Provider<DokumenAnggotaRepository>((ref) {
  return DokumenAnggotaRepository();
});

// State untuk daftar dokumen anggota
final dokumenAnggotaListProvider = StateNotifierProvider<DokumenAnggotaListNotifier, AsyncValue<List<DokumenAnggotaModel>>>((ref) {
  return DokumenAnggotaListNotifier(ref.watch(dokumenAnggotaRepositoryProvider));
});

class DokumenAnggotaListNotifier extends StateNotifier<AsyncValue<List<DokumenAnggotaModel>>> {
  final DokumenAnggotaRepository _repository;

  DokumenAnggotaListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDokumenAnggota();
  }

  Future<void> loadDokumenAnggota() async {
    try {
      state = const AsyncValue.loading();
      final dokumenList = await _repository.getAllDokumenAnggota();
      state = AsyncValue.data(dokumenList);
      print('✅ Loaded ${dokumenList.length} dokumen anggota'); // Debug log
    } catch (e, stackTrace) {
      print('❌ Error loading dokumen anggota: $e'); // Debug log
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadDokumenAnggotaByNama(String namaAnggota) async {
    try {
      state = const AsyncValue.loading();
      final dokumenList = await _repository.getDokumenAnggotaByNama(namaAnggota);
      state = AsyncValue.data(dokumenList);
      print('✅ Loaded ${dokumenList.length} dokumen for ${namaAnggota}'); // Debug log
    } catch (e, stackTrace) {
      print('❌ Error loading dokumen anggota by nama: $e'); // Debug log
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> addDokumenAnggota({
    required String namaAnggota,
    required String documentId,
    required String documentTitle,
    required File file,
    required String fileType,
    required String fileSize,
    required bool isRequired,
  }) async {
    print('➕ Adding new dokumen anggota: $documentTitle'); // Debug log
    print('📊 Provider received data:'); // Debug log
    print('   - Nama Anggota: $namaAnggota');
    print('   - Document ID: $documentId');
    print('   - Document Title: $documentTitle');
    print('   - File Path: ${file.path}');
    print('   - File Type: $fileType');
    print('   - File Size: $fileSize');
    print('   - Is Required: $isRequired');

    try {
      print('🗄️ Calling repository.addDokumenAnggota...'); // Debug log

      final now = DateTime.now().toIso8601String();
      final dokumen = DokumenAnggotaModel(
        namaAnggota: namaAnggota,
        documentId: documentId,
        documentTitle: documentTitle,
        filePath: file.path,
        fileName: file.path.split('/').last,
        fileType: fileType,
        fileSize: fileSize,
        isRequired: isRequired,
        uploadedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _repository.addDokumenAnggota(dokumen);
      print('✅ Dokumen anggota added with ID: $id'); // Debug log

      // Reload the list
      await loadDokumenAnggota();
      
      return true;
    } catch (e) {
      print('❌ Error adding dokumen anggota: $e'); // Debug log
      return false;
    }
  }

  Future<bool> updateDokumenAnggota({
    required int id,
    required String namaAnggota,
    required String documentId,
    required String documentTitle,
    required File file,
    required String fileType,
    required String fileSize,
    required bool isRequired,
    required String createdAt,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final dokumen = DokumenAnggotaModel(
        id: id,
        namaAnggota: namaAnggota,
        documentId: documentId,
        documentTitle: documentTitle,
        filePath: file.path,
        fileName: file.path.split('/').last,
        fileType: fileType,
        fileSize: fileSize,
        isRequired: isRequired,
        uploadedAt: now,
        createdAt: createdAt,
        updatedAt: now,
      );

      await _repository.updateDokumenAnggota(dokumen);
      
      // Reload the list
      await loadDokumenAnggota();
      
      return true;
    } catch (e) {
      print('❌ Error updating dokumen anggota: $e'); // Debug log
      return false;
    }
  }

  Future<bool> deleteDokumenAnggota(int id) async {
    try {
      await _repository.deleteDokumenAnggota(id);
      
      // Reload the list
      await loadDokumenAnggota();
      
      return true;
    } catch (e) {
      print('❌ Error deleting dokumen anggota: $e'); // Debug log
      return false;
    }
  }

  Future<bool> deleteDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    try {
      await _repository.deleteDokumenAnggotaByDocumentId(namaAnggota, documentId);
      
      // Reload the list
      await loadDokumenAnggota();
      
      return true;
    } catch (e) {
      print('❌ Error deleting dokumen anggota by document ID: $e'); // Debug log
      return false;
    }
  }

  Future<DokumenAnggotaModel?> getDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    try {
      return await _repository.getDokumenAnggotaByDocumentId(namaAnggota, documentId);
    } catch (e) {
      print('❌ Error getting dokumen anggota by document ID: $e'); // Debug log
      return null;
    }
  }
}

// Provider untuk search
final dokumenAnggotaSearchProvider = StateNotifierProvider<DokumenAnggotaSearchNotifier, AsyncValue<List<DokumenAnggotaModel>>>((ref) {
  return DokumenAnggotaSearchNotifier(ref.watch(dokumenAnggotaRepositoryProvider));
});

class DokumenAnggotaSearchNotifier extends StateNotifier<AsyncValue<List<DokumenAnggotaModel>>> {
  final DokumenAnggotaRepository _repository;

  DokumenAnggotaSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> searchDokumenAnggota(String keyword) async {
    if (keyword.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _repository.searchDokumenAnggota(keyword);
      state = AsyncValue.data(results);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}