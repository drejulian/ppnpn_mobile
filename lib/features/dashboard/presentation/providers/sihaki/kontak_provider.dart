import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/repositories/sihaki/kontak_repository.dart';
import '../../../../../common/data/models/sihaki/kontak_model.dart';

// State untuk menyimpan status loading dan data kontak
class KontakState {
  final bool isLoading;
  final KontakModel? kontak;
  final String? errorMessage;
  final List<KontakModel> allKontak;

  const KontakState({
    this.isLoading = false,
    this.kontak,
    this.errorMessage,
    this.allKontak = const [],
  });

  KontakState copyWith({
    bool? isLoading,
    KontakModel? kontak,
    String? errorMessage,
    List<KontakModel>? allKontak,
  }) {
    return KontakState(
      isLoading: isLoading ?? this.isLoading,
      kontak: kontak ?? this.kontak,
      errorMessage: errorMessage ?? this.errorMessage,
      allKontak: allKontak ?? this.allKontak,
    );
  }
}

// Notifier untuk mengelola state kontak
class KontakNotifier extends StateNotifier<KontakState> {
  final KontakRepository _repository;

  KontakNotifier(this._repository) : super(const KontakState());

  // Save kontak data
  Future<void> saveKontak({
    required String namaAnggota,
    required String noKontak,
    required String namaKontak,
    required String hubunganKontak,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final kontak = await _repository.saveKontak(
        namaAnggota: namaAnggota,
        noKontak: noKontak,
        namaKontak: namaKontak,
        hubunganKontak: hubunganKontak,
      );

      state = state.copyWith(
        isLoading: false,
        kontak: kontak,
        errorMessage: null,
      );

      print('KontakProvider: Successfully saved kontak for $namaAnggota');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      
      print('KontakProvider: Error saving kontak: $e');
      rethrow;
    }
  }

  // Load kontak by nama anggota
  Future<void> loadKontakByNama(String namaAnggota) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final kontak = await _repository.getKontakByNama(namaAnggota);

      state = state.copyWith(
        isLoading: false,
        kontak: kontak,
        errorMessage: null,
      );

      print('KontakProvider: Loaded kontak for $namaAnggota: ${kontak != null}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error loading kontak: $e');
      rethrow;
    }
  }

  // Load all kontak
  Future<void> loadAllKontak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final allKontak = await _repository.getAllKontak();

      state = state.copyWith(
        isLoading: false,
        allKontak: allKontak,
        errorMessage: null,
      );

      print('KontakProvider: Loaded ${allKontak.length} kontak records');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error loading all kontak: $e');
      rethrow;
    }
  }

  // Get latest kontak
  Future<void> loadLatestKontak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final kontak = await _repository.getLatestKontak();

      state = state.copyWith(
        isLoading: false,
        kontak: kontak,
        errorMessage: null,
      );

      print('KontakProvider: Loaded latest kontak: ${kontak?.namaAnggota}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error loading latest kontak: $e');
      rethrow;
    }
  }

  // Update kontak
  Future<void> updateKontak(KontakModel kontak) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedKontak = await _repository.updateKontak(kontak);

      state = state.copyWith(
        isLoading: false,
        kontak: updatedKontak,
        errorMessage: null,
      );

      print('KontakProvider: Updated kontak for ${updatedKontak.namaAnggota}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error updating kontak: $e');
      rethrow;
    }
  }

  // Delete kontak by nama anggota
  Future<void> deleteKontakByNama(String namaAnggota) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deleteKontakByNama(namaAnggota);

      if (success) {
        // Remove from current state if it's the same kontak
        if (state.kontak?.namaAnggota == namaAnggota) {
          state = state.copyWith(
            isLoading: false,
            kontak: null,
            errorMessage: null,
          );
        }

        // Reload all kontak to refresh the list
        await loadAllKontak();
      }

      print('KontakProvider: Deleted kontak for $namaAnggota: $success');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error deleting kontak: $e');
      rethrow;
    }
  }

  // Clear all kontak data
  Future<void> clearAllKontak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.clearAllKontak();

      state = state.copyWith(
        isLoading: false,
        kontak: null,
        allKontak: [],
        errorMessage: null,
      );

      print('KontakProvider: Cleared all kontak data');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      print('KontakProvider: Error clearing kontak data: $e');
      rethrow;
    }
  }

  // Reset state
  void resetState() {
    state = const KontakState();
  }
}

// Repository provider
final kontakRepositoryProvider = Provider<KontakRepository>((ref) {
  return KontakRepository();
});

// State notifier provider
final kontakProvider = StateNotifierProvider<KontakNotifier, KontakState>((ref) {
  final repository = ref.read(kontakRepositoryProvider);
  return KontakNotifier(repository);
});

// Helper providers for easier access
final kontakIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(kontakProvider).isLoading;
});

final currentKontakProvider = Provider<KontakModel?>((ref) {
  return ref.watch(kontakProvider).kontak;
});

final allKontakProvider = Provider<List<KontakModel>>((ref) {
  return ref.watch(kontakProvider).allKontak;
});

final kontakErrorProvider = Provider<String?>((ref) {
  return ref.watch(kontakProvider).errorMessage;
});