import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_lembur_page.dart';

class EditLemburPage extends ConsumerStatefulWidget {
  const EditLemburPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<EditLemburPage> createState() => _EditLemburPageState();
}

class _EditLemburPageState extends ConsumerState<EditLemburPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jenisCtrl;
  late final TextEditingController _tanggalCtrl;
  late final TextEditingController _jamMulaiCtrl;
  late final TextEditingController _jamSelesaiCtrl;
  late final TextEditingController _kegiatanCtrl;

  DateTime? _selectedDate;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  PlatformFile? _selectedFile;

  final List<String> _jenisLemburOptions = [
    'Lembur Komisi',
    'Lembur Anggaran',
    'Lembur Rapat',
    'Lembur Proyek',
    'Lembur Lainnya',
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStartTime
              ? (_jamMulai ?? TimeOfDay.now())
              : (_jamSelesai ?? TimeOfDay.now()),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _jamMulai = picked;
          _jamMulaiCtrl.text = _formatTime(picked);
        } else {
          _jamSelesai = picked;
          _jamSelesaiCtrl.text = _formatTime(picked);
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      } else {
        final hour = int.tryParse(timeString);
        if (hour != null && hour >= 0 && hour <= 23) {
          return TimeOfDay(hour: hour, minute: 0);
        }
      }
    } catch (e) {
      // Error parsing time, will return null
    }
    return null;
  }

  String _calculateDuration() {
    if (_jamMulai == null || _jamSelesai == null) {
      return '';
    }

    final startMinutes = _jamMulai!.hour * 60 + _jamMulai!.minute;
    final endMinutes = _jamSelesai!.hour * 60 + _jamSelesai!.minute;

    int durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60;
    }

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (minutes == 0) {
      return '$hours jam';
    } else {
      return '$hours jam $minutes menit';
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _jenisCtrl = TextEditingController(text: widget.data['type'] ?? '');

    final date = widget.data['date'];
    if (date is DateTime) {
      _selectedDate = date;
      _tanggalCtrl = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(date),
      );
    } else {
      final dateStr = date?.toString() ?? '';
      _tanggalCtrl = TextEditingController(text: dateStr);
    }

    final jamMulaiStr =
        widget.data['jamMulai'] ?? widget.data['mulai'] ?? '19:00';
    final jamSelesaiStr =
        widget.data['jamSelesai'] ?? widget.data['selesai'] ?? '22:00';

    _jamMulai = _parseTime(jamMulaiStr);
    _jamSelesai = _parseTime(jamSelesaiStr);

    _jamMulaiCtrl = TextEditingController(
      text: _jamMulai != null ? _formatTime(_jamMulai!) : jamMulaiStr,
    );
    _jamSelesaiCtrl = TextEditingController(
      text: _jamSelesai != null ? _formatTime(_jamSelesai!) : jamSelesaiStr,
    );

    _kegiatanCtrl = TextEditingController(text: widget.data['reason'] ?? '');

    final fileName = widget.data['fileName'];
    if (fileName != null) {}
  }

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _tanggalCtrl.dispose();
    _jamMulaiCtrl.dispose();
    _jamSelesaiCtrl.dispose();
    _kegiatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final String status = (widget.data['status'] ?? 'Menunggu') as String;
    final bool isLocked = status == 'Disetujui';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ubah Pengajuan Lembur',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Status chip on top
                if (status != 'Menunggu Persetujuan')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip(
                          'Status: $status',
                          _statusColor(status),
                          theme,
                        ),
                      ],
                    ),
                  ),

                if (isLocked)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pengajuan ini sudah disetujui dan tidak dapat diedit.',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                AppFormCard(
                  title: 'Form Edit Lembur',
                  titleIcon: Icons.edit,
                  showSaveButton: false,
                  fields: [
                    FormFieldConfig(
                      label: 'Jenis Lembur',
                      icon: Icons.category,
                      type: FormFieldType.dropdown,
                      isRequired: true,
                      options: _jenisLemburOptions,
                      value:
                          _jenisLemburOptions.contains(_jenisCtrl.text)
                              ? _jenisCtrl.text
                              : null,
                      onChanged:
                          isLocked
                              ? null
                              : (value) =>
                                  setState(() => _jenisCtrl.text = value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis lembur';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Tanggal Lembur',
                      icon: Icons.calendar_today,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _tanggalCtrl,
                      hintText: 'Pilih tanggal lembur',
                      suffixIcon: Icons.calendar_today,
                      onTap: isLocked ? null : _pickDate,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _selectedDate == null) {
                          return 'Pilih tanggal lembur';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Jam Mulai',
                      icon: Icons.schedule,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _jamMulaiCtrl,
                      hintText: 'Pilih jam mulai (contoh: 19:00)',
                      suffixIcon: Icons.access_time,
                      onTap: isLocked ? null : () => _pickTime(true),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _jamMulai == null) {
                          return 'Pilih jam mulai lembur';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Jam Selesai',
                      icon: Icons.schedule_outlined,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _jamSelesaiCtrl,
                      hintText: 'Pilih jam selesai (contoh: 22:00)',
                      suffixIcon: Icons.access_time,
                      onTap: isLocked ? null : () => _pickTime(false),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _jamSelesai == null) {
                          return 'Pilih jam selesai lembur';
                        }
                        if (_jamMulai != null && _jamSelesai != null) {
                          final startMinutes =
                              _jamMulai!.hour * 60 + _jamMulai!.minute;
                          final endMinutes =
                              _jamSelesai!.hour * 60 + _jamSelesai!.minute;
                          if (endMinutes <= startMinutes &&
                              endMinutes != startMinutes) {
                            return 'Jam selesai harus setelah jam mulai';
                          }
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Kegiatan Lembur',
                      icon: Icons.description,
                      type: FormFieldType.multiline,
                      isRequired: true,
                      controller: _kegiatanCtrl,
                      hintText: 'Jelaskan kegiatan lembur',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan kegiatan lembur';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // File Upload Section
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primarySwatch.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.cloud_upload,
                              color: theme.primarySwatch,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Lampiran (Opsional)',
                            style: theme.typographyBold.bodyMedium.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: isLocked ? null : _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isLocked
                                      ? Colors.grey[300]!
                                      : Colors.grey[300]!,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isLocked ? Colors.grey[50] : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color:
                                    isLocked
                                        ? Colors.grey[400]
                                        : theme.primarySwatch,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile?.name ??
                                          widget.data['fileName'] ??
                                          'Upload file pendukung',
                                      style: theme.typographyRegular.bodyMedium
                                          .copyWith(
                                            color:
                                                (_selectedFile != null ||
                                                        widget.data['fileName'] !=
                                                            null)
                                                    ? (isLocked
                                                        ? Colors.grey[600]
                                                        : Colors.grey[800])
                                                    : (isLocked
                                                        ? Colors.grey[400]
                                                        : Colors.grey[600]),
                                            fontWeight:
                                                (_selectedFile != null ||
                                                        widget.data['fileName'] !=
                                                            null)
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                    ),
                                    if (_selectedFile == null &&
                                        widget.data['fileName'] == null)
                                      Text(
                                        'Format: PDF, JPG, PNG (Max 5MB)',
                                        style: theme.typographyRegular.bodySmall
                                            .copyWith(
                                              color:
                                                  isLocked
                                                      ? Colors.grey[400]
                                                      : Colors.grey[500],
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_selectedFile != null && !isLocked)
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primarySwatch,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed:
                        isLocked
                            ? null
                            : () {
                              if (_formKey.currentState!.validate() &&
                                  _selectedDate != null &&
                                  _jamMulai != null &&
                                  _jamSelesai != null) {
                                // Check if ID is available
                                final lemburId = widget.data['id'];
                                if (lemburId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: ID lembur tidak ditemukan',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Get current status and preserve it
                                final currentStatus =
                                    widget.data['status'] ??
                                    'Menunggu Persetujuan';
                                final statusColor = _statusColor(currentStatus);

                                final updatedData = {
                                  'id': lemburId,
                                  'type': _jenisCtrl.text.trim(),
                                  'date': _selectedDate!,
                                  'jamMulai': _formatTime(_jamMulai!),
                                  'jamSelesai': _formatTime(_jamSelesai!),
                                  'duration': _calculateDuration(),
                                  'reason': _kegiatanCtrl.text.trim(),
                                  'status': currentStatus,
                                  'statusColor': statusColor,
                                  'fileName':
                                      _selectedFile?.name ??
                                      widget.data['fileName'],
                                };

                                try {
                                  // Update lembur data
                                  ref
                                      .read(lemburProvider.notifier)
                                      .update(lemburId, updatedData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Data lembur berhasil diperbarui',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  // Error updating data
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal memperbarui data lembur: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else if (_selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pilih tanggal lembur terlebih dahulu',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (_jamMulai == null ||
                                  _jamSelesai == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pilih jam mulai dan selesai lembur',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                    child: Text(
                      'SIMPAN PERUBAHAN',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Status helpers
  Color _statusColor(String s) {
    switch (s) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _statusChip(String label, Color color, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
