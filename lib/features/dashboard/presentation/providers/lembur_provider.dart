import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/data/models/menuutama/lembur_model.dart';
import '../../../../common/data/repositories/menuutama/lembur_repository.dart';

// State for lembur list management
class LemburState {
  final List<LemburModel> lemburList;
  final bool isLoading;
  final String? error;

  const LemburState({
    this.lemburList = const [],
    this.isLoading = false,
    this.error,
  });

  LemburState copyWith({
    List<LemburModel>? lemburList,
    bool? isLoading,
    String? error,
  }) {
    return LemburState(
      lemburList: lemburList ?? this.lemburList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Main lembur provider using StateNotifier
class LemburNotifier extends StateNotifier<LemburState> {
  final LemburRepository _repository;

  LemburNotifier(this._repository) : super(const LemburState()) {
    loadLembur();
  }

  Future<void> loadLembur() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lemburList = await _repository.getAllLembur();
      state = state.copyWith(lemburList: lemburList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addLembur(LemburModel lembur) async {
    try {
     
      await _repository.addLembur(
        type: lembur.type,
        date: lembur.date,
        startTime: lembur.startTime,
        endTime: lembur.endTime,
        duration: lembur.duration,
        reason: lembur.reason,
        fileName: lembur.fileName,
        userId: lembur.userId,
      );
    
      await loadLembur(); // Refresh list
      
    } catch (e) {
    
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateLembur(LemburModel lembur) async {
    try {
      if (lembur.id == null) {
        throw Exception('Cannot update lembur without ID');
      }
      await _repository.updateLembur(
        id: lembur.id!,
        type: lembur.type,
        date: lembur.date,
        startTime: lembur.startTime,
        endTime: lembur.endTime,
        duration: lembur.duration,
        reason: lembur.reason,
        fileName: lembur.fileName,
      );
      await loadLembur(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteLembur(int id) async {
    try {
      await _repository.deleteLembur(id);
      await loadLembur(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateLemburStatus(int id, String status) async {
    try {
      await _repository.updateLemburStatus(id, status);
      await loadLembur(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadLembur();
  }
}

// Repository provider
final lemburRepositoryProvider = Provider<LemburRepository>((ref) {
  return LemburRepository();
});

// Main lembur provider
final lemburProvider = StateNotifierProvider<LemburNotifier, LemburState>((ref) {
  final repository = ref.watch(lemburRepositoryProvider);
  return LemburNotifier(repository);
});

// Derived providers for specific data access
final lemburListProvider = Provider<List<LemburModel>>((ref) {
  return ref.watch(lemburProvider).lemburList;
});

final lemburLoadingProvider = Provider<bool>((ref) {
  return ref.watch(lemburProvider).isLoading;
});

final lemburErrorProvider = Provider<String?>((ref) {
  return ref.watch(lemburProvider).error;
});

// Search provider
final lemburSearchProvider = StateProvider<String>((ref) => '');

// Status filter provider
final lemburStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

// Filtered lembur provider
final filteredLemburProvider = Provider<List<LemburModel>>((ref) {
  final lemburList = ref.watch(lemburListProvider);
  final searchQuery = ref.watch(lemburSearchProvider);
  final statusFilter = ref.watch(lemburStatusFilterProvider);

  var filteredList = lemburList;

  // Apply status filter
  if (statusFilter != 'Semua') {
    filteredList = filteredList.where((lembur) => lembur.uiStatus == statusFilter).toList();
  }

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filteredList = filteredList.where((lembur) {
      final searchText = '${lembur.id} ${lembur.type} ${lembur.reason}'.toLowerCase();
      return searchText.contains(query);
    }).toList();
  }

  return filteredList;
});

// Statistics providers
final lemburCountProvider = Provider<int>((ref) {
  return ref.watch(lemburListProvider).length;
});

final lemburPendingCountProvider = Provider<int>((ref) {
  final lemburList = ref.watch(lemburListProvider);
  return lemburList.where((lembur) => lembur.uiStatus == 'Menunggu Persetujuan').length;
});

final lemburApprovedCountProvider = Provider<int>((ref) {
  final lemburList = ref.watch(lemburListProvider);
  return lemburList.where((lembur) => lembur.uiStatus == 'Disetujui').length;
});

final lemburRejectedCountProvider = Provider<int>((ref) {
  final lemburList = ref.watch(lemburListProvider);
  return lemburList.where((lembur) => lembur.uiStatus == 'Ditolak').length;
});

// Recent lembur provider (last 5)
final recentLemburProvider = Provider<List<LemburModel>>((ref) {
  final lemburList = ref.watch(lemburListProvider);
  final sortedList = [...lemburList];
  sortedList.sort((a, b) => b.date.compareTo(a.date));
  return sortedList.take(5).toList();
});

// Lembur by status providers
final lemburByStatusProvider = Provider.family<List<LemburModel>, String>((ref, status) {
  final lemburList = ref.watch(lemburListProvider);
  if (status == 'Semua') return lemburList;
  return lemburList.where((lembur) => lembur.uiStatus == status).toList();
});

// Monthly lembur provider
final monthlyLemburProvider = Provider.family<List<LemburModel>, DateTime>((ref, month) {
  final lemburList = ref.watch(lemburListProvider);
  return lemburList.where((lembur) {
    return lembur.date.year == month.year && lembur.date.month == month.month;
  }).toList();
});