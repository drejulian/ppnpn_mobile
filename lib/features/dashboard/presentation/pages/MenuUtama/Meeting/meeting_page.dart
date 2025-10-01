import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/meeting_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/meeting_provider.dart';
import 'edit_meeting_page.dart';
import 'tambah_meeting_page.dart';
import 'meeting_data.dart';

// Search and filter providers untuk meeting
final meetingSearchProvider = StateProvider<String>((ref) => ''); 
final meetingTypeFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredMeetingProvider = Provider<List<MeetingModel>>((ref) {
  final meetingState = ref.watch(meetingProvider);
  final meetings = meetingState.meetings;
  final searchQuery = ref.watch(meetingSearchProvider).toLowerCase().trim();
  final typeFilter = ref.watch(meetingTypeFilterProvider);

  return meetings.where((meeting) {
    final matchesSearch =
        searchQuery.isEmpty ||
        meeting.title.toLowerCase().contains(searchQuery) ||
        meeting.room.toLowerCase().contains(searchQuery);

    final matchesType =
        typeFilter == 'Semua' ||
        (typeFilter == 'Online' && meeting.isOnline) ||
        (typeFilter == 'Offline' && !meeting.isOnline);

    return matchesSearch && matchesType;
  }).toList();
});

class MeetingPage extends ConsumerStatefulWidget {
  const MeetingPage({super.key});

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load meetings when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetingProvider.notifier).loadMeetings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final meetingState = ref.watch(meetingProvider);
    final filteredMeetings = ref.watch(filteredMeetingProvider);
    final typeFilter = ref.watch(meetingTypeFilterProvider);

    // Show loading indicator if data is loading
    if (meetingState.isLoading && meetingState.meetings.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
          title: 'Meeting',
          onBackPressed: () => context.go('/home'),
          backTooltip: 'Kembali ke Beranda',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error message if there's an error
    if (meetingState.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
          title: 'Meeting',
          onBackPressed: () => context.go('/home'),
          backTooltip: 'Kembali ke Beranda',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading meetings',
                style: theme.typographyBold.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                meetingState.error!,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(meetingProvider.notifier).loadMeetings(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Meeting',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Column(
        children: [
          // Search Section with Filter
          Container(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Cari judul meeting atau ruangan...',
              margin: const EdgeInsets.all(16),
              hasActiveFilters: typeFilter != 'Semua',
              onChanged:
                  (value) =>
                      ref.read(meetingSearchProvider.notifier).state = value,
              onFilterReset: () {
                _searchController.clear();
                ref.read(meetingSearchProvider.notifier).state = '';
                ref.read(meetingTypeFilterProvider.notifier).state = 'Semua';
              },
              filterSection: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Tipe Meeting',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        ['Semua', 'Online', 'Offline']
                            .map(
                              (type) => FilterChip(
                                label: Text(type),
                                selected: typeFilter == type,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              meetingTypeFilterProvider
                                                  .notifier,
                                            )
                                            .state = type,
                                selectedColor: theme.primarySwatch.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: theme.primarySwatch,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Add Meeting Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          ),

          // Meeting List
          Expanded(
            child:
                filteredMeetings.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada meeting ditemukan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMeetings.length,
                      itemBuilder: (context, index) {
                        final meeting = filteredMeetings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMeetingCard(meeting, theme, index),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(MeetingModel meeting, theme, int index) {
    final isOnline = meeting.isOnline;

    return AppListCard(
      onTap: () => _showMeetingDetailDialog(context, meeting),
      leftAccentColor: Colors.teal,
      title: meeting.title,
      subtitle: meeting.room,
      leading: CircleAvatar(
        backgroundColor: Colors.teal.withOpacity(0.1),
        child: Icon(
          isOnline ? Icons.videocam : Icons.meeting_room,
          color: Colors.teal,
          size: 20,
        ),
      ),
      trailing: AppStatusChip(
        label: isOnline ? 'Online' : 'Offline',
        color: isOnline ? Colors.green : Colors.orange,
        icon: isOnline ? Icons.wifi : Icons.location_on,
      ),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy').format(meeting.date),
          color: Colors.teal,
        ),
        AppPillChip(
          icon: Icons.schedule,
          label: '${meeting.startTime} - ${meeting.endTime}',
          color: Colors.blue,
        ),
      ],
      actions: [
        AppViewDetailButton(
          onPressed: () => _showMeetingDetailDialog(context, meeting),
          tooltip: 'Lihat Detail',
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
          label: 'Ubah Meeting',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editMeeting(meeting);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Meeting',
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDeleteMeetingWithSIHAKI(meeting);
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
      MaterialPageRoute(builder: (context) => const TambahMeetingPage()),
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
