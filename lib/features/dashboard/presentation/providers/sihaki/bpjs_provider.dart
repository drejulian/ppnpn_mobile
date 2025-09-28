import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/models/sihaki/bpjs_model.dart';
import '../../../../../common/data/repositories/sihaki/bpjs_repository.dart';
import '../../../../../common/data/database/app_database_helper.dart';

// State untuk BPJS
class BPJSState {
  final List<BPJSModel> bpjsList;
  final bool isLoading;
  final String? errorMessage;

  const BPJSState({
    this.bpjsList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BPJSState copyWith({
    List<BPJSModel>? bpjsList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BPJSState(
      bpjsList: bpjsList ?? this.bpjsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// StateNotifier untuk mengelola state BPJS
class BPJSNotifier extends StateNotifier<BPJSState> {
  final BPJSRepository _repository;

  BPJSNotifier(this._repository) : super(const BPJSState());

  Future<void> loadBPJS() async {
    state = state.copyWith(isLoading: true);
    try {
      final bpjsList = await _repository.getAllBPJS();
      print('✅ Loaded ${bpjsList.length} BPJS data');
      
      state = state.copyWith(
        bpjsList: bpjsList,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading BPJS: $e');
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> addBPJS({
    required String nama,
    required String noBPJS,
    required String nik,
    required String hubunganKeluarga,
    required String tanggalLahir,
    required String namaFaskesTingkat1,
    String status = 'aktif',
  }) async {
    try {
      print('➕ Adding new BPJS: $nama');
      print('📊 Provider received data:');
      print('   - Nama: $nama');
      print('   - No BPJS: $noBPJS');
      print('   - NIK: $nik');
      print('   - Hubungan: $hubunganKeluarga');
      print('   - Tanggal Lahir: $tanggalLahir');
      print('   - Faskes: $namaFaskesTingkat1');
      print('   - Status: $status');
      
      // Validasi input data
      if (nama.trim().isEmpty) throw Exception('Nama tidak boleh kosong');
      if (noBPJS.trim().isEmpty) throw Exception('Nomor BPJS tidak boleh kosong');
      if (nik.trim().isEmpty) throw Exception('NIK tidak boleh kosong');
      if (hubunganKeluarga.trim().isEmpty) throw Exception('Hubungan keluarga tidak boleh kosong');
      if (tanggalLahir.trim().isEmpty) throw Exception('Tanggal lahir tidak boleh kosong');
      if (namaFaskesTingkat1.trim().isEmpty) throw Exception('Nama faskes tidak boleh kosong');
      
      // Validasi format
      if (noBPJS.trim().length != 13) throw Exception('Nomor BPJS harus 13 digit');
      if (nik.trim().length != 16) throw Exception('NIK harus 16 digit');
      if (!['aktif', 'non-aktif', 'pending'].contains(status)) {
        throw Exception('Status tidak valid: $status');
      }
      
      final now = DateTime.now();
      final newBPJS = BPJSModel(
        nama: nama.trim(),
        noBPJS: noBPJS.trim(),
        nik: nik.trim(),
        hubunganKeluarga: hubunganKeluarga.trim(),
        tanggalLahir: tanggalLahir.trim(),
        namaFaskesTingkat1: namaFaskesTingkat1.trim(),
        status: status,
        userId: null, // Set to null for now since we don't have user auth
        createdAt: now,
        updatedAt: now,
      );

      print('🗄️ Calling repository.addBPJS...');
      final result = await _repository.addBPJS(newBPJS);
      print('✅ BPJS berhasil ditambahkan ke database dengan ID: $result');
      
      print('🔄 Reloading data...');
      await loadBPJS(); // Reload data tanpa userId filter
      print('✅ Data refreshed after adding. Total items now: ${state.bpjsList.length}');
      
      return true;
    } catch (e) {
      print('❌ Error adding BPJS: $e');
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateBPJS(BPJSModel bpjs) async {
    try {
      final updatedBPJS = bpjs.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateBPJS(updatedBPJS);
      await loadBPJS(); // Reload data tanpa userId filter
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteBPJS(int id) async {
    try {
      await _repository.deleteBPJS(id);
      
      // Update state lokal
      state = state.copyWith(
        bpjsList: state.bpjsList.where((bpjs) => bpjs.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateStatusBPJS(int id, String statusBaru) async {
    try {
      await _repository.updateStatusBPJS(id, statusBaru);
      await loadBPJS(); // Reload untuk mendapatkan data terbaru
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  List<BPJSModel> getBPJSByStatus(String status) {
    return state.bpjsList
        .where((bpjs) => bpjs.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  List<BPJSModel> getBPJSByHubunganKeluarga(String hubunganKeluarga) {
    return state.bpjsList
        .where((bpjs) => bpjs.hubunganKeluarga
            .toLowerCase()
            .contains(hubunganKeluarga.toLowerCase()))
        .toList();
  }

  Future<Map<String, dynamic>> getBPJSStatistics() async {
    try {
      return await _repository.getBPJSStatistics();
    } catch (e) {
      throw Exception('Failed to get BPJS statistics: $e');
    }
  }
}

// Provider untuk dependencies
final appDatabaseHelperProvider = Provider<AppDatabaseHelper>((ref) {
  return AppDatabaseHelper();
});

final bpjsRepositoryProvider = Provider<BPJSRepository>((ref) {
  final databaseHelper = ref.watch(appDatabaseHelperProvider);
  return BPJSRepository(databaseHelper);
});

// Provider utama untuk BPJS
final bpjsProvider = StateNotifierProvider<BPJSNotifier, BPJSState>((ref) {
  final repository = ref.watch(bpjsRepositoryProvider);
  return BPJSNotifier(repository);
});