import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/data/models/menuutama/izin_model.dart';
import '../../../../common/data/repositories/menuutama/izin_repository.dart';

// State for izin list management
class IzinState {
  final List<IzinModel> izinList;
  final bool isLoading;
  final String? error;

  const IzinState({
    this.izinList = const [],
    this.isLoading = false,
    this.error,
  });

  IzinState copyWith({
    List<IzinModel>? izinList,
    bool? isLoading,
    String? error,
  }) {
    return IzinState(
      izinList: izinList ?? this.izinList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Main izin provider using StateNotifier
class IzinNotifier extends StateNotifier<IzinState> {
  final IzinRepository _repository;

  IzinNotifier(this._repository) : super(const IzinState()) {
    loadIzin();
  }

  Future<void> loadIzin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final izinList = await _repository.getAllIzin();
      state = state.copyWith(izinList: izinList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addIzin(IzinModel izin) async {
    try {
      print('DEBUG: Provider addIzin called with: ${izin.toMap()}'); // Debug log
      await _repository.addIzin(
        type: izin.type,
        date: izin.date,
        duration: izin.duration,
        reason: izin.reason,
        fileName: izin.fileName,
        userId: izin.userId,
      );
      print('DEBUG: Repository addIzin completed, refreshing list...'); // Debug log
      await loadIzin(); // Refresh list
      print('DEBUG: List refreshed, new state: ${state.izinList.length} items'); // Debug log
    } catch (e) {
      print('DEBUG: Error in addIzin: $e'); // Debug log
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateIzin(IzinModel izin) async {
    try {
      if (izin.id == null) {
        throw Exception('Cannot update izin without ID');
      }
      await _repository.updateIzin(
        id: izin.id!,
        type: izin.type,
        date: izin.date,
        duration: izin.duration,
        reason: izin.reason,
        fileName: izin.fileName,
      );
      await loadIzin(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteIzin(int id) async {
    try {
      await _repository.deleteIzin(id);
      await loadIzin(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<IzinModel>> searchIzin(String query) async {
    try {
      return await _repository.searchIzin(query);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, int>> getStatistics() async {
    try {
      return await _repository.getIzinStatistics();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Repository provider
final izinRepositoryProvider = Provider<IzinRepository>((ref) => IzinRepository());

// Main provider
final izinProvider = StateNotifierProvider<IzinNotifier, IzinState>((ref) {
  final repository = ref.watch(izinRepositoryProvider);
  return IzinNotifier(repository);
});

// Search query provider
final izinSearchProvider = StateProvider<String>((ref) => '');

// Status filter provider
final izinStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

// Filtered izin provider
final filteredIzinProvider = Provider<List<IzinModel>>((ref) {
  final izinState = ref.watch(izinProvider);
  final searchQuery = ref.watch(izinSearchProvider);
  final statusFilter = ref.watch(izinStatusFilterProvider);

  List<IzinModel> filtered = izinState.izinList;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((izin) {
      final query = searchQuery.toLowerCase();
      return izin.type.toLowerCase().contains(query) ||
             izin.reason.toLowerCase().contains(query) ||
             izin.id.toString().contains(query);
    }).toList();
  }

  // Apply status filter
  if (statusFilter != 'Semua') {
    filtered = filtered.where((izin) => izin.uiStatus == statusFilter).toList();
  }

  return filtered;
});

// Loading state provider
final izinLoadingProvider = Provider<bool>((ref) {
  return ref.watch(izinProvider).isLoading;
});

// Error state provider
final izinErrorProvider = Provider<String?>((ref) {
  return ref.watch(izinProvider).error;
});

// Statistics provider
final izinStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final notifier = ref.watch(izinProvider.notifier);
  return await notifier.getStatistics();
});

// Providers for specific status counts
final pendingIzinCountProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Menunggu Persetujuan').length;
});

final approvedIzinCountProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Disetujui').length;
});

final rejectedIzinCountProvider = Provider<int>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  return izinList.where((izin) => izin.uiStatus == 'Ditolak').length;
});

// Recent izin provider (last 5)
final recentIzinProvider = Provider<List<IzinModel>>((ref) {
  final izinList = ref.watch(izinProvider).izinList;
  final sortedList = [...izinList];
  sortedList.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
  return sortedList.take(5).toList();
});