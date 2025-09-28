import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/meeting_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/meeting_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Load meetings when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetingProvider.notifier).loadMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final meetingState = ref.watch(meetingProvider);
    final meetings = meetingState.meetings;

    // Show loading indicator if data is loading
    if (meetingState.isLoading && meetings.isEmpty) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error message if there's an error
    if (meetingState.error != null) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading meetings',
                style: theme.typographyBold.bodyLarge,
              ),
              SizedBox(height: 8),
              Text(
                meetingState.error!,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(meetingProvider.notifier).loadMeetings(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
            _buildCalendarSection(theme, meetings),

            const SizedBox(height: 20),

            // Meeting List Section
            _buildMeetingListSection(theme, meetings),
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

  Widget _buildCalendarSection(MyTheme theme, List<MeetingModel> meetings) {
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
          _buildCalendarGrid(theme, currentMonth, daysInMonth, firstDayWeekday, meetings),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(MyTheme theme, DateTime currentMonth, int daysInMonth, int firstDayWeekday, List<MeetingModel> meetings) {
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
          DateTime(currentMonth.year, currentMonth.month, dayNumber),
          meetings
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
  bool _hasMeetingOnDate(DateTime date, List<MeetingModel> meetings) {
    return meetings.any((meeting) => 
      meeting.date.year == date.year &&
      meeting.date.month == date.month &&
      meeting.date.day == date.day
    );
  }

  Widget _buildMeetingListSection(MyTheme theme, List<MeetingModel> meetings) {
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
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return _buildMeetingCard(meeting, theme, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(MeetingModel meeting, MyTheme theme, int index) {
    final isOnline = meeting.isOnline;
    
    // Define color based on meeting status
    Color cardColor;
    switch (meeting.status) {
      case MeetingStatus.scheduled:
        cardColor = Colors.blue;
        break;
      case MeetingStatus.ongoing:
        cardColor = Colors.green;
        break;
      case MeetingStatus.completed:
        cardColor = Colors.grey;
        break;
      case MeetingStatus.cancelled:
        cardColor = Colors.red;
        break;
    }
    
    return AppListCard(
      onTap: () => _showMeetingDetailDialog(context, meeting),
      leftAccentColor: cardColor,
      title: meeting.title,
      subtitle: meeting.room,
      chips: [
        AppPillChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy').format(meeting.date),
          color: cardColor,
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

  void _editMeeting(MeetingModel meeting) async {
    // Convert MeetingModel to MeetingData for compatibility with existing edit page
    final meetingData = MeetingData(
      title: meeting.title,
      room: meeting.room,
      date: meeting.date,
      startTime: meeting.startTime,
      endTime: meeting.endTime,
      color: Colors.blue, // Default color
    );
    
    final result = await Navigator.push<MeetingData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetingPage(
          meetingData: meetingData,
        ),
      ),
    );
    
    if (result != null && meeting.id != null) {
      // Update the meeting using the provider
      final updatedMeeting = MeetingModel(
        id: meeting.id,
        meetingId: meeting.meetingId,
        title: result.title,
        description: meeting.description,
        room: result.room,
        date: result.date,
        startTime: result.startTime,
        endTime: result.endTime,
        organizer: meeting.organizer,
        attendees: meeting.attendees,
        isOnline: meeting.isOnline,
        meetingLink: meeting.meetingLink,
        status: meeting.status,
        createdAt: meeting.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await ref.read(meetingProvider.notifier).updateMeeting(updatedMeeting);
    }
  }

  void _showMeetingDetailDialog(BuildContext context, MeetingModel meeting) {
    final isOnline = meeting.isOnline;
    
    final dialogData = SIHAKIDialogData(
      title: 'Detail Meeting - ${meeting.title}',
      fields: [
        SIHAKIDialogField(label: 'Title', value: meeting.title),
        SIHAKIDialogField(label: 'Room', value: meeting.room),
        SIHAKIDialogField(label: 'Date', value: DateFormat('dd MMM yyyy').format(meeting.date)),
        SIHAKIDialogField(label: 'Time', value: '${meeting.startTime} - ${meeting.endTime}'),
        SIHAKIDialogField(label: 'Organizer', value: meeting.organizer),
        SIHAKIDialogField(label: 'Status', value: meeting.status.label),
        SIHAKIDialogField(label: 'Type', value: isOnline ? 'Online Meeting' : 'Offline Meeting'),
        if (meeting.description != null && meeting.description!.isNotEmpty)
          SIHAKIDialogField(label: 'Description', value: meeting.description!),
        if (meeting.attendees.isNotEmpty)
          SIHAKIDialogField(label: 'Attendees', value: meeting.attendees.join(', ')),
        if (isOnline && meeting.meetingLink != null)
          SIHAKIDialogField(label: 'Meeting Link', value: meeting.meetingLink!),
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

  void _confirmDeleteMeetingWithSIHAKI(MeetingModel meeting) {
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

  void _shareMeeting(MeetingModel meeting) {
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

  void _deleteMeeting(MeetingModel meeting) async {
    if (meeting.id != null) {
      await ref.read(meetingProvider.notifier).deleteMeeting(meeting.id!);
      
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
  }

  void _showAddMeetingDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahMeetingPage(),
      ),
    );
    
    // If a new meeting was returned, add it using the provider
    if (result != null && result is MeetingData) {
      // Convert MeetingData to MeetingModel and add via provider
      final newMeeting = MeetingModel.fromFormData(
        title: result.title,
        room: result.room,
        date: result.date,
        startTime: result.startTime,
        endTime: result.endTime,
        organizer: 'Current User', // Default organizer
      );
      
      await ref.read(meetingProvider.notifier).addMeeting(newMeeting);
    }
  }
}
