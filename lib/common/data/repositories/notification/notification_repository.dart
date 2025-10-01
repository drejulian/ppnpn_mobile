import '../../models/notification/notification_model.dart';
import '../../database/notification_database_helper.dart';

class NotificationRepository {
  final NotificationDatabaseHelper _databaseHelper = NotificationDatabaseHelper();

  // Add new notification
  Future<NotificationModel> addNotification({
    required String title,
    required String subtitle,
    required String iconName,
    required String avatarColor,
    required String category,
  }) async {
    try {
      print('DEBUG: Repository addNotification called: $title');
      
      final notification = NotificationModel.create(
        title: title,
        subtitle: subtitle,
        iconName: iconName,
        avatarColor: avatarColor,
        category: category,
      );
      
      await _databaseHelper.insertNotification(notification);
      print('DEBUG: Repository addNotification success');
      
      return notification;
    } catch (e) {
      print('DEBUG: Repository addNotification error: $e');
      throw Exception('Failed to add notification: $e');
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      print('DEBUG: Repository getAllNotifications called');
      final notifications = await _databaseHelper.getAllNotifications();
      
      // Update time displays
      final updatedNotifications = notifications.map((n) => n.updateTimeDisplay()).toList();
      print('DEBUG: Repository getAllNotifications returned ${updatedNotifications.length} notifications');
      
      return updatedNotifications;
    } catch (e) {
      print('DEBUG: Repository getAllNotifications error: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      print('DEBUG: Repository getUnreadNotifications called');
      final notifications = await _databaseHelper.getUnreadNotifications();
      
      // Update time displays
      final updatedNotifications = notifications.map((n) => n.updateTimeDisplay()).toList();
      print('DEBUG: Repository getUnreadNotifications returned ${updatedNotifications.length} notifications');
      
      return updatedNotifications;
    } catch (e) {
      print('DEBUG: Repository getUnreadNotifications error: $e');
      throw Exception('Failed to load unread notifications: $e');
    }
  }

  // Get read notifications
  Future<List<NotificationModel>> getReadNotifications() async {
    try {
      print('DEBUG: Repository getReadNotifications called');
      final notifications = await _databaseHelper.getReadNotifications();
      
      // Update time displays
      final updatedNotifications = notifications.map((n) => n.updateTimeDisplay()).toList();
      print('DEBUG: Repository getReadNotifications returned ${updatedNotifications.length} notifications');
      
      return updatedNotifications;
    } catch (e) {
      print('DEBUG: Repository getReadNotifications error: $e');
      throw Exception('Failed to load read notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      print('DEBUG: Repository markAsRead called for: $notificationId');
      await _databaseHelper.markAsRead(notificationId);
      print('DEBUG: Repository markAsRead success');
    } catch (e) {
      print('DEBUG: Repository markAsRead error: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _databaseHelper.markAllAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      return await _databaseHelper.getUnreadCount();
    } catch (e) {
      print('DEBUG: Repository getUnreadCount error: $e');
      return 0;
    }
  }

  // Get notifications by category
  Future<List<NotificationModel>> getNotificationsByCategory(String category) async {
    try {
      final notifications = await _databaseHelper.getNotificationsByCategory(category);
      return notifications.map((n) => n.updateTimeDisplay()).toList();
    } catch (e) {
      throw Exception('Failed to load notifications by category: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databaseHelper.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      await _databaseHelper.deleteAllReadNotifications();
    } catch (e) {
      throw Exception('Failed to delete read notifications: $e');
    }
  }

  // Get notification statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      return await _databaseHelper.getNotificationStatistics();
    } catch (e) {
      throw Exception('Failed to get notification statistics: $e');
    }
  }

  // Clean old notifications
  Future<void> cleanOldNotifications({int daysToKeep = 30}) async {
    try {
      await _databaseHelper.cleanOldNotifications(daysToKeep: daysToKeep);
    } catch (e) {
      print('DEBUG: Repository cleanOldNotifications error: $e');
    }
  }

  // Specialized methods for different types of notifications

  // Add Cuti notification
  Future<NotificationModel> addCutiNotification({
    required String jenisCuti,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String alasan,
  }) async {
    return await addNotification(
      title: 'Pengajuan Cuti Berhasil Dikirim',
      subtitle: '$jenisCuti ($tanggalAwal - $tanggalAkhir) telah dikirim untuk persetujuan. Alasan: $alasan',
      iconName: 'event_busy',
      avatarColor: 'orange',
      category: 'cuti',
    );
  }

  // Add Izin notification
  Future<NotificationModel> addIzinNotification({
    required String jenisIzin,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String durasi,
    required String alasan,
  }) async {
    return await addNotification(
      title: 'Pengajuan Izin Berhasil Dikirim',
      subtitle: '$jenisIzin ($durasi) dari $tanggalAwal sampai $tanggalAkhir telah dikirim untuk persetujuan. Alasan: $alasan',
      iconName: 'how_to_reg',
      avatarColor: 'blue',
      category: 'izin',
    );
  }

  // Add Lembur notification
  Future<NotificationModel> addLemburNotification({
    required String jenisLembur,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String durasi,
    required String kegiatan,
  }) async {
    return await addNotification(
      title: 'Pengajuan Lembur Berhasil Dikirim',
      subtitle: '$jenisLembur pada $tanggal ($jamMulai - $jamSelesai, $durasi) telah dikirim untuk persetujuan. Kegiatan: $kegiatan',
      iconName: 'schedule',
      avatarColor: 'purple',
      category: 'lembur',
    );
  }

  // Add Reimburse notification
  Future<NotificationModel> addReimburseNotification({
    required String kategori,
    required String jumlah,
    required String tanggal,
    required String deskripsi,
  }) async {
    return await addNotification(
      title: 'Pengajuan Reimburse Berhasil Dikirim',
      subtitle: 'Reimburse $kategori sebesar $jumlah pada $tanggal telah dikirim untuk persetujuan. Deskripsi: $deskripsi',
      iconName: 'receipt_long',
      avatarColor: 'green',
      category: 'reimburse',
    );
  }

  // Add Meeting notification
  Future<NotificationModel> addMeetingNotification({
    required String judulMeeting,
    required String tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    required String tempat,
    required String jenisMeeting,
  }) async {
    return await addNotification(
      title: 'Meeting Berhasil Dijadwalkan',
      subtitle: '$judulMeeting pada $tanggal ($waktuMulai - $waktuSelesai) di $tempat telah dijadwalkan. Jenis: $jenisMeeting',
      iconName: 'event',
      avatarColor: 'blue',
      category: 'meeting',
    );
  }

  // Add Task notification
  Future<NotificationModel> addTaskNotification({
    required String judulTask,
    required String deskripsi,
    required String tanggalDeadline,
    required String prioritas,
    required String status,
    bool hasReminder = false,
  }) async {
    return await addNotification(
      title: 'Task Baru Berhasil Dibuat',
      subtitle: '$judulTask (prioritas: $prioritas, status: $status) dengan deadline $tanggalDeadline telah dibuat${hasReminder ? ' dengan pengingat aktif' : ''}.',
      iconName: 'task_alt',
      avatarColor: 'teal',
      category: 'task',
    );
  }

  // Add Media Sosial notification
  Future<NotificationModel> addMediaSosialNotification({
    required String platform,
    required String username,
    String? url,
    int? followers,
    bool isVerified = false,
  }) async {
    return await addNotification(
      title: 'Media Sosial Berhasil Ditambahkan',
      subtitle: 'Media sosial $platform dengan username @$username${followers != null ? ' ($followers followers)' : ''}${isVerified ? ' (Verified)' : ''} telah berhasil ditambahkan.',
      iconName: 'share',
      avatarColor: 'pink',
      category: 'media_sosial',
    );
  }

  // Add BPJS notification
  Future<NotificationModel> addBPJSNotification({
    required String nama,
    required String hubunganKeluarga,
    required String noBPJS,
    required String namaFaskes,
  }) async {
    return await addNotification(
      title: 'Data BPJS Berhasil Ditambahkan',
      subtitle: 'Data BPJS untuk $nama ($hubunganKeluarga) dengan nomor $noBPJS dan faskes $namaFaskes telah berhasil ditambahkan.',
      iconName: 'medical_services',
      avatarColor: 'red',
      category: 'bpjs',
    );
  }

  // Add Agenda notification
  Future<NotificationModel> addAgendaNotification({
    required String namaAcara,
    required String tanggal,
    required String waktu,
    required String deskripsi,
  }) async {
    return await addNotification(
      title: 'Agenda Pribadi Berhasil Ditambahkan',
      subtitle: 'Agenda "$namaAcara" pada $tanggal pukul $waktu telah berhasil dijadwalkan. $deskripsi',
      iconName: 'event_note',
      avatarColor: 'orange',
      category: 'agenda',
    );
  }
}