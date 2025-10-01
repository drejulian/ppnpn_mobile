import '../../models/sihaki/data_bpjs_model.dart';
import '../../database/app_database_helper.dart';

class DataBPJSRepository {
  final AppDatabaseHelper _databaseHelper;

  DataBPJSRepository(this._databaseHelper);

  Future<int> addDataBPJS(DataBPJSModel dataBpjs) async {
    try {
      final dataBpjsMap = dataBpjs.toMap();
      // Remove id dari map karena auto increment
      dataBpjsMap.remove('id');
      
      return await _databaseHelper.insertDataBPJS(dataBpjsMap);
    } catch (e) {
      throw Exception('Failed to add data BPJS: $e');
    }
  }

  Future<List<DataBPJSModel>> getAllDataBPJS([int? userId]) async {
    try {
      final dataBpjsList = await _databaseHelper.getAllDataBPJS(userId);
      
      return dataBpjsList.map((dataBpjs) => DataBPJSModel.fromMap(dataBpjs)).toList();
    } catch (e) {
      throw Exception('Failed to get data BPJS list: $e');
    }
  }

  Future<DataBPJSModel?> getDataBPJSById(int id) async {
    try {
      final dataBpjs = await _databaseHelper.getDataBPJSById(id);
      
      if (dataBpjs != null) {
        return DataBPJSModel.fromMap(dataBpjs);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get data BPJS: $e');
    }
  }

  Future<bool> updateDataBPJS(DataBPJSModel dataBpjs) async {
    try {
      if (dataBpjs.id == null) {
        throw Exception('Data BPJS ID is required for update');
      }

      final dataBpjsMap = dataBpjs.toMap();
      dataBpjsMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateDataBPJS(dataBpjs.id!, dataBpjsMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update data BPJS: $e');
    }
  }

  Future<bool> deleteDataBPJS(int id) async {
    try {
      final result = await _databaseHelper.deleteDataBPJS(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete data BPJS: $e');
    }
  }

  Future<List<DataBPJSModel>> getDataBPJSByJenis(String jenisBpjs, [int? userId]) async {
    try {
      final allDataBpjs = await getAllDataBPJS(userId);
      
      return allDataBpjs.where((dataBpjs) => 
          dataBpjs.jenisBpjs.toLowerCase() == jenisBpjs.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get data BPJS by jenis: $e');
    }
  }

  Future<List<DataBPJSModel>> getDataBPJSKesehatan([int? userId]) async {
    return await getDataBPJSByJenis('kesehatan', userId);
  }

  Future<List<DataBPJSModel>> getDataBPJSKetenagakerjaan([int? userId]) async {
    return await getDataBPJSByJenis('ketenagakerjaan', userId);
  }

  Future<List<DataBPJSModel>> searchDataBPJS(String keyword, [int? userId]) async {
    try {
      final allDataBpjs = await getAllDataBPJS(userId);
      final lowerKeyword = keyword.toLowerCase();
      
      return allDataBpjs.where((dataBpjs) {
        return dataBpjs.nomorBpjs.toLowerCase().contains(lowerKeyword) ||
               dataBpjs.namaPeserta.toLowerCase().contains(lowerKeyword) ||
               dataBpjs.statusKepesertaan.toLowerCase().contains(lowerKeyword) ||
               (dataBpjs.faskesTingkat1?.toLowerCase().contains(lowerKeyword) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search data BPJS: $e');
    }
  }

  Future<DataBPJSModel?> getDataBPJSByNomor(String nomorBpjs, [int? userId]) async {
    try {
      final allDataBpjs = await getAllDataBPJS(userId);
      
      final result = allDataBpjs.where((dataBpjs) => 
          dataBpjs.nomorBpjs == nomorBpjs).toList();
      
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception('Failed to get data BPJS by nomor: $e');
    }
  }

  Future<bool> updateStatusKepesertaan(int id, String statusBaru) async {
    try {
      final dataBpjs = await getDataBPJSById(id);
      if (dataBpjs == null) {
        throw Exception('Data BPJS not found');
      }

      final updatedDataBpjs = dataBpjs.copyWith(
        statusKepesertaan: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateDataBPJS(updatedDataBpjs);
    } catch (e) {
      throw Exception('Failed to update status kepesertaan: $e');
    }
  }

  Future<bool> updateKelasRawat(int id, String kelasRawatBaru) async {
    try {
      final dataBpjs = await getDataBPJSById(id);
      if (dataBpjs == null) {
        throw Exception('Data BPJS not found');
      }

      final updatedDataBpjs = dataBpjs.copyWith(
        kelasRawat: kelasRawatBaru,
        updatedAt: DateTime.now(),
      );

      return await updateDataBPJS(updatedDataBpjs);
    } catch (e) {
      throw Exception('Failed to update kelas rawat: $e');
    }
  }

  Future<bool> updateFaskesTingkat1(int id, String faskesBaru) async {
    try {
      final dataBpjs = await getDataBPJSById(id);
      if (dataBpjs == null) {
        throw Exception('Data BPJS not found');
      }

      final updatedDataBpjs = dataBpjs.copyWith(
        faskesTingkat1: faskesBaru,
        updatedAt: DateTime.now(),
      );

      return await updateDataBPJS(updatedDataBpjs);
    } catch (e) {
      throw Exception('Failed to update faskes tingkat 1: $e');
    }
  }

  Future<Map<String, int>> getDataBPJSStatistics([int? userId]) async {
    try {
      final allDataBpjs = await getAllDataBPJS(userId);
      
      final kesehatanCount = allDataBpjs.where((item) => item.jenisBpjs == 'kesehatan').length;
      final ketenagakerjaanCount = allDataBpjs.where((item) => item.jenisBpjs == 'ketenagakerjaan').length;
      final kelas1Count = allDataBpjs.where((item) => item.kelasRawat == '1').length;
      final kelas2Count = allDataBpjs.where((item) => item.kelasRawat == '2').length;
      final kelas3Count = allDataBpjs.where((item) => item.kelasRawat == '3').length;
      
      return {
        'total': allDataBpjs.length,
        'kesehatan': kesehatanCount,
        'ketenagakerjaan': ketenagakerjaanCount,
        'kelas_1': kelas1Count,
        'kelas_2': kelas2Count,
        'kelas_3': kelas3Count,
      };
    } catch (e) {
      throw Exception('Failed to get data BPJS statistics: $e');
    }
  }
}