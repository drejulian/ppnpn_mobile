import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification provider for managing unread notification count
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
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
  NotificationNotifier() : super(NotificationState(
    unreadCount: 4,
    unreadNotifications: _getInitialUnreadNotifications(),
    readNotifications: _getInitialReadNotifications(),
  ));

  static List<Map<String, dynamic>> _getInitialUnreadNotifications() {
    return [
      {
        'id': '1',
        'title': 'Pengajuan Cuti Anda Disetujui',
        'subtitle': 'Cuti tanggal 15-17 September 2025 telah disetujui oleh atasan.',
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
        'subtitle': 'Lembur tanggal 10 September 2025 tidak dapat disetujui. Silakan hubungi HRD untuk informasi lebih lanjut.',
        'time': '3h ago',
        'hasRedDot': true,
        'icon': 'cancel',
        'avatarColor': 'red',
      },
      {
        'id': '4',
        'title': 'Pengajuan Reimburse Disetujui',
        'subtitle': 'Reimburse transport Rp 150.000 telah disetujui dan akan segera diproses.',
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
        'subtitle': 'Meeting akan dimulai dalam 30 menit di ruang meeting lantai 3.',
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
    final unreadNotifications = List<Map<String, dynamic>>.from(state.unreadNotifications);
    final readNotifications = List<Map<String, dynamic>>.from(state.readNotifications);
    
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
    final unreadNotifications = List<Map<String, dynamic>>.from(state.unreadNotifications);
    unreadNotifications.insert(0, notification);
    
    state = state.copyWith(
      unreadCount: unreadNotifications.length,
      unreadNotifications: unreadNotifications,
    );
  }
}
