import '../../models/sihaki/data_pajak_ppnpn_model.dart';
import '../../database/app_database_helper.dart';

class DataPajakPPNPNRepository {
  final AppDatabaseHelper _databaseHelper;

  DataPajakPPNPNRepository(this._databaseHelper);

  Future<int> addDataPajakPPNPN(DataPajakPPNPNModel dataPajak) async {
    try {
      final dataPajakMap = dataPajak.toMap();
      dataPajakMap.remove('id');
      
      return await _databaseHelper.insertDataPajakPPNPN(dataPajakMap);
    } catch (e) {
      throw Exception('Failed to add data pajak PPNPN: $e');
    }
  }

  Future<List<DataPajakPPNPNModel>> getAllDataPajakPPNPN([int? userId]) async {
    try {
      final dataPajakList = await _databaseHelper.getAllDataPajakPPNPN(userId);
      
      return dataPajakList.map((dataPajak) => DataPajakPPNPNModel.fromMap(dataPajak)).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak PPNPN list: $e');
    }
  }

  Future<DataPajakPPNPNModel?> getDataPajakPPNPNById(int id) async {
    try {
      final dataPajak = await _databaseHelper.getDataPajakPPNPNById(id);
      
      if (dataPajak != null) {
        return DataPajakPPNPNModel.fromMap(dataPajak);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get data pajak PPNPN: $e');
    }
  }

  Future<bool> updateDataPajakPPNPN(DataPajakPPNPNModel dataPajak) async {
    try {
      if (dataPajak.id == null) {
        throw Exception('Data Pajak PPNPN ID is required for update');
      }

      final dataPajakMap = dataPajak.toMap();
      dataPajakMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateDataPajakPPNPN(dataPajak.id!, dataPajakMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update data pajak PPNPN: $e');
    }
  }

  Future<bool> deleteDataPajakPPNPN(int id) async {
    try {
      final result = await _databaseHelper.deleteDataPajakPPNPN(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete data pajak PPNPN: $e');
    }
  }

  Future<List<DataPajakPPNPNModel>> getDataPajakByTahun(int tahunPajak, [int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakPPNPN(userId);
      
      return allDataPajak.where((dataPajak) => dataPajak.tahunPajak == tahunPajak).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak by tahun: $e');
    }
  }

  Future<List<DataPajakPPNPNModel>> getDataPajakByBulan(int bulanPajak, int tahunPajak, [int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakPPNPN(userId);
      
      return allDataPajak.where((dataPajak) => 
          dataPajak.bulanPajak == bulanPajak && dataPajak.tahunPajak == tahunPajak).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak by bulan: $e');
    }
  }

  Future<Map<String, dynamic>> getPajakPPNPNStatistics([int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakPPNPN(userId);
      
      final totalGajiPokok = allDataPajak.fold<double>(0, (sum, item) => sum + item.gajiPokok);
      final totalTunjangan = allDataPajak.fold<double>(0, (sum, item) => sum + item.tunjangan);
      final totalPotonganPajak = allDataPajak.fold<double>(0, (sum, item) => sum + item.potonganPajak);
      
      return {
        'total_data': allDataPajak.length,
        'total_gaji_pokok': totalGajiPokok,
        'total_tunjangan': totalTunjangan,
        'total_potongan_pajak': totalPotonganPajak,
      };
    } catch (e) {
      throw Exception('Failed to get pajak PPNPN statistics: $e');
    }
  }
}