import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'edit_meeting_page.dart';
import 'tambah_meeting_page.dart';
import 'meeting_data.dart';

class MeetingPage extends ConsumerStatefulWidget {
  const MeetingPage({super.key});

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  DateTime _currentDate = DateTime.now();
  int _selectedMonthOffset = 0;

  // Sample meeting data
  List<MeetingData> _meetings = [
    MeetingData(
      title: 'Name Meetings',
      room: 'Meeting room - Gotham',
      date: DateTime(2025, 8, 30),
      startTime: '09:00',
      endTime: '09:30',
      color: Colors.teal,
    ),
    MeetingData(
      title: 'Name Meetings',
      room: 'Meeting room - Gotham',
      date: DateTime(2025, 8, 29),
      startTime: '09:00',
      endTime: '09:30',
      color: Colors.red,
    ),
    MeetingData(
      title: 'Name Meetings',
      room: 'Meeting room - Gotham',
      date: DateTime(2025, 8, 28),
      startTime: '09:00',
      endTime: '09:30',
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meeting',
          style: theme.typographyRegular.headingSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Add Meeting Button
            _buildAddMeetingButton(theme),

            const SizedBox(height: 20),

            // Calendar Section
            _buildCalendarSection(theme),

            const SizedBox(height: 20),

            // Meeting List Section
            _buildMeetingListSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMeetingButton(MyTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showAddMeetingDialog(context),
          icon: const Icon(Icons.add_circle, size: 20),
          label: Text(
            'TAMBAH MEETING BARU',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.primarySwatch,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection(MyTheme theme) {
    final currentMonth =
        DateTime(_currentDate.year, _currentDate.month + _selectedMonthOffset);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                  setState(() {
                    _selectedMonthOffset--;
                  });
                },
                icon: Icon(Icons.chevron_left, color: theme.primarySwatch),
              ),
              Column(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(currentMonth),
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    DateFormat('EEEE', 'id_ID').format(currentMonth),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonthOffset++;
                  });
                },
                icon: Icon(Icons.chevron_right, color: theme.primarySwatch),
              ),
            ],
          ),
          const SizedBox(height: 0),

          // Header Hari dalam Seminggu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                .map(
                  (day) => Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 0),

          // Grid Tanggal
          _buildCalendarGrid(theme, currentMonth, daysInMonth, firstDayWeekday),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(MyTheme theme, DateTime currentMonth, int daysInMonth, int firstDayWeekday) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        // Adjust for Sunday as first day (weekday 7 becomes 0)
        int adjustedFirstWeekday = firstDayWeekday % 7;
        int dayNumber = index - adjustedFirstWeekday + 1;

        bool isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
        bool isToday = isCurrentMonth &&
            dayNumber == DateTime.now().day &&
            currentMonth.month == DateTime.now().month &&
            currentMonth.year == DateTime.now().year;

        // Check if this date has any meetings
        bool hasmeeting = isCurrentMonth && _hasMeetingOnDate(
          DateTime(currentMonth.year, currentMonth.month, dayNumber)
        );

        // Check if it's weekend (Saturday = 6, Sunday = 7 in Dart weekday)
        DateTime dateTime = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        bool isWeekend = isCurrentMonth && (dateTime.weekday == 6 || dateTime.weekday == 7);

        return Container(
          decoration: BoxDecoration(
            color: isToday
                ? theme.primarySwatch
                : hasmeeting
                    ? theme.primarySwatch.shade100
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              isCurrentMonth ? dayNumber.toString() : '',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: (isToday || hasmeeting)
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isToday
                    ? Colors.white
                    : isWeekend
                        ? Colors.red.shade600
                        : hasmeeting
                            ? theme.primarySwatch.shade700
                            : Colors.grey[700],
                  ),
                ),
              ),
            );
          },
        );
  }

  // Helper function to check if a date has any meetings
  bool _hasMeetingOnDate(DateTime date) {
    return _meetings.any((meeting) => 
      meeting.date.year == date.year &&
      meeting.date.month == date.month &&
      meeting.date.day == date.day
    );
  }

  Widget _buildMeetingListSection(MyTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _meetings.length,
            itemBuilder: (context, index) {
              final meeting = _meetings[index];
              return _buildMeetingCard(meeting, theme, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(MeetingData meeting, MyTheme theme, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: meeting.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: theme.typographyRegular.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meeting.room,
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: meeting.color),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd.MM.yyyy').format(meeting.date),
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: meeting.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_outlined,
                            size: 14, color: meeting.color),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.startTime}-${meeting.endTime}',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: meeting.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showMeetingOptions(context, meeting),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.more_vert,
                  color: Colors.grey[600], size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMeetingOptions(BuildContext context, MeetingData meeting) {
    final theme = ref.watch(themeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Meeting Options',
                style: theme.typographyRegular.headingSmall.copyWith(
                  color: theme.primarySwatch.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Meeting',
                subtitle: 'Modify meeting details',
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditMeetingPage(meetingData: meeting),
                    ),
                  );
                  
                  // If meeting was updated, refresh the list
                  if (result != null && result is MeetingData) {
                    setState(() {
                      final index = _meetings.indexWhere((m) => m.title == meeting.title && 
                                                              m.date == meeting.date);
                      if (index != -1) {
                        _meetings[index] = result;
                      }
                    });
                  }
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Delete Meeting',
                subtitle: 'Remove this meeting',
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMeeting(meeting);
                },
                theme: theme,
                isDestructive: true,
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                icon: Icons.share_outlined,
                title: 'Share Meeting',
                subtitle: 'Send meeting details',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: share
                },
                theme: theme,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required MyTheme theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : theme.primarySwatch.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? Colors.red.shade600
              : theme.primarySwatch.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.typographyRegular.bodyMedium.copyWith(
          color:
              isDestructive ? Colors.red.shade700 : theme.primarySwatch.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.typographyRegular.bodySmall.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.grey[400], size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _confirmDeleteMeeting(MeetingData meeting) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Anda yakin ingin mendelete jadwal meeting ini?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteMeeting(meeting);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteMeeting(MeetingData meeting) {
    setState(() {
      _meetings.remove(meeting);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting deleted successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAddMeetingDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahMeetingPage(),
      ),
    );
    
    // If a new meeting was returned, add it to the list
    if (result != null && result is MeetingData) {
      setState(() {
        _meetings.add(result);
      });
    }
  }
}
