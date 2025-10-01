import '../../database/kesehatan_database_helper.dart';
import '../../models/sihaki/kesehatan_model.dart';

class KesehatanRepository {
  final KesehatanDatabaseHelper _databaseHelper = KesehatanDatabaseHelper();

  // Save or update kesehatan data
  Future<KesehatanModel> saveKesehatan({
    required String namaAnggota,
    required String beratBadan,
    required String tinggiBadan,
    required String golonganDarah,
    String? riwayatPenyakit,
    String? alergi,
  }) async {
    try {
      final now = DateTime.now();
      
      final kesehatan = KesehatanModel(
        namaAnggota: namaAnggota,
        beratBadan: beratBadan,
        tinggiBadan: tinggiBadan,
        golonganDarah: golonganDarah,
        riwayatPenyakit: riwayatPenyakit ?? '',
        alergi: alergi ?? '',
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertOrUpdateKesehatan(kesehatan);
      
      return kesehatan.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan data kesehatan - $e');
    }
  }

  // Get kesehatan by nama anggota
  Future<KesehatanModel?> getKesehatanByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getKesehatanByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kesehatan untuk $namaAnggota - $e');
    }
  }

  // Get all kesehatan
  Future<List<KesehatanModel>> getAllKesehatan() async {
    try {
      return await _databaseHelper.getAllKesehatan();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data kesehatan - $e');
    }
  }

  // Update kesehatan
  Future<KesehatanModel> updateKesehatan(KesehatanModel kesehatan) async {
    try {
      final updatedKesehatan = kesehatan.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.insertOrUpdateKesehatan(updatedKesehatan);
      return updatedKesehatan;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data kesehatan - $e');
    }
  }

  // Delete kesehatan by nama anggota
  Future<bool> deleteKesehatanByNama(String namaAnggota) async {
    try {
      final result = await _databaseHelper.deleteKesehatanByNama(namaAnggota);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kesehatan untuk $namaAnggota - $e');
    }
  }

  // Delete kesehatan by ID
  Future<bool> deleteKesehatanById(int id) async {
    try {
      final result = await _databaseHelper.deleteKesehatanById(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kesehatan dengan ID $id - $e');
    }
  }

  // Check if kesehatan exists for nama anggota
  Future<bool> kesehatanExists(String namaAnggota) async {
    try {
      final kesehatan = await getKesehatanByNama(namaAnggota);
      return kesehatan != null;
    } catch (e) {
      return false;
    }
  }

  // Get kesehatan count
  Future<int> getKesehatanCount() async {
    try {
      return await _databaseHelper.getKesehatanCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung data kesehatan - $e');
    }
  }

  // Clear all kesehatan data
  Future<bool> clearAllKesehatan() async {
    try {
      final result = await _databaseHelper.clearAllKesehatan();
      return result >= 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data kesehatan - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }

  // Get latest kesehatan (most recently updated)
  Future<KesehatanModel?> getLatestKesehatan() async {
    try {
      final allKesehatan = await getAllKesehatan();
      if (allKesehatan.isNotEmpty) {
        return allKesehatan.first; // Already ordered by updated_at DESC
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kesehatan terbaru - $e');
    }
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await _databaseHelper.forceRecreateDatabase();
  }
}