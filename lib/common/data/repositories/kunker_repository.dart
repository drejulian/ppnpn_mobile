import '../database/kunker_database_helper.dart';
import '../models/sihaki/kunker_model.dart';

class KunkerRepository {
  final KunkerDatabaseHelper _dbHelper = KunkerDatabaseHelper();

  // Get all kunker data
  Future<List<KunkerModel>> getAllKunker() async {
    try {
      return await _dbHelper.getAllKunker();
    } catch (e) {
      throw Exception('Failed to get kunker data: $e');
    }
  }

  // Get kunker by ID
  Future<KunkerModel?> getKunkerById(int id) async {
    try {
      return await _dbHelper.getKunkerById(id);
    } catch (e) {
      throw Exception('Failed to get kunker by ID: $e');
    }
  }

  // Get kunker by No. Surat
  Future<KunkerModel?> getKunkerByNoSurat(String noSurat) async {
    try {
      return await _dbHelper.getKunkerByNoSurat(noSurat);
    } catch (e) {
      throw Exception('Failed to get kunker by No. Surat: $e');
    }
  }

  // Search kunker
  Future<List<KunkerModel>> searchKunker(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllKunker();
      }
      return await _dbHelper.searchKunker(query.trim());
    } catch (e) {
      throw Exception('Failed to search kunker: $e');
    }
  }

  // Get kunker by status
  Future<List<KunkerModel>> getKunkerByStatus(String status) async {
    try {
      return await _dbHelper.getKunkerByStatus(status);
    } catch (e) {
      throw Exception('Failed to get kunker by status: $e');
    }
  }

  // Get kunker by anggota
  Future<List<KunkerModel>> getKunkerByAnggota(String anggota) async {
    try {
      return await _dbHelper.getKunkerByAnggota(anggota);
    } catch (e) {
      throw Exception('Failed to get kunker by anggota: $e');
    }
  }

  // Add new kunker
  Future<int> addKunker(KunkerModel kunker) async {
    try {
      return await _dbHelper.insertKunker(kunker);
    } catch (e) {
      if (e.toString().contains('No. Surat sudah ada')) {
        throw Exception('No. Surat sudah ada, gunakan nomor yang berbeda');
      }
      throw Exception('Failed to add kunker: $e');
    }
  }

  // Add kunker from UI map format
  Future<int> addKunkerFromUIMap(Map<String, dynamic> uiData) async {
    try {
      // Print debug info
      print('DEBUG Repository: Adding kunker with data: $uiData');
      
      // Check existing no_surat list for debugging
      await _dbHelper.getAllNoSurat();
      
      return await _dbHelper.insertKunkerFromUIMap(uiData);
    } catch (e) {
      print('DEBUG Repository: Error adding kunker: $e');
      if (e.toString().contains('No. Surat sudah ada')) {
        throw Exception('No. Surat sudah ada, gunakan nomor yang berbeda');
      }
      throw Exception('Failed to add kunker: $e');
    }
  }

  // Check if no_surat exists
  Future<bool> isNoSuratExists(String noSurat) async {
    try {
      return await _dbHelper.isNoSuratExists(noSurat);
    } catch (e) {
      throw Exception('Failed to check no_surat: $e');
    }
  }

  // Update kunker
  Future<int> updateKunker(int id, KunkerModel kunker) async {
    try {
      final result = await _dbHelper.updateKunker(id, kunker);
      if (result == 0) {
        throw Exception('Kunker tidak ditemukan');
      }
      return result;
    } catch (e) {
      throw Exception('Failed to update kunker: $e');
    }
  }

  // Update kunker by No. Surat
  Future<int> updateKunkerByNoSurat(String noSurat, KunkerModel kunker) async {
    try {
      final result = await _dbHelper.updateKunkerByNoSurat(noSurat, kunker);
      if (result == 0) {
        throw Exception('Kunker dengan No. Surat $noSurat tidak ditemukan');
      }
      return result;
    } catch (e) {
      throw Exception('Failed to update kunker: $e');
    }
  }

  // Update kunker from UI map format
  Future<int> updateKunkerFromUIMap(String noSurat, Map<String, dynamic> uiData) async {
    try {
      return await _dbHelper.updateKunkerFromUIMap(noSurat, uiData);
    } catch (e) {
      throw Exception('Failed to update kunker: $e');
    }
  }

  // Delete kunker
  Future<int> deleteKunker(int id) async {
    try {
      final result = await _dbHelper.deleteKunker(id);
      if (result == 0) {
        throw Exception('Kunker tidak ditemukan');
      }
      return result;
    } catch (e) {
      throw Exception('Failed to delete kunker: $e');
    }
  }

  // Delete kunker by No. Surat
  Future<int> deleteKunkerByNoSurat(String noSurat) async {
    try {
      final result = await _dbHelper.deleteKunkerByNoSurat(noSurat);
      if (result == 0) {
        throw Exception('Kunker dengan No. Surat $noSurat tidak ditemukan');
      }
      return result;
    } catch (e) {
      throw Exception('Failed to delete kunker: $e');
    }
  }

  // Get total count
  Future<int> getKunkerCount() async {
    try {
      return await _dbHelper.getKunkerCount();
    } catch (e) {
      throw Exception('Failed to get kunker count: $e');
    }
  }

  // Get statistics
  Future<List<Map<String, dynamic>>> getKunkerStats() async {
    try {
      return await _dbHelper.getKunkerStats();
    } catch (e) {
      throw Exception('Failed to get kunker stats: $e');
    }
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllKunker() async {
    try {
      await _dbHelper.clearAllKunker();
    } catch (e) {
      throw Exception('Failed to clear kunker data: $e');
    }
  }

  // Convert database models to UI format
  List<Map<String, dynamic>> convertToUIFormat(List<KunkerModel> kunkerList) {
    return kunkerList.map((kunker) => kunker.toUIMap()).toList();
  }

  // Batch operations
  Future<List<int>> addMultipleKunker(List<KunkerModel> kunkerList) async {
    final List<int> results = [];
    for (final kunker in kunkerList) {
      try {
        final id = await addKunker(kunker);
        results.add(id);
      } catch (e) {
        // Log error but continue with other items
        print('Failed to add kunker ${kunker.noSurat}: $e');
        results.add(-1); // Indicate failure
      }
    }
    return results;
  }

  Future<int> updateMultipleKunkerStatus(List<String> noSuratList, String newStatus) async {
    int updatedCount = 0;
    for (final noSurat in noSuratList) {
      try {
        final existing = await getKunkerByNoSurat(noSurat);
        if (existing != null) {
          final updated = existing.copyWith(statusPengajuan: newStatus);
          await updateKunker(existing.id!, updated);
          updatedCount++;
        }
      } catch (e) {
        print('Failed to update status for $noSurat: $e');
      }
    }
    return updatedCount;
  }

  // Analytics methods
  Future<Map<String, int>> getStatusDistribution() async {
    try {
      final stats = await getKunkerStats();
      final Map<String, int> distribution = {};
      for (final stat in stats) {
        distribution[stat['status_pengajuan']] = stat['count'];
      }
      return distribution;
    } catch (e) {
      throw Exception('Failed to get status distribution: $e');
    }
  }

  Future<List<KunkerModel>> getRecentKunker({int limit = 10}) async {
    try {
      final allKunker = await getAllKunker();
      // Already sorted by created_at DESC in database helper
      return allKunker.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent kunker: $e');
    }
  }

  Future<List<KunkerModel>> getKunkerByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allKunker = await getAllKunker();
      return allKunker.where((kunker) {
        try {
          final createdAt = DateTime.parse(kunker.createdAt);
          return createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 createdAt.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to get kunker by date range: $e');
    }
  }
}