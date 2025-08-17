import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/providers.dart';

class DataDokumenAnggotaPage extends ConsumerStatefulWidget {
  const DataDokumenAnggotaPage({super.key});

  @override
  ConsumerState<DataDokumenAnggotaPage> createState() => _DataDokumenAnggotaPageState();
}

class _DataDokumenAnggotaPageState extends ConsumerState<DataDokumenAnggotaPage> {
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, String> _fileSizes = {};
  final Map<String, String> _changeLogs = {};
  bool _isEditing = false;
  bool _isDataSaved = false; 
  final TextEditingController _memberNameController = TextEditingController(text: 'Nama Anggota');
  final _formKey = GlobalKey<FormState>();

  static final Map<String, File?> _persistentFiles = {};
  static final Map<String, String> _persistentFileTypes = {};
  static final Map<String, String> _persistentFileSizes = {};
  static final Map<String, String> _persistentChangeLogs = {};

  @override
  void initState() {
    super.initState();
    _uploadedFiles.addAll(_persistentFiles);
    _fileTypes.addAll(_persistentFileTypes);
    _fileSizes.addAll(_persistentFileSizes);
    _changeLogs.addAll(_persistentChangeLogs);
    _updateFilledStatus();
    _isDataSaved = _isAllRequiredFilled(); 
  }

  final List<DocumentItem> _documents = [
    DocumentItem('vaksin_covid_1', '[DASI] Vaksin Covid 1', true),
    DocumentItem('vaksin_covid_2', '[DASI] Vaksin Covid 2', true),
    DocumentItem('vaksin_covid_3', '[DASI] Vaksin Covid 3', true),
    DocumentItem('vaksin_booster_1', '[DASI] Vaksin Covid Booster 1', true),
    DocumentItem('vaksin_booster_2', '[DASI] Vaksin Covid Booster 2', true),
    DocumentItem('vaksin_meningitis', '[DASI] Vaksin Meningitis', true),
    DocumentItem('ktp_pasangan', '[DASI] KTP Pasangan', true),
    DocumentItem('paspor_pasangan', '[DASI] Paspor Pasangan', true),
    DocumentItem('paspor_hijau', '[DASI] Paspor Hijau', true),
    DocumentItem('paspor_biru', '[DASI] Paspor Biru', true),
    DocumentItem('paspor_hitam', '[DASI] Paspor Hitam', true),
    DocumentItem('paspor_hijau_hal5', '[DASI] Paspor Hijau (Halaman 5)', true),
    DocumentItem('paspor_biru_hal5', '[DASI] Paspor Biru (Halaman 5)', true),
    DocumentItem('pasfoto_tanpapecidankacamata', '[DASI] Pas Foto (Tanpa Peci/Kacamata)', true),
    DocumentItem('ktp_anggota', '[DASI] KTP Anggota', true),
    DocumentItem('kartu_anggota', '[DASI] Kartu Anggota', true),
    DocumentItem('kartu_keluarga', '[DASI] Kartu Keluarga', true),
    DocumentItem('npwp', '[DASI] NPWP', true),
    DocumentItem('sk', '[DASI] SK', true),
    DocumentItem('akta_lahir', '[DASI] Akta Lahir', true),
    DocumentItem('surat_nikah', '[DASI] Surat Nikah', true),
  ];

