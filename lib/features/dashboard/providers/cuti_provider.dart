import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/repositories/menuutama/cuti_repository.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/cuti_model.dart';

// Repository provider
final cutiRepositoryProvider = Provider<CutiRepository>((ref) {
  return CutiRepository();
});

// State for cuti data
class CutiState {
  final List<CutiModel> cutiList;
  final bool isLoading;
  final String? error;
  final Map<String, int>? statistics;

  const CutiState({
    this.cutiList = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  CutiState copyWith({
    List<CutiModel>? cutiList,
    bool? isLoading,
    String? error,
    Map<String, int>? statistics,
  }) {
    return CutiState(
      cutiList: cutiList ?? this.cutiList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }

  // Convert to legacy format for backward compatibility
  List<Map<String, dynamic>> get legacyFormat {
    return cutiList.map((cuti) => cuti.toLegacyMap()).toList();
  }
}

// Main cuti state notifier
class CutiNotifier extends StateNotifier<CutiState> {
  final CutiRepository _repository;

  CutiNotifier(this._repository) : super(const CutiState()) {
    loadCuti();
  }

  // Load all cuti data
  Future<void> loadCuti() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final cutiList = await _repository.getAllCuti();
      final statistics = await _repository.getCutiStatistics();
      
      state = state.copyWith(
        cutiList: cutiList,
        isLoading: false,
        statistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add new cuti
  Future<bool> addCuti({
    required CutiType type,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String alasan,
    String? fileName,
    String? filePath,
  }) async {
    try {
      final newCuti = await _repository.addCuti(
        type: type,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        alasan: alasan,
        fileName: fileName,
        filePath: filePath,
      );

      // Update state with new cuti
      final updatedList = [newCuti, ...state.cutiList];
      final statistics = await _repository.getCutiStatistics();
      
      state = state.copyWith(
        cutiList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Add cuti from legacy format (for backward compatibility)
  Future<bool> addCutiFromLegacyMap(Map<String, dynamic> legacyData) async {
    try {
      final newCuti = await _repository.addCutiFromLegacyMap(legacyData);

      // Update state
      final updatedList = [newCuti, ...state.cutiList];
      final statistics = await _repository.getCutiStatistics();
      
      state = state.copyWith(
        cutiList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update existing cuti
  Future<bool> updateCuti(CutiModel cuti) async {
    try {
      final updatedCuti = await _repository.updateCuti(cuti);

      // Update state
      final updatedList = state.cutiList.map((item) {
        return item.id == updatedCuti.id ? updatedCuti : item;
      }).toList();
      
      final statistics = await _repository.getCutiStatistics();
      
      state = state.copyWith(
        cutiList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update cuti by ID (for legacy compatibility)
  Future<bool> updateCutiById(String cutiId, Map<String, dynamic> updatedData) async {
    try {
      // Find existing cuti
      final existingCuti = state.cutiList.firstWhere(
        (cuti) => cuti.cutiId == cutiId,
        orElse: () => throw Exception('Cuti dengan ID $cutiId tidak ditemukan'),
      );

      // Create updated model
      final updatedCuti = CutiModel.fromLegacyMap({
        ...existingCuti.toLegacyMap(),
        ...updatedData,
      }).copyWith(
        id: existingCuti.id,
        cutiId: existingCuti.cutiId,
        createdAt: existingCuti.createdAt,
      );

      return await updateCuti(updatedCuti);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete cuti
  Future<bool> deleteCuti(String cutiId) async {
    try {
      final success = await _repository.deleteCuti(cutiId);
      
      if (success) {
        // Update state
        final updatedList = state.cutiList.where((cuti) => cuti.cutiId != cutiId).toList();
        final statistics = await _repository.getCutiStatistics();
        
        state = state.copyWith(
          cutiList: updatedList,
          statistics: statistics,
        );
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete cuti by index (for legacy compatibility)
  Future<bool> deleteCutiByIndex(int index) async {
    try {
      if (index < 0 || index >= state.cutiList.length) {
        throw Exception('Index tidak valid');
      }
      
      final cutiToDelete = state.cutiList[index];
      return await deleteCuti(cutiToDelete.cutiId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update cuti status
  Future<bool> updateCutiStatus(String cutiId, CutiStatus newStatus) async {
    try {
      final updatedCuti = await _repository.updateCutiStatus(cutiId, newStatus);

      // Update state
      final updatedList = state.cutiList.map((item) {
        return item.cutiId == cutiId ? updatedCuti : item;
      }).toList();
      
      final statistics = await _repository.getCutiStatistics();
      
      state = state.copyWith(
        cutiList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Search cuti
  Future<void> searchCuti(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await _repository.searchCuti(query);
      state = state.copyWith(
        cutiList: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Filter by status
  Future<void> filterByStatus(CutiStatus? status) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      List<CutiModel> results;
      if (status == null) {
        results = await _repository.getAllCuti();
      } else {
        results = await _repository.getCutiByStatus(status);
      }
      
      state = state.copyWith(
        cutiList: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Advanced search with filters
  Future<void> searchWithFilters({
    String? query,
    CutiStatus? status,
    CutiType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await _repository.searchCutiWithFilters(
        query: query,
        status: status,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        cutiList: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCuti();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

// Main provider
final cutiProvider = StateNotifierProvider<CutiNotifier, CutiState>((ref) {
  final repository = ref.watch(cutiRepositoryProvider);
  return CutiNotifier(repository);
});

// Search query provider
final cutiSearchProvider = StateProvider<String>((ref) => '');

// Status filter provider
final cutiStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

// Filtered cuti provider
final filteredCutiProvider = Provider<List<CutiModel>>((ref) {
  final cutiState = ref.watch(cutiProvider);
  final query = ref.watch(cutiSearchProvider).toLowerCase().trim();
  final statusFilter = ref.watch(cutiStatusFilterProvider);

  List<CutiModel> cutiList = cutiState.cutiList;

  // Apply text search
  if (query.isNotEmpty) {
    cutiList = cutiList.where((cuti) {
      return cuti.cutiId.toLowerCase().contains(query) ||
             cuti.type.label.toLowerCase().contains(query) ||
             cuti.alasan.toLowerCase().contains(query) ||
             cuti.status.label.toLowerCase().contains(query);
    }).toList();
  }

  // Apply status filter
  if (statusFilter != 'Semua') {
    cutiList = cutiList.where((cuti) => cuti.status.label == statusFilter).toList();
  }

  return cutiList;
});

// Legacy providers for backward compatibility
final daftarCutiNotifierProvider = Provider<CutiNotifier>((ref) {
  return ref.watch(cutiProvider.notifier);
});

// Convert to legacy format
final legacyCutiProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final cutiState = ref.watch(cutiProvider);
  return cutiState.legacyFormat;
});

// Legacy filtered provider
final filteredLegacyCutiProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final filteredCuti = ref.watch(filteredCutiProvider);
  return filteredCuti.map((cuti) => cuti.toLegacyMap()).toList();
});

// Statistics provider
final cutiStatisticsProvider = Provider<Map<String, int>?>((ref) {
  final cutiState = ref.watch(cutiProvider);
  return cutiState.statistics;
});

// Loading state provider
final cutiLoadingProvider = Provider<bool>((ref) {
  final cutiState = ref.watch(cutiProvider);
  return cutiState.isLoading;
});

// Error state provider
final cutiErrorProvider = Provider<String?>((ref) {
  final cutiState = ref.watch(cutiProvider);
  return cutiState.error;
});