import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/models/sihaki/keanggotaan_model.dart';
import '../../../../../common/data/repositories/sihaki/keanggotaan_repository.dart';

// Repository provider
final keanggotaanRepositoryProvider = Provider<KeanggotaanRepository>((ref) {
  return KeanggotaanRepository();
});

// Keanggotaan state
class KeanggotaanState {
  final List<KeanggotaanModel> keanggotaanList;
  final bool isLoading;
  final String? errorMessage;
  final KeanggotaanModel? currentKeanggotaan;

  const KeanggotaanState({
    this.keanggotaanList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentKeanggotaan,
  });

  KeanggotaanState copyWith({
    List<KeanggotaanModel>? keanggotaanList,
    bool? isLoading,
    String? errorMessage,
    KeanggotaanModel? currentKeanggotaan,
  }) {
    return KeanggotaanState(
      keanggotaanList: keanggotaanList ?? this.keanggotaanList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentKeanggotaan: currentKeanggotaan ?? this.currentKeanggotaan,
    );
  }

  bool get hasData => keanggotaanList.isNotEmpty;
  bool get hasError => errorMessage != null;
  int get totalCount => keanggotaanList.length;
}

// Keanggotaan notifier
class KeanggotaanNotifier extends StateNotifier<KeanggotaanState> {
  final KeanggotaanRepository _repository;

  KeanggotaanNotifier(this._repository) : super(const KeanggotaanState());

  // Load all keanggotaan
  Future<void> loadKeanggotaan() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final keanggotaanList = await _repository.getAllKeanggotaan();
      state = state.copyWith(
        keanggotaanList: keanggotaanList,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Load keanggotaan by ID
  Future<void> loadKeanggotaanById(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final keanggotaan = await _repository.getKeanggotaanById(id);
      state = state.copyWith(
        currentKeanggotaan: keanggotaan,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Load keanggotaan by no anggota
  Future<KeanggotaanModel?> loadKeanggotaanByNoAnggota(String noAnggota) async {
    try {
      return await _repository.getKeanggotaanByNoAnggota(noAnggota);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Add new keanggotaan
  Future<bool> addKeanggotaan({
    required String nama,
    required String noAnggota,
    required String fraksi,
    required String dapil,
    required String area,
    String? noRekening,
    required String namaRekening,
    String? userId,
  }) async {
    try {
      // Check if no anggota already exists
      final exists = await _repository.isNoAnggotaExists(noAnggota);
      if (exists) {
        state = state.copyWith(
          errorMessage: 'Nomor anggota "$noAnggota" sudah terdaftar',
        );
        return false;
      }

      final newKeanggotaan = await _repository.addKeanggotaan(
        nama: nama,
        noAnggota: noAnggota,
        fraksi: fraksi,
        dapil: dapil,
        area: area,
        noRekening: noRekening,
        namaRekening: namaRekening,
        userId: userId,
      );

      // Update state with new keanggotaan
      final updatedList = [...state.keanggotaanList, newKeanggotaan];
      state = state.copyWith(
        keanggotaanList: updatedList,
        currentKeanggotaan: newKeanggotaan,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Update existing keanggotaan
  Future<bool> updateKeanggotaan(KeanggotaanModel keanggotaan) async {
    try {
      // Check if no anggota already exists (excluding current record)
      final exists = await _repository.isNoAnggotaExists(
        keanggotaan.noAnggota,
        excludeId: keanggotaan.id,
      );
      if (exists) {
        state = state.copyWith(
          errorMessage: 'Nomor anggota "${keanggotaan.noAnggota}" sudah terdaftar',
        );
        return false;
      }

      final updatedKeanggotaan = await _repository.updateKeanggotaan(keanggotaan);

      // Update state
      final updatedList = state.keanggotaanList.map((item) {
        return item.id == updatedKeanggotaan.id ? updatedKeanggotaan : item;
      }).toList();

      state = state.copyWith(
        keanggotaanList: updatedList,
        currentKeanggotaan: updatedKeanggotaan,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Delete keanggotaan
  Future<bool> deleteKeanggotaan(int id) async {
    try {
      final success = await _repository.deleteKeanggotaan(id);
      
      if (success) {
        final updatedList = state.keanggotaanList.where((item) => item.id != id).toList();
        state = state.copyWith(
          keanggotaanList: updatedList,
          errorMessage: null,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Search keanggotaan
  Future<void> searchKeanggotaan(String query) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final searchResults = await _repository.searchKeanggotaan(query);
      state = state.copyWith(
        keanggotaanList: searchResults,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Get keanggotaan statistics
  Future<Map<String, dynamic>?> getKeanggotaanStatistics() async {
    try {
      return await _repository.getKeanggotaanStatistics();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadKeanggotaan();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

// Main provider
final keanggotaanProvider = StateNotifierProvider<KeanggotaanNotifier, KeanggotaanState>((ref) {
  final repository = ref.watch(keanggotaanRepositoryProvider);
  return KeanggotaanNotifier(repository);
});

// Search query provider
final keanggotaanSearchProvider = StateProvider<String>((ref) => '');

// Filtered keanggotaan provider
final filteredKeanggotaanProvider = Provider<List<KeanggotaanModel>>((ref) {
  final keanggotaanState = ref.watch(keanggotaanProvider);
  final query = ref.watch(keanggotaanSearchProvider).toLowerCase().trim();

  if (query.isEmpty) return keanggotaanState.keanggotaanList;

  return keanggotaanState.keanggotaanList.where((keanggotaan) {
    return keanggotaan.nama.toLowerCase().contains(query) ||
        keanggotaan.noAnggota.toLowerCase().contains(query) ||
        keanggotaan.fraksi.toLowerCase().contains(query) ||
        keanggotaan.dapil.toLowerCase().contains(query);
  }).toList();
});

// Current keanggotaan provider
final currentKeanggotaanProvider = Provider<KeanggotaanModel?>((ref) {
  final keanggotaanState = ref.watch(keanggotaanProvider);
  return keanggotaanState.currentKeanggotaan;
});

// Statistics provider
final keanggotaanStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final keanggotaanNotifier = ref.watch(keanggotaanProvider.notifier);
  final statistics = await keanggotaanNotifier.getKeanggotaanStatistics();
  return statistics ?? {};
});