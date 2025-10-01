import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kegiatan_rumah_aspirasi_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/kegiatan_rumah_aspirasi_repository.dart';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';

// State untuk Kegiatan Rumah Aspirasi
class KegiatanRumahAspirasiState {
  final List<KegiatanRumahAspirasiModel> kegiatanList;
  final bool isLoading;
  final String? errorMessage;

  KegiatanRumahAspirasiState({
    this.kegiatanList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KegiatanRumahAspirasiState copyWith({
    List<KegiatanRumahAspirasiModel>? kegiatanList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KegiatanRumahAspirasiState(
      kegiatanList: kegiatanList ?? this.kegiatanList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// StateNotifier untuk Kegiatan Rumah Aspirasi
class KegiatanRumahAspirasiNotifier extends StateNotifier<KegiatanRumahAspirasiState> {
  final KegiatanRumahAspirasiRepository _repository;

  KegiatanRumahAspirasiNotifier(this._repository) : super(KegiatanRumahAspirasiState());

  Future<void> loadKegiatan([int? userId]) async {
    print('🔄 Loading kegiatan rumah aspirasi...');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final kegiatanList = await _repository.getAllKegiatanRumahAspirasi();
      print('✅ Loaded ${kegiatanList.length} kegiatan rumah aspirasi');
      
      state = state.copyWith(
        kegiatanList: kegiatanList,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading kegiatan: $e');
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> addKegiatan({
    required String namaKegiatan,
    required String tanggalKegiatan,
    required String waktuMulai,
    required String waktuSelesai,
    required String tempat,
    String? deskripsi,
    int jumlahPeserta = 0,
    required String pic,
    String? kontakPic,
    String status = 'direncanakan',
  }) async {
    try {
      print('➕ Adding new kegiatan: $namaKegiatan');
      final now = DateTime.now();
      final newKegiatan = KegiatanRumahAspirasiModel(
        namaKegiatan: namaKegiatan,
        tanggalKegiatan: tanggalKegiatan,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        tempat: tempat,
        deskripsi: deskripsi,
        jumlahPeserta: jumlahPeserta,
        pic: pic,
        kontakPic: kontakPic,
        status: status,
        userId: null, // Set to null for now since we don't have user auth
        createdAt: now,
        updatedAt: now,
      );

      final result = await _repository.addKegiatanRumahAspirasi(newKegiatan);
      print('✅ Kegiatan berhasil ditambahkan ke database dengan ID: $result');
      
      await loadKegiatan(); // Reload data tanpa userId filter
      print('✅ Data refreshed after adding. Total items now: ${state.kegiatanList.length}');
      
      return true;
    } catch (e) {
      print('❌ Error adding kegiatan: $e');
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateKegiatan(KegiatanRumahAspirasiModel kegiatan) async {
    try {
      final updatedKegiatan = kegiatan.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateKegiatanRumahAspirasi(updatedKegiatan);
      await loadKegiatan(); // Reload data tanpa userId filter
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteKegiatan(int id) async {
    try {
      await _repository.deleteKegiatanRumahAspirasi(id);
      
      // Update state lokal
      final updatedList = state.kegiatanList.where((k) => k.id != id).toList();
      state = state.copyWith(kegiatanList: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Search functionality
  List<KegiatanRumahAspirasiModel> searchKegiatan(String keyword) {
    if (keyword.isEmpty) return state.kegiatanList;
    
    final lowerKeyword = keyword.toLowerCase();
    return state.kegiatanList.where((kegiatan) {
      return kegiatan.namaKegiatan.toLowerCase().contains(lowerKeyword) ||
             kegiatan.tanggalKegiatan.toLowerCase().contains(lowerKeyword) ||
             kegiatan.tempat.toLowerCase().contains(lowerKeyword) ||
             kegiatan.pic.toLowerCase().contains(lowerKeyword) ||
             kegiatan.status.toLowerCase().contains(lowerKeyword) ||
             (kegiatan.deskripsi?.toLowerCase().contains(lowerKeyword) ?? false);
    }).toList();
  }

  // Filter by status
  List<KegiatanRumahAspirasiModel> getKegiatanByStatus(String status) {
    return state.kegiatanList.where((k) => k.status == status).toList();
  }

  // Filter by date range
  List<KegiatanRumahAspirasiModel> getKegiatanByDateRange(String startDate, String endDate) {
    return state.kegiatanList.where((k) {
      // Simple string comparison for dates in YYYY-MM-DD format
      return k.tanggalKegiatan.compareTo(startDate) >= 0 &&
             k.tanggalKegiatan.compareTo(endDate) <= 0;
    }).toList();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider untuk Database Helper  
final appDatabaseHelperProvider = Provider<AppDatabaseHelper>((ref) {
  return AppDatabaseHelper();
});

// Provider untuk Repository
final kegiatanRumahAspirasiRepositoryProvider = Provider<KegiatanRumahAspirasiRepository>((ref) {
  final databaseHelper = ref.watch(appDatabaseHelperProvider);
  return KegiatanRumahAspirasiRepository(databaseHelper);
});

// Provider untuk StateNotifier
final kegiatanRumahAspirasiProvider = StateNotifierProvider<KegiatanRumahAspirasiNotifier, KegiatanRumahAspirasiState>((ref) {
  final repository = ref.watch(kegiatanRumahAspirasiRepositoryProvider);
  return KegiatanRumahAspirasiNotifier(repository);
});