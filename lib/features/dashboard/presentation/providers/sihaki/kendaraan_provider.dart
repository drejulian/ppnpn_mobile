import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kendaraan_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/kendaraan_repository.dart';

// State class untuk Kendaraan
class KendaraanState {
  final List<KendaraanModel> kendaraanList;
  final bool isLoading;
  final String? error;
  final Map<String, int>? statistics;

  const KendaraanState({
    this.kendaraanList = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  KendaraanState copyWith({
    List<KendaraanModel>? kendaraanList,
    bool? isLoading,
    String? error,
    Map<String, int>? statistics,
  }) {
    return KendaraanState(
      kendaraanList: kendaraanList ?? this.kendaraanList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Repository Provider
final kendaraanRepositoryProvider = Provider<KendaraanRepository>((ref) {
  return KendaraanRepository();
});

// Notifier class untuk manage state
class KendaraanNotifier extends StateNotifier<KendaraanState> {
  final KendaraanRepository _repository;

  KendaraanNotifier(this._repository) : super(const KendaraanState()) {
    loadKendaraan();
  }

  // Load all kendaraan
  Future<void> loadKendaraan() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final kendaraanList = await _repository.getAllKendaraan();
      final statistics = await _repository.getKendaraanStatistics();
      
      state = state.copyWith(
        isLoading: false,
        kendaraanList: kendaraanList,
        statistics: statistics,
        error: null,
      );
      
      print('DEBUG: Loaded ${kendaraanList.length} kendaraan records');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('DEBUG: Error loading kendaraan: $e');
    }
  }

  // Save kendaraan
  Future<KendaraanModel?> saveKendaraan({
    required String namaAnggota,
    required String nopolDinas,
    required String nopolPribadi,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final kendaraan = await _repository.saveKendaraan(
        namaAnggota: namaAnggota,
        nopolDinas: nopolDinas,
        nopolPribadi: nopolPribadi,
      );
      
      // Reload data to get updated list
      await loadKendaraan();
      
      return kendaraan;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('DEBUG: Error saving kendaraan: $e');
      return null;
    }
  }

  // Get kendaraan by nama anggota
  Future<KendaraanModel?> getKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      return await _repository.getKendaraanByNamaAnggota(namaAnggota);
    } catch (e) {
      print('DEBUG: Error getting kendaraan by nama anggota: $e');
      return null;
    }
  }

  // Update kendaraan
  Future<bool> updateKendaraan(KendaraanModel kendaraan) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.updateKendaraan(kendaraan);
      
      // Reload data to get updated list
      await loadKendaraan();
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('DEBUG: Error updating kendaraan: $e');
      return false;
    }
  }

  // Delete kendaraan
  Future<bool> deleteKendaraan(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteKendaraan(id);
      
      // Reload data to get updated list
      await loadKendaraan();
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('DEBUG: Error deleting kendaraan: $e');
      return false;
    }
  }

  // Delete by nama anggota
  Future<bool> deleteKendaraanByNamaAnggota(String namaAnggota) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteKendaraanByNamaAnggota(namaAnggota);
      
      // Reload data to get updated list
      await loadKendaraan();
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('DEBUG: Error deleting kendaraan by nama anggota: $e');
      return false;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadKendaraan();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

// Main provider
final kendaraanProvider = StateNotifierProvider<KendaraanNotifier, KendaraanState>((ref) {
  final repository = ref.watch(kendaraanRepositoryProvider);
  return KendaraanNotifier(repository);
});