import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:path/path.dart' as path;

class ReimbursePage extends ConsumerStatefulWidget {
  const ReimbursePage({super.key});

  @override
  ConsumerState<ReimbursePage> createState() => _ReimbursePageState();
}

class _ReimbursePageState extends ConsumerState<ReimbursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseTypeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;
  late DateTime _currentTime;
  late Timer _timer;

  final List<Map<String, dynamic>> _reimbursementItems = [
    {
      'title': 'Transportasi Meeting',
      'amount': 'Rp 500.000',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Disetujui',
      'statusColor': Colors.green,
      'description': 'Biaya transportasi untuk meeting di Jakarta',
      'fileName': null,
    },
    {
      'title': 'Biaya Training',
      'amount': 'Rp 1.200.000',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Menunggu',
      'statusColor': Colors.orange,
      'description': 'Biaya pendaftaran training manajemen',
      'fileName': null,
    },
    {
      'title': 'Peralatan Kantor',
      'amount': 'Rp 750.000',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'Ditolak',
      'statusColor': Colors.red,
      'description': 'Pembelian alat tulis kantor',
      'fileName': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _expenseTypeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reimburse',
          style: theme.typographyBold.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(theme, context),
                const SizedBox(height: 24),

                // Reimbursement Form Section
                _buildReimbursementForm(theme, context),
                const SizedBox(height: 24),

                // Reimbursement History Section
                _buildReimbursementHistory(theme, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch, theme.secondarySwatch],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Reimburse',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReimbursementForm(dynamic theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formulir Pengajuan Reimburse',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis Pengeluaran',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _expenseTypeController,
                            decoration: InputDecoration(
                              labelText: 'Jenis Pengeluaran',
                              labelStyle: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.primarySwatch),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan jenis pengeluaran';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[200], thickness: 1),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah (Rp)',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Jumlah (Rp)',
                              labelStyle: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.primarySwatch),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan jumlah';
                              }
                              final numValue = double.tryParse(value);
                              if (numValue == null || numValue <= 0) {
                                return 'Jumlah harus berupa angka positif';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[200], thickness: 1),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keterangan',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              labelStyle: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.primarySwatch),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan keterangan';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[200], thickness: 1),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.upload_file,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unggah Berkas (opsional)',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Pilih Berkas'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primarySwatch.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _selectedFile != null ? path.basename(_selectedFile!.path!) : 'Tidak ada berkas dipilih',
                                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _reimbursementItems.insert(0, {
                          'title': _expenseTypeController.text,
                          'amount': 'Rp ${NumberFormat("#,##0", "id_ID").format(double.parse(_amountController.text))}',
                          'date': DateTime.now(),
                          'status': 'Menunggu',
                          'statusColor': Colors.orange,
                          'description': _descriptionController.text,
                          'fileName': _selectedFile?.name,
                        });
                        _expenseTypeController.clear();
                        _amountController.clear();
                        _descriptionController.clear();
                        _selectedFile = null;
                      });
                      debugPrint('📝 Submitting reimbursement form');
                      debugPrint('👤 User: miftahul01');
                      debugPrint('📅 Time: ${_currentTime.toIso8601String().substring(0, 19)} WIB');
                      debugPrint('📋 Expense Type: ${_expenseTypeController.text}');
                      debugPrint('💰 Amount: ${_amountController.text}');
                      debugPrint('📝 Description: ${_descriptionController.text}');
                      debugPrint('📄 File: ${_selectedFile?.name ?? 'No file'}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengajuan reimburse berhasil dikirim'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Ajukan Reimburse',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReimbursementHistory(dynamic theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Reimburse',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('📜 Viewing all reimbursement history');
                debugPrint('👤 User: miftahul01');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur riwayat lengkap akan segera tersedia'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: theme.primarySwatch,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _reimbursementItems.isEmpty
              ? _buildEmptyState('Tidak ada riwayat reimburse', Icons.receipt)
              : Column(
                  children: _reimbursementItems.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primarySwatch.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: theme.primarySwatch,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: theme.typographyRegular.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: Colors.grey[200], height: 1),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.monetization_on,
                                    label: 'Jumlah',
                                    value: item['amount'] as String,
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today,
                                    label: 'Tanggal',
                                    value: DateFormat('dd MMMM yyyy', 'id_ID').format(item['date'] as DateTime),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.info,
                                    label: 'Status',
                                    value: item['status'] as String,
                                    statusColor: item['statusColor'] as Color,
                                    theme: theme,
                                  ),
                                  if (item['description'] != null) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      icon: Icons.description,
                                      label: 'Keterangan',
                                      value: item['description'] as String,
                                      theme: theme,
                                    ),
                                  ],
                                  if (item['fileName'] != null) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      icon: Icons.attach_file,
                                      label: 'Berkas',
                                      value: item['fileName'] as String,
                                      theme: theme,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required dynamic theme,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.typographyRegular.bodyExtraSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              statusColor != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: theme.typographyRegular.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}