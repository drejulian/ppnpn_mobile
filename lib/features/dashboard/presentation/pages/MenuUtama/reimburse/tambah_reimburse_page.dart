import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/reimburse_model.dart';
import 'daftar_reimburse_page.dart';

class TambahReimbursePage extends ConsumerStatefulWidget {
  const TambahReimbursePage({super.key});

  @override
  ConsumerState<TambahReimbursePage> createState() => _TambahReimbursePageState();
}

class _TambahReimbursePageState extends ConsumerState<TambahReimbursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kategoriCtrl = TextEditingController();
  final TextEditingController _tanggalCtrl = TextEditingController();
  final TextEditingController _jumlahCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  
  final List<String> _kategoriOptions = [
    'Transport',
    'Makan', 
    'Hotel',
    'Komunikasi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tanggalCtrl.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
  }

  @override
  void dispose() {
    _kategoriCtrl.dispose();
    _tanggalCtrl.dispose();
    _jumlahCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

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
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajukan Reimburse',
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
              AppFormCard(
                title: 'Form Pengajuan Reimburse',
                titleIcon: Icons.receipt_long,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Kategori',
                    icon: Icons.category,
                    type: FormFieldType.dropdown,
                    isRequired: true,
                    options: _kategoriOptions,
                    value: _kategoriCtrl.text.isEmpty ? null : _kategoriCtrl.text,
                    onChanged: (value) => setState(() => _kategoriCtrl.text = value ?? ''),
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
                    onTap: _pickDate,
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
                      // Remove all non-numeric characters except decimal point
                      final numericValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
                      if (numericValue.isEmpty) {
                        return 'Masukkan angka yang valid';
                      }
                      final amount = double.tryParse(numericValue);
                      if (amount == null || amount <= 0) {
                        return 'Jumlah harus lebih dari 0';
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
                    hintText: 'Jelaskan detail keperluan reimburse',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // File Upload Section - Moved after date field
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
              
              // Submit button moved to bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      String amountText = _jumlahCtrl.text.trim();
                      if (amountText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Jumlah harus diisi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      // Remove all non-numeric characters except decimal point
                      final numericValue = amountText.replaceAll(RegExp(r'[^0-9.]'), '');
                      final amount = double.tryParse(numericValue);
                      
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan jumlah yang valid'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      // Create new reimburse data using ReimburseModel
                      final newReimburse = ReimburseModel.create(
                        category: _kategoriCtrl.text,
                        amount: amount.toDouble(),
                        description: _deskripsiCtrl.text,
                        date: _selectedDate ?? DateTime.now(),
                        fileName: _selectedFile?.name,
                        userId: 1, // TODO: Get from auth provider
                      );

                      // Add to provider
                      await ref.read(reimburseListProvider.notifier).addReimburse(newReimburse);
                      
                      // Debug: Print the new reimburse data
                      print('New reimburse added: $newReimburse');

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengajuan reimburse berhasil dikirim'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        context.pop();
                      }
                    } catch (e) {
                      print('Error adding reimburse: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'AJUKAN REIMBURSE',
                    style: TextStyle(
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
}
