import '../../database/data_komisi_database_helper.dart';
import '../../models/sihaki/data_komisi_model.dart';

class DataKomisiRepository {
  final DataKomisiDatabaseHelper _databaseHelper = DataKomisiDatabaseHelper();

  // Add new data komisi
  Future<DataKomisiModel> addDataKomisi({
    required String moduleName,
    required bool isCompleted,
    DateTime? completedAt,
    String? userId,
    String? metadata,
  }) async {
    try {
      print('Repository DEBUG: ➕ Adding new data komisi:');
      print('  - Module: "$moduleName"');
      print('  - Completed: $isCompleted');
      print('  - User ID: "${userId ?? 'current_user'}"');
      
      final now = DateTime.now();
      
      final newDataKomisi = DataKomisiModel(
        moduleName: moduleName,
        isCompleted: isCompleted,
        completedAt: completedAt ?? (isCompleted ? now : null),
        userId: userId ?? 'current_user',
        createdAt: now,
        updatedAt: now,
        metadata: metadata,
      );

      print('Repository DEBUG: 📦 Model object: $newDataKomisi');

      final id = await _databaseHelper.insertDataKomisi(newDataKomisi);
      
      final savedModel = newDataKomisi.copyWith(id: id);
      
      print('Repository DEBUG: ✅ Saved model ID: $id');
      
      return savedModel;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to add data komisi: $e');
      throw Exception('Repository: Gagal menambahkan data komisi - $e');
    }
  }

  // Get all data komisi
  Future<List<DataKomisiModel>> getAllDataKomisi({
    String? orderBy = 'created_at ASC',
  }) async {
    try {
      return await _databaseHelper.getAllDataKomisi(orderBy: orderBy);
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get all data komisi: $e');
      throw Exception('Repository: Gagal mengambil semua data komisi - $e');
    }
  }

  // Get data komisi by ID
  Future<DataKomisiModel?> getDataKomisiById(int id) async {
    try {
      return await _databaseHelper.getDataKomisiById(id);
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get data komisi by ID $id: $e');
      throw Exception('Repository: Gagal mengambil data komisi dengan ID $id - $e');
    }
  }

  // Get data komisi by module name
  Future<DataKomisiModel?> getDataKomisiByModuleName(String moduleName) async {
    try {
      return await _databaseHelper.getDataKomisiByModuleName(moduleName);
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get data komisi by module $moduleName: $e');
      throw Exception('Repository: Gagal mengambil data komisi untuk modul $moduleName - $e');
    }
  }

  // Get data komisi by user ID
  Future<List<DataKomisiModel>> getDataKomisiByUserId(String userId) async {
    try {
      return await _databaseHelper.getDataKomisiByUserId(userId);
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get data komisi by user $userId: $e');
      throw Exception('Repository: Gagal mengambil data komisi untuk user $userId - $e');
    }
  }

  // Update data komisi
  Future<DataKomisiModel> updateDataKomisi(DataKomisiModel dataKomisi) async {
    try {
      print('Repository DEBUG: 📝 Updating data komisi:');
      print('  - ID: ${dataKomisi.id}');
      print('  - Module: "${dataKomisi.moduleName}"');
      print('  - Completed: ${dataKomisi.isCompleted}');
      
      final updatedDataKomisi = dataKomisi.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _databaseHelper.updateDataKomisi(updatedDataKomisi);
      
      print('Repository DEBUG: ✅ Update completed');
      
      return updatedDataKomisi;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to update data komisi: $e');
      throw Exception('Repository: Gagal mengupdate data komisi - $e');
    }
  }

