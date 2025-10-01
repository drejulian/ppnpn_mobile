import '../../database/feedback_komisi_database_helper.dart';
import '../../models/sihaki/feedback_komisi_model.dart';

class FeedbackKomisiRepository {
  final FeedbackKomisiDatabaseHelper _databaseHelper = FeedbackKomisiDatabaseHelper();

  // Add new feedback komisi
  Future<FeedbackKomisiModel> addFeedbackKomisi({
    required String topik,
    required String feedback,
    required String ratingKinerja,
    String? saranPerbaikan,
    String? userId,
  }) async {
    try {
      print('Repository DEBUG: ➕ Adding new feedback with data:');
      print('  - Topik: "$topik"');
      print('  - Feedback: "$feedback"');  
      print('  - Rating Kinerja: "$ratingKinerja"');
      print('  - Saran: "$saranPerbaikan"');
      print('  - User ID: "${userId ?? 'current_user'}"');
      
      final now = DateTime.now();
      
      final newFeedbackKomisi = FeedbackKomisiModel(
        topik: topik,
        feedback: feedback,
        ratingKinerja: ratingKinerja,
        saranPerbaikan: saranPerbaikan,
        userId: userId ?? 'current_user', // Default user ID
        createdAt: now,
        updatedAt: now,
      );

      print('Repository DEBUG: 📦 Model object rating: "${newFeedbackKomisi.ratingKinerja}"');

      final id = await _databaseHelper.insertFeedbackKomisi(newFeedbackKomisi);
      
      final savedModel = newFeedbackKomisi.copyWith(id: id);
      
      print('Repository DEBUG: ✅ Saved model rating: "${savedModel.ratingKinerja}"');
      
      // Verify the insert
      final verifyFeedback = await getFeedbackKomisiById(id);
      print('Repository DEBUG: 🔍 Verification after insert - rating: "${verifyFeedback?.ratingKinerja}"');
      
      return savedModel;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to add feedback: $e');
      throw Exception('Repository: Gagal menambahkan feedback komisi - $e');
    }
  }

  // Get all feedback komisi
  Future<List<FeedbackKomisiModel>> getAllFeedbackKomisi({
    String? orderBy = 'created_at DESC',
  }) async {
    try {
      return await _databaseHelper.getAllFeedbackKomisi(orderBy: orderBy);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil semua feedback komisi - $e');
    }
  }

  // Get feedback komisi by ID
  Future<FeedbackKomisiModel?> getFeedbackKomisiById(int id) async {
    try {
      return await _databaseHelper.getFeedbackKomisiById(id);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil feedback komisi dengan ID $id - $e');
    }
  }

  // Get feedback komisi by user ID
  Future<List<FeedbackKomisiModel>> getFeedbackKomisiByUserId(String userId) async {
    try {
      return await _databaseHelper.getFeedbackKomisiByUserId(userId);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil feedback komisi untuk user $userId - $e');
    }
  }

  // Update feedback komisi
  Future<FeedbackKomisiModel> updateFeedbackKomisi(FeedbackKomisiModel feedbackKomisi) async {
    try {
      final updatedFeedbackKomisi = feedbackKomisi.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _databaseHelper.updateFeedbackKomisi(updatedFeedbackKomisi);
      
      return updatedFeedbackKomisi;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate feedback komisi - $e');
    }
  }

  // Delete feedback komisi
  Future<bool> deleteFeedbackKomisi(int id) async {
    try {
      final result = await _databaseHelper.deleteFeedbackKomisi(id);
      return result > 0;
    } catch (e) {
      throw Exception('Repository: Gagal menghapus feedback komisi - $e');
    }
  }

  // Search feedback komisi
  Future<List<FeedbackKomisiModel>> searchFeedbackKomisi(String query) async {
    try {
      return await _databaseHelper.searchFeedbackKomisi(query);
    } catch (e) {
      throw Exception('Repository: Gagal mencari feedback komisi - $e');
    }
  }

  // Get feedback komisi by rating
  Future<List<FeedbackKomisiModel>> getFeedbackKomisiByRating(int rating) async {
    try {
      return await _databaseHelper.getFeedbackKomisiByRating(rating);
    } catch (e) {
      throw Exception('Repository: Gagal mengambil feedback komisi dengan rating $rating - $e');
    }
  }

  // Get feedback komisi count
  Future<int> getFeedbackKomisiCount() async {
    try {
      return await _databaseHelper.getFeedbackKomisiCount();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil jumlah feedback komisi - $e');
    }
  }

  // Get feedback statistics
  Future<Map<String, dynamic>> getFeedbackStatistics() async {
    try {
      return await _databaseHelper.getFeedbackStatistics();
    } catch (e) {
      throw Exception('Repository: Gagal mengambil statistik feedback komisi - $e');
    }
  }

  // Update existing feedback komisi with new data
  Future<FeedbackKomisiModel> updateFeedbackKomisiData({
    required int id,
    required String topik,
    required String feedback,
    required String ratingKinerja,
    String? saranPerbaikan,
  }) async {
    try {
      print('Repository DEBUG: 📝 Updating feedback with data:');
      print('  - ID: $id');
      print('  - Topik: "$topik"');
      print('  - Feedback: "$feedback"');  
      print('  - Rating Kinerja: "$ratingKinerja"');
      print('  - Saran: "$saranPerbaikan"');
      
      final existingFeedback = await getFeedbackKomisiById(id);
      if (existingFeedback == null) {
        throw Exception('Feedback komisi dengan ID $id tidak ditemukan');
      }

      print('Repository DEBUG: 📋 Existing feedback rating: "${existingFeedback.ratingKinerja}"');

      final updatedFeedback = existingFeedback.copyWith(
        topik: topik,
        feedback: feedback,
        ratingKinerja: ratingKinerja,
        saranPerbaikan: saranPerbaikan,
        updatedAt: DateTime.now(),
      );

      print('Repository DEBUG: 🔄 Updated feedback object rating: "${updatedFeedback.ratingKinerja}"');

      await _databaseHelper.updateFeedbackKomisi(updatedFeedback);
      
      // Verify the update
      final verifyFeedback = await getFeedbackKomisiById(id);
      print('Repository DEBUG: ✅ Verification after update - rating: "${verifyFeedback?.ratingKinerja}"');
      
      return updatedFeedback;
    } catch (e) {
      print('Repository ERROR: ❌ Failed to update feedback: $e');
      throw Exception('Repository: Gagal mengupdate data feedback komisi - $e');
    }
  }

  // Close database connection - hanya dipanggil saat aplikasi benar-benar selesai
  Future<void> close() async {
    print('Repository DEBUG: 🚪 Repository close() called - but keeping database open');
    // Tidak menutup database helper karena masih bisa dipakai di halaman lain
    // await _databaseHelper.close();
  }
  
  // Method untuk mengecek status database
  Future<bool> isDatabaseOpen() async {
    return await _databaseHelper.isDatabaseOpen();
  }
}