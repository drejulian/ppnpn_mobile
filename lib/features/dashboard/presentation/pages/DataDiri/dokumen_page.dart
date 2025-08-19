import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class DokumenPage extends ConsumerStatefulWidget {
  const DokumenPage({super.key});

  @override
  ConsumerState<DokumenPage> createState() => _DokumenPageState();
}

class _DokumenPageState extends ConsumerState<DokumenPage> {
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};

  final List<DocumentItem> _documents = [
    DocumentItem('ktp', 'KTP (ID Card)', true),
    DocumentItem('kk', 'KK (Family Card)', true),
    DocumentItem('npwp', 'NPWP (Tax ID)', true),
    DocumentItem('norek', 'Norek (Account Number)', true),
    DocumentItem('skck', 'SKCK (Police Clearance Certificate)', true),
    DocumentItem('ijazah', 'Ijazah (Diploma)', true),
    DocumentItem('transkrip', 'Transkrip Nilai (Academic Transcript)', true),
    DocumentItem(
      'bebas_narkoba',
      'Surat Bebas Narkoba (Drug-Free Certificate)',
      true,
    ),
    DocumentItem('sehat', 'Surat Sehat (Health Certificate)', true),
    DocumentItem(
      'pengalaman_kerja',
      'Surat Pengalaman Kerja (TAA/SP) (Work Experience Letter)',
      false,
    ),
    DocumentItem('toefl', 'TOEFL (TAA/SA)', false),
    DocumentItem(
      'penyetaraan',
      'Surat Penyetaraan Ijazah/GAB (Ijazah luar negeri) (Diploma Equivalency Certificate/GAB (Overseas Diploma))',
      false,
    ),
    DocumentItem('bpjs_kesehatan', 'BPJS Kesehatan (Health BPJS)', true),
    DocumentItem(
      'bpjs_ketenagakerjaan',
      'BPJS Ketenagakerjaan (Employment BPJS)',
      true,
    ),
    DocumentItem('lainnya', 'Lain-lain (Others)', false),
  ];

  Future<void> _pickFile(String documentId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _uploadedFiles[documentId] = File(result.files.single.path!);
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
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      _showSuccessDialog('File berhasil diupload');
    } catch (e) {
      _showErrorDialog('Gagal mengupload file: $e');
    } finally {
      setState(() {
        _uploading[documentId] = false;
      });
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Document Uploads',
          style: theme.typographyRegular.bodyMedium.copyWith(
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(theme),
            const SizedBox(height: 20),
            _buildDocumentSection(theme),
          ],
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
            'Setelah SK Penetapan diunduh dan dicetak, stempel basah dapat diperoleh pada Bagian Tata Persuratan dan Penyimpanan (Gedung Sejen Lantai 1).',
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
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
          // Section Title
          Row(
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
                  Icons.file_upload,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Document Uploads Section',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
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
                  onPressed: () => _pickFile(document.id),
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
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed:
                      isUploading ? null : () => _uploadFile(document.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
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
        ],
      ),
    );
  }
}

class DocumentItem {
  final String id;
  final String title;
  final bool isRequired;

  DocumentItem(this.id, this.title, this.isRequired);
}
