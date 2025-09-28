import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification provider for managing unread notification count
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier();
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
  NotificationNotifier()
    : super(
        NotificationState(
          unreadCount: 4,
          unreadNotifications: _getInitialUnreadNotifications(),
          readNotifications: _getInitialReadNotifications(),
        ),
      );

  static List<Map<String, dynamic>> _getInitialUnreadNotifications() {
    return [
      {
        'id': '1',
        'title': 'Pengajuan Cuti Anda Disetujui',
        'subtitle':
            'Cuti tanggal 15-17 September 2025 telah disetujui oleh atasan.',
        'time': '1h ago',
        'hasRedDot': true,
        'icon': 'check_circle',
        'avatarColor': 'green',
      },
      {
        'id': '2',
        'title': 'Pengajuan Izin Sedang Diproses',
        'subtitle': 'Izin sakit tanggal 12 September 2025 sedang dalam review.',
        'time': '2h ago',
        'hasRedDot': true,
        'icon': 'access_time',
        'avatarColor': 'orange',
      },
      {
        'id': '3',
        'title': 'Pengajuan Lembur Ditolak',
        'subtitle':
            'Lembur tanggal 10 September 2025 tidak dapat disetujui. Silakan hubungi HRD untuk informasi lebih lanjut.',
        'time': '3h ago',
        'hasRedDot': true,
        'icon': 'cancel',
        'avatarColor': 'red',
      },
      {
        'id': '4',
        'title': 'Pengajuan Reimburse Disetujui',
        'subtitle':
            'Reimburse transport Rp 150.000 telah disetujui dan akan segera diproses.',
        'time': '4h ago',
        'hasRedDot': true,
        'icon': 'attach_money',
        'avatarColor': 'blue',
      },
    ];
  }

  static List<Map<String, dynamic>> _getInitialReadNotifications() {
    return [
      {
        'id': '5',
        'title': 'Reminder: Meeting Tim Marketing',
        'subtitle':
            'Meeting akan dimulai dalam 30 menit di ruang meeting lantai 3.',
        'time': 'Yesterday',
        'hasRedDot': false,
        'icon': 'event',
        'avatarColor': 'purple',
      },
      {
        'id': '6',
        'title': 'Task Baru Telah Ditambahkan',
        'subtitle': 'Anda memiliki task baru: "Review dokumen proposal Q4".',
        'time': '2 days ago',
        'hasRedDot': false,
        'icon': 'task_alt',
        'avatarColor': 'teal',
      },
    ];
  }

  void markAsRead(String notificationId) {
    final unreadNotifications = List<Map<String, dynamic>>.from(
      state.unreadNotifications,
    );
    final readNotifications = List<Map<String, dynamic>>.from(
      state.readNotifications,
    );

    // Find notification in unread list
    final notificationIndex = unreadNotifications.indexWhere(
      (notification) => notification['id'] == notificationId,
    );

    if (notificationIndex != -1) {
      // Get the notification
      final notification = unreadNotifications[notificationIndex];

      // Update notification status
      notification['hasRedDot'] = false;

      // Move from unread to read
      unreadNotifications.removeAt(notificationIndex);
      readNotifications.insert(0, notification); // Add to top of read list

      // Update state
      state = state.copyWith(
        unreadCount: unreadNotifications.length,
        unreadNotifications: unreadNotifications,
        readNotifications: readNotifications,
      );
    }
  }

  void addNotification(Map<String, dynamic> notification) {
    final unreadNotifications = List<Map<String, dynamic>>.from(
      state.unreadNotifications,
    );
    unreadNotifications.insert(0, notification);

    state = state.copyWith(
      unreadCount: unreadNotifications.length,
      unreadNotifications: unreadNotifications,
    );
  }

  // Method khusus untuk menambahkan notifikasi pengajuan cuti
  void addCutiNotification({
    required String jenisCtri,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String alasan,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Pengajuan Cuti Berhasil Dikirim',
      'subtitle': '$jenisCtri ($tanggalAwal - $tanggalAkhir) telah dikirim untuk persetujuan. Alasan: $alasan',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'event_busy',
      'avatarColor': 'orange',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi pengajuan izin
  void addIzinNotification({
    required String jenisIzin,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String durasi,
    required String alasan,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Pengajuan Izin Berhasil Dikirim',
      'subtitle': '$jenisIzin ($durasi) dari $tanggalAwal sampai $tanggalAkhir telah dikirim untuk persetujuan. Alasan: $alasan',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'how_to_reg',
      'avatarColor': 'blue',
    };
    
    addNotification(notification);
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
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Pengajuan Lembur Berhasil Dikirim',
      'subtitle': '$jenisLembur pada $tanggal ($jamMulai - $jamSelesai, $durasi) telah dikirim untuk persetujuan. Kegiatan: $kegiatan',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'schedule',
      'avatarColor': 'purple',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi pengajuan reimburse
  void addReimburseNotification({
    required String kategori,
    required String jumlah,
    required String tanggal,
    required String deskripsi,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Pengajuan Reimburse Berhasil Dikirim',
      'subtitle': 'Reimburse $kategori sebesar $jumlah pada $tanggal telah dikirim untuk persetujuan. Deskripsi: $deskripsi',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'receipt_long',
      'avatarColor': 'green',
    };
    
    addNotification(notification);
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
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Meeting Berhasil Dijadwalkan',
      'subtitle': '$judulMeeting pada $tanggal ($waktuMulai - $waktuSelesai) di $tempat telah dijadwalkan. Jenis: $jenisMeeting',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'event',
      'avatarColor': 'blue',
    };
    
    addNotification(notification);
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
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Task Baru Berhasil Dibuat',
      'subtitle': '$judulTask (prioritas: $prioritas, status: $status) dengan deadline $tanggalDeadline telah dibuat${hasReminder ? ' dengan pengingat aktif' : ''}.',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'task_alt',
      'avatarColor': 'teal',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi kunjungan kerja
  void addKunkerNotification({
    required String noSurat,
    required String tanggalAwal,
    required String tanggalAkhir,
    required String lokasi,
    required String jenisPerjadin,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Kunjungan Kerja Berhasil Diajukan',
      'subtitle': 'Kunjungan kerja $noSurat ke $lokasi pada $tanggalAwal - $tanggalAkhir ($jenisPerjadin) telah berhasil diajukan.',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'business_center',
      'avatarColor': 'orange',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi rumah aspirasi
  void addRumahAspirasiNotification({
    required String namaAnggota,
    required String fraksi,
    required String dapil,
    required String tanggalSurat,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Kegiatan Rumah Aspirasi Berhasil Ditambahkan',
      'subtitle': 'Kegiatan rumah aspirasi untuk $namaAnggota ($fraksi - $dapil) tanggal $tanggalSurat telah berhasil ditambahkan.',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'home',
      'avatarColor': 'purple',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi BPJS
  void addBPJSNotification({
    required String nama,
    required String hubunganKeluarga,
    required String noBPJS,
    required String namaFaskes,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Data BPJS Berhasil Ditambahkan',
      'subtitle': 'Data BPJS untuk $nama ($hubunganKeluarga) dengan nomor $noBPJS dan faskes $namaFaskes telah berhasil ditambahkan.',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'medical_services',
      'avatarColor': 'red',
    };
    
    addNotification(notification);
  }

  // Method khusus untuk menambahkan notifikasi agenda pribadi
  void addAgendaNotification({
    required String namaAcara,
    required String tanggal,
    required String waktu,
    required String deskripsi,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Agenda Pribadi Berhasil Ditambahkan',
      'subtitle': '$namaAcara pada $tanggal pukul $waktu telah dijadwalkan. Deskripsi: $deskripsi',
      'time': 'Baru saja',
      'hasRedDot': true,
      'icon': 'calendar_month',
      'avatarColor': 'indigo',
    };
    
    addNotification(notification);
  }
}