  Future<void> _pickFile(String documentId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _uploadedFiles[documentId] = file;
          _fileTypes[documentId] = file.path.split('.').last.toUpperCase();
          final sizeInBytes = file.lengthSync();
          _fileSizes[documentId] = sizeInBytes < 1024 * 1024
              ? '${(sizeInBytes / 1024).toStringAsFixed(2)} KB'
              : '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
          _updateFilledStatus();
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih file: $e');
    }
  }

  Future<void> _uploadFile(String documentId) async {
    if (_uploadedFiles[documentId] == null) {
      _showErrorDialog('Silakan pilih file terlebih dahulu');
      return;
    }

    setState(() {
      _uploading[documentId] = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      setState(() {
        _changeLogs[documentId] = '${now.toLocal().toString().split('.')[0]} WIB';
        _updateFilledStatus();
      });

      _showSuccessDialog('File berhasil diupload');
    } catch (e) {
      _showErrorDialog('Gagal mengupload file: $e');
    } finally {
      setState(() {
        _uploading[documentId] = false;
      });
    }
  }

  void _saveData(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      _persistentFiles.addAll(_uploadedFiles);
      _persistentFileTypes.addAll(_fileTypes);
      _persistentFileSizes.addAll(_fileSizes);
      _persistentChangeLogs.addAll(_changeLogs);

      final isFilled = _isAllRequiredFilled();
      ref.read(dataDokumenAnggotaFilledProvider.notifier).state = isFilled;
      setState(() {
        _isDataSaved = isFilled; 
      });
      print('Data saved, dataDokumenAnggotaFilledProvider set to: $isFilled, _isDataSaved: $_isDataSaved');


      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Simpan Data Dokumen Anggota',
            style: ref.read(themeProvider).typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: const Text('Data dokumen anggota berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home', extra: {'justSaved': true, 'sourcePage': '/data-dokumen-anggota'});
                print('Navigating back with extra: ${{'justSaved': true, 'sourcePage': '/data-dokumen-anggota'}}');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataDokumenAnggotaFilledProvider.notifier).state = isFilled;
    print('Updated status - dataDokumenAnggotaFilledProvider: $isFilled');
  }

  bool _isAllRequiredFilled() {
    return _documents
        .where((doc) => doc.isRequired)
        .every((doc) => _uploadedFiles[doc.id] != null);
  }

  void _showErrorDialog(String message) {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Upload Berhasil',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Data Dokumen Anggota',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(theme),
              const SizedBox(height: 20),
              // Kartu untuk Mengedit Nama Anggota
              _buildMemberNameCard(theme),
              const SizedBox(height: 20),
              _buildDocumentSection(theme),
              const SizedBox(height: 20),
              // Tombol Edit dan Simpan
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primarySwatch,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'EDIT',
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isEditing || !_isAllRequiredFilled()
                          ? () => _saveData(context, ref)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isEditing || _isAllRequiredFilled())
                            ? theme.primarySwatch
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled))
                              return Colors.grey[400]!;
                            return theme.primarySwatch;
                          },
                        ),
                      ),
                      child: Text(
                        'SIMPAN',
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informasi Penting',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dokumen Anggota dapat diunggah untuk keperluan administrasi resmi. Pastikan dokumen telah disetujui oleh Bagian Tata Persuratan.',
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberNameCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Cart
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch, theme.secondarySwatch.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Pribadi Anggota',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextFieldWithRequired(
            'Nama Anggota',
            _memberNameController,
            Icons.person,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama lengkap anggota',
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Cart
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch.withOpacity(0.9), theme.secondarySwatch],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.file_upload, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Dokumen Anggota',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // File Format Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keterangan : Format file yang diupload JPG/PDF',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Document List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final document = _documents[index];
              return _buildDocumentItem(theme, document);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(dynamic theme, DocumentItem document) {
    final isUploaded = _uploadedFiles[document.id] != null;
    final isUploading = _uploading[document.id] ?? false;
    final fileType = _fileTypes[document.id] ?? '';
    final fileSize = _fileSizes[document.id] ?? '';
    final changeLog = _changeLogs[document.id] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: isUploaded ? Colors.green[50] : Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Title
          Row(
            children: [
              Expanded(
                child: Text(
                  document.title,
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (document.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Wajib diisi',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 10.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Upload Section
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isEditing ? () => _pickFile(document.id) : null,
                  icon: Icon(
                    isUploaded ? Icons.check_circle : Icons.folder_open,
                    size: 16,
                  ),
                  label: Text(
                    isUploaded
                        ? 'File dipilih: ${_uploadedFiles[document.id]!.path.split('/').last}'
                        : 'Browse...',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isUploaded ? Colors.green[600] : theme.primarySwatch,
                    side: BorderSide(
                      color:
                          isUploaded ? Colors.green[300]! : theme.primarySwatch,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).copyWith(
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled))
                          return Colors.grey[600]!;
                        return isUploaded ? Colors.green[600]! : theme.primarySwatch;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed:
                      _isEditing && !isUploading ? () => _uploadFile(document.id) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled))
                          return theme.primarySwatch.withOpacity(0.5);
                        return theme.primarySwatch;
                      },
                    ),
                  ),
                  child:
                      isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'UPLOAD',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10.0,
                              ),
                            ),
                ),
              ),
            ],
          ),

          // File Details
          if (isUploaded)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tipe File: $fileType',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.storage, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ukuran File: $fileSize',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Log Perubahan: $changeLog',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithRequired(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isLast = false,
    bool enabled = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    enabled: enabled,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired && enabled
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field ini wajib diisi';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class DocumentItem {
  final String id;
  final String title;
  final bool isRequired;

  DocumentItem(this.id, this.title, this.isRequired);
}