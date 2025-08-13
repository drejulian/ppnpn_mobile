import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:path/path.dart' as path;

class IzinPage extends ConsumerStatefulWidget {
  const IzinPage({super.key});

  @override
  ConsumerState<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends ConsumerState<IzinPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _currentTime;
  late Timer _timer;
  String? _selectedLeaveType;
  DateTime? _selectedStartDate;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  PlatformFile? _selectedFile;

  final List<Map<String, dynamic>> _leaveItems = [
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'duration': '1 hari',
      'type': 'Izin Sakit',
      'reason': 'Sakit demam',
      'status': 'Disetujui',
      'statusColor': Colors.green,
      'fileName': null,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'duration': '2 hari',
      'type': 'Izin Pribadi',
      'reason': 'Urusan keluarga',
      'status': 'Menunggu Persetujuan',
      'statusColor': Colors.orange,
      'fileName': null,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'duration': '1 hari',
      'type': 'Izin Lainnya',
      'reason': 'Kegiatan komunitas',
      'status': 'Ditolak',
      'statusColor': Colors.red,
      'fileName': null,
    },
  ];

  final List<String> _leaveTypes = [
    'Izin Sakit',
    'Izin Pribadi',
    'Izin Keluarga',
    'Izin Lainnya',
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
    _durationController.dispose();
    _reasonController.dispose();
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
          'Izin',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
                    Icons.event_busy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Izin',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeaveForm(theme, context),
                    const SizedBox(height: 24),
                    _buildLeaveHistory(theme, context, _currentTime),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveForm(dynamic theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengajuan Izin',
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
                            'Jenis Izin',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Jenis Izin',
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
                            value: _selectedLeaveType,
                            items: _leaveTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: theme.typographyRegular.bodySmall.copyWith(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLeaveType = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih jenis izin';
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
                        Icons.calendar_today,
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
                            'Tanggal Mulai Izin',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tanggal Mulai Izin',
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
                            readOnly: true,
                            controller: TextEditingController(
                              text: _selectedStartDate != null
                                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedStartDate!)
                                  : '',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedStartDate = picked;
                                });
                                debugPrint('📅 Selected leave start date: ${DateFormat('yyyy-MM-dd').format(picked)}');
                              }
                            },
                            validator: (value) {
                              if (_selectedStartDate == null) {
                                return 'Pilih tanggal mulai izin';
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
                        Icons.access_time,
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
                            'Durasi (Hari)',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _durationController,
                            decoration: InputDecoration(
                              labelText: 'Durasi (Hari)',
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
                                return 'Masukkan durasi izin';
                              }
                              final numValue = double.tryParse(value);
                              if (numValue == null || numValue <= 0) {
                                return 'Durasi harus berupa angka positif';
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
                            'Alasan Izin',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              labelText: 'Alasan Izin',
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
                                return 'Masukkan alasan izin';
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _leaveItems.insert(0, {
                          'date': _selectedStartDate!,
                          'duration': _durationController.text + ' hari',
                          'type': _selectedLeaveType!,
                          'reason': _reasonController.text,
                          'status': 'Menunggu Persetujuan',
                          'statusColor': Colors.orange,
                          'fileName': _selectedFile?.name,
                        });
                        _selectedLeaveType = null;
                        _selectedStartDate = null;
                        _durationController.clear();
                        _reasonController.clear();
                        _selectedFile = null;
                      });
                      debugPrint('📤 Submitting leave request');
                      debugPrint('👤 User: miftahul01');
                      debugPrint('📅 Time: ${_currentTime.toIso8601String().substring(0, 19)} WIB');
                      debugPrint('📅 Leave Start Date: ${DateFormat('yyyy-MM-dd').format(_selectedStartDate!)}');
                      debugPrint('📋 Leave Type: $_selectedLeaveType');
                      debugPrint('📏 Duration: ${_durationController.text} hari');
                      debugPrint('📝 Reason: ${_reasonController.text}');
                      debugPrint('📄 File: ${_selectedFile?.name ?? 'No file'}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengajuan izin berhasil dikirim'),
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
                  ),
                  child: Text(
                    'Ajukan Izin',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildLeaveHistory(dynamic theme, BuildContext context, DateTime currentTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Izin',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('📋 Viewing all leave history');
                debugPrint('👤 User: miftahul01');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur lihat semua riwayat akan segera tersedia'),
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
          child: _leaveItems.isEmpty
              ? _buildEmptyState('Tidak ada riwayat izin', Icons.history)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _leaveItems.length,
                  itemBuilder: (context, index) {
                    final leave = _leaveItems[index];
                    return _buildLeaveCard(leave, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave, dynamic theme) {
    final isApproved = leave['status'] == 'Disetujui';
    final statusColor = leave['statusColor'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(context, leave, theme),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(leave['date'] as DateTime),
                              style: theme.typographyBold.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              leave['type'],
                              style: theme.typographyRegular.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(leave['status'], statusColor, theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal',
                    value: DateFormat('dd MMMM yyyy', 'id_ID').format(leave['date'] as DateTime),
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Durasi',
                    value: leave['duration'],
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.description,
                    label: 'Alasan',
                    value: leave['reason'],
                    theme: theme,
                  ),
                  if (leave['fileName'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.attach_file,
                      label: 'Berkas',
                      value: leave['fileName'],
                      theme: theme,
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (isApproved) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Unduh Bukti Izin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _downloadBuktiIzin(leave),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: isApproved ? 'Tidak dapat diedit' : 'Edit',
                        icon: Icon(
                          Icons.edit,
                          color: isApproved ? Colors.grey : theme.primarySwatch,
                        ),
                        onPressed: isApproved ? null : () => _navigateToEditPage(leave),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(leave),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: theme.typographyBold.bodySmall?.copyWith(color: color),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required dynamic theme,
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
              Text(
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

  void _navigateToEditPage(Map<String, dynamic> leave) {
    debugPrint('📝 Navigating to edit page for leave on ${DateFormat('yyyy-MM-dd').format(leave['date'] as DateTime)}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit izin akan segera tersedia'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadBuktiIzin(Map<String, dynamic> leave) {
    debugPrint('📥 Downloading proof for leave on ${DateFormat('yyyy-MM-dd').format(leave['date'] as DateTime)}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh bukti izin untuk ${leave['type']}'),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> leave) {
    final date = DateFormat('dd MMMM yyyy', 'id_ID').format(leave['date'] as DateTime);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengajuan Izin'),
        content: Text('Yakin menghapus pengajuan izin pada $date?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _leaveItems.remove(leave);
              });
              debugPrint('🗑️ Deleting leave on $date');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengajuan izin dihapus')),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _showDetailDialog(BuildContext context, Map<String, dynamic> leave, dynamic theme) {
    final statusColor = leave['statusColor'] as Color;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, theme.primarySwatch.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Izin',
                    style: theme.typographyRegular.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primarySwatch,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.primarySwatch,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Status',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primarySwatch.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatusField(
                      'Status Pengajuan',
                      leave['status'],
                      statusColor,
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Izin',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primarySwatch.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      'Tanggal',
                      DateFormat('dd MMMM yyyy', 'id_ID').format(leave['date'] as DateTime),
                      theme,
                    ),
                    _buildTextField(
                      'Jenis Izin',
                      leave['type'],
                      theme,
                    ),
                    _buildTextField(
                      'Durasi',
                      leave['duration'],
                      theme,
                    ),
                    _buildTextField(
                      'Alasan',
                      leave['reason'],
                      theme,
                      isLast: leave['fileName'] == null,
                    ),
                    if (leave['fileName'] != null)
                      _buildTextField(
                        'Berkas',
                        leave['fileName'],
                        theme,
                        isLast: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (leave['status'] == 'Disetujui') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Unduh Bukti Izin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _downloadBuktiIzin(leave),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    dynamic theme, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.typographyRegular.bodyMedium.copyWith(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildStatusField(
    String label,
    String value,
    Color color,
    dynamic theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: theme.typographyBold.bodySmall?.copyWith(color: color),
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