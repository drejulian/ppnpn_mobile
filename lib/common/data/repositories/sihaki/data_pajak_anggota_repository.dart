import '../../models/sihaki/data_pajak_anggota_model.dart';
import '../../database/app_database_helper.dart';

class DataPajakAnggotaRepository {
  final AppDatabaseHelper _databaseHelper;

  DataPajakAnggotaRepository(this._databaseHelper);

  Future<int> addDataPajakAnggota(DataPajakAnggotaModel dataPajak) async {
    try {
      final dataPajakMap = dataPajak.toMap();
      dataPajakMap.remove('id');
      
      return await _databaseHelper.insertDataPajakAnggota(dataPajakMap);
    } catch (e) {
      throw Exception('Failed to add data pajak anggota: $e');
    }
  }

  Future<List<DataPajakAnggotaModel>> getAllDataPajakAnggota([int? userId]) async {
    try {
      final dataPajakList = await _databaseHelper.getAllDataPajakAnggota(userId);
      
      return dataPajakList.map((dataPajak) => DataPajakAnggotaModel.fromMap(dataPajak)).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak anggota list: $e');
    }
  }

  Future<DataPajakAnggotaModel?> getDataPajakAnggotaById(int id) async {
    try {
      final dataPajak = await _databaseHelper.getDataPajakAnggotaById(id);
      
      if (dataPajak != null) {
        return DataPajakAnggotaModel.fromMap(dataPajak);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get data pajak anggota: $e');
    }
  }

  Future<bool> updateDataPajakAnggota(DataPajakAnggotaModel dataPajak) async {
    try {
      if (dataPajak.id == null) {
        throw Exception('Data Pajak Anggota ID is required for update');
      }

      final dataPajakMap = dataPajak.toMap();
      dataPajakMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateDataPajakAnggota(dataPajak.id!, dataPajakMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update data pajak anggota: $e');
    }
  }

  Future<bool> deleteDataPajakAnggota(int id) async {
    try {
      final result = await _databaseHelper.deleteDataPajakAnggota(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete data pajak anggota: $e');
    }
  }

  Future<List<DataPajakAnggotaModel>> getDataPajakByTahun(int tahunPajak, [int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakAnggota(userId);
      
      return allDataPajak.where((dataPajak) => dataPajak.tahunPajak == tahunPajak).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak by tahun: $e');
    }
  }

  Future<List<DataPajakAnggotaModel>> getDataPajakByJenis(String jenisPajak, [int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakAnggota(userId);
      
      return allDataPajak.where((dataPajak) => 
          dataPajak.jenisPajak.toLowerCase() == jenisPajak.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak by jenis: $e');
    }
  }

  Future<List<DataPajakAnggotaModel>> getDataPajakByStatus(String statusBayar, [int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakAnggota(userId);
      
      return allDataPajak.where((dataPajak) => 
          dataPajak.statusBayar.toLowerCase() == statusBayar.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get data pajak by status: $e');
    }
  }

  Future<bool> updateStatusBayar(int id, String statusBaru) async {
    try {
      final dataPajak = await getDataPajakAnggotaById(id);
      if (dataPajak == null) {
        throw Exception('Data pajak not found');
      }

      final updatedDataPajak = dataPajak.copyWith(
        statusBayar: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateDataPajakAnggota(updatedDataPajak);
    } catch (e) {
      throw Exception('Failed to update status bayar: $e');
    }
  }

  Future<Map<String, dynamic>> getPajakStatistics([int? userId]) async {
    try {
      final allDataPajak = await getAllDataPajakAnggota(userId);
      
      final totalPajak = allDataPajak.fold<double>(0, (sum, item) => sum + item.jumlahPajak);
      final sudahBayar = allDataPajak.where((item) => item.statusBayar == 'sudah_bayar').length;
      final belumBayar = allDataPajak.where((item) => item.statusBayar == 'belum_bayar').length;
      final terlambat = allDataPajak.where((item) => item.statusBayar == 'terlambat').length;
      
      return {
        'total_data': allDataPajak.length,
        'total_pajak': totalPajak,
        'sudah_bayar': sudahBayar,
        'belum_bayar': belumBayar,
        'terlambat': terlambat,
      };
    } catch (e) {
      throw Exception('Failed to get pajak statistics: $e');
    }
  }
}