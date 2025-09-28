import '../../models/sihaki/kegiatan_rumah_aspirasi_model.dart';
import '../../database/app_database_helper.dart';

class KegiatanRumahAspirasiRepository {
  final AppDatabaseHelper _databaseHelper;

  KegiatanRumahAspirasiRepository(this._databaseHelper);

  Future<int> addKegiatanRumahAspirasi(KegiatanRumahAspirasiModel kegiatan) async {
    try {
      final kegiatanMap = kegiatan.toMap();
      kegiatanMap.remove('id');
      
      return await _databaseHelper.insertKegiatanRumahAspirasi(kegiatanMap);
    } catch (e) {
      throw Exception('Failed to add kegiatan rumah aspirasi: $e');
    }
  }

  Future<List<KegiatanRumahAspirasiModel>> getAllKegiatanRumahAspirasi([int? userId]) async {
    try {
      final kegiatanList = await _databaseHelper.getAllKegiatanRumahAspirasi(userId);
      
      return kegiatanList.map((kegiatan) => KegiatanRumahAspirasiModel.fromMap(kegiatan)).toList();
    } catch (e) {
      throw Exception('Failed to get kegiatan rumah aspirasi list: $e');
    }
  }

  Future<KegiatanRumahAspirasiModel?> getKegiatanRumahAspirasiById(int id) async {
    try {
      final kegiatan = await _databaseHelper.getKegiatanRumahAspirasiById(id);
      
      if (kegiatan != null) {
        return KegiatanRumahAspirasiModel.fromMap(kegiatan);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get kegiatan rumah aspirasi: $e');
    }
  }

  Future<bool> updateKegiatanRumahAspirasi(KegiatanRumahAspirasiModel kegiatan) async {
    try {
      if (kegiatan.id == null) {
        throw Exception('Kegiatan Rumah Aspirasi ID is required for update');
      }

      final kegiatanMap = kegiatan.toMap();
      kegiatanMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateKegiatanRumahAspirasi(kegiatan.id!, kegiatanMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update kegiatan rumah aspirasi: $e');
    }
  }

  Future<bool> deleteKegiatanRumahAspirasi(int id) async {
    try {
      final result = await _databaseHelper.deleteKegiatanRumahAspirasi(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete kegiatan rumah aspirasi: $e');
    }
  }

  Future<List<KegiatanRumahAspirasiModel>> getKegiatanByStatus(String status, [int? userId]) async {
    try {
      final allKegiatan = await getAllKegiatanRumahAspirasi(userId);
      
      return allKegiatan.where((kegiatan) => 
          kegiatan.status.toLowerCase() == status.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get kegiatan by status: $e');
    }
  }

  Future<List<KegiatanRumahAspirasiModel>> getKegiatanByTanggal(String tanggal, [int? userId]) async {
    try {
      final allKegiatan = await getAllKegiatanRumahAspirasi(userId);
      
      return allKegiatan.where((kegiatan) => kegiatan.tanggalKegiatan == tanggal).toList();
    } catch (e) {
      throw Exception('Failed to get kegiatan by tanggal: $e');
    }
  }

  Future<bool> updateStatusKegiatan(int id, String statusBaru) async {
    try {
      final kegiatan = await getKegiatanRumahAspirasiById(id);
      if (kegiatan == null) {
        throw Exception('Kegiatan not found');
      }

      final updatedKegiatan = kegiatan.copyWith(
        status: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateKegiatanRumahAspirasi(updatedKegiatan);
    } catch (e) {
      throw Exception('Failed to update status kegiatan: $e');
    }
  }

  Future<Map<String, dynamic>> getKegiatanStatistics([int? userId]) async {
    try {
      final allKegiatan = await getAllKegiatanRumahAspirasi(userId);
      
      final direncanakan = allKegiatan.where((item) => item.status == 'direncanakan').length;
      final berlangsung = allKegiatan.where((item) => item.status == 'berlangsung').length;
      final selesai = allKegiatan.where((item) => item.status == 'selesai').length;
      final dibatalkan = allKegiatan.where((item) => item.status == 'dibatalkan').length;
      final totalPeserta = allKegiatan.fold<int>(0, (sum, item) => sum + item.jumlahPeserta);
      
      return {
        'total_kegiatan': allKegiatan.length,
        'direncanakan': direncanakan,
        'berlangsung': berlangsung,
        'selesai': selesai,
        'dibatalkan': dibatalkan,
        'total_peserta': totalPeserta,
      };
    } catch (e) {
      throw Exception('Failed to get kegiatan statistics: $e');
    }
  }
}