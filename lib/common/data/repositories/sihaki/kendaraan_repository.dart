import '../../database/kendaraan_database_helper.dart';
import '../../models/sihaki/kendaraan_model.dart';

class KendaraanRepository {
  final KendaraanDatabaseHelper _databaseHelper = KendaraanDatabaseHelper();

  // Get all kendaraan with optional filtering and sorting
  Future<List<KendaraanModel>> getAllKendaraan({
    String? orderBy = 'updated_at DESC',
  }) async {
    try {
      return await _databaseHelper.getAllKendaraan(orderBy: orderBy);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data kendaraan - $e');
    }
  }

  // Get kendaraan by ID
  Future<KendaraanModel?> getKendaraanById(int id) async {
    try {
      return await _databaseHelper.getKendaraanById(id);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kendaraan dengan ID $id - $e');
    }
  }

  // Get kendaraan by nama anggota
  Future<KendaraanModel?> getKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      return await _databaseHelper.getKendaraanByNamaAnggota(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kendaraan untuk $namaAnggota - $e');
    }
  }

  // Add or update kendaraan
  Future<KendaraanModel> saveKendaraan({
    required String namaAnggota,
    required String nopolDinas,
    required String nopolPribadi,
  }) async {
    try {
      final now = DateTime.now();
      
      final kendaraan = KendaraanModel(
        namaAnggota: namaAnggota,
        nopolDinas: nopolDinas,
        nopolPribadi: nopolPribadi,
        createdAt: now,
        updatedAt: now,
      );
      
      final id = await _databaseHelper.insertKendaraan(kendaraan);
      
      // Return the saved kendaraan with the generated ID
      return kendaraan.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan data kendaraan - $e');
    }
  }

  // Update existing kendaraan
  Future<KendaraanModel> updateKendaraan(KendaraanModel kendaraan) async {
    try {
      final updatedKendaraan = kendaraan.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.updateKendaraan(updatedKendaraan);
      return updatedKendaraan;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data kendaraan - $e');
    }
  }

  // Delete kendaraan by ID
  Future<void> deleteKendaraan(int id) async {
    try {
      await _databaseHelper.deleteKendaraan(id);
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kendaraan - $e');
    }
  }

  // Delete kendaraan by nama anggota
  Future<void> deleteKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      await _databaseHelper.deleteKendaraanByNamaAnggota(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kendaraan untuk $namaAnggota - $e');
    }
  }

  // Get statistics
  Future<Map<String, int>> getKendaraanStatistics() async {
    try {
      final count = await _databaseHelper.getKendaraanCount();
      return {
        'total': count,
      };
    } catch (e) {
      throw Exception('Repository: Gagal mengambil statistik kendaraan - $e');
    }
  }

  // Clear all data
  Future<void> clearAllKendaraan() async {
    try {
      await _databaseHelper.clearAllKendaraan();
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data kendaraan - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }
}