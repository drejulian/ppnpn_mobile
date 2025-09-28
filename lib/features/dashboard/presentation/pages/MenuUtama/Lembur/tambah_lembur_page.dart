import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/lembur_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/lembur_provider.dart';

class TambahLemburPage extends ConsumerStatefulWidget {
  const TambahLemburPage({super.key});

  @override
  ConsumerState<TambahLemburPage> createState() => _TambahLemburPageState();
}

class _TambahLemburPageState extends ConsumerState<TambahLemburPage> {
  final _formKey = GlobalKey<FormState>();
  final _jenisCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _jamMulaiCtrl = TextEditingController();
  final _jamSelesaiCtrl = TextEditingController();
  final _kegiatanCtrl = TextEditingController();
  
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
      initialDate: now,
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
      initialTime: isStartTime 
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tambah Pengajuan Lembur',
          style: theme.typographyBold.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppFormCard(
                  title: 'Form Pengajuan Lembur',
                  titleIcon: Icons.add_circle_outline,
                  showSaveButton: false,
                  fields: [
                    FormFieldConfig(
                      label: 'Jenis Lembur',
                      icon: Icons.category,
                      type: FormFieldType.dropdown,
                      isRequired: true,
                      options: _jenisLemburOptions,
                      value: _jenisCtrl.text.isNotEmpty && _jenisLemburOptions.contains(_jenisCtrl.text) ? _jenisCtrl.text : null,
                      onChanged: (value) => setState(() => _jenisCtrl.text = value ?? ''),
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
                      onTap: _pickDate,
                      validator: (value) {
                        if (value == null || value.isEmpty || _selectedDate == null) {
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
                      onTap: () => _pickTime(true),
                      validator: (value) {
                        if (value == null || value.isEmpty || _jamMulai == null) {
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
                      onTap: () => _pickTime(false),
                      validator: (value) {
                        if (value == null || value.isEmpty || _jamSelesai == null) {
                          return 'Pilih jam selesai lembur';
                        }
                        if (_jamMulai != null && _jamSelesai != null) {
                          final startMinutes = _jamMulai!.hour * 60 + _jamMulai!.minute;
                          final endMinutes = _jamSelesai!.hour * 60 + _jamSelesai!.minute;
                          if (endMinutes <= startMinutes && endMinutes != startMinutes) {
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
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: theme.primarySwatch,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile?.name ?? 'Upload file pendukung',
                                      style: theme.typographyRegular.bodyMedium.copyWith(
                                        color: _selectedFile != null
                                            ? Colors.grey[800]
                                            : Colors.grey[600],
                                        fontWeight: _selectedFile != null
                                            ? FontWeight.w600 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (_selectedFile == null)
                                      Text(
                                        'Format: PDF, JPG, PNG (Max 5MB)',
                                        style: theme.typographyRegular.bodySmall.copyWith(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _selectedDate != null && _jamMulai != null && _jamSelesai != null) {
                        try {
                          final newLembur = LemburModel(
                            type: _jenisCtrl.text.trim(),
                            date: _selectedDate!,
                            duration: _calculateDuration(),
                            startTime: _formatTime(_jamMulai!),
                            endTime: _formatTime(_jamSelesai!),
                            reason: _kegiatanCtrl.text.trim(),
                            status: 'menunggu_persetujuan', // Use database status format
                            userId: 1, // You might need to get this from user session
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            fileName: _selectedFile?.name,
                          );

                          await ref.read(lemburProvider.notifier).addLembur(newLembur);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengajuan lembur berhasil dikirim'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          context.pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengirim pengajuan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih tanggal lembur terlebih dahulu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (_jamMulai == null || _jamSelesai == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih jam mulai dan selesai lembur'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'SUBMIT PENGAJUAN',
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
}