import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/izin_model.dart';

class IzinAsyncNotifier extends AsyncNotifier<List<IzinModel>> {
  final AppDatabaseHelper _databaseHelper = AppDatabaseHelper();

  @override
  Future<List<IzinModel>> build() async {
    return await getAllIzin();
  }

  Future<List<IzinModel>> getAllIzin() async {
    try {
      final izinMaps = await _databaseHelper.getAllIzin();
      return izinMaps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load izin data: $e');
    }
  }

  Future<List<IzinModel>> getIzinByUserId(int userId) async {
    try {
      final izinMaps = await _databaseHelper.getIzinByUserId(userId);
      return izinMaps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load izin data for user $userId: $e');
    }
  }

  Future<void> addIzin(IzinModel izin) async {
    state = const AsyncLoading();
    
    try {
      await _databaseHelper.insertIzin(
        type: izin.type,
        date: izin.date,
        duration: izin.duration,
        reason: izin.reason,
        status: izin.status,
        fileName: izin.fileName,
        userId: izin.userId,
      );
      
      // Refresh data
      final updatedList = await getAllIzin();
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateIzin(int id, IzinModel updatedIzin) async {
    state = const AsyncLoading();
    
    try {
      await _databaseHelper.updateIzin(
        id: id,
        type: updatedIzin.type,
        date: updatedIzin.date,
        duration: updatedIzin.duration,
        reason: updatedIzin.reason,
        status: updatedIzin.status,
        fileName: updatedIzin.fileName,
        userId: updatedIzin.userId,
      );
      
      // Refresh data
      final updatedList = await getAllIzin();
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteIzin(int id) async {
    state = const AsyncLoading();
    
    try {
      await _databaseHelper.deleteIzin(id);
      
      // Refresh data
      final updatedList = await getAllIzin();
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateIzinStatus(int id, String newStatus, {String? keterangan}) async {
    state = const AsyncLoading();
    
    try {
      await _databaseHelper.updateIzinStatus(id, newStatus);
      
      // Refresh data
      final updatedList = await getAllIzin();
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<List<IzinModel>> getIzinByStatus(String status) async {
    try {
      final izinMaps = await _databaseHelper.getIzinByStatus(status);
      return izinMaps.map((map) => IzinModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load izin data by status $status: $e');
    }
  }

  Future<IzinModel?> getIzinById(int id) async {
    try {
      final izinMap = await _databaseHelper.getIzinById(id);
      if (izinMap != null) {
        return IzinModel.fromMap(izinMap);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load izin with id $id: $e');
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

// Provider untuk IzinAsyncNotifier
final izinAsyncProvider = AsyncNotifierProvider<IzinAsyncNotifier, List<IzinModel>>(
  () => IzinAsyncNotifier(),
);

// Provider untuk filter pencarian
final izinSearchProvider = StateProvider<String>((ref) => '');

// Provider untuk filter status
final izinStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

// Provider untuk filtered izin list
final filteredIzinProvider = Provider<AsyncValue<List<IzinModel>>>((ref) {
  final izinAsync = ref.watch(izinAsyncProvider);
  final searchQuery = ref.watch(izinSearchProvider).toLowerCase().trim();
  final statusFilter = ref.watch(izinStatusFilterProvider);
  
  return izinAsync.when(
    data: (izinList) {
      final filteredList = izinList.where((izin) {
        final matchesQuery = searchQuery.isEmpty ||
            izin.type.toLowerCase().contains(searchQuery) ||
            izin.reason.toLowerCase().contains(searchQuery) ||
            izin.id.toString().contains(searchQuery);
            
        final matchesStatus = statusFilter == 'Semua' || 
            _mapStatusForFilter(izin.status) == statusFilter;
            
        return matchesQuery && matchesStatus;
      }).toList();
      
      return AsyncData(filteredList);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});

// Helper function untuk mapping status ke filter UI
String _mapStatusForFilter(String dbStatus) {
  switch (dbStatus) {
    case 'menunggu_persetujuan':
      return 'Menunggu Persetujuan';
    case 'disetujui':
      return 'Disetujui';
    case 'ditolak':
      return 'Ditolak';
    default:
      return dbStatus;
  }
}