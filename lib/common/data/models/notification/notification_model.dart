import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final bool hasRedDot;
  final bool isRead;
  final String iconName;
  final String avatarColor;
  final String category; // 'cuti', 'izin', 'lembur', 'reimburse', etc.
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.hasRedDot,
    required this.isRead,
    required this.iconName,
    required this.avatarColor,
    required this.category,
    required this.createdAt,
    this.readAt,
  });

  // Create from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      time: map['time'] as String,
      hasRedDot: (map['has_red_dot'] as int) == 1,
      isRead: (map['is_read'] as int) == 1,
      iconName: map['icon_name'] as String,
      avatarColor: map['avatar_color'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      readAt: map['read_at'] != null 
          ? DateTime.parse(map['read_at'] as String)
          : null,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'has_red_dot': hasRedDot ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'icon_name': iconName,
      'avatar_color': avatarColor,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Convert to legacy format for UI compatibility
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'hasRedDot': hasRedDot,
      'icon': iconName,
      'avatarColor': avatarColor,
    };
  }

  // Create notification with auto-generated ID and current timestamp
  factory NotificationModel.create({
    required String title,
    required String subtitle,
    required String iconName,
    required String avatarColor,
    required String category,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      time: 'Baru saja',
      hasRedDot: true,
      isRead: false,
      iconName: iconName,
      avatarColor: avatarColor,
      category: category,
      createdAt: now,
    );
  }

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    bool? hasRedDot,
    bool? isRead,
    String? iconName,
    String? avatarColor,
    String? category,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      hasRedDot: hasRedDot ?? this.hasRedDot,
      isRead: isRead ?? this.isRead,
      iconName: iconName ?? this.iconName,
      avatarColor: avatarColor ?? this.avatarColor,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      hasRedDot: false,
      readAt: DateTime.now(),
    );
  }

  // Update time display based on creation time
  NotificationModel updateTimeDisplay() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    String timeDisplay;
    if (difference.inMinutes < 1) {
      timeDisplay = 'Baru saja';
    } else if (difference.inMinutes < 60) {
      timeDisplay = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeDisplay = '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      timeDisplay = 'Yesterday';
    } else if (difference.inDays < 7) {
      timeDisplay = '${difference.inDays} days ago';
    } else {
      timeDisplay = DateFormat('dd MMM yyyy').format(createdAt);
    }
    
    return copyWith(time: timeDisplay);
  }

  @override
  String toString() {
    return 'NotificationModel{id: $id, title: $title, category: $category, isRead: $isRead}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}