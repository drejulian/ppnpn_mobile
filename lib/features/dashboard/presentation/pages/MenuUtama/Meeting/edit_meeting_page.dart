import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'meeting_data.dart';

class EditMeetingPage extends ConsumerStatefulWidget {
  final MeetingData meetingData;

  const EditMeetingPage({
    super.key,
    required this.meetingData,
  });

  @override
  ConsumerState<EditMeetingPage> createState() => _EditMeetingPageState();
}

class _EditMeetingPageState extends ConsumerState<EditMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _roomController;
  late TextEditingController _linkController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  
  // Selected values
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;
  late String _meetingType; // 'Online' atau 'Offline'

  final List<Color> _colorOptions = [
    Colors.teal,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.meetingData.title);
    _descriptionController = TextEditingController(text: 'Meeting discussion and planning session');
    
    // Initialize date and time
    _selectedDate = widget.meetingData.date;
    _selectedColor = widget.meetingData.color;
    
    // Determine meeting type and initialize controllers accordingly
    if (widget.meetingData.room.startsWith('Online - ')) {
      _meetingType = 'Online';
      _linkController = TextEditingController(
        text: widget.meetingData.room.replaceFirst('Online - ', '')
      );
      _roomController = TextEditingController();
    } else {
      _meetingType = 'Offline';
      _roomController = TextEditingController(text: widget.meetingData.room);
      _linkController = TextEditingController();
    }
    
    // Parse time from string
    final startTimeParts = widget.meetingData.startTime.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );
    
    final endTimeParts = widget.meetingData.endTime.split(':');
    _endTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );
    
    // Initialize text controllers for date and time
    _dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(_selectedDate)
    );
    _startTimeController = TextEditingController(
      text: widget.meetingData.startTime
    );
    _endTimeController = TextEditingController(
      text: widget.meetingData.endTime
    );
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
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
        _startTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
        _endTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Meeting',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
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
                    label: 'Deskripsi',
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
                    label: 'Tanggal',
                    icon: Icons.calendar_today,
                    type: FormFieldType.datePicker,
                    hintText: 'Pilih tanggal meeting',
                    controller: _dateController,
                    onTap: _pickDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Waktu Mulai',
                    icon: Icons.access_time,
                    type: FormFieldType.datePicker,
                    hintText: 'Pilih waktu mulai',
                    controller: _startTimeController,
                    onTap: _pickStartTime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu mulai tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Waktu Selesai',
                    icon: Icons.access_time_filled,
                    type: FormFieldType.datePicker,
                    hintText: 'Pilih waktu selesai',
                    controller: _endTimeController,
                    onTap: _pickEndTime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu selesai tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Color Selection Card
              _buildColorSelectionCard(theme),

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
                    'SIMPAN PERUBAHAN',
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
                child: const Icon(Icons.video_call, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Jenis Meeting',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _meetingType == 'Offline' 
                          ? theme.primarySwatch.shade50 
                          : Colors.grey[100],
                      border: Border.all(
                        color: _meetingType == 'Offline' 
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
                          color: _meetingType == 'Offline' 
                              ? theme.primarySwatch 
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color: _meetingType == 'Offline' 
                                ? theme.primarySwatch 
                                : Colors.grey[700],
                            fontWeight: _meetingType == 'Offline' 
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _meetingType == 'Online' 
                          ? theme.primarySwatch.shade50 
                          : Colors.grey[100],
                      border: Border.all(
                        color: _meetingType == 'Online' 
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
                          color: _meetingType == 'Online' 
                              ? theme.primarySwatch 
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Online',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color: _meetingType == 'Online' 
                                ? theme.primarySwatch 
                                : Colors.grey[700],
                            fontWeight: _meetingType == 'Online' 
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
          hintText: _meetingType == 'Online' 
              ? 'Masukkan link meeting (Zoom, Teams, dll)' 
              : 'Masukkan nama ruangan',
          controller: _meetingType == 'Online' ? _linkController : _roomController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _meetingType == 'Online' 
                  ? 'Link meeting tidak boleh kosong' 
                  : 'Ruangan tidak boleh kosong';
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

  Widget _buildColorSelectionCard(dynamic theme) {
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
                child: const Icon(Icons.palette, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Warna Meeting',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Pilih warna untuk membedakan meeting',
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((color) {
              final isSelected = _selectedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Colors.black,
                            width: 3,
                          )
                        : Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _saveMeeting() {
    if (_formKey.currentState!.validate()) {
      // Validate time logic
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;
      
      if (startMinutes >= endMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Waktu selesai harus lebih dari waktu mulai!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Create updated meeting data
      final updatedMeeting = MeetingData(
        title: _titleController.text,
        room: _meetingType == 'Online' 
            ? 'Online - ${_linkController.text}' 
            : _roomController.text,
        date: _selectedDate,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        color: _selectedColor,
      );

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meeting berhasil diperbarui!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back with updated meeting data
      Navigator.of(context).pop(updatedMeeting);
    }
  }
}