  // Update module completion status
  Future<bool> updateModuleCompletionStatus(String moduleName, bool isCompleted, {String? userId}) async {
    try {
      print('Repository DEBUG: 🔄 Updating module completion:');
      print('  - Module: "$moduleName"');
      print('  - Completed: $isCompleted');
      print('  - User: "${userId ?? 'current_user'}"');
      
      final result = await _databaseHelper.updateModuleCompletionStatus(
        moduleName, 
        isCompleted, 
        userId: userId ?? 'current_user'
      );
      
      final success = result > 0;
      print('Repository DEBUG: ${success ? '✅' : '❌'} Module update result: $result rows affected');
      
      return success;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to update module completion: $e');
      throw Exception('Repository: Gagal mengupdate status modul $moduleName - $e');
    }
  }

  // Delete data komisi
  Future<bool> deleteDataKomisi(int id) async {
    try {
      final result = await _databaseHelper.deleteDataKomisi(id);
      return result > 0;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to delete data komisi: $e');
      throw Exception('Repository: Gagal menghapus data komisi - $e');
    }
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStatistics({String? userId}) async {
    try {
      return await _databaseHelper.getCompletionStatistics(userId: userId ?? 'current_user');
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get completion statistics: $e');
      throw Exception('Repository: Gagal mengambil statistik penyelesaian - $e');
    }
  }

  // Reset all modules
  Future<bool> resetAllModules({String? userId}) async {
    try {
      print('Repository DEBUG: 🔄 Resetting all modules for user: ${userId ?? 'current_user'}');
      
      final result = await _databaseHelper.resetAllModules(userId: userId ?? 'current_user');
      
      final success = result > 0;
      print('Repository DEBUG: ${success ? '✅' : '❌'} Reset result: $result modules reset');
      
      return success;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to reset modules: $e');
      throw Exception('Repository: Gagal mereset semua modul - $e');
    }
  }

  // Get modules by completion status
  Future<List<DataKomisiModel>> getModulesByStatus(bool isCompleted, {String? userId}) async {
    try {
      return await _databaseHelper.getModulesByStatus(isCompleted, userId: userId ?? 'current_user');
    } catch (e) {
      print('Repository ERROR: ❌ Failed to get modules by status: $e');
      throw Exception('Repository: Gagal mengambil modul berdasarkan status - $e');
    }
  }

  // Sync module status from providers (untuk sinkronisasi data)
  Future<void> syncModuleStatuses(Map<String, bool> moduleStatuses, {String? userId}) async {
    try {
      print('Repository DEBUG: 🔄 Syncing module statuses:');
      for (final entry in moduleStatuses.entries) {
        print('  - ${entry.key}: ${entry.value}');
      }
      
      for (final entry in moduleStatuses.entries) {
        await updateModuleCompletionStatus(entry.key, entry.value, userId: userId);
      }
      
      print('Repository DEBUG: ✅ Sync completed');
    } catch (e) {
      print('Repository ERROR: ❌ Failed to sync module statuses: $e');
      throw Exception('Repository: Gagal sinkronisasi status modul - $e');
    }
  }

  // Initialize default modules for user (jika belum ada)
  Future<void> initializeDefaultModules({String? userId}) async {
    try {
      print('Repository DEBUG: 🔧 Initializing default modules for user: ${userId ?? 'current_user'}');
      
      final existingModules = await getDataKomisiByUserId(userId ?? 'current_user');
      
      if (existingModules.isEmpty) {
        final modules = [
          'data_keanggotaan',
          'data_kendaraan', 
          'data_pribadi',
          'data_penerbangan',
          'data_kesehatan',
          'data_kontak',
          'data_tata_naskah',
          'data_feedback_komisi',
        ];
        
        for (String module in modules) {
          await addDataKomisi(
            moduleName: module,
            isCompleted: false,
            userId: userId ?? 'current_user',
          );
        }
        
        print('Repository DEBUG: ✅ Initialized ${modules.length} default modules');
      } else {
        print('Repository DEBUG: ℹ️ Modules already exist (${existingModules.length} found)');
      }
    } catch (e) {
      print('Repository ERROR: ❌ Failed to initialize default modules: $e');
      throw Exception('Repository: Gagal inisialisasi modul default - $e');
    }
  }

  // Close repository
  Future<void> close() async {
    await _databaseHelper.close();
  }
}
