import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';
import '../../models/menuutama/izin_model.dart';

class IzinRepository {
  final AppDatabaseHelper _databaseHelper = AppDatabaseHelper();

  // Get all izin records
  Future<List<IzinModel>> getAllIzin() async {
    try {
      print('DEBUG: Repository getAllIzin called'); // Debug log
      final maps = await _databaseHelper.getAllIzin();
      print('DEBUG: Repository getAllIzin returned ${maps.length} records'); // Debug log
      return maps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Repository getAllIzin error: $e'); // Debug log
      throw Exception('Failed to load izin data: $e');
    }
  }

  // Get izin by user ID
  Future<List<IzinModel>> getIzinByUserId(int userId) async {
    try {
      final maps = await _databaseHelper.getIzinByUserId(userId);
      return maps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load izin data for user $userId: $e');
    }
  }

  // Get izin by status
  Future<List<IzinModel>> getIzinByStatus(String status) async {
    try {
      final maps = await _databaseHelper.getIzinByStatus(status);
      return maps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load izin data by status: $e');
    }
  }

  // Get izin by ID
  Future<IzinModel?> getIzinById(int id) async {
    try {
      final map = await _databaseHelper.getIzinById(id);
      if (map != null) {
        return IzinModel.fromMap(map);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load izin with ID $id: $e');
    }
  }

  // Add new izin
  Future<IzinModel> addIzin({
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
    int? userId,
  }) async {
    try {
      print('DEBUG: Repository addIzin called with: type=$type, date=$date, duration=$duration, reason=$reason'); // Debug log
      final id = await _databaseHelper.insertIzin(
        type: type,
        date: date,
        duration: duration,
        reason: reason,
        status: 'menunggu_persetujuan',
        fileName: fileName,
        userId: userId ?? 1,
      );
      print('DEBUG: Database insert returned ID: $id'); // Debug log
      
      // Return the created izin
      final createdMap = await _databaseHelper.getIzinById(id);
      print('DEBUG: Retrieved created izin: $createdMap'); // Debug log
      if (createdMap != null) {
        return IzinModel.fromMap(createdMap);
      } else {
        throw Exception('Failed to retrieve created izin');
      }
    } catch (e) {
      print('DEBUG: Repository addIzin error: $e'); // Debug log
      throw Exception('Failed to add izin: $e');
    }
  }

  // Update izin
  Future<IzinModel> updateIzin({
    required int id,
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
  }) async {
    try {
      await _databaseHelper.updateIzin(
        id: id,
        type: type,
        date: date,
        duration: duration,
        reason: reason,
        fileName: fileName,
      );
      
      // Return the updated izin
      final updatedMap = await _databaseHelper.getIzinById(id);
      if (updatedMap != null) {
        return IzinModel.fromMap(updatedMap);
      } else {
        throw Exception('Failed to retrieve updated izin');
      }
    } catch (e) {
      throw Exception('Failed to update izin: $e');
    }
  }

  // Update izin status
  Future<void> updateIzinStatus(int id, String status) async {
    try {
      await _databaseHelper.updateIzinStatus(id, _convertStatusToDb(status));
    } catch (e) {
      throw Exception('Failed to update izin status: $e');
    }
  }

  // Delete izin
  Future<void> deleteIzin(int id) async {
    try {
      await _databaseHelper.deleteIzin(id);
    } catch (e) {
      throw Exception('Failed to delete izin: $e');
    }
  }

  // Get izin statistics
  Future<Map<String, int>> getIzinStatistics() async {
    try {
      final allIzin = await getAllIzin();
      
      final statistics = <String, int>{
        'total': allIzin.length,
        'pending': allIzin.where((izin) => izin.uiStatus == 'Menunggu Persetujuan').length,
        'approved': allIzin.where((izin) => izin.uiStatus == 'Disetujui').length,
        'rejected': allIzin.where((izin) => izin.uiStatus == 'Ditolak').length,
      };

      // Group by type
      final typeStats = <String, int>{};
      for (final izin in allIzin) {
        typeStats[izin.type] = (typeStats[izin.type] ?? 0) + 1;
      }
      statistics.addAll(typeStats);

      return statistics;
    } catch (e) {
      throw Exception('Failed to get izin statistics: $e');
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

  // Search izin
  Future<List<IzinModel>> searchIzin(String query) async {
    try {
      final allIzin = await getAllIzin();
      final searchQuery = query.toLowerCase();
      
      return allIzin.where((izin) {
        final searchText = '${izin.id} ${izin.type} ${izin.reason}'.toLowerCase();
        return searchText.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search izin: $e');
    }
  }

  // Get izin by date range
  Future<List<IzinModel>> getIzinByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allIzin = await getAllIzin();
      
      return allIzin.where((izin) {
        return izin.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               izin.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get izin by date range: $e');
    }
  }
}