import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/models/sihaki/agenda_pribadi_anggota_model.dart';
import '../../../../../common/data/repositories/sihaki/agenda_pribadi_anggota_repository.dart';
import '../../../../../common/data/database/app_database_helper.dart';

// State untuk loading
class AgendaPribadiState {
  final List<AgendaPribadiAnggotaModel> agendaList;
  final bool isLoading;
  final String? errorMessage;

  AgendaPribadiState({
    this.agendaList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AgendaPribadiState copyWith({
    List<AgendaPribadiAnggotaModel>? agendaList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AgendaPribadiState(
      agendaList: agendaList ?? this.agendaList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AgendaPribadiAnggotaNotifier extends StateNotifier<AgendaPribadiState> {
  final AgendaPribadiAnggotaRepository _repository;

  AgendaPribadiAnggotaNotifier(this._repository) : super(AgendaPribadiState()) {
    loadAgenda();
  }

  Future<void> loadAgenda([int? userId]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final agendaList = await _repository.getAllAgenda(userId);
      state = state.copyWith(
        agendaList: agendaList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> addAgenda(AgendaPribadiAnggotaModel agenda) async {
    try {
      final now = DateTime.now();
      final newAgenda = agenda.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addAgenda(newAgenda);
      await loadAgenda(agenda.userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAgenda(AgendaPribadiAnggotaModel agenda) async {
    try {
      final updatedAgenda = agenda.copyWith(updatedAt: DateTime.now());
      await _repository.updateAgenda(updatedAgenda);
      await loadAgenda(agenda.userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteAgenda(int id, [int? userId]) async {
    try {
      await _repository.deleteAgenda(id);
      await loadAgenda(userId); // Reload data
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  List<AgendaPribadiAnggotaModel> searchAgenda(String keyword) {
    if (keyword.isEmpty) return state.agendaList;
    
    final lowerKeyword = keyword.toLowerCase();
    return state.agendaList.where((agenda) {
      return agenda.agenda.toLowerCase().contains(lowerKeyword) ||
             agenda.tempat.toLowerCase().contains(lowerKeyword) ||
             agenda.tanggal.toLowerCase().contains(lowerKeyword) ||
             agenda.waktu.toLowerCase().contains(lowerKeyword) ||
             (agenda.keterangan?.toLowerCase().contains(lowerKeyword) ?? false);
    }).toList();
  }

  List<AgendaPribadiAnggotaModel> getUpcomingAgenda() {
    final today = DateTime.now();
    final todayString = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
    
    return state.agendaList.where((agenda) {
      return agenda.tanggal.compareTo(todayString) >= 0;
    }).toList();
  }
}

// Providers
final appDatabaseHelperProvider = Provider<AppDatabaseHelper>((ref) {
  return AppDatabaseHelper();
});

final agendaPribadiRepositoryProvider = Provider<AgendaPribadiAnggotaRepository>((ref) {
  final databaseHelper = ref.watch(appDatabaseHelperProvider);
  return AgendaPribadiAnggotaRepository(databaseHelper);
});

final agendaPribadiProvider = StateNotifierProvider<AgendaPribadiAnggotaNotifier, AgendaPribadiState>((ref) {
  final repository = ref.watch(agendaPribadiRepositoryProvider);
  return AgendaPribadiAnggotaNotifier(repository);
});

// Search provider
final agendaSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAgendaPribadiProvider = Provider<List<AgendaPribadiAnggotaModel>>((ref) {
  final query = ref.watch(agendaSearchQueryProvider);
  final notifier = ref.watch(agendaPribadiProvider.notifier);
  
  return notifier.searchAgenda(query);
});