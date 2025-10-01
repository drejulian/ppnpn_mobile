import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import '../../../../../common/data/repositories/kunker_repository.dart';
import '../../../../../common/data/models/sihaki/kunker_model.dart';

// Repository provider
final kunkerRepositoryProvider = Provider<KunkerRepository>((ref) {
  return KunkerRepository();
});

// Kunker state class
class KunkerState {
  final List<KunkerModel> kunkerList;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const KunkerState({
    this.kunkerList = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  KunkerState copyWith({
    List<KunkerModel>? kunkerList,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return KunkerState(
      kunkerList: kunkerList ?? this.kunkerList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Convert to UI format for backward compatibility
  List<Map<String, dynamic>> get uiKunkerList {
    return kunkerList.map((kunker) => kunker.toUIMap()).toList();
  }

  // Get filtered list based on search query
  List<KunkerModel> get filteredKunkerList {
    if (searchQuery.isEmpty) return kunkerList;
    
    final query = searchQuery.toLowerCase();
    return kunkerList.where((kunker) {
      return kunker.noSurat.toLowerCase().contains(query) ||
             kunker.anggota.toLowerCase().contains(query) ||
             kunker.ta.toLowerCase().contains(query) ||
             kunker.dapil.toLowerCase().contains(query) ||
             kunker.jenisPerjadin.toLowerCase().contains(query) ||
             kunker.tanggalAwal.toLowerCase().contains(query) ||
             kunker.tanggalAkhir.toLowerCase().contains(query) ||
             kunker.statusPengajuan.toLowerCase().contains(query) ||
             kunker.statusPencairan.toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredUIKunkerList {
    return filteredKunkerList.map((kunker) => kunker.toUIMap()).toList();
  }
}

// Kunker StateNotifier
class KunkerNotifier extends StateNotifier<KunkerState> {
  final KunkerRepository _repository;
  bool _isAddingKunker = false; // Simple lock for preventing concurrent adds

  KunkerNotifier(this._repository) : super(const KunkerState()) {
    loadKunkerData();
  }

  // Load all kunker data
  Future<void> loadKunkerData() async {
    print('DEBUG KunkerProvider: Loading kunker data...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final kunkerList = await _repository.getAllKunker();
      print('DEBUG KunkerProvider: Loaded ${kunkerList.length} kunker items');
      state = state.copyWith(
        kunkerList: kunkerList,
        isLoading: false,
      );
    } catch (e) {
      print('DEBUG KunkerProvider: Error loading kunker data: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadKunkerData();
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // Add new kunker
  Future<bool> addKunker(Map<String, dynamic> kunkerData) async {
    final noSurat = kunkerData['no_surat']?.toString().trim() ?? '';
    
    // Prevent concurrent adds
    if (_isAddingKunker || state.isLoading) {
      throw Exception('Sedang memproses pengajuan sebelumnya, silakan tunggu');
    }
    
    _isAddingKunker = true;
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Validate no_surat is not empty
      if (noSurat.isEmpty) {
        throw Exception('No. Surat tidak boleh kosong');
      }
      
      // Let the database helper handle duplicate validation
      await _repository.addKunkerFromUIMap(kunkerData);
      
      // Refresh the list without changing loading state
      await _refreshDataSilently();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    } finally {
      _isAddingKunker = false;
    }
  }

  // Refresh data without changing loading state
  Future<void> _refreshDataSilently() async {
    try {
      final kunkerList = await _repository.getAllKunker();
      state = state.copyWith(kunkerList: kunkerList, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Update kunker
  Future<bool> updateKunker(String noSurat, Map<String, dynamic> updatedData) async {
    try {
      await _repository.updateKunkerFromUIMap(noSurat, updatedData);
      await loadKunkerData(); // Refresh the list
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete kunker
  Future<bool> deleteKunkerByNoSurat(String noSurat) async {
    try {
      await _repository.deleteKunkerByNoSurat(noSurat);
      await loadKunkerData(); // Refresh the list
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Get kunker by No. Surat
  Future<KunkerModel?> getKunkerByNoSurat(String noSurat) async {
    try {
      return await _repository.getKunkerByNoSurat(noSurat);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Search kunker
  Future<void> searchKunker(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final searchResults = await _repository.searchKunker(query);
      state = state.copyWith(
        kunkerList: searchResults,
        isLoading: false,
        searchQuery: query,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get statistics
  Future<Map<String, int>> getStatusDistribution() async {
    try {
      return await _repository.getStatusDistribution();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return {};
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset loading state (for debugging/emergency)
  void resetState() {
    _isAddingKunker = false;
    state = state.copyWith(isLoading: false, error: null);
  }

  // Backward compatibility methods for existing UI
  
  // Add kunker (backward compatibility)
  void addKunkerLegacy(Map<String, dynamic> kunker) {
    addKunker(kunker);
  }

  // Remove kunker by index (backward compatibility)
  void removeKunker(int index) {
    if (index >= 0 && index < state.kunkerList.length) {
      final kunker = state.kunkerList[index];
      deleteKunkerByNoSurat(kunker.noSurat);
    }
  }

  // Update kunker (backward compatibility)
  void updateKunkerLegacy(String noSurat, Map<String, dynamic> updated) {
    updateKunker(noSurat, updated);
  }
}

// Main provider
final kunkerProvider = StateNotifierProvider<KunkerNotifier, KunkerState>((ref) {
  final repository = ref.watch(kunkerRepositoryProvider);
  return KunkerNotifier(repository);
});

// Search query provider (for backward compatibility)
final searchQueryProvider = StateProvider<String>((ref) => '');

// Watch search query and update main provider
final kunkerSearchProvider = Provider<void>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final kunkerNotifier = ref.read(kunkerProvider.notifier);
  
  // Update search query in main provider
  WidgetsBinding.instance.addPostFrameCallback((_) {
    kunkerNotifier.setSearchQuery(searchQuery);
  });
});

// Filtered kunker provider (KunkerModel)
final filteredKunkerProvider = Provider<List<KunkerModel>>((ref) {
  final kunkerState = ref.watch(kunkerProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (searchQuery.isEmpty) {
    return kunkerState.kunkerList;
  }

  return kunkerState.kunkerList.where((kunker) {
    return kunker.noSurat.toLowerCase().contains(searchQuery) ||
        kunker.anggota.toLowerCase().contains(searchQuery) ||
        kunker.ta.toLowerCase().contains(searchQuery) ||
        kunker.dapil.toLowerCase().contains(searchQuery) ||
        kunker.jenisPerjadin.toLowerCase().contains(searchQuery) ||
        kunker.tanggalAwal.toLowerCase().contains(searchQuery) ||
        kunker.tanggalAkhir.toLowerCase().contains(searchQuery) ||
        kunker.statusPengajuan.toLowerCase().contains(searchQuery) ||
        kunker.statusPencairan.toLowerCase().contains(searchQuery);
  }).toList();
});

// Legacy provider for backward compatibility with existing UI
final kunkerDataProvider = StateNotifierProvider<LegacyKunkerNotifier, List<Map<String, dynamic>>>((ref) {
  return LegacyKunkerNotifier(ref);
});

// Legacy notifier for backward compatibility
class LegacyKunkerNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref _ref;
  
  LegacyKunkerNotifier(this._ref) : super([]) {
    _initializeData();
  }

  void _initializeData() {
    // Listen to the main provider and sync the state
    _ref.listen(kunkerProvider, (previous, next) {
      state = next.uiKunkerList;
    });
    
    // Don't load initial data here to avoid race condition
    // Let the main provider handle initial loading
  }

  void addKunker(Map<String, dynamic> kunker) {
    _ref.read(kunkerProvider.notifier).addKunker(kunker);
  }

  void removeKunker(int index) {
    _ref.read(kunkerProvider.notifier).removeKunker(index);
  }

  void updateKunker(String noSurat, Map<String, dynamic> updated) {
    _ref.read(kunkerProvider.notifier).updateKunker(noSurat, updated);
  }
}

// Additional utility providers
final kunkerStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(kunkerRepositoryProvider);
  return await repository.getStatusDistribution();
});

final kunkerCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(kunkerRepositoryProvider);
  return await repository.getKunkerCount();
});

final recentKunkerProvider = FutureProvider<List<KunkerModel>>((ref) async {
  final repository = ref.watch(kunkerRepositoryProvider);
  return await repository.getRecentKunker(limit: 5);
});