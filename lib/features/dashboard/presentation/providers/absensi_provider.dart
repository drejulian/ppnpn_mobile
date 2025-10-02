import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'package:ppnpm_dpr/common/data/repositories/absensi_repository.dart';
import 'package:ppnpm_dpr/common/data/models/absensi_model.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/common/data/repositories/notification/notification_repository.dart';

// Repository provider
final absensiRepositoryProvider = Provider<AbsensiRepository>((ref) {
  return AbsensiRepository.instance;
});

// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Current user ID provider (should be set from auth)
final currentUserIdProvider = StateProvider<int>((ref) => 1); // Default user ID

// Today's attendance status provider
final todayAttendanceProvider = FutureProvider<Map<String, AbsensiModel?>>((ref) async {
  final repository = ref.read(absensiRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  
  return await repository.getTodayAttendanceStatus(userId);
});

// Can check in provider
final canCheckInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(absensiRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  
  return await repository.canCheckIn(userId);
});

// Can check out provider
final canCheckOutProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(absensiRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  
  return await repository.canCheckOut(userId);
});

// Monthly statistics provider
final monthlyStatsProvider = FutureProvider<List<AbsensiMonthlyStats>>((ref) async {
  final repository = ref.read(absensiRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  
  return await repository.getMonthlyStats(userId);
});

// Attendance streak provider
final attendanceStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(absensiRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  
  return await repository.getAttendanceStreak(userId);
});

// Absensi submission provider
class AbsensiNotifier extends StateNotifier<AsyncValue<void>> {
  AbsensiNotifier(this.ref) : super(const AsyncValue.data(null));
  
  final Ref ref;

  Future<void> submitAbsensi({
    required String type, // 'checkin' or 'checkout'
    required Position location,
    String? imagePath,
    Uint8List? imageBytes,
    required String status,
    String? keterangan,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(absensiRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);
      final now = DateTime.now();
      
      // Create absensi model
      final absensi = AbsensiModel(
        userId: userId,
        tanggal: DateFormat('yyyy-MM-dd').format(now),
        type: type,
        jam: DateFormat('HH:mm:ss').format(now),
        latitude: location.latitude,
        longitude: location.longitude,
        imagePath: imagePath,
        imageBytes: imageBytes,
        status: status,
        keterangan: keterangan,
        createdAt: now,
        updatedAt: now,
      );
      
      // Insert to database
      await repository.insertAbsensi(absensi);
      
      // Add notification to database (untuk halaman notifikasi dalam app)
      print('DEBUG: 📝 Adding absensi notification to database...');
      await _addAbsensiNotificationToDatabase(type, status, DateFormat('HH:mm').format(now));
      
      // Send local notification (untuk notifikasi sistem)
      print('DEBUG: 📱 Sending local absensi notification...');
      await _sendLocalNotification(type, status, DateFormat('HH:mm').format(now));
      
      // Refresh providers
      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(canCheckInProvider);
      ref.invalidate(canCheckOutProvider);
      ref.invalidate(monthlyStatsProvider);
      ref.invalidate(attendanceStreakProvider);
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add notification to database for in-app notification
  Future<void> _addAbsensiNotificationToDatabase(String type, String status, String time) async {
    try {
      final notificationProvider = ref.read(notificationRepositoryProvider);
      
      String title = type == 'checkin' ? 'Check In Berhasil' : 'Check Out Berhasil';
      String subtitle = '${type == 'checkin' ? 'Check In' : 'Check Out'} pada $time - Status: $status';
      
      await notificationProvider.addNotification(
        title: title,
        subtitle: subtitle,
        iconName: type == 'checkin' ? 'login' : 'logout',
        avatarColor: status.contains('Tepat Waktu') ? 'green' : 'orange',
        category: 'absensi',
      );
      
      print('DEBUG: 🔔 Notifikasi absensi berhasil ditambahkan ke database: $title');
    } catch (e) {
      print('DEBUG: ❌ Gagal menambahkan notifikasi absensi ke database: $e');
    }
  }

  // Send local notification for system notification
  Future<void> _sendLocalNotification(String type, String status, String time) async {
    try {
      String title = type == 'checkin' ? 'Check In Berhasil!' : 'Check Out Berhasil!';
      String body = '${type == 'checkin' ? 'Check In' : 'Check Out'} pada $time - Status: $status';
      
      // Use showNotification (same as media sosial) instead of showAbsensiNotification
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
        payload: 'absensi_$type',
      );
      
      print('DEBUG: 📱 Notifikasi lokal absensi berhasil dikirim: $title');
    } catch (e) {
      print('DEBUG: ❌ Gagal mengirim notifikasi lokal absensi: $e');
    }
  }
}

final absensiNotifierProvider = StateNotifierProvider<AbsensiNotifier, AsyncValue<void>>((ref) {
  return AbsensiNotifier(ref);
});

// Date change detector provider
final currentDateProvider = StateProvider<String>((ref) {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
});

// Provider to check if date has changed
final dateChangeProvider = Provider<bool>((ref) {
  final currentDate = ref.watch(currentDateProvider);
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  if (currentDate != todayDate) {
    // Update current date and refresh attendance data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentDateProvider.notifier).state = todayDate;
      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(canCheckInProvider);
      ref.invalidate(canCheckOutProvider);
    });
  }
  
  return currentDate == todayDate;
});