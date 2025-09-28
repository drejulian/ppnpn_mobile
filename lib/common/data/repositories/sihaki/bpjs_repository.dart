import '../../models/sihaki/bpjs_model.dart';
import '../../database/app_database_helper.dart';

class BPJSRepository {
  final AppDatabaseHelper _databaseHelper;

  BPJSRepository(this._databaseHelper);

  Future<int> addBPJS(BPJSModel bpjs) async {
    try {
      print('🗄️ Repository: Starting addBPJS...');
      
      final bpjsMap = bpjs.toMap();
      bpjsMap.remove('id'); // Remove ID for auto increment
      
      print('📋 Repository: Data to insert:');
      bpjsMap.forEach((key, value) {
        print('   $key: $value');
      });
      
      print('🔄 Repository: Calling database insertBPJS...');
      final result = await _databaseHelper.insertBPJS(bpjsMap);
      print('✅ Repository: Insert successful with ID: $result');
      
      return result;
    } catch (e) {
      print('❌ Repository Error: $e');
      throw Exception('Failed to add BPJS data: $e');
    }
  }

  Future<List<BPJSModel>> getAllBPJS([int? userId]) async {
    try {
      final bpjsList = await _databaseHelper.getAllBPJS(userId);
      
      return bpjsList.map((bpjs) => BPJSModel.fromMap(bpjs)).toList();
    } catch (e) {
      throw Exception('Failed to get BPJS list: $e');
    }
  }

  Future<BPJSModel?> getBPJSById(int id) async {
    try {
      final bpjs = await _databaseHelper.getBPJSById(id);
      
      if (bpjs != null) {
        return BPJSModel.fromMap(bpjs);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get BPJS data: $e');
    }
  }

  Future<bool> updateBPJS(BPJSModel bpjs) async {
    try {
      if (bpjs.id == null) {
        throw Exception('BPJS ID is required for update');
      }

      final bpjsMap = bpjs.toMap();
      bpjsMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateBPJS(bpjs.id!, bpjsMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update BPJS data: $e');
    }
  }

  Future<bool> deleteBPJS(int id) async {
    try {
      final result = await _databaseHelper.deleteBPJS(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete BPJS data: $e');
    }
  }

  Future<List<BPJSModel>> getBPJSByStatus(String status, [int? userId]) async {
    try {
      final allBPJS = await getAllBPJS(userId);
      
      return allBPJS.where((bpjs) => 
          bpjs.status.toLowerCase() == status.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get BPJS by status: $e');
    }
  }

  Future<List<BPJSModel>> getBPJSByHubunganKeluarga(String hubunganKeluarga, [int? userId]) async {
    try {
      final allBPJS = await getAllBPJS(userId);
      
      return allBPJS.where((bpjs) => 
          bpjs.hubunganKeluarga.toLowerCase().contains(hubunganKeluarga.toLowerCase())).toList();
    } catch (e) {
      throw Exception('Failed to get BPJS by hubungan keluarga: $e');
    }
  }

  Future<bool> updateStatusBPJS(int id, String statusBaru) async {
    try {
      final bpjs = await getBPJSById(id);
      if (bpjs == null) {
        throw Exception('BPJS data not found');
      }

      final updatedBPJS = bpjs.copyWith(
        status: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateBPJS(updatedBPJS);
    } catch (e) {
      throw Exception('Failed to update BPJS status: $e');
    }
  }

  Future<Map<String, dynamic>> getBPJSStatistics([int? userId]) async {
    try {
      final allBPJS = await getAllBPJS(userId);
      
      final aktif = allBPJS.where((item) => item.status == 'aktif').length;
      final nonAktif = allBPJS.where((item) => item.status == 'non-aktif').length;
      final pending = allBPJS.where((item) => item.status == 'pending').length;
      
      final hubunganKeluargaStats = <String, int>{};
      for (final bpjs in allBPJS) {
        hubunganKeluargaStats[bpjs.hubunganKeluarga] = 
            (hubunganKeluargaStats[bpjs.hubunganKeluarga] ?? 0) + 1;
      }
      
      return {
        'total_bpjs': allBPJS.length,
        'aktif': aktif,
        'non_aktif': nonAktif,
        'pending': pending,
        'hubungan_keluarga_stats': hubunganKeluargaStats,
      };
    } catch (e) {
      throw Exception('Failed to get BPJS statistics: $e');
    }
  }
}