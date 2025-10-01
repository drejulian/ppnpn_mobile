import '../../models/sihaki/agenda_pribadi_anggota_model.dart';
import '../../database/app_database_helper.dart';

class AgendaPribadiAnggotaRepository {
  final AppDatabaseHelper _databaseHelper;

  AgendaPribadiAnggotaRepository(this._databaseHelper);

  Future<int> addAgenda(AgendaPribadiAnggotaModel agenda) async {
    try {
      final agendaMap = agenda.toMap();
      // Remove id dari map karena auto increment
      agendaMap.remove('id');
      
      return await _databaseHelper.insertAgendaPribadi(agendaMap);
    } catch (e) {
      throw Exception('Failed to add agenda: $e');
    }
  }

  Future<List<AgendaPribadiAnggotaModel>> getAllAgenda([int? userId]) async {
    try {
      final agendaList = await _databaseHelper.getAllAgendaPribadi(userId);
      
      return agendaList.map((agenda) => AgendaPribadiAnggotaModel.fromMap(agenda)).toList();
    } catch (e) {
      throw Exception('Failed to get agenda list: $e');
    }
  }

  Future<AgendaPribadiAnggotaModel?> getAgendaById(int id) async {
    try {
      final agenda = await _databaseHelper.getAgendaPribadiById(id);
      
      if (agenda != null) {
        return AgendaPribadiAnggotaModel.fromMap(agenda);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get agenda: $e');
    }
  }

  Future<bool> updateAgenda(AgendaPribadiAnggotaModel agenda) async {
    try {
      if (agenda.id == null) {
        throw Exception('Agenda ID is required for update');
      }

      final agendaMap = agenda.toMap();
      agendaMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateAgendaPribadi(agenda.id!, agendaMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update agenda: $e');
    }
  }

  Future<bool> deleteAgenda(int id) async {
    try {
      final result = await _databaseHelper.deleteAgendaPribadi(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete agenda: $e');
    }
  }

  Future<List<AgendaPribadiAnggotaModel>> getAgendaByDate(String date, [int? userId]) async {
    try {
      final allAgenda = await getAllAgenda(userId);
      
      return allAgenda.where((agenda) => agenda.tanggal == date).toList();
    } catch (e) {
      throw Exception('Failed to get agenda by date: $e');
    }
  }

  Future<List<AgendaPribadiAnggotaModel>> getUpcomingAgenda([int? userId]) async {
    try {
      final allAgenda = await getAllAgenda(userId);
      final today = DateTime.now();
      final todayString = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      return allAgenda.where((agenda) {
        return agenda.tanggal.compareTo(todayString) >= 0;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming agenda: $e');
    }
  }

  Future<List<AgendaPribadiAnggotaModel>> searchAgenda(String keyword, [int? userId]) async {
    try {
      final allAgenda = await getAllAgenda(userId);
      final lowerKeyword = keyword.toLowerCase();
      
      return allAgenda.where((agenda) {
        return agenda.agenda.toLowerCase().contains(lowerKeyword) ||
               agenda.tempat.toLowerCase().contains(lowerKeyword) ||
               (agenda.keterangan?.toLowerCase().contains(lowerKeyword) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search agenda: $e');
    }
  }
}