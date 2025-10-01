import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/meeting_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/menuutama/meeting_repository.dart';

// Meeting state class
class MeetingState {
  final List<MeetingModel> meetings;
  final bool isLoading;
  final String? error;

  const MeetingState({
    this.meetings = const [],
    this.isLoading = false,
    this.error,
  });

  MeetingState copyWith({
    List<MeetingModel>? meetings,
    bool? isLoading,
    String? error,
  }) {
    return MeetingState(
      meetings: meetings ?? this.meetings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Meeting StateNotifier
class MeetingNotifier extends StateNotifier<MeetingState> {
  final MeetingRepository _repository;

  MeetingNotifier(this._repository) : super(const MeetingState()) {
    loadMeetings();
  }

  // Load all meetings
  Future<void> loadMeetings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final meetings = await _repository.getAllMeetings();
      state = state.copyWith(
        meetings: meetings,
        isLoading: false,
        error: null,
      );
     
    } catch (e) {
     
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load meetings: $e',
      );
    }
  }

  // Add new meeting
  Future<void> addMeeting(MeetingModel meeting) async {
    try {
      print('DEBUG: Provider addMeeting called with: ${meeting.toMap()}'); // Debug log
      
      await _repository.addMeeting(
        title: meeting.title,
        description: meeting.description,
        room: meeting.room,
        date: meeting.date,
        startTime: meeting.startTime,
        endTime: meeting.endTime,
        organizer: meeting.organizer,
        attendees: meeting.attendees,
        isOnline: meeting.isOnline,
        meetingLink: meeting.meetingLink,
      );
      
      // Refresh the list to get the updated data with IDs
      await loadMeetings();
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to add meeting: $e');
    }
  }

  // Update meeting
  Future<void> updateMeeting(MeetingModel meeting) async {
    try {
      if (meeting.id == null) {
        throw Exception('Meeting ID is required for update');
      }

      await _repository.updateMeeting(
        id: meeting.id!,
        title: meeting.title,
        description: meeting.description,
        room: meeting.room,
        date: meeting.date,
        startTime: meeting.startTime,
        endTime: meeting.endTime,
        organizer: meeting.organizer,
        attendees: meeting.attendees,
        isOnline: meeting.isOnline,
        meetingLink: meeting.meetingLink,
        status: meeting.status.name,
      );

      // Refresh the list
      await loadMeetings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update meeting: $e');
    }
  }

  // Update meeting status
  Future<void> updateMeetingStatus(int id, String status) async {
    try {
      await _repository.updateMeetingStatus(id, status);
      await loadMeetings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update meeting status: $e');
    }
  }

  // Delete meeting
  Future<void> deleteMeeting(int id) async {
    try {
      await _repository.deleteMeeting(id);
      await loadMeetings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete meeting: $e');
    }
  }

  // Get meetings by date
  Future<List<MeetingModel>> getMeetingsByDate(DateTime date) async {
    try {
      return await _repository.getMeetingsByDate(date);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get meetings by date: $e');
      return [];
    }
  }

  // Search meetings
  Future<List<MeetingModel>> searchMeetings(String query) async {
    try {
      return await _repository.searchMeetings(query);
    } catch (e) {
      state = state.copyWith(error: 'Failed to search meetings: $e');
      return [];
    }
  }

  // Get upcoming meetings
  Future<List<MeetingModel>> getUpcomingMeetings() async {
    try {
      return await _repository.getUpcomingMeetings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to get upcoming meetings: $e');
      return [];
    }
  }

  // Get today's meetings
  Future<List<MeetingModel>> getTodaysMeetings() async {
    try {
      return await _repository.getTodaysMeetings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to get today\'s meetings: $e');
      return [];
    }
  }

  // Get meeting statistics
  Future<Map<String, int>> getMeetingStatistics() async {
    try {
      return await _repository.getMeetingStatistics();
    } catch (e) {
      state = state.copyWith(error: 'Failed to get meeting statistics: $e');
      return {};
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh meetings
  Future<void> refresh() async {
    await loadMeetings();
  }
}

// Providers
final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository();
});

final meetingProvider = StateNotifierProvider<MeetingNotifier, MeetingState>((ref) {
  final repository = ref.watch(meetingRepositoryProvider);
  return MeetingNotifier(repository);
});

// Computed providers
final meetingListProvider = Provider<List<MeetingModel>>((ref) {
  final meetingState = ref.watch(meetingProvider);
  return meetingState.meetings;
});

final meetingLoadingProvider = Provider<bool>((ref) {
  final meetingState = ref.watch(meetingProvider);
  return meetingState.isLoading;
});

final meetingErrorProvider = Provider<String?>((ref) {
  final meetingState = ref.watch(meetingProvider);
  return meetingState.error;
});

// Provider for meetings by date
final meetingsByDateProvider = FutureProvider.family<List<MeetingModel>, DateTime>((ref, date) async {
  final notifier = ref.watch(meetingProvider.notifier);
  return await notifier.getMeetingsByDate(date);
});

// Provider for upcoming meetings
final upcomingMeetingsProvider = FutureProvider<List<MeetingModel>>((ref) async {
  final notifier = ref.watch(meetingProvider.notifier);
  return await notifier.getUpcomingMeetings();
});

// Provider for today's meetings
final todaysMeetingsProvider = FutureProvider<List<MeetingModel>>((ref) async {
  final notifier = ref.watch(meetingProvider.notifier);
  return await notifier.getTodaysMeetings();
});

// Provider for meeting statistics
final meetingStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final notifier = ref.watch(meetingProvider.notifier);
  return await notifier.getMeetingStatistics();
});

// Provider for search results
final meetingSearchProvider = FutureProvider.family<List<MeetingModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    final meetingState = ref.watch(meetingProvider);
    return meetingState.meetings;
  }
  final notifier = ref.watch(meetingProvider.notifier);
  return await notifier.searchMeetings(query);
});