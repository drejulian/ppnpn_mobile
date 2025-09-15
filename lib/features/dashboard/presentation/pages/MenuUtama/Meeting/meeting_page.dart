import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
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
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
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
            style: theme.typographyBold.bodyMedium.copyWith(
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
    final isOnline = meeting.room.toLowerCase().contains('online') || 
                     meeting.room.toLowerCase().contains('zoom') || 
                     meeting.room.toLowerCase().contains('meet');
    
    return AppListCard(
      onTap: () => _showMeetingDetailDialog(context, meeting),
      leftAccentColor: meeting.color,
      title: meeting.title,
      subtitle: meeting.room,
      chips: [
        AppPillChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy').format(meeting.date),
          color: meeting.color,
        ),
        AppPillChip(
          icon: Icons.schedule,
          label: '${meeting.startTime} - ${meeting.endTime}',
          color: Colors.blue,
        ),
        if (isOnline)
          AppPillChip(
            icon: Icons.videocam,
            label: 'Online Meeting',
            color: Colors.green,
          )
        else
          AppPillChip(
            icon: Icons.room,
            label: 'On-site',
            color: Colors.orange,
          ),
      ],
    );
  }

  void _editMeeting(MeetingData meeting) async {
    final result = await Navigator.push<MeetingData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetingPage(
          meetingData: meeting,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        final index = _meetings.indexWhere((m) => 
          m.title == meeting.title && 
          m.date == meeting.date
        );
        if (index != -1) {
          _meetings[index] = result;
        }
      });
    }
  }

  void _showMeetingDetailDialog(BuildContext context, MeetingData meeting) {
    final isOnline = meeting.room.toLowerCase().contains('online') || 
                     meeting.room.toLowerCase().contains('zoom') || 
                     meeting.room.toLowerCase().contains('meet');
    
    final dialogData = SIHAKIDialogData(
      title: 'Detail Meeting - ${meeting.title}',
      fields: [
        SIHAKIDialogField(label: 'Title', value: meeting.title),
        SIHAKIDialogField(label: 'Room', value: meeting.room),
        SIHAKIDialogField(label: 'Date', value: DateFormat('dd MMM yyyy').format(meeting.date)),
        SIHAKIDialogField(label: 'Time', value: '${meeting.startTime} - ${meeting.endTime}'),
        SIHAKIDialogField(label: 'Type', value: isOnline ? 'Online Meeting' : 'Offline Meeting'),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Edit Meeting',
          backgroundColor: Colors.orange[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editMeeting(meeting);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Delete Meeting',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDeleteMeetingWithSIHAKI(meeting);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.share_rounded,
          label: 'Share Meeting',
          backgroundColor: Colors.blue[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _shareMeeting(meeting);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _confirmDeleteMeetingWithSIHAKI(MeetingData meeting) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Meeting',
      message:
          'Apakah Anda yakin ingin menghapus meeting "${meeting.title}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        _deleteMeeting(meeting);
      },
    );
  }

  void _shareMeeting(MeetingData meeting) {
    // Implementasi share meeting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing meeting: ${meeting.title}'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
