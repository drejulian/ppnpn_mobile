import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/repositories/menuutama/izin_repository.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/izin_model.dart';

// Repository provider
final izinRepositoryProvider = Provider<IzinRepository>((ref) {
  return IzinRepository();
});

// State for izin data
class IzinState {
  final List<IzinModel> izinList;
  final bool isLoading;
  final String? error;
  final Map<String, int>? statistics;

  const IzinState({
    this.izinList = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  IzinState copyWith({
    List<IzinModel>? izinList,
    bool? isLoading,
    String? error,
    Map<String, int>? statistics,
  }) {
    return IzinState(
      izinList: izinList ?? this.izinList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }

  // Convert to legacy format for backward compatibility
  List<Map<String, dynamic>> get legacyFormat {
    return izinList.map((izin) => izin.toMap()).toList();
  }
}

// Main izin state notifier
class IzinNotifier extends StateNotifier<IzinState> {
  final IzinRepository _repository;

  IzinNotifier(this._repository) : super(const IzinState()) {
    loadIzin();
  }

  // Load all izin data
  Future<void> loadIzin() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final izinList = await _repository.getAllIzin();
      final statistics = await _repository.getIzinStatistics();
      
      state = state.copyWith(
        izinList: izinList,
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

  // Add new izin
  Future<bool> addIzin({
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
  }) async {
    try {
      final newIzin = await _repository.addIzin(
        type: type,
        date: date,
        duration: duration,
        reason: reason,
        fileName: fileName,
        filePath: filePath,
      );

      // Update state with new izin
      final updatedList = [newIzin, ...state.izinList];
      final statistics = await _repository.getIzinStatistics();
      
      state = state.copyWith(
        izinList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update existing izin
  Future<bool> updateIzin({
    required int id,
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? fileName,
    String? filePath,
  }) async {
    try {
      final updatedIzin = await _repository.updateIzin(
        id: id,
        type: type,
        date: date,
        duration: duration,
        reason: reason,
        fileName: fileName,
        filePath: filePath,
      );

      // Update state with updated izin
      final updatedList = state.izinList.map((izin) {
        return izin.id == id ? updatedIzin : izin;
      }).toList();
      
      final statistics = await _repository.getIzinStatistics();
      
      state = state.copyWith(
        izinList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete izin
  Future<bool> deleteIzin(int id) async {
    try {
      await _repository.deleteIzin(id);
      
      // Update state by removing the deleted izin
      final updatedList = state.izinList.where((izin) => izin.id != id).toList();
      final statistics = await _repository.getIzinStatistics();
      
      state = state.copyWith(
        izinList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update izin status
  Future<bool> updateIzinStatus(int id, String status) async {
    try {
      await _repository.updateIzinStatus(id, status);
      
      // Update state with new status
      final updatedList = state.izinList.map((izin) {
        if (izin.id == id) {
          return izin.copyWith(status: status);
        }
        return izin;
      }).toList();
      
      final statistics = await _repository.getIzinStatistics();
      
      state = state.copyWith(
        izinList: updatedList,
        statistics: statistics,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadIzin();
  }

  // Get izin by ID
  IzinModel? getIzinById(int id) {
    try {
      return state.izinList.firstWhere((izin) => izin.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get izin by status
  List<IzinModel> getIzinByStatus(String status) {
    return state.izinList.where((izin) => izin.status == status).toList();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// State provider
final izinProvider = StateNotifierProvider<IzinNotifier, IzinState>((ref) {
  final repository = ref.watch(izinRepositoryProvider);
  return IzinNotifier(repository);
});

// Search query provider
final izinSearchProvider = StateProvider<String>((ref) => '');

// Status filter provider
final izinStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

// Filtered izin list provider
final filteredIzinProvider = Provider<List<IzinModel>>((ref) {
  final izinState = ref.watch(izinProvider);
  final searchQuery = ref.watch(izinSearchProvider).toLowerCase();
  final statusFilter = ref.watch(izinStatusFilterProvider);

  List<IzinModel> filteredList = izinState.izinList;

  // Apply status filter
  if (statusFilter != 'Semua') {
    filteredList = filteredList.where((izin) {
      final uiStatus = izin.uiStatus;
      return uiStatus == statusFilter;
    }).toList();
  }

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredList = filteredList.where((izin) {
      final searchText = '${izin.id} ${izin.type} ${izin.reason}'.toLowerCase();
      return searchText.contains(searchQuery);
    }).toList();
  }

  return filteredList;
});

// Statistics providers
final izinStatisticsProvider = Provider<Map<String, int>?>((ref) {
  return ref.watch(izinProvider).statistics;
});

final totalIzinProvider = Provider<int>((ref) {
  return ref.watch(izinProvider).izinList.length;
});

final pendingIzinProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Menunggu Persetujuan').length;
});

final approvedIzinProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Disetujui').length;
});

final rejectedIzinProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Ditolak').length;
});