import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'daftar_cuti_page.dart';

class EditCutiPage extends ConsumerStatefulWidget {
  const EditCutiPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<EditCutiPage> createState() => _EditCutiPageState();
}

class _EditCutiPageState extends ConsumerState<EditCutiPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jenisCtrl;
  late final TextEditingController _awalCtrl;
  late final TextEditingController _akhirCtrl;
  late final TextEditingController _alasanCtrl;

  DateTime? _awalDate;
  DateTime? _akhirDate;
  PlatformFile? _selectedFile;

  final List<String> _jenisOptions = [
    'Cuti Tahunan',
    'Cuti Sakit',
    'Cuti Melahirkan',
    'Cuti Lainnya',
  ];

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

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? (_awalDate ?? now) : (_akhirDate ?? _awalDate ?? now),
      firstDate: DateTime(now.year - 1),
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

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Invalid date format
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    _jenisCtrl = TextEditingController(
      text: widget.data['type'] ?? widget.data['jenis'] ?? '',
    );

    final dateData = widget.data['date'];
    if (dateData != null && dateData is DateTime) {
      _awalDate = dateData;
      _awalCtrl = TextEditingController(text: _formatDate(dateData));
    } else {
      final tanggalAwal = widget.data['tanggal_awal'];
      if (tanggalAwal != null && tanggalAwal.toString().isNotEmpty) {
        _awalDate = _parseDate(tanggalAwal.toString());
        _awalCtrl = TextEditingController(text: tanggalAwal.toString());
      } else {
        _awalCtrl = TextEditingController();
      }
    }

    final tanggalAkhir = widget.data['tanggal_akhir'];
    if (tanggalAkhir != null && tanggalAkhir.toString().isNotEmpty) {
      _akhirDate = _parseDate(tanggalAkhir.toString());
      _akhirCtrl = TextEditingController(text: tanggalAkhir.toString());
    } else {
      _akhirCtrl = TextEditingController();
    }

    _alasanCtrl = TextEditingController(
      text: widget.data['reason'] ?? widget.data['alasan'] ?? '',
    );

    final fileName = widget.data['fileName'];
    if (fileName != null) {}
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
    final String status = (widget.data['status'] ?? 'Menunggu') as String;
    final bool isLocked = status == 'Disetujui';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Ubah Pengajuan Cuti',
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
                          _getStatusColor(status),
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
                  title: 'Form Edit Cuti',
                  titleIcon: Icons.edit,
                  showSaveButton: false,
                  fields: [
                    FormFieldConfig(
                      label: 'Jenis Cuti',
                      icon: Icons.category,
                      type: FormFieldType.dropdown,
                      isRequired: true,
                      options: _jenisOptions,
                      value:
                          _jenisOptions.contains(_jenisCtrl.text)
                              ? _jenisCtrl.text
                              : null,
                      onChanged:
                          isLocked
                              ? null
                              : (value) =>
                                  setState(() => _jenisCtrl.text = value ?? ''),
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
                      onTap: isLocked ? null : () => _pickDate(true),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _awalDate == null) {
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
                      onTap: isLocked ? null : () => _pickDate(false),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _akhirDate == null) {
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
                                  _awalDate != null &&
                                  _akhirDate != null) {
                                _submitForm();
                              } else if (_awalDate == null ||
                                  _akhirDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pilih tanggal mulai dan selesai cuti terlebih dahulu',
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

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _awalDate != null &&
        _akhirDate != null) {
      final cutiId = widget.data['id'];
      if (cutiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: ID cuti tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final currentStatus = widget.data['status'] ?? 'Menunggu Persetujuan';
      final updatedCuti = {
        'id': cutiId,
        'type': _jenisCtrl.text,
        'date': _awalDate!,
        'duration': _formatDuration(),
        'reason': _alasanCtrl.text,
        'status': currentStatus,
        'statusColor': _getStatusColor(currentStatus),
        'fileName': _selectedFile?.name ?? widget.data['fileName'],

        'jenis': _jenisCtrl.text,
        'tanggal_awal': _awalCtrl.text,
        'tanggal_akhir': _akhirCtrl.text,
        'alasan': _alasanCtrl.text,
      };

      try {
        ref.read(cutiProvider.notifier).update(cutiId, updatedCuti);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data cuti berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data cuti: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
