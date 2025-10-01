import '../../database/cuti_database_helper.dart';
import '../../models/menuutama/cuti_model.dart';

class CutiRepository {
  final CutiDatabaseHelper _databaseHelper = CutiDatabaseHelper();

  // Get all cuti with optional filtering and sorting
  Future<List<CutiModel>> getAllCuti({
    String? orderBy = 'createdAt DESC',
  }) async {
    try {
      return await _databaseHelper.getAllCuti(orderBy: orderBy);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua data cuti - $e');
    }
  }

  // Get cuti by ID
  Future<CutiModel?> getCutiById(String cutiId) async {
    try {
      return await _databaseHelper.getCutiById(cutiId);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data cuti dengan ID $cutiId - $e');
    }
  }

  // Add new cuti
  Future<CutiModel> addCuti({
    required CutiType type,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String alasan,
    String? fileName,
    String? filePath,
  }) async {
    try {
      // Generate unique ID
      final cutiId = await _databaseHelper.generateUniqueCutiId();
      final now = DateTime.now();
      
      final newCuti = CutiModel(
        cutiId: cutiId,
        type: type,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        alasan: alasan,
        status: CutiStatus.menungguPersetujuan,
        fileName: fileName,
        filePath: filePath,
        createdAt: now,
        updatedAt: now,
      );

      // Validate before inserting
      final validationError = newCuti.validate();
      if (validationError != null) {
        throw Exception('Validation error: $validationError');
      }

      await _databaseHelper.insertCuti(newCuti);
      
      // Return the inserted cuti with ID
      final insertedCuti = await _databaseHelper.getCutiById(cutiId);
      if (insertedCuti == null) {
        throw Exception('Failed to retrieve inserted cuti');
      }
      
      return insertedCuti;
    } catch (e) {
      throw Exception('Repository: Gagal menambah data cuti - $e');
    }
  }

  // Update existing cuti
  Future<CutiModel> updateCuti(CutiModel cuti) async {
    try {
      if (cuti.id == null) {
        throw Exception('ID database tidak boleh null untuk update');
      }

      // Check if cuti can be edited
      if (!cuti.canEdit) {
        throw Exception('Cuti dengan status ${cuti.status.label} tidak dapat diedit');
      }

      final updatedCuti = cuti.copyWith(updatedAt: DateTime.now());
      
      // Validate before updating
      final validationError = updatedCuti.validate();
      if (validationError != null) {
        throw Exception('Validation error: $validationError');
      }

      final result = await _databaseHelper.updateCuti(updatedCuti);
      if (result == 0) {
        throw Exception('Tidak ada data yang diupdate');
      }

      // Return the updated cuti
      final retrievedCuti = await _databaseHelper.getCutiById(cuti.cutiId);
      if (retrievedCuti == null) {
        throw Exception('Failed to retrieve updated cuti');
      }
      
      return retrievedCuti;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate data cuti - $e');
    }
  }

  // Update cuti status only
  Future<CutiModel> updateCutiStatus(String cutiId, CutiStatus newStatus) async {
    try {
      final result = await _databaseHelper.updateCutiStatus(cutiId, newStatus);
      if (result == 0) {
        throw Exception('Tidak ada data yang diupdate');
      }

      // Return the updated cuti
      final updatedCuti = await _databaseHelper.getCutiById(cutiId);
      if (updatedCuti == null) {
        throw Exception('Failed to retrieve updated cuti');
      }
      
      return updatedCuti;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate status cuti - $e');
    }
  }

  // Delete cuti
  Future<bool> deleteCuti(String cutiId) async {
    try {
      final result = await _databaseHelper.deleteCuti(cutiId);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus data cuti - $e');
    }
  }

