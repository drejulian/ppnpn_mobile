import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kesehatan_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/kesehatan_repository.dart';

// Repository provider
final kesehatanRepositoryProvider = Provider<KesehatanRepository>((ref) {
  return KesehatanRepository();
});

// State class for kesehatan
class KesehatanState {
  final List<KesehatanModel> kesehatanList;
  final bool isLoading;
  final String? error;
  final KesehatanModel? currentKesehatan;

  const KesehatanState({
    this.kesehatanList = const [],
    this.isLoading = false,
    this.error,
    this.currentKesehatan,
  });

  KesehatanState copyWith({
    List<KesehatanModel>? kesehatanList,
    bool? isLoading,
    String? error,
    KesehatanModel? currentKesehatan,
  }) {
    return KesehatanState(
      kesehatanList: kesehatanList ?? this.kesehatanList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentKesehatan: currentKesehatan ?? this.currentKesehatan,
    );
  }
}

// Notifier class for kesehatan
class KesehatanNotifier extends StateNotifier<KesehatanState> {
  final KesehatanRepository _repository;

  KesehatanNotifier(this._repository) : super(const KesehatanState());

  // Load kesehatan by nama anggota
  Future<void> loadKesehatanByNama(String namaAnggota) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final kesehatan = await _repository.getKesehatanByNama(namaAnggota);
      
      state = state.copyWith(
        isLoading: false,
        currentKesehatan: kesehatan,
        error: null,
      );
      
      print('KesehatanProvider: Loaded kesehatan for $namaAnggota: ${kesehatan?.toString()}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('KesehatanProvider: Error loading kesehatan: $e');
    }
  }

  // Load all kesehatan
  Future<void> loadAllKesehatan() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final kesehatanList = await _repository.getAllKesehatan();
      
      state = state.copyWith(
        isLoading: false,
        kesehatanList: kesehatanList,
        error: null,
      );
      
      print('KesehatanProvider: Loaded ${kesehatanList.length} kesehatan records');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('KesehatanProvider: Error loading all kesehatan: $e');
    }
  }

  // Save kesehatan
  Future<bool> saveKesehatan({
    required String namaAnggota,
    required String beratBadan,
    required String tinggiBadan,
    required String golonganDarah,
    String? riwayatPenyakit,
    String? alergi,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final kesehatan = await _repository.saveKesehatan(
        namaAnggota: namaAnggota,
        beratBadan: beratBadan,
        tinggiBadan: tinggiBadan,
        golonganDarah: golonganDarah,
        riwayatPenyakit: riwayatPenyakit,
        alergi: alergi,
      );
      
      state = state.copyWith(
        isLoading: false,
        currentKesehatan: kesehatan,
        error: null,
      );
      
      print('KesehatanProvider: Saved kesehatan for $namaAnggota');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('KesehatanProvider: Error saving kesehatan: $e');
      return false;
    }
  }

  // Update kesehatan
  Future<bool> updateKesehatan(KesehatanModel kesehatan) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedKesehatan = await _repository.updateKesehatan(kesehatan);
      
      state = state.copyWith(
        isLoading: false,
        currentKesehatan: updatedKesehatan,
        error: null,
      );
      
      print('KesehatanProvider: Updated kesehatan for ${kesehatan.namaAnggota}');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('KesehatanProvider: Error updating kesehatan: $e');
      return false;
    }
  }

  // Delete kesehatan by nama anggota
  Future<bool> deleteKesehatanByNama(String namaAnggota) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _repository.deleteKesehatanByNama(namaAnggota);
      
      if (success) {
        // Clear current kesehatan if it matches
        if (state.currentKesehatan?.namaAnggota == namaAnggota) {
          state = state.copyWith(
            isLoading: false,
            currentKesehatan: null,
            error: null,
          );
        } else {
          state = state.copyWith(isLoading: false, error: null);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Gagal menghapus data kesehatan',
        );
      }
      
      print('KesehatanProvider: Delete kesehatan for $namaAnggota: $success');
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('KesehatanProvider: Error deleting kesehatan: $e');
      return false;
    }
  }

  // Check if kesehatan exists
  Future<bool> kesehatanExists(String namaAnggota) async {
    try {
      return await _repository.kesehatanExists(namaAnggota);
    } catch (e) {
      print('KesehatanProvider: Error checking kesehatan existence: $e');
      return false;
    }
  }

  // Clear state
  void clearState() {
    state = const KesehatanState();
    print('KesehatanProvider: State cleared');
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

// Main provider
final kesehatanProvider = StateNotifierProvider<KesehatanNotifier, KesehatanState>((ref) {
  final repository = ref.watch(kesehatanRepositoryProvider);
  return KesehatanNotifier(repository);
});

// Provider for current kesehatan
final currentKesehatanProvider = Provider<KesehatanModel?>((ref) {
  final kesehatanState = ref.watch(kesehatanProvider);
  return kesehatanState.currentKesehatan;
});

// Provider for loading state
final kesehatanLoadingProvider = Provider<bool>((ref) {
  final kesehatanState = ref.watch(kesehatanProvider);
  return kesehatanState.isLoading;
});

// Provider for error state
final kesehatanErrorProvider = Provider<String?>((ref) {
  final kesehatanState = ref.watch(kesehatanProvider);
  return kesehatanState.error;
});