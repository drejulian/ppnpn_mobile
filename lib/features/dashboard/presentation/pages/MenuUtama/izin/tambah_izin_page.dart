import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/features/dashboard/providers/notification_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'daftar_izin_page.dart';

class TambahIzinPage extends ConsumerStatefulWidget {
  const TambahIzinPage({super.key});

  @override
  ConsumerState<TambahIzinPage> createState() => _TambahIzinPageState();
}

class _TambahIzinPageState extends ConsumerState<TambahIzinPage> {
  final _formKey = GlobalKey<FormState>();
  final _jenisCtrl = TextEditingController();
  final _awalCtrl = TextEditingController();
  final _akhirCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  DateTime? _awalDate;
  DateTime? _akhirDate;
  PlatformFile? _selectedFile;

  final List<String> _jenisIzinOptions = [
    'Izin Sakit',
    'Izin Pribadi',
    'Izin Keluarga',
    'Izin Lainnya',
  ];

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? (_awalDate ?? now) : (_akhirDate ?? _awalDate ?? now),
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

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
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

  String _generateId() {
    final now = DateTime.now();
    return 'I-${now.millisecondsSinceEpoch % 10000}';
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

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _awalCtrl.dispose();
    _akhirCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ajukan Izin',
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
                AppFormCard(
                  title: 'Form Pengajuan Izin',
                  titleIcon: Icons.event_busy,
                  showSaveButton: false,
                  fields: [
                    FormFieldConfig(
                      label: 'Jenis Izin',
                      icon: Icons.category,
                      type: FormFieldType.dropdown,
                      isRequired: true,
                      options: _jenisIzinOptions,
                      value: _jenisCtrl.text.isEmpty ? null : _jenisCtrl.text,
                      onChanged:
                          (value) =>
                              setState(() => _jenisCtrl.text = value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis izin';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Tanggal Mulai Izin',
                      icon: Icons.calendar_today,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _awalCtrl,
                      hintText: 'Pilih tanggal mulai izin',
                      suffixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(true),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _awalDate == null) {
                          return 'Pilih tanggal mulai izin';
                        }
                        return null;
                      },
                    ),
                    FormFieldConfig(
                      label: 'Tanggal Selesai Izin',
                      icon: Icons.event_available,
                      type: FormFieldType.datePicker,
                      isRequired: true,
                      controller: _akhirCtrl,
                      hintText: 'Pilih tanggal selesai izin',
                      suffixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(false),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _akhirDate == null) {
                          return 'Pilih tanggal selesai izin';
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
                      label: 'Alasan Izin',
                      icon: Icons.description,
                      type: FormFieldType.multiline,
                      isRequired: true,
                      controller: _alasanCtrl,
                      hintText: 'Jelaskan alasan pengajuan izin',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan alasan izin';
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
                                      style: theme.typographyRegular.bodyMedium
                                          .copyWith(
                                            color:
                                                _selectedFile != null
                                                    ? Colors.grey[800]
                                                    : Colors.grey[600],
                                            fontWeight:
                                                _selectedFile != null
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                    ),
                                    if (_selectedFile == null)
                                      Text(
                                        'Format: PDF, JPG, PNG (Max 5MB)',
                                        style: theme.typographyRegular.bodySmall
                                            .copyWith(color: Colors.grey[500]),
                                      ),
                                  ],
                                ),
                              ),
                              if (_selectedFile != null)
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _awalDate != null &&
                          _akhirDate != null) {
                        try {
                          final newIzin = {
                            'id': _generateId(),
                            'type': _jenisCtrl.text,
                            'date': _awalDate!,
                            'duration': _formatDuration(),
                            'reason': _alasanCtrl.text,
                            'status': 'Menunggu Persetujuan',
                            'statusColor': _getStatusColor(
                              'Menunggu Persetujuan',
                            ),
                            'fileName': _selectedFile?.name,
                          };

                          // Tambah izin ke provider
                          ref.read(izinProvider.notifier).add(newIzin);

                          // Tambah notifikasi in-app
                          ref
                              .read(notificationProvider.notifier)
                              .addIzinNotification(
                                jenisIzin: _jenisCtrl.text,
                                tanggalAwal: _formatDate(_awalDate!),
                                tanggalAkhir: _formatDate(_akhirDate!),
                                durasi: _formatDuration(),
                                alasan: _alasanCtrl.text,
                              );

                          // Kirim notifikasi lokal setelah 2 detik
                          await NotificationService.scheduleTaskReminder(
                            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            title: 'Pengajuan Izin Berhasil',
                            body:
                                'Pengajuan ${_jenisCtrl.text} Anda telah dikirim dan sedang menunggu persetujuan.',
                            scheduledDate: DateTime.now().add(
                              const Duration(seconds: 2),
                            ),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pengajuan izin berhasil dikirim dan notifikasi akan segera muncul',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            context.pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menambahkan izin: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else if (_awalDate == null || _akhirDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pilih tanggal mulai dan selesai izin terlebih dahulu',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'AJUKAN IZIN',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontSize: 18.0,
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
