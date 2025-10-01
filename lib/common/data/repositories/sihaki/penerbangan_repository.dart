import '../../database/penerbangan_database_helper.dart';
import '../../models/sihaki/penerbangan_model.dart';

class PenerbanganRepository {
  final PenerbanganDatabaseHelper _databaseHelper = PenerbanganDatabaseHelper();

  // Save or update penerbangan data
  Future<PenerbanganModel> savePenerbangan({
    required String namaAnggota,
    required String nomorPassport,
    required String bandaraPreferensi,
    required String maskapaiPreferensi,
    required String kelasPenerbangan,
  }) async {
    try {
      final now = DateTime.now();
      
      final penerbangan = PenerbanganModel(
        namaAnggota: namaAnggota,
        nomorPassport: nomorPassport,
        bandaraPreferensi: bandaraPreferensi,
        maskapaiPreferensi: maskapaiPreferensi,
        kelasPenerbangan: kelasPenerbangan,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertOrUpdatePenerbangan(penerbangan);
      
      return penerbangan.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan data penerbangan - $e');
    }
  }

  // Get penerbangan by nama anggota
  Future<PenerbanganModel?> getPenerbanganByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getPenerbanganByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data penerbangan untuk $namaAnggota - $e');
    }
  }

  // Get all penerbangan
  Future<List<PenerbanganModel>> getAllPenerbangan() async {
    try {
      return await _databaseHelper.getAllPenerbangan();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data penerbangan - $e');
    }
  }

  // Update penerbangan
  Future<PenerbanganModel> updatePenerbangan(PenerbanganModel penerbangan) async {
    try {
      final updatedPenerbangan = penerbangan.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.insertOrUpdatePenerbangan(updatedPenerbangan);
      return updatedPenerbangan;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data penerbangan - $e');
    }
  }

  // Delete penerbangan by nama anggota
  Future<bool> deletePenerbanganByNama(String namaAnggota) async {
    try {
      final result = await _databaseHelper.deletePenerbanganByNama(namaAnggota);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data penerbangan untuk $namaAnggota - $e');
    }
  }

  // Delete penerbangan by ID
  Future<bool> deletePenerbanganById(int id) async {
    try {
      final result = await _databaseHelper.deletePenerbanganById(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data penerbangan dengan ID $id - $e');
    }
  }

  // Check if penerbangan exists for nama anggota
  Future<bool> penerbanganExists(String namaAnggota) async {
    try {
      final penerbangan = await getPenerbanganByNama(namaAnggota);
      return penerbangan != null;
    } catch (e) {
      return false;
    }
  }

  // Get penerbangan count
  Future<int> getPenerbanganCount() async {
    try {
      return await _databaseHelper.getPenerbanganCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung data penerbangan - $e');
    }
  }

  // Clear all penerbangan data
  Future<bool> clearAllPenerbangan() async {
    try {
      final result = await _databaseHelper.clearAllPenerbangan();
      return result >= 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data penerbangan - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }

  // Get latest penerbangan (most recently updated)
  Future<PenerbanganModel?> getLatestPenerbangan() async {
    try {
      final allPenerbangan = await getAllPenerbangan();
      if (allPenerbangan.isNotEmpty) {
        return allPenerbangan.first; // Already ordered by updated_at DESC
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data penerbangan terbaru - $e');
    }
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await _databaseHelper.forceRecreateDatabase();
  }
}