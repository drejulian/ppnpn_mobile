import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/features/dashboard/providers/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'daftar_cuti_page.dart';

class TambahCutiPage extends ConsumerStatefulWidget {
  const TambahCutiPage({super.key});

  @override
  ConsumerState<TambahCutiPage> createState() => _TambahCutiPageState();
}

class _TambahCutiPageState extends ConsumerState<TambahCutiPage> {
  final _formKey = GlobalKey<FormState>();
  final _jenisCtrl = TextEditingController();
  final _awalCtrl = TextEditingController();
  final _akhirCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  DateTime? _awalDate;
  DateTime? _akhirDate;
  PlatformFile? _selectedFile;

  final List<String> _jenisOptions = [
    'Cuti Tahunan',
    'Cuti Sakit',
    'Cuti Melahirkan',
    'Cuti Lainnya',
  ];

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
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

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_awalDate ?? now)
          : (_akhirDate ?? _awalDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _awalDate = picked;
          _awalCtrl.text = _formatDate(picked);
          if (_akhirDate != null && _akhirDate!.isBefore(picked)) {
            _akhirDate = null;
            _akhirCtrl.clear();
          }
        } else {
          _akhirDate = picked;
          _akhirCtrl.text = _formatDate(picked);
        }
      });
    }
  }

  String _generateId() {
    final now = DateTime.now();
    return 'C-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Menunggu Persetujuan':
      default:
        return Colors.orange;
    }
  }

  String _formatDuration() {
    if (_awalDate == null || _akhirDate == null) {
      return '';
    }
    
    final difference = _akhirDate!.difference(_awalDate!).inDays + 1;
    final awalFormatted = DateFormat('dd MMM').format(_awalDate!);
    final akhirFormatted = DateFormat('dd MMM').format(_akhirDate!);
    
    return '$difference hari ($awalFormatted - $akhirFormatted)';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _awalDate != null && _akhirDate != null) {
      final newCuti = {
      
        'id': _generateId(),
        'type': _jenisCtrl.text,
        'date': _awalDate!,
        'duration': _formatDuration(),
        'reason': _alasanCtrl.text,
        'status': 'Menunggu Persetujuan',
        'statusColor': _getStatusColor('Menunggu Persetujuan'),
        'fileName': _selectedFile?.name,
        

        'jenis': _jenisCtrl.text,
        'tanggal_awal': _awalCtrl.text,
        'tanggal_akhir': _akhirCtrl.text,
        'alasan': _alasanCtrl.text,
      };

      try {
        // Tambahkan ke provider cuti
        ref.read(cutiProvider.notifier).add(newCuti);

        // Tambahkan notifikasi ke dalam app
        ref.read(notificationProvider.notifier).addCutiNotification(
          jenisCtri: _jenisCtrl.text,
          tanggalAwal: _awalCtrl.text,
          tanggalAkhir: _akhirCtrl.text,
          alasan: _alasanCtrl.text,
        );

        // Kirim notifikasi lokal setelah 2 detik
        await NotificationService.scheduleTaskReminder(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Pengajuan Cuti Berhasil',
          body: 'Pengajuan ${_jenisCtrl.text} Anda telah dikirim dan sedang menunggu persetujuan.',
          scheduledDate: DateTime.now().add(const Duration(seconds: 2)),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan cuti berhasil ditambahkan dan notifikasi akan segera muncul'),
              backgroundColor: Colors.green,
            ),
          );

          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan cuti: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Ajukan Cuti',
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
                  title: 'Form Pengajuan Cuti',
                  titleIcon: Icons.event_available,
                  showSaveButton: false,
                  fields: [
                    FormFieldConfig(
                      label: 'Jenis Cuti',
                      icon: Icons.category,
                      type: FormFieldType.dropdown,
                      isRequired: true,
                      options: _jenisOptions,
                      value: _jenisCtrl.text.isEmpty ? null : _jenisCtrl.text,
                      onChanged: (value) => setState(() => _jenisCtrl.text = value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis cuti';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Tanggal Mulai',
                      icon: Icons.calendar_today,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _awalCtrl,
                      hintText: 'Pilih tanggal mulai cuti',
                      suffixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(true),
                      validator: (value) {
                        if (value == null || value.isEmpty || _awalDate == null) {
                          return 'Pilih tanggal mulai cuti';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Tanggal Selesai',
                      icon: Icons.event_available,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _akhirCtrl,
                      hintText: 'Pilih tanggal selesai cuti',
                      suffixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(false),
                      validator: (value) {
                        if (value == null || value.isEmpty || _akhirDate == null) {
                          return 'Pilih tanggal selesai cuti';
                        }
                        if (_awalDate != null && _akhirDate != null) {
                          if (_akhirDate!.isBefore(_awalDate!)) {
                            return 'Tanggal selesai harus setelah tanggal mulai';
                          }
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Alasan Cuti',
                      icon: Icons.description,
                      type: FormFieldType.multiline,
                      isRequired: true,
                      controller: _alasanCtrl,
                      hintText: 'Jelaskan alasan pengajuan cuti',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan alasan cuti';
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
                                      _selectedFile != null 
                                          ? _selectedFile!.name 
                                          : 'Upload file pendukung',
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
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _awalDate != null && _akhirDate != null) {
                        _submitForm();
                      } else if (_awalDate == null || _akhirDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih tanggal mulai dan selesai cuti terlebih dahulu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'AJUKAN CUTI',
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

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _awalCtrl.dispose();
    _akhirCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }
}