  // Search cuti with query
  Future<List<CutiModel>> searchCuti(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCuti();
      }
      return await _databaseHelper.searchCuti(query);
    } catch (e) {
      throw Exception('Repository: Gagal mencari data cuti - $e');
    }
  }

  // Filter cuti by status
  Future<List<CutiModel>> getCutiByStatus(CutiStatus status) async {
    try {
      return await _databaseHelper.getCutiByStatus(status);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data cuti berdasarkan status - $e');
    }
  }

  // Filter cuti by type
  Future<List<CutiModel>> getCutiByType(CutiType type) async {
    try {
      return await _databaseHelper.getCutiByType(type);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data cuti berdasarkan jenis - $e');
    }
  }

  // Get cuti in date range
  Future<List<CutiModel>> getCutiByDateRange(DateTime start, DateTime end) async {
    try {
      return await _databaseHelper.getCutiByDateRange(start, end);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data cuti berdasarkan tanggal - $e');
    }
  }

  // Advanced search with multiple filters
  Future<List<CutiModel>> searchCutiWithFilters({
    String? query,
    CutiStatus? status,
    CutiType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<CutiModel> results = await getAllCuti();

      // Apply text search filter
      if (query != null && query.trim().isNotEmpty) {
        results = await searchCuti(query);
      }

      // Apply status filter
      if (status != null) {
        results = results.where((cuti) => cuti.status == status).toList();
      }

      // Apply type filter
      if (type != null) {
        results = results.where((cuti) => cuti.type == type).toList();
      }

      // Apply date range filter
      if (startDate != null && endDate != null) {
        results = results.where((cuti) {
          return (cuti.tanggalMulai.isAtSameMomentAs(startDate) ||
                  cuti.tanggalMulai.isAfter(startDate)) &&
                 (cuti.tanggalSelesai.isAtSameMomentAs(endDate) ||
                  cuti.tanggalSelesai.isBefore(endDate));
        }).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Repository: Gagal mencari data cuti dengan filter - $e');
    }
  }

  // Get statistics
  Future<Map<String, int>> getCutiStatistics() async {
    try {
      return await _databaseHelper.getCutiStatistics();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil statistik cuti - $e');
    }
  }

  // Get cuti count
  Future<int> getCutiCount() async {
    try {
      return await _databaseHelper.getCutiCount();
    } catch (e) {
      throw Exception('Repository: Gagal menghitung jumlah cuti - $e');
    }
  }

  // Get cuti count by status
  Future<int> getCutiCountByStatus(CutiStatus status) async {
    try {
      return await _databaseHelper.getCutiCountByStatus(status);
    } catch (e) {
      throw Exception('Repository: Gagal menghitung jumlah cuti berdasarkan status - $e');
    }
  }

  // Check if cuti ID exists
  Future<bool> isCutiIdExists(String cutiId) async {
    try {
      return await _databaseHelper.isCutiIdExists(cutiId);
    } catch (e) {
      return false;
    }
  }

  // Generate unique cuti ID
  Future<String> generateUniqueCutiId() async {
    try {
      return await _databaseHelper.generateUniqueCutiId();
    } catch (e) {
      throw Exception('Repository: Gagal generate ID cuti - $e');
    }
  }

  // Convert from legacy format for backward compatibility
  Future<CutiModel> addCutiFromLegacyMap(Map<String, dynamic> legacyData) async {
    try {
      final cutiModel = CutiModel.fromLegacyMap(legacyData);
      
      // Ensure unique ID
      if (await isCutiIdExists(cutiModel.cutiId)) {
        final newId = await generateUniqueCutiId();
        final updatedModel = cutiModel.copyWith(cutiId: newId);
        await _databaseHelper.insertCuti(updatedModel);
        return updatedModel;
      } else {
        await _databaseHelper.insertCuti(cutiModel);
        return cutiModel;
      }
    } catch (e) {
      throw Exception('Repository: Gagal menambah cuti dari format lama - $e');
    }
  }

  // Get legacy format for backward compatibility
  Future<List<Map<String, dynamic>>> getAllCutiLegacyFormat() async {
    try {
      final cutiList = await getAllCuti();
      return cutiList.map((cuti) => cuti.toLegacyMap()).toList();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil data dalam format lama - $e');
    }
  }

  // Maintenance methods
  Future<void> resetData() async {
    try {
      await _databaseHelper.resetDatabase();
    } catch (e) {
      throw Exception('Repository: Gagal reset database - $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _databaseHelper.clearAllData();
    } catch (e) {
      throw Exception('Repository: Gagal menghapus semua data - $e');
    }
  }

  // Export/Import for backup
  Future<List<Map<String, dynamic>>> exportAllData() async {
    try {
      return await _databaseHelper.exportAllData();
    } catch (e) {
      throw Exception('Repository: Gagal mengekspor data - $e');
    }
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    try {
      await _databaseHelper.importData(data);
    } catch (e) {
      throw Exception('Repository: Gagal mengimpor data - $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    try {
      await _databaseHelper.close();
    } catch (e) {
      // Ignore close errors
    }
  }
}