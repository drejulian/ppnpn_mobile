import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'edit_meeting_page.dart';
import 'tambah_meeting_page.dart';
import 'meeting_data.dart';

// Meeting Providers
class MeetingNotifier extends StateNotifier<List<MeetingData>> {
  MeetingNotifier()
    : super([
        MeetingData(
          title: 'Rapat Koordinasi Tim',
          room: 'Meeting room - Gotham',
          date: DateTime(2025, 9, 30),
          startTime: '09:00',
          endTime: '10:30',
        ),
        MeetingData(
          title: 'Online - Project Review',
          room: 'Online - Zoom Meeting',
          date: DateTime(2025, 10, 2),
          startTime: '14:00',
          endTime: '15:30',
        ),
        MeetingData(
          title: 'Presentasi Proposal',
          room: 'Ruang Konferensi A',
          date: DateTime(2025, 10, 5),
          startTime: '10:00',
          endTime: '11:30',
        ),
        MeetingData(
          title: 'Daily Standup',
          room: 'Online - Google Meet',
          date: DateTime.now().add(const Duration(days: 1)),
          startTime: '08:30',
          endTime: '09:00',
        ),
        MeetingData(
          title: 'Client Presentation',
          room: 'Ruang Meeting Utama',
          date: DateTime.now().add(const Duration(days: 3)),
          startTime: '13:00',
          endTime: '14:30',
        ),
      ]);

  void add(MeetingData meeting) {
    state = [...state, meeting];
  }

  void remove(MeetingData meeting) {
    state = state.where((m) => m != meeting).toList();
  }

  void update(MeetingData oldMeeting, MeetingData newMeeting) {
    final index = state.indexWhere(
      (m) => m.title == oldMeeting.title && m.date == oldMeeting.date,
    );
    if (index != -1) {
      final newState = [...state];
      newState[index] = newMeeting;
      state = newState;
    }
  }
}

final meetingProvider =
    StateNotifierProvider<MeetingNotifier, List<MeetingData>>(
      (ref) => MeetingNotifier(),
    );
final meetingSearchProvider = StateProvider<String>((ref) => '');
final meetingTypeFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredMeetingProvider = Provider<List<MeetingData>>((ref) {
  final meetings = ref.watch(meetingProvider);
  final searchQuery = ref.watch(meetingSearchProvider).toLowerCase().trim();
  final typeFilter = ref.watch(meetingTypeFilterProvider);

  return meetings.where((meeting) {
    final matchesSearch =
        searchQuery.isEmpty ||
        meeting.title.toLowerCase().contains(searchQuery) ||
        meeting.room.toLowerCase().contains(searchQuery);

    final isOnline =
        meeting.room.toLowerCase().contains('online') ||
        meeting.room.toLowerCase().contains('zoom') ||
        meeting.room.toLowerCase().contains('meet');

    final matchesType =
        typeFilter == 'Semua' ||
        (typeFilter == 'Online' && isOnline) ||
        (typeFilter == 'Offline' && !isOnline);

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredMeetings = ref.watch(filteredMeetingProvider);
    final typeFilter = ref.watch(meetingTypeFilterProvider);

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

  Widget _buildMeetingCard(MeetingData meeting, MyTheme theme, int index) {
    final isOnline =
        meeting.room.toLowerCase().contains('online') ||
        meeting.room.toLowerCase().contains('zoom') ||
        meeting.room.toLowerCase().contains('meet');

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

  void _editMeeting(MeetingData meeting) async {
    final result = await Navigator.push<MeetingData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetingPage(meetingData: meeting),
      ),
    );

    if (result != null) {
      ref.read(meetingProvider.notifier).update(meeting, result);
    }
  }

  void _showMeetingDetailDialog(BuildContext context, MeetingData meeting) {
    final isOnline =
        meeting.room.toLowerCase().contains('online') ||
        meeting.room.toLowerCase().contains('zoom') ||
        meeting.room.toLowerCase().contains('meet');

    final dialogData = SIHAKIDialogData(
      title: 'Detail Meeting - ${meeting.title}',
      fields: [
        SIHAKIDialogField(label: 'Title', value: meeting.title),
        SIHAKIDialogField(label: 'Room', value: meeting.room),
        SIHAKIDialogField(
          label: 'Date',
          value: DateFormat('dd MMM yyyy').format(meeting.date),
        ),
        SIHAKIDialogField(
          label: 'Time',
          value: '${meeting.startTime} - ${meeting.endTime}',
        ),
        SIHAKIDialogField(
          label: 'Type',
          value: isOnline ? 'Online Meeting' : 'Offline Meeting',
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteMeeting(MeetingData meeting) {
    ref.read(meetingProvider.notifier).remove(meeting);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting deleted successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddMeetingDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahMeetingPage()),
    );

    // If a new meeting was returned, add it to the list
    if (result != null && result is MeetingData) {
      ref.read(meetingProvider.notifier).add(result);
    }
  }
}
