import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'daftar_reimburse_page.dart';

class EditReimbursePage extends ConsumerStatefulWidget {
  const EditReimbursePage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<EditReimbursePage> createState() => _EditReimbursePageState();
}

class _EditReimbursePageState extends ConsumerState<EditReimbursePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kategoriCtrl;
  late final TextEditingController _tanggalCtrl;
  late final TextEditingController _jumlahCtrl;
  late final TextEditingController _deskripsiCtrl;
  
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  
  final List<String> _kategoriOptions = [
    'Transport',
    'Makan', 
    'Hotel',
    'Komunikasi',
    'Lainnya',
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
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
    
    // Map kategori dari data ke opsi yang tersedia
    String initialCategory = widget.data['category'] ?? '';
    // Jika kategori tidak ada dalam opsi, gunakan kategori pertama sebagai default
    if (!_kategoriOptions.contains(initialCategory) && initialCategory.isNotEmpty) {
      // Coba mapping beberapa variasi umum
      switch (initialCategory.toLowerCase()) {
        case 'transportasi':
          initialCategory = 'Transport';
          break;
        case 'akomodasi':
          initialCategory = 'Hotel';
          break;
        default:
          initialCategory = ''; // Biarkan kosong agar user memilih
      }
    }
    _kategoriCtrl = TextEditingController(text: initialCategory);
    
    // Parse date
    if (widget.data['date'] != null) {
      if (widget.data['date'] is DateTime) {
        _selectedDate = widget.data['date'] as DateTime;
        _tanggalCtrl = TextEditingController(
          text: DateFormat('dd-MM-yyyy').format(_selectedDate!),
        );
      } else {
        _tanggalCtrl = TextEditingController(text: widget.data['date'].toString());
      }
    } else {
      _tanggalCtrl = TextEditingController();
    }
    
    // Parse amount - handle both int and double
    final amount = widget.data['amount'];
    if (amount != null) {
      if (amount is int) {
        _jumlahCtrl = TextEditingController(text: amount.toString());
      } else if (amount is double) {
        _jumlahCtrl = TextEditingController(text: amount.toStringAsFixed(0));
      } else {
        _jumlahCtrl = TextEditingController(text: amount.toString());
      }
    } else {
      _jumlahCtrl = TextEditingController();
    }
    
    _deskripsiCtrl = TextEditingController(text: widget.data['description'] ?? '');
    
    // Handle file
    if (widget.data['fileName'] != null) {
      _selectedFile = PlatformFile(
        name: widget.data['fileName'],
        size: 0,
      );
    }
  }

  @override
  void dispose() {
    _kategoriCtrl.dispose();
    _tanggalCtrl.dispose();
    _jumlahCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final String status = (widget.data['status'] ?? 'Menunggu Persetujuan') as String;
    final bool isLocked = status == 'Disetujui';
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Ubah Pengajuan Reimburse',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      _statusChip('Status: $status', _statusColor(status), theme),
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
                title: 'Form Edit Reimburse',
                titleIcon: Icons.receipt_long,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Kategori',
                    icon: Icons.category,
                    type: FormFieldType.dropdown,
                    isRequired: true,
                    options: _kategoriOptions,
                    value: _kategoriOptions.contains(_kategoriCtrl.text) ? _kategoriCtrl.text : null,
                    onChanged: isLocked ? null : (value) => setState(() => _kategoriCtrl.text = value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih kategori reimburse';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Tanggal Pengeluaran',
                    icon: Icons.calendar_today,
                    type: FormFieldType.datePicker,
                    isRequired: true,
                    controller: _tanggalCtrl,
                    hintText: 'Pilih tanggal pengeluaran',
                    suffixIcon: Icons.calendar_today,
                    onTap: isLocked ? null : _pickDate,
                    validator: (value) {
                      if (value == null || value.isEmpty || _selectedDate == null) {
                        return 'Pilih tanggal pengeluaran';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Jumlah (Rp)',
                    icon: Icons.money,
                    type: FormFieldType.text,
                    isRequired: true,
                    controller: _jumlahCtrl,
                    hintText: 'Masukkan jumlah pengeluaran',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan jumlah pengeluaran';
                      }
                      final numValue = double.tryParse(value);
                      if (numValue == null || numValue <= 0) {
                        return 'Jumlah harus berupa angka positif';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Deskripsi',
                    icon: Icons.description,
                    type: FormFieldType.multiline,
                    isRequired: true,
                    controller: _deskripsiCtrl,
                    hintText: 'Jelaskan detail pengeluaran',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan deskripsi pengeluaran';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // File Upload Section (matching edit_izin_page style)
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
                            color: isLocked ? Colors.grey[300]! : Colors.grey[300]!,
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
                              color: isLocked ? Colors.grey[400] : theme.primarySwatch,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile?.name ?? widget.data['fileName'] ?? 'Upload file pendukung',
                                    style: theme.typographyRegular.bodyMedium.copyWith(
                                      color: (_selectedFile != null || widget.data['fileName'] != null)
                                          ? (isLocked ? Colors.grey[600] : Colors.grey[800])
                                          : (isLocked ? Colors.grey[400] : Colors.grey[600]),
                                      fontWeight: (_selectedFile != null || widget.data['fileName'] != null)
                                          ? FontWeight.w600 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (_selectedFile == null && widget.data['fileName'] == null)
                                    Text(
                                      'Format: PDF, JPG, PNG (Max 5MB)',
                                      style: theme.typographyRegular.bodySmall.copyWith(
                                        color: isLocked ? Colors.grey[400] : Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_selectedFile != null && !isLocked)
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
              const SizedBox(height: 16),
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
                            if (!_formKey.currentState!.validate() || _selectedDate == null) {
                              if (_selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pilih tanggal pengeluaran terlebih dahulu'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }
                            final updatedReimburse = {
                              'id': widget.data['id'], // Keep the original ID
                              'category': _kategoriCtrl.text,
                              'date': _selectedDate!,
                              'amount': double.parse(_jumlahCtrl.text).toInt(), // Convert to int to match data structure
                              'description': _deskripsiCtrl.text,
                              'status': 'Menunggu Persetujuan', // Reset status
                              'fileName': _selectedFile?.name,
                            };
                            
                            final reimburseList = ref.read(reimburseProvider.notifier);
                            final index = ref.read(reimburseProvider).indexWhere((item) => item['id'] == widget.data['id']);
                            if (index != -1) {
                              reimburseList.updateReimburse(index, updatedReimburse);
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengajuan reimburse berhasil diperbarui'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            context.pop();
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
