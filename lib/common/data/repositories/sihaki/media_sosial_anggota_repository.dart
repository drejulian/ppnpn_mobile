import '../../models/sihaki/media_sosial_anggota_model.dart';
import '../../database/app_database_helper.dart';

class MediaSosialAnggotaRepository {
  final AppDatabaseHelper _databaseHelper;

  MediaSosialAnggotaRepository(this._databaseHelper);

  Future<int> addMediaSosial(MediaSosialAnggotaModel mediaSosial) async {
    try {
      final mediaSosialMap = mediaSosial.toMap();
      // Remove id dari map karena auto increment
      mediaSosialMap.remove('id');
      
      return await _databaseHelper.insertMediaSosial(mediaSosialMap);
    } catch (e) {
      throw Exception('Failed to add media sosial: $e');
    }
  }

  Future<List<MediaSosialAnggotaModel>> getAllMediaSosial([int? userId]) async {
    try {
      final mediaSosialList = await _databaseHelper.getAllMediaSosial(userId);
      
      return mediaSosialList.map((mediaSosial) => MediaSosialAnggotaModel.fromMap(mediaSosial)).toList();
    } catch (e) {
      throw Exception('Failed to get media sosial list: $e');
    }
  }

  Future<MediaSosialAnggotaModel?> getMediaSosialById(int id) async {
    try {
      final mediaSosial = await _databaseHelper.getMediaSosialById(id);
      
      if (mediaSosial != null) {
        return MediaSosialAnggotaModel.fromMap(mediaSosial);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get media sosial: $e');
    }
  }

  Future<bool> updateMediaSosial(MediaSosialAnggotaModel mediaSosial) async {
    try {
      if (mediaSosial.id == null) {
        throw Exception('Media Sosial ID is required for update');
      }

      final mediaSosialMap = mediaSosial.toMap();
      mediaSosialMap['updated_at'] = DateTime.now().toIso8601String();
      
      final result = await _databaseHelper.updateMediaSosial(mediaSosial.id!, mediaSosialMap);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update media sosial: $e');
    }
  }

  Future<bool> deleteMediaSosial(int id) async {
    try {
      final result = await _databaseHelper.deleteMediaSosial(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete media sosial: $e');
    }
  }

  Future<List<MediaSosialAnggotaModel>> getMediaSosialByPlatform(String platform, [int? userId]) async {
    try {
      final allMediaSosial = await getAllMediaSosial(userId);
      
      return allMediaSosial.where((mediaSosial) => 
          mediaSosial.platform.toLowerCase() == platform.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get media sosial by platform: $e');
    }
  }

  Future<List<MediaSosialAnggotaModel>> getActiveMediaSosial([int? userId]) async {
    try {
      final allMediaSosial = await getAllMediaSosial(userId);
      
      return allMediaSosial.where((mediaSosial) => mediaSosial.status == 'aktif').toList();
    } catch (e) {
      throw Exception('Failed to get active media sosial: $e');
    }
  }

  Future<List<MediaSosialAnggotaModel>> getVerifiedMediaSosial([int? userId]) async {
    try {
      final allMediaSosial = await getAllMediaSosial(userId);
      
      return allMediaSosial.where((mediaSosial) => mediaSosial.isVerified).toList();
    } catch (e) {
      throw Exception('Failed to get verified media sosial: $e');
    }
  }

  Future<bool> updateFollowersCount(int id, int newFollowersCount) async {
    try {
      final mediaSosial = await getMediaSosialById(id);
      if (mediaSosial == null) {
        throw Exception('Media sosial not found');
      }

      final updatedMediaSosial = mediaSosial.copyWith(
        followers: newFollowersCount,
        updatedAt: DateTime.now(),
      );

      return await updateMediaSosial(updatedMediaSosial);
    } catch (e) {
      throw Exception('Failed to update followers count: $e');
    }
  }

  Future<bool> toggleVerificationStatus(int id) async {
    try {
      final mediaSosial = await getMediaSosialById(id);
      if (mediaSosial == null) {
        throw Exception('Media sosial not found');
      }

      final updatedMediaSosial = mediaSosial.copyWith(
        isVerified: !mediaSosial.isVerified,
        updatedAt: DateTime.now(),
      );

      return await updateMediaSosial(updatedMediaSosial);
    } catch (e) {
      throw Exception('Failed to toggle verification status: $e');
    }
  }

  Future<bool> toggleActiveStatus(int id) async {
    try {
      final mediaSosial = await getMediaSosialById(id);
      if (mediaSosial == null) {
        throw Exception('Media sosial not found');
      }

      final newStatus = mediaSosial.status == 'aktif' ? 'tidak_aktif' : 'aktif';
      final updatedMediaSosial = mediaSosial.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      return await updateMediaSosial(updatedMediaSosial);
    } catch (e) {
      throw Exception('Failed to toggle active status: $e');
    }
  }

  Future<Map<String, int>> getMediaSosialStatistics([int? userId]) async {
    try {
      final allMediaSosial = await getAllMediaSosial(userId);
      
      final totalFollowers = allMediaSosial.fold<int>(0, (sum, item) => sum + item.followers);
      final activeCount = allMediaSosial.where((item) => item.status == 'aktif').length;
      final verifiedCount = allMediaSosial.where((item) => item.isVerified).length;
      final platformCount = allMediaSosial.map((item) => item.platform).toSet().length;
      
      return {
        'total_accounts': allMediaSosial.length,
        'total_followers': totalFollowers,
        'active_accounts': activeCount,
        'verified_accounts': verifiedCount,
        'platform_count': platformCount,
      };
    } catch (e) {
      throw Exception('Failed to get media sosial statistics: $e');
    }
  }
}