import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataTataNaskahPage extends ConsumerStatefulWidget {
  const DataTataNaskahPage({super.key});

  @override
  ConsumerState<DataTataNaskahPage> createState() => _DataTataNaskahPageState();
}

class _DataTataNaskahPageState extends ConsumerState<DataTataNaskahPage> {
  final _formKey = GlobalKey<FormState>();

  // Upload file
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, String> _fileSizes = {};
  final Map<String, String> _changeLogs = {};

  static final Map<String, File?> _persistentFiles = {};
  static final Map<String, String> _persistentFileTypes = {};
  static final Map<String, String> _persistentFileSizes = {};
  static final Map<String, String> _persistentChangeLogs = {};

  final List<DocumentItem> _documents = [
    DocumentItem('naskah_asli', '[DASI] Naskah Asli', true),
    DocumentItem('naskah_revisi', '[DASI] Naskah Revisi', false),
    DocumentItem('lampiran', '[DASI] Lampiran', false),
    DocumentItem('cover_letter', '[DASI] Cover Letter', false),
  ];

  @override
  void initState() {
    super.initState();
    _uploadedFiles.addAll(_persistentFiles);
    _fileTypes.addAll(_persistentFileTypes);
    _fileSizes.addAll(_persistentFileSizes);
    _changeLogs.addAll(_persistentChangeLogs);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    // Memuat data persisten saat halaman dimuat
    setState(() {
      if (_isAllRequiredFilled()) {
        ref.read(dataTataNaskahFilledProvider.notifier).state = true;
      } else {
        ref.read(dataTataNaskahFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    // Check required documents only
    final documentsFilled = _documents
        .where((doc) => doc.isRequired)
        .every((doc) => _uploadedFiles[doc.id] != null);

    return documentsFilled;
  }

  Future<void> _pickFile(String documentId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // Validasi ukuran file (maksimal 5MB)
        if (platformFile.size > 5 * 1024 * 1024) {
          _showFileErrorDialog('Ukuran file terlalu besar. Maksimal 5 MB.');
          return;
        }

        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final extension = platformFile.extension?.toLowerCase() ?? '';

          // Validasi hanya PDF
          if (extension != 'pdf') {
            _showFileErrorDialog(
              'Hanya file PDF yang diperbolehkan. File yang dipilih: .$extension',
            );
            return;
          }

          setState(() {
            _uploadedFiles[documentId] = file;
            _fileTypes[documentId] = extension.toUpperCase();
            final sizeInBytes = platformFile.size;
            _fileSizes[documentId] =
                sizeInBytes < 1024 * 1024
                    ? '${(sizeInBytes / 1024).toStringAsFixed(2)} KB'
                    : '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
          });

          _showSuccessDialog('File PDF berhasil dipilih: ${platformFile.name}');
        } else {
          _showFileErrorDialog('Path file tidak valid.');
        }
      }
    } catch (e) {
      _showFileErrorDialog('Gagal memilih file: ${e.toString()}');
    }
  }

  Future<void> _uploadFile(String documentId) async {
    if (_uploadedFiles[documentId] == null) {
      _showFileErrorDialog('Silakan pilih file PDF terlebih dahulu');
      return;
    }

    setState(() {
      _uploading[documentId] = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      setState(() {
        _changeLogs[documentId] =
            '${now.toLocal().toString().split('.')[0]} WIB';
      });

      _showSuccessDialog('File PDF berhasil diupload!');
    } catch (e) {
      _showFileErrorDialog('Gagal mengupload file: ${e.toString()}');
    } finally {
      setState(() {
        _uploading[documentId] = false;
      });
    }
  }

  void _showFileErrorDialog(String message) {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
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

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      _persistentFiles.addAll(_uploadedFiles);
      _persistentFileTypes.addAll(_fileTypes);
      _persistentFileSizes.addAll(_fileSizes);
      _persistentChangeLogs.addAll(_changeLogs);

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Tata Naskah',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data tata naskah berhasil disimpan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      await Future.delayed(Duration.zero, () {
        ref.read(dataTataNaskahFilledProvider.notifier).state =
            _isAllRequiredFilled();
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-tata-naskah'},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Upload Dokumen Tata Naskah',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
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
              // Document Upload Section
              SIHAKIDataCard(
                title: 'Upload Dokumen Tata Naskah',
                subtitle: 'Upload dokumen pendukung tata naskah',
                leadingIcon: Icons.file_upload,
                statusColor: Colors.blue[600],
                statusText: 'Upload',
                fields: [
                  SIHAKIDataField(label: 'Format File', value: 'PDF'),
                  SIHAKIDataField(
                    label: 'Ukuran Maksimal',
                    value: '5 MB per file',
                  ),
                  SIHAKIDataField(
                    label: 'Sudah Upload',
                    value:
                        '${_uploadedFiles.length} dari ${_documents.length} dokumen',
                    isLast: true,
                  ),
                ],
                actions: [],
                isTablet: isTablet,
              ),
              const SizedBox(height: 16),

              // Document List
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primarySwatch, theme.secondarySwatch],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Daftar Dokumen',
                            style: theme.typographyRegular.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documents.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final document = _documents[index];
                        return _buildDocumentItem(theme, document, isTablet);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tombol SIMPAN
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveData(context, ref, theme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primarySwatch,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    dynamic theme,
    DocumentItem document,
    bool isTablet,
  ) {
    final isUploaded = _uploadedFiles[document.id] != null;
    final isUploading = _uploading[document.id] ?? false;
    final fileType = _fileTypes[document.id] ?? '';
    final fileSize = _fileSizes[document.id] ?? '';
    final changeLog = _changeLogs[document.id] ?? '';

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: isUploaded ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? Colors.green[200]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
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
                  color:
                      isUploaded
                          ? Colors.green[100]
                          : theme.primarySwatch.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : Icons.description,
                  size: 18,
                  color: isUploaded ? Colors.green[600] : theme.primarySwatch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (document.isRequired) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
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
                  ],
                ),
              ),
              if (isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Uploaded',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isUploaded ? Colors.green[300]! : theme.primarySwatch,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _pickFile(document.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isUploaded
                                  ? Icons.check_circle
                                  : Icons.folder_open,
                              size: 16,
                              color:
                                  isUploaded
                                      ? Colors.green[600]
                                      : theme.primarySwatch,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isUploaded
                                    ? 'File: ${_uploadedFiles[document.id]!.path.split('/').last}'
                                    : 'Pilih File PDF...',
                                style: theme.typographyRegular.bodySmall
                                    .copyWith(
                                      color:
                                          isUploaded
                                              ? Colors.green[700]
                                              : theme.primarySwatch,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.0,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        (_uploadedFiles[document.id] != null && !isUploading)
                            ? [theme.primarySwatch, theme.secondarySwatch]
                            : [Colors.grey[400]!, Colors.grey[500]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_uploadedFiles[document.id] != null && !isUploading)
                              ? theme.primarySwatch.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        (_uploadedFiles[document.id] != null && !isUploading)
                            ? () => _uploadFile(document.id)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child:
                          isUploading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'UPLOAD',
                                    style: theme.typographyRegular.bodySmall
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.0,
                                        ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isUploaded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildFileDetail(
                    Icons.description,
                    'Format',
                    fileType,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildFileDetail(Icons.storage, 'Ukuran', fileSize, theme),
                  const SizedBox(height: 8),
                  _buildFileDetail(
                    Icons.access_time,
                    'Diupload',
                    changeLog,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileDetail(
    IconData icon,
    String label,
    String value,
    dynamic theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.typographyRegular.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
