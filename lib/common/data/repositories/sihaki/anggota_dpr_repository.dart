import '../../models/sihaki/anggota_dpr_model.dart';
import '../../database/app_database_helper.dart';

class AnggotaDPRRepository {
  final AppDatabaseHelper _databaseHelper;

  AnggotaDPRRepository(this._databaseHelper);

  Future<int> addAnggotaDPR(AnggotaDPRModel anggota) async {
    try {
      final anggotaMap = anggota.toMap();
      anggotaMap.remove('id');
      
      return await _databaseHelper.insertAnggotaDPR(anggotaMap);
    } catch (e) {
      throw Exception('Failed to add anggota DPR: $e');
    }
  }

  Future<List<AnggotaDPRModel>> getAllAnggotaDPR() async {
    try {
      final anggotaList = await _databaseHelper.getAllAnggotaDPR();
      
      return anggotaList.map((anggota) => AnggotaDPRModel.fromMap(anggota)).toList();
    } catch (e) {
      throw Exception('Failed to get anggota DPR list: $e');
    }
  }

  Future<AnggotaDPRModel?> getAnggotaDPRById(int id) async {
    try {
      final anggota = await _databaseHelper.getAnggotaDPRById(id);
      
      if (anggota != null) {
        return AnggotaDPRModel.fromMap(anggota);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get anggota DPR: $e');
    }
  }

  Future<AnggotaDPRModel?> getAnggotaDPRByNIP(String nip) async {
    try {
      final anggota = await _databaseHelper.getAnggotaDPRByNIP(nip);
      
      if (anggota != null) {
        return AnggotaDPRModel.fromMap(anggota);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get anggota DPR by NIP: $e');
    }
  }

  Future<bool> updateAnggotaDPR(AnggotaDPRModel anggota) async {
    try {
      if (anggota.id == null) {
        throw Exception('Anggota DPR ID is required for update');
      }

      final anggotaMap = anggota.toMap();
      anggotaMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateAnggotaDPR(anggota.id!, anggotaMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update anggota DPR: $e');
    }
  }

  Future<bool> deleteAnggotaDPR(int id) async {
    try {
      final result = await _databaseHelper.deleteAnggotaDPR(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete anggota DPR: $e');
    }
  }

  Future<List<AnggotaDPRModel>> searchAnggotaDPR(String keyword) async {
    try {
      final anggotaList = await _databaseHelper.searchAnggotaDPR(keyword);
      
      return anggotaList.map((anggota) => AnggotaDPRModel.fromMap(anggota)).toList();
    } catch (e) {
      throw Exception('Failed to search anggota DPR: $e');
    }
  }

  Future<List<AnggotaDPRModel>> getAnggotaDPRByPartai(String partai) async {
    try {
      final anggotaList = await _databaseHelper.getAnggotaDPRByPartai(partai);
      
      return anggotaList.map((anggota) => AnggotaDPRModel.fromMap(anggota)).toList();
    } catch (e) {
      throw Exception('Failed to get anggota DPR by partai: $e');
    }
  }

  Future<List<AnggotaDPRModel>> getAnggotaDPRByDapil(String dapil) async {
    try {
      final anggotaList = await _databaseHelper.getAnggotaDPRByDapil(dapil);
      
      return anggotaList.map((anggota) => AnggotaDPRModel.fromMap(anggota)).toList();
    } catch (e) {
      throw Exception('Failed to get anggota DPR by dapil: $e');
    }
  }

  Future<List<AnggotaDPRModel>> getAnggotaAktif() async {
    try {
      final allAnggota = await getAllAnggotaDPR();
      
      return allAnggota.where((anggota) => anggota.status == 'aktif').toList();
    } catch (e) {
      throw Exception('Failed to get anggota aktif: $e');
    }
  }

  Future<bool> updateStatusAnggota(int id, String statusBaru) async {
    try {
      final anggota = await getAnggotaDPRById(id);
      if (anggota == null) {
        throw Exception('Anggota DPR not found');
      }

      final updatedAnggota = anggota.copyWith(
        status: statusBaru,
        updatedAt: DateTime.now(),
      );

      return await updateAnggotaDPR(updatedAnggota);
    } catch (e) {
      throw Exception('Failed to update status anggota: $e');
    }
  }

  Future<Map<String, dynamic>> getAnggotaDPRStatistics() async {
    try {
      final allAnggota = await getAllAnggotaDPR();
      
      final aktif = allAnggota.where((item) => item.status == 'aktif').length;
      final tidakAktif = allAnggota.where((item) => item.status == 'tidak_aktif').length;
      final pengganti = allAnggota.where((item) => item.status == 'pengganti').length;
      final lakiLaki = allAnggota.where((item) => item.jenisKelamin == 'L').length;
      final perempuan = allAnggota.where((item) => item.jenisKelamin == 'P').length;
      
      // Count by party
      final partaiCount = <String, int>{};
      for (final anggota in allAnggota) {
        partaiCount[anggota.partai] = (partaiCount[anggota.partai] ?? 0) + 1;
      }
      
      return {
        'total_anggota': allAnggota.length,
        'aktif': aktif,
        'tidak_aktif': tidakAktif,
        'pengganti': pengganti,
        'laki_laki': lakiLaki,
        'perempuan': perempuan,
        'partai_count': partaiCount,
      };
    } catch (e) {
      throw Exception('Failed to get anggota DPR statistics: $e');
    }
  }
}