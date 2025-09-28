import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';
import '../../models/menuutama/lembur_model.dart';

class LemburRepository {
  final AppDatabaseHelper _databaseHelper = AppDatabaseHelper();

  // Get all lembur records
  Future<List<LemburModel>> getAllLembur() async {
    try {
      print('DEBUG: Repository getAllLembur called'); // Debug log
      final maps = await _databaseHelper.getAllLembur();
      print('DEBUG: Repository getAllLembur returned ${maps.length} records'); // Debug log
      return maps.map((map) => LemburModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Repository getAllLembur error: $e'); // Debug log
      throw Exception('Failed to load lembur data: $e');
    }
  }

  // Get lembur by user ID
  Future<List<LemburModel>> getLemburByUserId(int userId) async {
    try {
      final maps = await _databaseHelper.getLemburByUserId(userId);
      return maps.map((map) => LemburModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load lembur data for user $userId: $e');
    }
  }

  // Get lembur by status
  Future<List<LemburModel>> getLemburByStatus(String status) async {
    try {
      final maps = await _databaseHelper.getLemburByStatus(status);
      return maps.map((map) => LemburModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load lembur data by status: $e');
    }
  }

  // Get lembur by ID
  Future<LemburModel?> getLemburById(int id) async {
    try {
      final map = await _databaseHelper.getLemburById(id);
      if (map != null) {
        return LemburModel.fromMap(map);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load lembur with ID $id: $e');
    }
  }

  // Add new lembur
  Future<LemburModel> addLembur({
    required String type,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
    int? userId,
  }) async {
    try {
      print('DEBUG: Repository addLembur called with: type=$type, date=$date, startTime=$startTime, endTime=$endTime, duration=$duration, reason=$reason'); // Debug log
      final id = await _databaseHelper.insertLembur(
        type: type,
        date: date,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        reason: reason,
        status: 'menunggu_persetujuan',
        fileName: fileName,
        userId: userId ?? 1,
      );
      print('DEBUG: Database insert returned ID: $id'); // Debug log
      
      // Return the created lembur
      final createdMap = await _databaseHelper.getLemburById(id);
      print('DEBUG: Retrieved created lembur: $createdMap'); // Debug log
      if (createdMap != null) {
        return LemburModel.fromMap(createdMap);
      } else {
        throw Exception('Failed to retrieve created lembur');
      }
    } catch (e) {
      print('DEBUG: Repository addLembur error: $e'); // Debug log
      throw Exception('Failed to add lembur: $e');
    }
  }

  // Update lembur
  Future<LemburModel> updateLembur({
    required int id,
    required String type,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
  }) async {
    try {
      await _databaseHelper.updateLembur(
        id: id,
        type: type,
        date: date,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        reason: reason,
        fileName: fileName,
      );
      
      // Return the updated lembur
      final updatedMap = await _databaseHelper.getLemburById(id);
      if (updatedMap != null) {
        return LemburModel.fromMap(updatedMap);
      } else {
        throw Exception('Failed to retrieve updated lembur');
      }
    } catch (e) {
      throw Exception('Failed to update lembur: $e');
    }
  }

  // Update lembur status
  Future<void> updateLemburStatus(int id, String status) async {
    try {
      await _databaseHelper.updateLemburStatus(id, _convertStatusToDb(status));
    } catch (e) {
      throw Exception('Failed to update lembur status: $e');
    }
  }

  // Delete lembur
  Future<void> deleteLembur(int id) async {
    try {
      await _databaseHelper.deleteLembur(id);
    } catch (e) {
      throw Exception('Failed to delete lembur: $e');
    }
  }

  // Get lembur statistics
  Future<Map<String, int>> getLemburStatistics() async {
    try {
      final allLembur = await getAllLembur();
      
      final statistics = <String, int>{
        'total': allLembur.length,
        'pending': allLembur.where((lembur) => lembur.uiStatus == 'Menunggu Persetujuan').length,
        'approved': allLembur.where((lembur) => lembur.uiStatus == 'Disetujui').length,
        'rejected': allLembur.where((lembur) => lembur.uiStatus == 'Ditolak').length,
      };

      // Group by type
      final typeStats = <String, int>{};
      for (final lembur in allLembur) {
        typeStats[lembur.type] = (typeStats[lembur.type] ?? 0) + 1;
      }
      statistics.addAll(typeStats);

      return statistics;
    } catch (e) {
      throw Exception('Failed to get lembur statistics: $e');
    }
  }

  // Helper method to convert UI status to database status
  String _convertStatusToDb(String uiStatus) {
    switch (uiStatus) {
      case 'Menunggu Persetujuan':
        return 'menunggu_persetujuan';
      case 'Disetujui':
        return 'disetujui';
      case 'Ditolak':
        return 'ditolak';
      default:
        return 'menunggu_persetujuan';
    }
  }

  // Search lembur
  Future<List<LemburModel>> searchLembur(String query) async {
    try {
      final allLembur = await getAllLembur();
      final searchQuery = query.toLowerCase();
      
      return allLembur.where((lembur) {
        final searchText = '${lembur.id} ${lembur.type} ${lembur.reason}'.toLowerCase();
        return searchText.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search lembur: $e');
    }
  }

  // Get lembur by date range
  Future<List<LemburModel>> getLemburByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allLembur = await getAllLembur();
      
      return allLembur.where((lembur) {
        return lembur.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               lembur.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get lembur by date range: $e');
    }
  }
}