import 'package:sqflite/sqflite.dart';
import 'app_database_helper.dart';
import '../models/notification/notification_model.dart';

class NotificationDatabaseHelper {
  final AppDatabaseHelper _appDatabaseHelper = AppDatabaseHelper();

  // Get database instance
  Future<Database> get _database => _appDatabaseHelper.database;

  // Create notifications table
  Future<void> createNotificationTable(Database db) async {
    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        time TEXT NOT NULL,
        has_red_dot INTEGER NOT NULL DEFAULT 1,
        is_read INTEGER NOT NULL DEFAULT 0,
        icon_name TEXT NOT NULL,
        avatar_color TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        read_at TEXT,
        user_id INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
    await db.execute('CREATE INDEX idx_notifications_category ON notifications(category)');
    await db.execute('CREATE INDEX idx_notifications_created_at ON notifications(created_at)');
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications(user_id)');

    print('DEBUG: Notifications table created successfully');
  }

  // Insert notification
  Future<String> insertNotification(NotificationModel notification) async {
    try {
      final db = await _database;
      final notificationData = notification.toMap();
      
      print('DEBUG: Inserting notification: ${notification.title}');
      
      await db.insert('notifications', notificationData);
      print('DEBUG: Notification inserted successfully with ID: ${notification.id}');
      
      return notification.id;
    } catch (e) {
      print('DEBUG: Error inserting notification: $e');
      throw Exception('Failed to insert notification: $e');
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final db = await _database;
      final maps = await db.query(
        'notifications',
        orderBy: 'created_at DESC',
      );
      
      print('DEBUG: Retrieved ${maps.length} notifications from database');
      
      return maps.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Error getting all notifications: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final db = await _database;
      final maps = await db.query(
        'notifications',
        where: 'is_read = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
      );
      
      print('DEBUG: Retrieved ${maps.length} unread notifications');
      
      return maps.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Error getting unread notifications: $e');
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  // Get read notifications
  Future<List<NotificationModel>> getReadNotifications() async {
    try {
      final db = await _database;
      final maps = await db.query(
        'notifications',
        where: 'is_read = ?',
        whereArgs: [1],
        orderBy: 'read_at DESC',
      );
      
      print('DEBUG: Retrieved ${maps.length} read notifications');
      
      return maps.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Error getting read notifications: $e');
      throw Exception('Failed to get read notifications: $e');
    }
  }

  // Get notifications by category
  Future<List<NotificationModel>> getNotificationsByCategory(String category) async {
    try {
      final db = await _database;
      final maps = await db.query(
        'notifications',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get notifications by category: $e');
    }
  }

  // Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final db = await _database;
      final maps = await db.query(
        'notifications',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return NotificationModel.fromMap(maps.first);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get notification by ID: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      final db = await _database;
      final now = DateTime.now();
      
      print('DEBUG: Marking notification $id as read');
      
      final updated = await db.update(
        'notifications',
        {
          'is_read': 1,
          'has_red_dot': 0,
          'read_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DEBUG: Marked $updated notification(s) as read');
    } catch (e) {
      print('DEBUG: Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final db = await _database;
      final now = DateTime.now();
      
      final updated = await db.update(
        'notifications',
        {
          'is_read': 1,
          'has_red_dot': 0,
          'read_at': now.toIso8601String(),
        },
        where: 'is_read = ?',
        whereArgs: [0],
      );
      
      print('DEBUG: Marked $updated notifications as read');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      final db = await _database;
      
      await db.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('DEBUG: Deleted notification with ID: $id');
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      final db = await _database;
      
      final deleted = await db.delete(
        'notifications',
        where: 'is_read = ?',
        whereArgs: [1],
      );
      
      print('DEBUG: Deleted $deleted read notifications');
    } catch (e) {
      throw Exception('Failed to delete read notifications: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0'
      );
      
      final count = result.first['count'] as int;
      print('DEBUG: Unread notification count: $count');
      
      return count;
    } catch (e) {
      print('DEBUG: Error getting unread count: $e');
      return 0;
    }
  }

  // Get notification statistics
  Future<Map<String, int>> getNotificationStatistics() async {
    try {
      final db = await _database;
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM notifications');
      final unreadResult = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE is_read = 0');
      final readResult = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE is_read = 1');
      
      return {
        'total': totalResult.first['count'] as int,
        'unread': unreadResult.first['count'] as int,
        'read': readResult.first['count'] as int,
      };
    } catch (e) {
      throw Exception('Failed to get notification statistics: $e');
    }
  }

  // Update notification time displays
  Future<void> updateTimeDisplays() async {
    try {
      final notifications = await getAllNotifications();
      final db = await _database;
      
      for (final notification in notifications) {
        final updatedNotification = notification.updateTimeDisplay();
        if (updatedNotification.time != notification.time) {
          await db.update(
            'notifications',
            {'time': updatedNotification.time},
            where: 'id = ?',
            whereArgs: [notification.id],
          );
        }
      }
      
      print('DEBUG: Updated time displays for notifications');
    } catch (e) {
      print('DEBUG: Error updating time displays: $e');
    }
  }

  // Clean old notifications (older than 30 days)
  Future<void> cleanOldNotifications({int daysToKeep = 30}) async {
    try {
      final db = await _database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final deleted = await db.delete(
        'notifications',
        where: 'created_at < ? AND is_read = 1',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      
      print('DEBUG: Cleaned $deleted old notifications');
    } catch (e) {
      print('DEBUG: Error cleaning old notifications: $e');
    }
  }
}
