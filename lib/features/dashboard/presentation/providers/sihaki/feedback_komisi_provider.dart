import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/models/sihaki/feedback_komisi_model.dart';
import '../../../../../common/data/repositories/sihaki/feedback_komisi_repository.dart';

// Repository Provider
final feedbackKomisiRepositoryProvider = Provider<FeedbackKomisiRepository>((ref) {
  return FeedbackKomisiRepository();
});

// State class for Feedback Komisi
class FeedbackKomisiState {
  final List<FeedbackKomisiModel> feedbackList;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  const FeedbackKomisiState({
    this.feedbackList = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  FeedbackKomisiState copyWith({
    List<FeedbackKomisiModel>? feedbackList,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return FeedbackKomisiState(
      feedbackList: feedbackList ?? this.feedbackList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Notifier class for Feedback Komisi
class FeedbackKomisiNotifier extends StateNotifier<FeedbackKomisiState> {
  final FeedbackKomisiRepository _repository;

  FeedbackKomisiNotifier(this._repository) : super(const FeedbackKomisiState()) {
    loadFeedbackKomisi();
  }

  // Load all feedback komisi
  Future<void> loadFeedbackKomisi() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final feedbackList = await _repository.getAllFeedbackKomisi();
      final statistics = await _repository.getFeedbackStatistics();

      state = state.copyWith(
        feedbackList: feedbackList,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add new feedback komisi
  Future<bool> addFeedbackKomisi({
    required String topik,
    required String feedback,
    required String ratingKinerja,
    String? saranPerbaikan,
    String? userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.addFeedbackKomisi(
        topik: topik,
        feedback: feedback,
        ratingKinerja: ratingKinerja,
        saranPerbaikan: saranPerbaikan,
        userId: userId,
      );

      await loadFeedbackKomisi();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update existing feedback komisi
  Future<bool> updateFeedbackKomisi({
    required int id,
    required String topik,
    required String feedback,
    required String ratingKinerja,
    String? saranPerbaikan,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.updateFeedbackKomisiData(
        id: id,
        topik: topik,
        feedback: feedback,
        ratingKinerja: ratingKinerja,
        saranPerbaikan: saranPerbaikan,
      );

      await loadFeedbackKomisi();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Delete feedback komisi
  Future<bool> deleteFeedbackKomisi(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _repository.deleteFeedbackKomisi(id);
      if (success) {
        await loadFeedbackKomisi();
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Search feedback komisi
  Future<void> searchFeedbackKomisi(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      List<FeedbackKomisiModel> results;
      if (query.trim().isEmpty) {
        results = await _repository.getAllFeedbackKomisi();
      } else {
        results = await _repository.searchFeedbackKomisi(query);
      }

      state = state.copyWith(
        feedbackList: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Filter by rating
  Future<void> filterByRating(int? rating) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      List<FeedbackKomisiModel> results;
      if (rating == null) {
        results = await _repository.getAllFeedbackKomisi();
      } else {
        results = await _repository.getFeedbackKomisiByRating(rating);
      }

      state = state.copyWith(
        feedbackList: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get feedback komisi by user ID
  Future<void> loadFeedbackKomisiByUserId(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final feedbackList = await _repository.getFeedbackKomisiByUserId(userId);

      state = state.copyWith(
        feedbackList: feedbackList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadFeedbackKomisi();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}

// Main provider
final feedbackKomisiProvider = StateNotifierProvider<FeedbackKomisiNotifier, FeedbackKomisiState>((ref) {
  final repository = ref.watch(feedbackKomisiRepositoryProvider);
  return FeedbackKomisiNotifier(repository);
});

// Search query provider
final feedbackKomisiSearchProvider = StateProvider<String>((ref) => '');

// Rating filter provider
final feedbackKomisiRatingFilterProvider = StateProvider<int?>((ref) => null);

// Filtered feedback komisi provider
final filteredFeedbackKomisiProvider = Provider<List<FeedbackKomisiModel>>((ref) {
  final feedbackState = ref.watch(feedbackKomisiProvider);
  final query = ref.watch(feedbackKomisiSearchProvider).toLowerCase().trim();
  final ratingFilter = ref.watch(feedbackKomisiRatingFilterProvider);

  var filteredList = feedbackState.feedbackList;

  // Filter by search query
  if (query.isNotEmpty) {
    filteredList = filteredList.where((feedback) {
      return feedback.topik.toLowerCase().contains(query) ||
          feedback.feedback.toLowerCase().contains(query) ||
          (feedback.saranPerbaikan?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Filter by rating
  if (ratingFilter != null) {
    filteredList = filteredList.where((feedback) {
      return feedback.ratingValue == ratingFilter;
    }).toList();
  }

  return filteredList;
});

// Statistics provider
final feedbackKomisiStatisticsProvider = Provider<Map<String, dynamic>?>((ref) {
  final feedbackState = ref.watch(feedbackKomisiProvider);
  return feedbackState.statistics;
});