import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/media_sosial_anggota_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/media_sosial_anggota_repository.dart';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';

// State untuk Media Sosial Anggota
class MediaSosialAnggotaState {
  final List<MediaSosialAnggotaModel> medsosList;
  final bool isLoading;
  final String? errorMessage;

  MediaSosialAnggotaState({
    this.medsosList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MediaSosialAnggotaState copyWith({
    List<MediaSosialAnggotaModel>? medsosList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MediaSosialAnggotaState(
      medsosList: medsosList ?? this.medsosList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
} 

// StateNotifier untuk Media Sosial Anggota
class MediaSosialAnggotaNotifier extends StateNotifier<MediaSosialAnggotaState> {
  final MediaSosialAnggotaRepository _repository;

  MediaSosialAnggotaNotifier(this._repository) : super(MediaSosialAnggotaState());

  Future<void> loadMediaSosial([int? userId]) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final medsosList = await _repository.getAllMediaSosial(userId);
      state = state.copyWith(
        medsosList: medsosList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> addMediaSosial({
    required String platform,
    required String username,
    required String url,
    int followers = 0,
    bool isVerified = false,
    String status = 'aktif',
    int? userId,
  }) async {
    try {
      final now = DateTime.now();
      final newMediaSosial = MediaSosialAnggotaModel(
        platform: platform,
        username: username,
        url: url,
        followers: followers,
        isVerified: isVerified,
        status: status,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addMediaSosial(newMediaSosial);
      await loadMediaSosial(userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateMediaSosial(MediaSosialAnggotaModel medsos) async {
    try {
      final updatedMediaSosial = medsos.copyWith(
        updatedAt: DateTime.now(),
      );
      await _repository.updateMediaSosial(updatedMediaSosial);
      await loadMediaSosial(medsos.userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteMediaSosial(int id, [int? userId]) async {
    try {
      await _repository.deleteMediaSosial(id);
      await loadMediaSosial(userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  List<MediaSosialAnggotaModel> searchMediaSosial(String keyword) {
    if (keyword.isEmpty) return state.medsosList;
    
    final lowerKeyword = keyword.toLowerCase();
    return state.medsosList.where((medsos) {
      return medsos.platform.toLowerCase().contains(lowerKeyword) ||
             medsos.username.toLowerCase().contains(lowerKeyword) ||
             medsos.url.toLowerCase().contains(lowerKeyword) ||
             medsos.status.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  List<MediaSosialAnggotaModel> getMediaSosialByPlatform(String platform) {
    return state.medsosList.where((medsos) => 
        medsos.platform.toLowerCase() == platform.toLowerCase()).toList();
  }

  MediaSosialAnggotaModel? getMediaSosialById(int id) {
    try {
      return state.medsosList.firstWhere((medsos) => medsos.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getUniquePlatforms() {
    final platforms = state.medsosList.map((medsos) => medsos.platform).toSet().toList();
    platforms.sort();
    return platforms;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider untuk Database Helper  
final appDatabaseHelperProvider = Provider<AppDatabaseHelper>((ref) {
  return AppDatabaseHelper();
});

// Provider untuk repository
final mediaSosialAnggotaRepositoryProvider = Provider<MediaSosialAnggotaRepository>((ref) {
  final databaseHelper = ref.watch(appDatabaseHelperProvider);
  return MediaSosialAnggotaRepository(databaseHelper);
});

// Provider utama untuk Media Sosial Anggota
final mediaSosialAnggotaProvider = StateNotifierProvider<MediaSosialAnggotaNotifier, MediaSosialAnggotaState>((ref) {
  final repository = ref.watch(mediaSosialAnggotaRepositoryProvider);
  return MediaSosialAnggotaNotifier(repository);
});