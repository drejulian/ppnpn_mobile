import '../../database/keanggotaan_database_helper.dart';
import '../../models/sihaki/keanggotaan_model.dart';

class KeanggotaanRepository {
  final KeanggotaanDatabaseHelper _databaseHelper = KeanggotaanDatabaseHelper();

  // Get all keanggotaan with optional filtering and sorting
  Future<List<KeanggotaanModel>> getAllKeanggotaan({
    String? orderBy = 'created_at DESC',
  }) async {
    try {
      return await _databaseHelper.getAllKeanggotaan(orderBy: orderBy);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data keanggotaan - $e');
    }
  }

  // Get keanggotaan by ID
  Future<KeanggotaanModel?> getKeanggotaanById(int id) async {
    try {
      return await _databaseHelper.getKeanggotaanById(id);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data keanggotaan dengan ID $id - $e');
    }
  }

  // Get keanggotaan by no anggota
  Future<KeanggotaanModel?> getKeanggotaanByNoAnggota(String noAnggota) async {
    try {
      return await _databaseHelper.getKeanggotaanByNoAnggota(noAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data keanggotaan dengan no anggota $noAnggota - $e');
    }
  }

  // Add new keanggotaan
  Future<KeanggotaanModel> addKeanggotaan({
    required String nama,
    required String noAnggota,
    required String fraksi,
    required String dapil,
    required String area,
    String? noRekening,
    required String namaRekening,
    String? userId,
  }) async {
    try {
      final now = DateTime.now();
      
      final newKeanggotaan = KeanggotaanModel(
        nama: nama,
        noAnggota: noAnggota,
        fraksi: fraksi,
        dapil: dapil,
        area: area,
        noRekening: noRekening,
        namaRekening: namaRekening,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertKeanggotaan(newKeanggotaan);
      
      return newKeanggotaan.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menambah data keanggotaan - $e');
    }
  }

  // Update existing keanggotaan
  Future<KeanggotaanModel> updateKeanggotaan(KeanggotaanModel keanggotaan) async {
    try {
      if (keanggotaan.id == null) {
        throw Exception('ID keanggotaan tidak boleh null untuk update');
      }

      await _databaseHelper.updateKeanggotaan(keanggotaan);
      
      // Return updated keanggotaan with current timestamp
      return keanggotaan.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data keanggotaan - $e');
    }
  }

  // Delete keanggotaan
  Future<bool> deleteKeanggotaan(int id) async {
    try {
      final rowsAffected = await _databaseHelper.deleteKeanggotaan(id);
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data keanggotaan - $e');
    }
  }

  // Search keanggotaan
  Future<List<KeanggotaanModel>> searchKeanggotaan(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllKeanggotaan();
      }
      return await _databaseHelper.searchKeanggotaan(query.trim());
    } catch (e) {
      throw Exception('Repository: Gagal mencari data keanggotaan - $e');
    }
  }

  // Get keanggotaan by user ID
  Future<List<KeanggotaanModel>> getKeanggotaanByUserId(String userId) async {
    try {
      return await _databaseHelper.getKeanggotaanByUserId(userId);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data keanggotaan untuk user $userId - $e');
    }
  }

  // Get keanggotaan count
  Future<int> getKeanggotaanCount() async {
    try {
      return await _databaseHelper.getKeanggotaanCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung jumlah keanggotaan - $e');
    }
  }

  // Clear all keanggotaan data
  Future<void> clearAllKeanggotaan() async {
    try {
      await _databaseHelper.clearAllKeanggotaan();
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data keanggotaan - $e');
    }
  }

  // Check if no anggota already exists
  Future<bool> isNoAnggotaExists(String noAnggota, {int? excludeId}) async {
    try {
      final existing = await _databaseHelper.getKeanggotaanByNoAnggota(noAnggota);
      if (existing == null) return false;
      
      // If excludeId is provided, don't consider it as duplicate (for updates)
      if (excludeId != null && existing.id == excludeId) {
        return false;
      }
      
      return true;
    } catch (e) {
      throw Exception('Repository: Gagal mengecek keberadaan no anggota - $e');
    }
  }

  // Get keanggotaan statistics
  Future<Map<String, dynamic>> getKeanggotaanStatistics() async {
    try {
      final allKeanggotaan = await getAllKeanggotaan();
      
      // Count by fraksi
      final fraksiCount = <String, int>{};
      final dapilCount = <String, int>{};
      
      for (final keanggotaan in allKeanggotaan) {
        fraksiCount[keanggotaan.fraksi] = (fraksiCount[keanggotaan.fraksi] ?? 0) + 1;
        dapilCount[keanggotaan.dapil] = (dapilCount[keanggotaan.dapil] ?? 0) + 1;
      }

      return {
        'total': allKeanggotaan.length,
        'fraksiCount': fraksiCount,
        'dapilCount': dapilCount,
        'withRekening': allKeanggotaan.where((k) => k.noRekening?.isNotEmpty == true).length,
        'withoutRekening': allKeanggotaan.where((k) => k.noRekening?.isEmpty != false).length,
      };
    } catch (e) {
      throw Exception('Repository: Gagal mengambil statistik keanggotaan - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    try {
      await _databaseHelper.close();
    } catch (e) {
      print('Repository: Error closing keanggotaan database - $e');
    }
  }
}