import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/providers/notification_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _markAsRead(String notificationId) {
    // Use provider to mark as read
    ref.read(notificationProvider.notifier).markAsRead(notificationId);
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi ditandai sebagai sudah dibaca'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () {
            _tabController.animateTo(1); // Switch to "Sudah Dibaca" tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.typographyBold.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.primarySwatch,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                labelStyle: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: theme.typographyRegular.bodySmall.copyWith(
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(
                    height: 40,
                    child: notificationState.unreadNotifications.isNotEmpty
                        ? Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Center(
                                child: Text(
                                  'Belum Dibaca',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                right: -8,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${notificationState.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'Belum Dibaca',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  const Tab(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Sudah Dibaca',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationList(isUnread: true),
                  _buildNotificationList(isUnread: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildNotificationList({required bool isUnread}) {
    final notificationState = ref.watch(notificationProvider);
    // Use provider state instead of local state
    final notifications = isUnread ? notificationState.unreadNotifications : notificationState.readNotifications;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUnread ? 'Tidak ada notifikasi yang belum dibaca' : 'Tidak ada notifikasi yang sudah dibaca',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification, isUnread);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, bool isUnread) {
    final theme = ref.watch(themeProvider);
    
    // Helper function to get icon from string
    IconData getIconFromString(String iconName) {
      switch (iconName) {
        case 'check_circle':
          return Icons.check_circle;
        case 'access_time':
          return Icons.access_time;
        case 'cancel':
          return Icons.cancel;
        case 'attach_money':
          return Icons.attach_money;
        case 'event':
          return Icons.event;
        case 'task_alt':
          return Icons.task_alt;
        case 'event_busy':
          return Icons.event_busy;
        case 'how_to_reg':
          return Icons.how_to_reg;
        case 'schedule':
          return Icons.schedule;
        case 'receipt_long':
          return Icons.receipt_long;
        case 'business_center':
          return Icons.business_center;
        case 'home':
          return Icons.home;
        case 'medical_services':
          return Icons.medical_services;
        case 'calendar_month':
          return Icons.calendar_month;
        default:
          return Icons.notifications;
      }
    }
    
    // Helper function to get color from string
    Color getColorFromString(String colorName) {
      switch (colorName) {
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'purple':
          return Colors.purple;
        case 'teal':
          return Colors.teal;
        default:
          return theme.primarySwatch;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread && notification['hasRedDot'] == true
            ? Border.all(color: theme.primarySwatch.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar or Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification['avatarColor'] is String 
                  ? getColorFromString(notification['avatarColor'])
                  : notification['avatarColor'] ?? theme.primarySwatch,
              borderRadius: BorderRadius.circular(20),
            ),
            child: notification['avatar'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      notification['avatar'],
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    notification['icon'] is String 
                        ? getIconFromString(notification['icon'])
                        : notification['icon'] ?? Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] ?? '',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: isUnread && notification['hasRedDot'] == true 
                        ? FontWeight.w700 
                        : FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['subtitle'] ?? '',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['time'] ?? '',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    if (isUnread && notification['hasRedDot'] == true) ...[
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Status indicator and action button
          Column(
            children: [
              if (notification['hasRedDot'] == true)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              if (isUnread && notification['hasRedDot'] == true) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _markAsRead(notification['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primarySwatch.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primarySwatch.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.done,
                      size: 18,
                      color: theme.primarySwatch,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

}
