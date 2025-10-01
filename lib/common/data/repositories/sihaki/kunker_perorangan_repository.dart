import '../../models/sihaki/kunker_perorangan_model.dart';
import '../../database/app_database_helper.dart';

class KunkerPeroranganRepository {
  final AppDatabaseHelper _databaseHelper;

  KunkerPeroranganRepository(this._databaseHelper);

  Future<int> addKunkerPerorangan(KunkerPeroranganModel kunker) async {
    try {
      final kunkerMap = kunker.toMap();
      kunkerMap.remove('id');
      
      return await _databaseHelper.insertKunkerPerorangan(kunkerMap);
    } catch (e) {
      throw Exception('Failed to add kunker perorangan: $e');
    }
  }

  Future<List<KunkerPeroranganModel>> getAllKunkerPerorangan([int? userId]) async {
    try {
      final kunkerList = await _databaseHelper.getAllKunkerPerorangan(userId);
      
      return kunkerList.map((kunker) => KunkerPeroranganModel.fromMap(kunker)).toList();
    } catch (e) {
      throw Exception('Failed to get kunker perorangan list: $e');
    }
  }

  Future<KunkerPeroranganModel?> getKunkerPeroranganById(int id) async {
    try {
      final kunker = await _databaseHelper.getKunkerPeroranganById(id);
      
      if (kunker != null) {
        return KunkerPeroranganModel.fromMap(kunker);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get kunker perorangan: $e');
    }
  }

  Future<bool> updateKunkerPerorangan(KunkerPeroranganModel kunker) async {
    try {
      if (kunker.id == null) {
        throw Exception('Kunker Perorangan ID is required for update');
      }

      final kunkerMap = kunker.toMap();
      kunkerMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateKunkerPerorangan(kunker.id!, kunkerMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update kunker perorangan: $e');
    }
  }

  Future<bool> deleteKunkerPerorangan(int id) async {
    try {
      final result = await _databaseHelper.deleteKunkerPerorangan(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete kunker perorangan: $e');
    }
  }

  Future<List<KunkerPeroranganModel>> getKunkerByStatus(String status, [int? userId]) async {
    try {
      final allKunker = await getAllKunkerPerorangan(userId);
      
      return allKunker.where((kunker) => 
          kunker.status.toLowerCase() == status.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get kunker by status: $e');
    }
  }

  Future<List<KunkerPeroranganModel>> getKunkerByNegara(String negara, [int? userId]) async {
    try {
      final allKunker = await getAllKunkerPerorangan(userId);
      
      return allKunker.where((kunker) => 
          kunker.negara.toLowerCase() == negara.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get kunker by negara: $e');
    }
  }

  Future<bool> updateStatusKunker(int id, String statusBaru) async {
    try {
      final kunker = await getKunkerPeroranganById(id);
      if (kunker == null) {
        throw Exception('Kunker not found');
      }

      final updatedKunker = kunker.copyWith(
        status: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateKunkerPerorangan(updatedKunker);
    } catch (e) {
      throw Exception('Failed to update status kunker: $e');
    }
  }

  Future<Map<String, dynamic>> getKunkerStatistics([int? userId]) async {
    try {
      final allKunker = await getAllKunkerPerorangan(userId);
      
      final diajukan = allKunker.where((item) => item.status == 'diajukan').length;
      final disetujui = allKunker.where((item) => item.status == 'disetujui').length;
      final ditolak = allKunker.where((item) => item.status == 'ditolak').length;
      final selesai = allKunker.where((item) => item.status == 'selesai').length;
      final totalAnggaran = allKunker.fold<double>(0, (sum, item) => sum + item.anggaran);
      
      return {
        'total_kunker': allKunker.length,
        'diajukan': diajukan,
        'disetujui': disetujui,
        'ditolak': ditolak,
        'selesai': selesai,
        'total_anggaran': totalAnggaran,
      };
    } catch (e) {
      throw Exception('Failed to get kunker statistics: $e');
    }
  }
}