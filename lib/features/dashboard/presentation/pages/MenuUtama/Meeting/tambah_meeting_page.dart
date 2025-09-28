import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/features/dashboard/providers/notification_provider.dart';
import 'meeting_data.dart';

class TambahMeetingPage extends ConsumerStatefulWidget {
  const TambahMeetingPage({super.key});

  @override
  ConsumerState<TambahMeetingPage> createState() => _TambahMeetingPageState();
}

class _TambahMeetingPageState extends ConsumerState<TambahMeetingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _roomController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Selected values
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _meetingType = 'Offline'; // 'Online' atau 'Offline'

  // Reminder settings
  DateTime? _reminderDateTime;
  bool _enableReminder = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Initialize date controller
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);

    // Initialize time controllers using consistent format
    _startTimeController.text = _formatTime(_startTime);
    _endTimeController.text = _formatTime(_endTime);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = _formatTime(picked);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = _formatTime(picked);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roomController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Tambah Meeting',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Data Meeting Card
              AppFormCard(
                title: 'Data Meeting',
                titleIcon: Icons.event,
                fields: [
                  FormFieldConfig(
                    label: 'Judul Meeting',
                    icon: Icons.title,
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    hintText: 'Masukkan judul meeting',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul meeting tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Deskripsi Meeting',
                    icon: Icons.description,
                    type: FormFieldType.multiline,
                    hintText: 'Masukkan deskripsi meeting (opsional)',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Jenis Meeting Card
              _buildJenisMeetingCard(theme),

              const SizedBox(height: 16),

              // Ruangan/Link Card (Conditional)
              _buildLocationCard(theme),

              const SizedBox(height: 16),

              // Tanggal & Waktu Card
              AppFormCard(
                title: 'Tanggal & Waktu',
                titleIcon: Icons.schedule,
                fields: [
                  FormFieldConfig(
                    label: 'Tanggal Meeting',
                    icon: Icons.calendar_today,
                    type: FormFieldType.datePicker,
                    isRequired: true,
                    controller: _dateController,
                    hintText: 'Pilih tanggal meeting',
                    suffixIcon: Icons.calendar_today,
                    onTap: _pickDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih tanggal meeting';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Waktu Mulai',
                    icon: Icons.schedule,
                    type: FormFieldType.datePicker,
                    isRequired: true,
                    controller: _startTimeController,
                    hintText: 'Pilih waktu mulai (contoh: 09:00)',
                    suffixIcon: Icons.access_time,
                    onTap: _pickStartTime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih waktu mulai meeting';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Waktu Selesai',
                    icon: Icons.schedule_outlined,
                    type: FormFieldType.datePicker,
                    isRequired: true,
                    controller: _endTimeController,
                    hintText: 'Pilih waktu selesai (contoh: 11:00)',
                    suffixIcon: Icons.access_time,
                    onTap: _pickEndTime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih waktu selesai meeting';
                      }
                      // Validate time logic consistent with edit_lembur_page
                      final startMinutes =
                          _startTime.hour * 60 + _startTime.minute;
                      final endMinutes = _endTime.hour * 60 + _endTime.minute;
                      if (endMinutes <= startMinutes) {
                        return 'Waktu selesai harus setelah waktu mulai';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reminder Section
              _buildReminderSection(theme),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'SIMPAN MEETING',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJenisMeetingCard(dynamic theme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primarySwatch,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.video_call,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Jenis Meeting',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _meetingType = 'Offline';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _meetingType == 'Offline'
                              ? theme.primarySwatch.shade50
                              : Colors.grey[100],
                      border: Border.all(
                        color:
                            _meetingType == 'Offline'
                                ? theme.primarySwatch
                                : Colors.grey[300]!,
                        width: _meetingType == 'Offline' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color:
                              _meetingType == 'Offline'
                                  ? theme.primarySwatch
                                  : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color:
                                _meetingType == 'Offline'
                                    ? theme.primarySwatch
                                    : Colors.grey[700],
                            fontWeight:
                                _meetingType == 'Offline'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _meetingType = 'Online';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _meetingType == 'Online'
                              ? theme.primarySwatch.shade50
                              : Colors.grey[100],
                      border: Border.all(
                        color:
                            _meetingType == 'Online'
                                ? theme.primarySwatch
                                : Colors.grey[300]!,
                        width: _meetingType == 'Online' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color:
                              _meetingType == 'Online'
                                  ? theme.primarySwatch
                                  : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Online',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color:
                                _meetingType == 'Online'
                                    ? theme.primarySwatch
                                    : Colors.grey[700],
                            fontWeight:
                                _meetingType == 'Online'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
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

  Widget _buildLocationCard(dynamic theme) {
    return AppFormCard(
      title: _meetingType == 'Online' ? 'Link Meeting' : 'Lokasi Meeting',
      titleIcon: _meetingType == 'Online' ? Icons.link : Icons.meeting_room,
      fields: [
        FormFieldConfig(
          label: _meetingType == 'Online' ? 'Link Meeting' : 'Ruangan',
          icon: _meetingType == 'Online' ? Icons.link : Icons.meeting_room,
          type: FormFieldType.textRequired,
          isRequired: true,
          hintText:
              _meetingType == 'Online'
                  ? 'Masukkan link meeting (Zoom, Teams, dll)'
                  : 'Masukkan nama ruangan',
          controller:
              _meetingType == 'Online' ? _linkController : _roomController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _meetingType == 'Online'
                  ? 'Link meeting tidak boleh kosong'
                  : 'Nama ruangan tidak boleh kosong';
            }
            if (_meetingType == 'Online' && !_isValidUrl(value)) {
              return 'Format link tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Widget _buildReminderSection(dynamic theme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primarySwatch,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pengingat Meeting',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enable reminder switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.alarm, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Aktifkan Pengingat',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _enableReminder,
                      onChanged: (value) {
                        setState(() {
                          _enableReminder = value;
                          if (!value) {
                            _reminderDateTime = null;
                          }
                        });
                      },
                      activeColor: theme.primarySwatch,
                    ),
                  ],
                ),

                if (_enableReminder) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Reminder datetime picker
                  GestureDetector(
                    onTap: _selectReminderDateTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _reminderDateTime != null
                                ? DateFormat(
                                  'dd-MM-yyyy, HH:mm',
                                ).format(_reminderDateTime!)
                                : 'Pilih waktu pengingat',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color:
                                  _reminderDateTime != null
                                      ? Colors.grey[900]
                                      : Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Anda akan menerima notifikasi pada waktu yang dipilih',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDate,
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            _reminderDateTime != null
                ? TimeOfDay.fromDateTime(_reminderDateTime!)
                : TimeOfDay.now(),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Check if selected time is not in the past
        if (selectedDateTime.isAfter(DateTime.now())) {
          setState(() {
            _reminderDateTime = selectedDateTime;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pilih tanggal dan waktu yang akan datang'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  void _saveMeeting() async {
    if (_formKey.currentState!.validate()) {
      // Validate time logic - same as edit_lembur_page
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;

      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Waktu selesai harus setelah waktu mulai!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      try {
        // Schedule notifications if enabled
        if (_enableReminder && _reminderDateTime != null) {
          try {
            // Check and request permissions first
            final hasPermissions =
                await NotificationService.requestPermissionsWithDialog(context);

            if (hasPermissions) {
              // Schedule meeting reminder notification
              await NotificationService.scheduleTaskReminder(
                id: _titleController.text.hashCode,
                title: 'Meeting Reminder',
                body: 'Don\'t forget: ${_titleController.text}',
                scheduledDate: _reminderDateTime!,
              );
            } else {
              // Show message if permissions denied
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Notifikasi dinonaktifkan - pengingat tidak akan bekerja',
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          } catch (e) {
            print('Failed to schedule notification: $e');
          }
        }

        // Create new meeting data using consistent time format
        final newMeeting = MeetingData(
          title: _titleController.text,
          room:
              _meetingType == 'Online'
                  ? 'Online - ${_linkController.text}'
                  : _roomController.text,
          date: _selectedDate,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          hasReminder: _enableReminder,
          reminderDateTime: _reminderDateTime,
        );

        // Tambah notifikasi in-app
        ref
            .read(notificationProvider.notifier)
            .addMeetingNotification(
              judulMeeting: _titleController.text,
              tanggal: DateFormat('dd-MM-yyyy').format(_selectedDate),
              waktuMulai: _formatTime(_startTime),
              waktuSelesai: _formatTime(_endTime),
              tempat:
                  _meetingType == 'Online'
                      ? 'Online - ${_linkController.text}'
                      : _roomController.text,
              jenisMeeting: _meetingType,
            );

        // Kirim notifikasi lokal setelah 2 detik
        await NotificationService.scheduleTaskReminder(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Meeting Berhasil Dijadwalkan',
          body:
              'Meeting "${_titleController.text}" telah dijadwalkan pada ${DateFormat('dd-MM-yyyy').format(_selectedDate)} ${_formatTime(_startTime)}-${_formatTime(_endTime)}.',
          scheduledDate: DateTime.now().add(const Duration(seconds: 2)),
        );

        if (mounted) {
          // Show success feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _enableReminder && _reminderDateTime != null
                    ? 'Meeting berhasil ditambahkan dengan pengingat!'
                    : 'Meeting berhasil ditambahkan dan notifikasi akan segera muncul!',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate back with new meeting data
          Navigator.of(context).pop(newMeeting);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan meeting: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}
