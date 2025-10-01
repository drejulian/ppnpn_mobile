import '../../database/data_pribadi_database_helper.dart';
import '../../models/sihaki/data_pribadi_model.dart';

class DataPribadiRepository {
  final DataPribadiDatabaseHelper _databaseHelper = DataPribadiDatabaseHelper();

  // Save or update data pribadi
  Future<DataPribadiModel> saveDataPribadi({
    required String namaAnggota,
    required String handphone,
    required String email,
    required String telponRuangan,
    required String ruangKerja,
    required String bahasaAsing,
    required String alamatRumah,
    required String keteranganDomisili,
    required String namaAyahKandung,
    required String namaIbuKandung,
    required String noRekeningMitra,
    required String namaRekeningMitra,
  }) async {
    try {
      final now = DateTime.now();
      
      final dataPribadi = DataPribadiModel(
        namaAnggota: namaAnggota,
        handphone: handphone,
        email: email,
        telponRuangan: telponRuangan,
        ruangKerja: ruangKerja,
        bahasaAsing: bahasaAsing,
        alamatRumah: alamatRumah,
        keteranganDomisili: keteranganDomisili,
        namaAyahKandung: namaAyahKandung,
        namaIbuKandung: namaIbuKandung,
        noRekeningMitra: noRekeningMitra,
        namaRekeningMitra: namaRekeningMitra,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertOrUpdateDataPribadi(dataPribadi);
      
      return dataPribadi.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan data pribadi - $e');
    }
  }

  // Get data pribadi by nama anggota
  Future<DataPribadiModel?> getDataPribadiByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getDataPribadiByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data pribadi untuk $namaAnggota - $e');
    }
  }

  // Get all data pribadi
  Future<List<DataPribadiModel>> getAllDataPribadi() async {
    try {
      return await _databaseHelper.getAllDataPribadi();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data pribadi - $e');
    }
  }

  // Update data pribadi
  Future<DataPribadiModel> updateDataPribadi(DataPribadiModel dataPribadi) async {
    try {
      final updatedDataPribadi = dataPribadi.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.insertOrUpdateDataPribadi(updatedDataPribadi);
      return updatedDataPribadi;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data pribadi - $e');
    }
  }

  // Delete data pribadi by nama anggota
  Future<bool> deleteDataPribadiByNama(String namaAnggota) async {
    try {
      final result = await _databaseHelper.deleteDataPribadiByNama(namaAnggota);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data pribadi untuk $namaAnggota - $e');
    }
  }

  // Delete data pribadi by ID
  Future<bool> deleteDataPribadiById(int id) async {
    try {
      final result = await _databaseHelper.deleteDataPribadiById(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data pribadi dengan ID $id - $e');
    }
  }

  // Check if data pribadi exists for nama anggota
  Future<bool> dataPribadiExists(String namaAnggota) async {
    try {
      final dataPribadi = await getDataPribadiByNama(namaAnggota);
      return dataPribadi != null;
    } catch (e) {
      return false;
    }
  }

  // Get data pribadi count
  Future<int> getDataPribadiCount() async {
    try {
      return await _databaseHelper.getDataPribadiCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung data pribadi - $e');
    }
  }

  // Clear all data pribadi data
  Future<bool> clearAllDataPribadi() async {
    try {
      final result = await _databaseHelper.clearAllDataPribadi();
      return result >= 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data pribadi - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }

  // Get latest data pribadi (most recently updated)
  Future<DataPribadiModel?> getLatestDataPribadi() async {
    try {
      final allDataPribadi = await getAllDataPribadi();
      if (allDataPribadi.isNotEmpty) {
        return allDataPribadi.first; // Already ordered by updated_at DESC
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data pribadi terbaru - $e');
    }
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await _databaseHelper.forceRecreateDatabase();
  }
}