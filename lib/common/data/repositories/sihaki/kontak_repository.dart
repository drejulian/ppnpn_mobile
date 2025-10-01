import '../../database/kontak_database_helper.dart';
import '../../models/sihaki/kontak_model.dart';

class KontakRepository {
  final KontakDatabaseHelper _databaseHelper = KontakDatabaseHelper();

  // Save or update kontak data
  Future<KontakModel> saveKontak({
    required String namaAnggota,
    required String noKontak,
    required String namaKontak,
    required String hubunganKontak,
  }) async {
    try {
      final now = DateTime.now();
      
      final kontak = KontakModel(
        namaAnggota: namaAnggota,
        noKontak: noKontak,
        namaKontak: namaKontak,
        hubunganKontak: hubunganKontak,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertOrUpdateKontak(kontak);
      
      return kontak.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menyimpan data kontak - $e');
    }
  }

  // Get kontak by nama anggota
  Future<KontakModel?> getKontakByNama(String namaAnggota) async {
    try {
      return await _databaseHelper.getKontakByNama(namaAnggota);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kontak untuk $namaAnggota - $e');
    }
  }

  // Get all kontak
  Future<List<KontakModel>> getAllKontak() async {
    try {
      return await _databaseHelper.getAllKontak();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data kontak - $e');
    }
  }

  // Update kontak
  Future<KontakModel> updateKontak(KontakModel kontak) async {
    try {
      final updatedKontak = kontak.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.insertOrUpdateKontak(updatedKontak);
      return updatedKontak;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data kontak - $e');
    }
  }

  // Delete kontak by nama anggota
  Future<bool> deleteKontakByNama(String namaAnggota) async {
    try {
      final result = await _databaseHelper.deleteKontakByNama(namaAnggota);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kontak untuk $namaAnggota - $e');
    }
  }

  // Delete kontak by ID
  Future<bool> deleteKontakById(int id) async {
    try {
      final result = await _databaseHelper.deleteKontakById(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data kontak dengan ID $id - $e');
    }
  }

  // Check if kontak exists for nama anggota
  Future<bool> kontakExists(String namaAnggota) async {
    try {
      final kontak = await getKontakByNama(namaAnggota);
      return kontak != null;
    } catch (e) {
      return false;
    }
  }

  // Get kontak count
  Future<int> getKontakCount() async {
    try {
      return await _databaseHelper.getKontakCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung data kontak - $e');
    }
  }

  // Clear all kontak data
  Future<bool> clearAllKontak() async {
    try {
      final result = await _databaseHelper.clearAllKontak();
      return result >= 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data kontak - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
  }

  // Get latest kontak (most recently updated)
  Future<KontakModel?> getLatestKontak() async {
    try {
      final allKontak = await getAllKontak();
      if (allKontak.isNotEmpty) {
        return allKontak.first; // Already ordered by updated_at DESC
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data kontak terbaru - $e');
    }
  }

  // Force recreate database (for development/testing)
  Future<void> forceRecreateDatabase() async {
    await _databaseHelper.forceRecreateDatabase();
  }
}