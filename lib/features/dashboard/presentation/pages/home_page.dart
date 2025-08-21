import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/sihaki_submenu_modal.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = _currentTime.hour;

    if (hour < 12) return 'Selamat Pagii';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(theme, context, _currentTime),
                const SizedBox(height: 24),

                // Absensi Card
                _buildAbsensiCard(theme, context, _currentTime),
                const SizedBox(height: 24),

                // Menu Utama Section
                _buildMenuSection(
                  'Menu Utama',
                  _getMainMenuItems(),
                  theme,
                  context,
                ),
                const SizedBox(height: 24),

                // Data Pribadi Section
                _buildMenuSection(
                  'Data Pribadi',
                  _getDataPribadiItems(context),
                  theme,
                  context,
                ),
                const SizedBox(height: 24),

                // SIHAKI Section (New Addition)
                _buildSihakiSection(
                  'SIHAKI', // Title for the new section
                  _getSihakiItems(context), // Get SIHAKI specific menu items
                  theme,
                  context,
                ),
                const SizedBox(height: 24),

                // Kalender Section
                _buildKalenderSection(theme, context, _currentTime),
                const SizedBox(height: 24),

                // Agenda Section
                _buildAgendaSection(theme, context, _currentTime),
                const SizedBox(height: 24),

                // Pengumuman Section
                _buildPengumumanSection(theme, context, _currentTime),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    dynamic theme,
    BuildContext context,
    DateTime currentTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.primarySwatch, theme.secondarySwatch],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),

          // Greeting and Name with Current Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat(
                          'HH:mm:ss',
                          'id_ID',
                        ).format(currentTime), // Added seconds for realtime
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: theme.primarySwatch,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Miftahul Fazi',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(currentTime),
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada notifikasi baru'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiCard(
    dynamic theme,
    BuildContext context,
    DateTime currentTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primarySwatch, theme.secondarySwatch],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Absensi Hari Ini',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(currentTime),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'miftahul01',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Single Row Layout
          Row(
            children: [
              // Check In Button
              Expanded(
                flex: 2,
                child: _buildAbsensiButton(
                  'Check In',
                  Icons.login,
                  '08:00',
                  theme,
                  true,
                ),
              ),
              const SizedBox(width: 12),

              // Check Out Button
              Expanded(
                flex: 2,
                child: _buildAbsensiButton(
                  'Check Out',
                  Icons.logout,
                  '--:--',
                  theme,
                  false,
                ),
              ),
              const SizedBox(width: 12),

              // Riwayat Button
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('📊 Viewing attendance history');
                    debugPrint('👤 User: miftahul01');
                    debugPrint(
                      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur riwayat absensi akan segera tersedia',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.primarySwatch,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Riwayat\nAbsensi',
                    textAlign: TextAlign.center,
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiButton(
    String title,
    IconData icon,
    String time,
    dynamic theme,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.typographyRegular.bodyExtraSmall.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: theme.typographyRegular.bodyExtraSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    String title,
    List<MenuItemData> items,
    dynamic theme,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 6 : 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildMenuItem(item, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData item, dynamic theme) {
    return GestureDetector(
      onTap: item.onTap ?? () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [item.color.withValues(alpha: 0.8), item.color],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              item.title,
              style: theme.typographyRegular.bodyExtraSmall.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // New method for SIHAKI section
  Widget _buildSihakiSection(
    String title,
    List<MenuItemData> items,
    dynamic theme,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 6 : 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildMenuItem(item, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKalenderSection(
    dynamic theme,
    BuildContext context,
    DateTime currentTime,
  ) {
    final daysInMonth =
        DateTime(currentTime.year, currentTime.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentTime.year, currentTime.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalender',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Bulan dan Tahun
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      debugPrint('📅 Previous month navigation');
                    },
                    icon: Icon(Icons.chevron_left, color: theme.primarySwatch),
                  ),
                  Column(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(currentTime),
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE', 'id_ID').format(currentTime),
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      debugPrint('📅 Next month navigation');
                    },
                    icon: Icon(Icons.chevron_right, color: theme.primarySwatch),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Header Hari dalam Seminggu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                        .map(
                          (day) => Container(
                            width: 35,
                            height: 35,
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: theme.typographyRegular.bodyExtraSmall
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 8),

              // Grid Tanggal
              _buildCalendarGrid(theme, currentTime, daysInMonth, firstWeekday),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(
    dynamic theme,
    DateTime currentTime,
    int daysInMonth,
    int firstWeekday,
  ) {
    List<Widget> dayWidgets = [];

    // Empty cells for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 35, height: 35));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final isToday = day == currentTime.day;
      final isWeekend = (firstWeekday + day - 2) % 7 >= 5;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            final selectedDate = DateTime(
              currentTime.year,
              currentTime.month,
              day,
            );
            debugPrint(
              '📅 Selected date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            );
            debugPrint('👤 User: miftahul01');
          },
          child: Container(
            width: 35,
            height: 35,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday ? theme.primarySwatch : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  isToday
                      ? null
                      : Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: theme.typographyRegular.bodyExtraSmall.copyWith(
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color:
                    isToday
                        ? Colors.white
                        : isWeekend
                        ? Colors.red[400]
                        : Colors.grey[700],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: dayWidgets,
    );
  }

  Widget _buildAgendaSection(
    dynamic theme,
    BuildContext context,
    DateTime currentTime,
  ) {
    // Generate agenda with dynamic dates based on current time
    final agendaItems = [
      {
        'title': 'Rapat Tim Development',
        'time': '09:00 - 10:00',
        'date': currentTime, // Today
        'location': 'Meeting Room A',
        'type': 'meeting',
      },
      {
        'title': 'Review Code Sprint 3',
        'time': '14:00 - 15:00',
        'date': currentTime, // Today
        'location': 'Virtual',
        'type': 'review',
      },
      {
        'title': 'Standup Meeting',
        'time': '16:00 - 16:30',
        'date': currentTime.add(const Duration(days: 1)), // Tomorrow
        'location': 'Office',
        'type': 'meeting',
      },
      {
        'title': 'Training Flutter Advanced',
        'time': '10:00 - 12:00',
        'date': currentTime.add(const Duration(days: 2)), // Day after tomorrow
        'location': 'Training Center',
        'type': 'training',
      },
      {
        'title': 'Client Presentation',
        'time': '13:00 - 14:30',
        'date': currentTime.add(const Duration(days: 6)), // Next week
        'location': 'Conference Hall',
        'type': 'presentation',
      },
    ];

    // Group agenda by date
    Map<String, List<Map<String, dynamic>>> groupedAgenda = {};
    for (var item in agendaItems) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item['date'] as DateTime);
      if (!groupedAgenda.containsKey(dateKey)) {
        groupedAgenda[dateKey] = [];
      }
      groupedAgenda[dateKey]!.add(item);
    }

    // Sort dates
    final sortedDates =
        groupedAgenda.keys.toList()
          ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agenda',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('📋 Viewing all agenda');
                debugPrint('👤 User: miftahul01');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur lihat semua agenda akan segera tersedia',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: theme.primarySwatch,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              agendaItems.isEmpty
                  ? _buildEmptyState('Tidak ada agenda', Icons.event_note)
                  : Column(
                    children:
                        sortedDates.take(3).map((dateKey) {
                          final date = DateTime.parse(dateKey);
                          final items = groupedAgenda[dateKey]!;
                          return _buildAgendaDateGroup(
                            date,
                            items,
                            theme,
                            currentTime,
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildAgendaDateGroup(
    DateTime date,
    List<Map<String, dynamic>> items,
    dynamic theme,
    DateTime currentTime,
  ) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(currentTime);
    final isTomorrow =
        DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat(
          'yyyy-MM-dd',
        ).format(currentTime.add(const Duration(days: 1)));

    String dateLabel;
    if (isToday) {
      dateLabel = 'Hari Ini';
    } else if (isTomorrow) {
      dateLabel = 'Besok';
    } else {
      dateLabel = DateFormat('EEEE', 'id_ID').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.primarySwatch.withValues(alpha: 0.1),
                theme.secondarySwatch.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primarySwatch.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isToday ? theme.primarySwatch : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(date),
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'id_ID').format(date).toUpperCase(),
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isToday ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isToday ? theme.primarySwatch : Colors.grey[800],
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy', 'id_ID').format(date),
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} agenda',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Agenda Items
        ...items.map((item) {
          return _buildAgendaItem(item, theme);
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAgendaItem(Map<String, dynamic> item, dynamic theme) {
    Color getTypeColor(String type) {
      switch (type) {
        case 'meeting':
          return Colors.blue;
        case 'review':
          return Colors.orange;
        case 'training':
          return Colors.green;
        case 'presentation':
          return Colors.purple;
        default:
          return theme.primarySwatch;
      }
    }

    IconData getTypeIcon(String type) {
      switch (type) {
        case 'meeting':
          return Icons.groups;
        case 'review':
          return Icons.rate_review;
        case 'training':
          return Icons.school;
        case 'presentation':
          return Icons.present_to_all;
        default:
          return Icons.event;
      }
    }

    final typeColor = getTypeColor(item['type']);
    final typeIcon = getTypeIcon(item['type']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      item['time']!,
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location']!,
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengumumanSection(
    dynamic theme,
    BuildContext context,
    DateTime currentTime,
  ) {
    // Generate dynamic pengumuman dates
    final pengumumanItems = [
      {
        'title': 'Update Sistem Absensi',
        'content':
            'Sistem absensi akan mengalami maintenance pada tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(currentTime.add(const Duration(days: 1)))}',
        'date': DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(currentTime.subtract(const Duration(days: 2))),
      },
      {
        'title': 'Libur Nasional',
        'content': 'Hari Kemerdekaan RI - 17 Agustus ${currentTime.year}',
        'date': DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(currentTime.subtract(const Duration(days: 15))),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengumuman',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              pengumumanItems.isEmpty
                  ? _buildEmptyState('Tidak ada pengumuman', Icons.campaign)
                  : Column(
                    children:
                        pengumumanItems.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title']!,
                                        style: theme.typographyRegular.bodySmall
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                      ),
                                    ),
                                    Text(
                                      item['date']!,
                                      style: theme
                                          .typographyRegular
                                          .bodyExtraSmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['content']!,
                                  style: theme.typographyRegular.bodyExtraSmall
                                      .copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  List<MenuItemData> _getMainMenuItems() {
    return [
      MenuItemData(
        'Cuti',
        Icons.event_busy,
        Colors.orange,
        onTap: () {
          context.pushNamed(Routes.cuti.name);
        },
      ),
       MenuItemData('izin', Icons.assignment, Colors.blue,
          onTap: () {context.pushNamed(Routes.izin.name);},),
      MenuItemData(
        'Lembur',
        Icons.access_time,
        Colors.purple,
        onTap: () {
          context.pushNamed(Routes.lembur.name);
        },
      ),
      MenuItemData('Reimburse', Icons.assignment, Colors.blue,
          onTap: () {context.pushNamed(Routes.reimbursePage.name);},),
      MenuItemData('Training', Icons.school, Colors.indigo),
      MenuItemData('Meeting', Icons.groups, Colors.teal),
      MenuItemData('Task', Icons.task_alt, Colors.red),
      MenuItemData('Report', Icons.bar_chart, Colors.amber),
    ];
  }

  List<MenuItemData> _getDataPribadiItems(BuildContext context) {
    return [
      MenuItemData(
        'Edit Profil',
        Icons.person,
        Colors.blueAccent,
        onTap: () {
          context.pushNamed(Routes.editProfile.name);
        },
      ),
      MenuItemData(
        'Edit Identitas Diri',
        Icons.person,
        Colors.blue,
        onTap: () {
          context.pushNamed(Routes.pribadi.name);
        },
      ),
      MenuItemData(
        'Edit Data Honorarium',
        Icons.payments,
        Colors.green,
        onTap: () {
          context.pushNamed(Routes.honorarium.name);
        },
      ),
      MenuItemData(
        'Keluarga',
        Icons.family_restroom,
        Colors.green,
        onTap: () {
          context.pushNamed(Routes.keluarga.name);
        },
      ),
      MenuItemData(
        'PAS Foto',
        Icons.contact_phone,
        Colors.red,
        onTap: () {
          context.pushNamed(Routes.idCard.name);
        },
      ),
      MenuItemData(
        'Dokumen',
        Icons.folder,
        Colors.teal,
        onTap: () {
          context.pushNamed(Routes.dokumen.name);
        },
      ),
      MenuItemData(
        'Pendidikan',
        Icons.school,
        Colors.purple,
        onTap: () {
          debugPrint('🎓 Navigating to Pendidikan page');
          debugPrint('👤 User: miftahul01');
          context.pushNamed(Routes.pendidikan.name);
        },
      ),
      MenuItemData(
        'Riwayat Pekerjaan',
        Icons.work,
        Colors.orange,
        onTap: () {
          context.pushNamed(Routes.riwayatPekerjaan.name);
        },
      ),
      MenuItemData(
        'Data Lamaran',
        Icons.card_membership,
        Colors.indigo,
        onTap: () {
          context.pushNamed(Routes.dataLamaran.name);
        },
      ),
    ];
  }

  // Updated method to provide SIHAKI menu items with sub-menu functionality
  List<MenuItemData> _getSihakiItems(BuildContext context) {
    return [
      MenuItemData(
        'Data Pajak PPNPN',
        Icons.receipt_long,
        Colors.deepOrange,
        onTap: () {
          debugPrint('💰 Opening submenu for Data Pajak PPNPN');
          _showSihakiSubMenu(context, 'Data Pajak PPNPN', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description,
              Colors.blue,
              onTap: () {
                // Navigate to SKP PPNPM page
                debugPrint('Navigating to PPNPN SKP'); //
                // context.pushNamed(Routes.ppnpmSkp.name);
                context.pushNamed(Routes.skp.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money,
              Colors.green,
              onTap: () {
                // Navigate to Final Tax Withholding Slip PPNPM page
                debugPrint('Navigating to PPNPN Bukti Potong Pajak Final'); //
                context.pushNamed(Routes.ppf.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A1',
              Icons.format_list_numbered,
              Colors.purple,
              onTap: () {
                // Navigate to Tax Withholding Slip A1 PPNPM page
                debugPrint('Navigating to PPNPN Bukti Potong Pajak A1');
                context.pushNamed(Routes.ppa.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Agenda Pribadi Anggota',
        Icons.calendar_today,
        Colors.pink,
        onTap: () {
          debugPrint('🗓️ Opening submenu for Agenda Pribadi Anggota');
          _showSihakiSubMenu(context, 'Agenda Pribadi Anggota', [
            SubMenuItemData(
              'Daftar Agenda',
              Icons.list_alt,
              Colors.orange,
              onTap: () {
                // Navigate to Agenda List page
                debugPrint('Navigating to Daftar Agenda'); //
                 context.pushNamed(Routes.daftarAgenda.name);
              },
            ),
            SubMenuItemData(
              'Media Sosial Anggota',
              Icons.share,
              Colors.teal,
              onTap: () {
                // Navigate to Member's Social Media page
                debugPrint('Navigating to Media Sosial Anggota'); 
                 context.pushNamed(Routes.mediaSosialAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Data Pajak Anggota',
        Icons.account_balance_wallet,
        Colors.brown,
        onTap: () {
          debugPrint('💲 Opening submenu for Data Pajak Anggota');
          _showSihakiSubMenu(context, 'Data Pajak Anggota', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description,
              Colors.blue,
              onTap: () {
                // Navigate to SKP Anggota page
                debugPrint('Navigating to Anggota SKP'); //
                context.pushNamed(Routes.skpAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money,
              Colors.green,
              onTap: () {
                // Navigate to Final Tax Withholding Slip Anggota page
                debugPrint('Navigating to Anggota Bukti Potong Pajak Final'); //
                context.pushNamed(Routes.ppfAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A2',
              Icons.format_list_numbered_rtl,
              Colors.red,
              onTap: () {
                // Navigate to Tax Withholding Slip A2 Anggota page
                debugPrint('Navigating to Anggota Bukti Potong Pajak A2'); //
                context.pushNamed(Routes.ppaAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
  'Database Anggota DPR RI',
  Icons.storage,
  Colors.cyan,
  onTap: () {
    debugPrint('Navigating directly to Data Komisi');
    context.pushNamed('dataKomisi');
        },
      ),
      MenuItemData(
        'Data Kunjungan Kerja Perorangan',
        Icons.flight,
        Colors.lime,
        onTap: () {
          debugPrint('✈️ Navigating to Data Kunjungan Kerja Perorangan'); //
          context.pushNamed(Routes.kunkerPerorangan.name);
        },
      ),
      MenuItemData(
        'Data SIGOTA - KANJENK',
        Icons.fingerprint,
        Colors.grey,
        onTap: () {
          debugPrint('👍 Navigating to Data SIGOTA - KANJENK'); //
          // context.pushNamed(Routes.dataSigotaKanjek.name);
        },
      ),
      MenuItemData(
        'Dokumen Anggota',
        Icons.article,
        Colors.purpleAccent,
        onTap: () {
          debugPrint('📄 Navigating to Dokumen Anggota'); //
          context.pushNamed(Routes.dataDokumenAnggota.name);
        },
      ),
      MenuItemData(
        'Kegiatan Rumah Aspirasi',
        Icons.home,
        Colors.tealAccent,
        onTap: () {
          debugPrint('🏡 Navigating to Kegiatan Rumah Aspirasi'); //
          context.pushNamed(Routes.daftarPengajuanRumahAspirasi.name);
        },
      ),
      MenuItemData(
        'BPJS',
        Icons.local_hospital,
        Colors.lightGreen,
        onTap: () {
          debugPrint('🏥 Navigating to BPJS'); //
          context.pushNamed(Routes.dataBPJS.name);
        },
      ),
    ];
  }

  // Helper method to show the bottom sheet modal
  void _showSihakiSubMenu(
    BuildContext context,
    String title,
    List<SubMenuItemData> subMenuItems,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SihakiSubMenuModal(title: title, subMenuItems: subMenuItems);
      },
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  MenuItemData(this.title, this.icon, this.color, {this.onTap});
}