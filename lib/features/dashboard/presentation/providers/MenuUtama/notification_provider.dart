import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/data/repositories/notification/notification_repository.dart';

// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Notification provider for managing unread notification count
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(ref.read(notificationRepositoryProvider));
    });

class NotificationState {
  final int unreadCount;
  final List<Map<String, dynamic>> unreadNotifications;
  final List<Map<String, dynamic>> readNotifications;

  NotificationState({
    required this.unreadCount,
    required this.unreadNotifications,
    required this.readNotifications,
  });

  NotificationState copyWith({
    int? unreadCount,
    List<Map<String, dynamic>>? unreadNotifications,
    List<Map<String, dynamic>>? readNotifications,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      readNotifications: readNotifications ?? this.readNotifications,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository)
    : super(
        NotificationState(
          unreadCount: 0,
          unreadNotifications: [],
          readNotifications: [],
        ),
      ) {
    // Load notifications from database when initialized
    loadNotifications();
  }



  // Load notifications from database
  Future<void> loadNotifications() async {
    try {
      print('DEBUG: Loading notifications from database...');
      
      final unreadNotifications = await _repository.getUnreadNotifications();
      final readNotifications = await _repository.getReadNotifications();
      final unreadCount = await _repository.getUnreadCount();
      
      // Convert NotificationModel to legacy Map format for UI compatibility
      final unreadMaps = unreadNotifications.map((n) => n.toLegacyMap()).toList();
      final readMaps = readNotifications.map((n) => n.toLegacyMap()).toList();
      
      state = state.copyWith(
        unreadCount: unreadCount,
        unreadNotifications: unreadMaps,
        readNotifications: readMaps,
      );
      
      print('DEBUG: Loaded ${unreadNotifications.length} unread, ${readNotifications.length} read notifications');
    } catch (e) {
      print('DEBUG: Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print('DEBUG: Marking notification $notificationId as read');
      
      // Mark as read in database
      await _repository.markAsRead(notificationId);
      
      // Reload notifications from database to update state
      await loadNotifications();
      
      print('DEBUG: Notification marked as read successfully');
    } catch (e) {
      print('DEBUG: Error marking notification as read: $e');
    }
  }

  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    try {
      print('DEBUG: Adding new notification: ${notificationData['title']}');
      
      // Add to database using repository
      await _repository.addNotification(
        title: notificationData['title'] ?? '',
        subtitle: notificationData['subtitle'] ?? '',
        iconName: notificationData['icon'] ?? 'notifications',
        avatarColor: notificationData['avatarColor'] ?? 'blue',
        category: notificationData['category'] ?? 'general',
      );
      
      // Reload notifications to update state
      await loadNotifications();
      
      print('DEBUG: Notification added successfully');
    } catch (e) {
      print('DEBUG: Error adding notification: $e');
    }
  }

  // Method khusus untuk menambahkan notifikasi pengajuan cuti
  Future<void> addCutiNotification({
    required String jenisCtri,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String alasan,
  }) async {
    try {
      await _repository.addCutiNotification(
        jenisCuti: jenisCtri,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
        alasan: alasan,
      );
      
      // Reload notifications to update state
      await loadNotifications();
    } catch (e) {
      print('DEBUG: Error adding cuti notification: $e');
    }
  }

  // Method khusus untuk menambahkan notifikasi pengajuan izin
  void addIzinNotification({
    required String jenisIzin,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String durasi,
    required String alasan,
  }) {
    _repository.addIzinNotification(
      jenisIzin: jenisIzin,
      tanggalAwal: tanggalAwal,
      tanggalAkhir: tanggalAkhir,
      durasi: durasi,
      alasan: alasan,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi pengajuan lembur
  void addLemburNotification({
    required String jenisLembur,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String durasi,
    required String kegiatan,
  }) {
    _repository.addLemburNotification(
      jenisLembur: jenisLembur,
      tanggal: tanggal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      durasi: durasi,
      kegiatan: kegiatan,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi pengajuan reimburse
  void addReimburseNotification({
    required String kategori,
    required String jumlah,
    required String tanggal,
    required String deskripsi,
  }) {
    _repository.addReimburseNotification(
      kategori: kategori,
      jumlah: jumlah,
      tanggal: tanggal,
      deskripsi: deskripsi,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi media sosial
  void addMediaSosialNotification({
    required String platform,
    required String username,
    String? url,
    int? followers,
    bool isVerified = false,
  }) {
    _repository.addMediaSosialNotification(
      platform: platform,
      username: username,
      url: url,
      followers: followers,
      isVerified: isVerified,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi BPJS
  void addBPJSNotification({
    required String nama,
    required String hubunganKeluarga,
    required String noBPJS,
    required String namaFaskes,
  }) {
    _repository.addBPJSNotification(
      nama: nama,
      hubunganKeluarga: hubunganKeluarga,
      noBPJS: noBPJS,
      namaFaskes: namaFaskes,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi meeting
  void addMeetingNotification({
    required String judulMeeting,
    required String tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    required String tempat,
    required String jenisMeeting,
  }) {
    _repository.addMeetingNotification(
      judulMeeting: judulMeeting,
      tanggal: tanggal,
      waktuMulai: waktuMulai,
      waktuSelesai: waktuSelesai,
      tempat: tempat,
      jenisMeeting: jenisMeeting,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi task
  void addTaskNotification({
    required String judulTask,
    required String deskripsi,
    required String tanggalDeadline,
    required String prioritas,
    required String status,
    bool hasReminder = false,
  }) {
    _repository.addTaskNotification(
      judulTask: judulTask,
      deskripsi: deskripsi,
      tanggalDeadline: tanggalDeadline,
      prioritas: prioritas,
      status: status,
      hasReminder: hasReminder,
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi kunker
  void addKunkerNotification({
    required String noSurat,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String lokasi,
    required String jenisPerjadin,
  }) {
    _repository.addNotification(
      title: 'Kunjungan Kerja Berhasil Diajukan',
      subtitle: 'Kunjungan kerja $noSurat ($jenisPerjadin) ke $lokasi dari $tanggalAwal sampai $tanggalAkhir telah berhasil diajukan.',
      iconName: 'business_center',
      avatarColor: 'indigo',
      category: 'kunker',
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi update media sosial
  void addEditMediaSosialNotification({
    required String platform,
    required String username,
    String? url,
    int? followers,
    bool isVerified = false,
  }) {
    _repository.addNotification(
      title: 'Media Sosial Berhasil Diperbarui',
      subtitle: 'Media sosial $platform dengan username @$username${followers != null ? ' ($followers followers)' : ''}${isVerified ? ' (Verified)' : ''} telah berhasil diperbarui.',
      iconName: 'edit',
      avatarColor: 'cyan',
      category: 'media_sosial',
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi hapus media sosial
  void addDeleteMediaSosialNotification({
    required String platform,
    required String username,
  }) {
    _repository.addNotification(
      title: 'Media Sosial Berhasil Dihapus',
      subtitle: 'Media sosial $platform dengan username @$username telah berhasil dihapus dari akun Anda.',
      iconName: 'delete',
      avatarColor: 'red',
      category: 'media_sosial',
    ).then((_) => loadNotifications());
  }

  // Method khusus untuk menambahkan notifikasi agenda pribadi
  void addAgendaNotification({
    required String namaAcara,
    required String tanggal,
    required String waktu,
    required String deskripsi,
  }) {
    _repository.addAgendaNotification(
      namaAcara: namaAcara,
      tanggal: tanggal,
      waktu: waktu,
      deskripsi: deskripsi,
    ).then((_) => loadNotifications());
  }
}
