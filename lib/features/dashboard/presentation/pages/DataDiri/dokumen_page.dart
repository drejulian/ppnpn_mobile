import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/profile_data_provider.dart';

class DokumenPage extends ConsumerStatefulWidget {
  const DokumenPage({super.key});

  @override
  ConsumerState<DokumenPage> createState() => _DokumenPageState();
}

class _DokumenPageState extends ConsumerState<DokumenPage> {
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};
  Map<String, dynamic> _originalData = {};
  bool _dataLoaded = false;
  bool _hasUnsavedChanges = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dataLoaded) {
      final savedData = ref.read(dokumenDataProvider);

      if (savedData.ktpUploaded) _uploadedFiles['ktp'] = File('dummy_ktp.pdf');
      if (savedData.kkUploaded) _uploadedFiles['kk'] = File('dummy_kk.pdf');
      if (savedData.ijazahUploaded) _uploadedFiles['ijazah'] = File('dummy_ijazah.pdf');
      if (savedData.transkripUploaded) _uploadedFiles['transkrip'] = File('dummy_transkrip.pdf');
      if (savedData.cvUploaded) _uploadedFiles['cv'] = File('dummy_cv.pdf');
      if (savedData.suratLamaranUploaded) _uploadedFiles['surat_lamaran'] = File('dummy_surat_lamaran.pdf');
      if (savedData.fotoUploaded) _uploadedFiles['foto'] = File('dummy_foto.jpg');
      if (savedData.sertifikatUploaded) _uploadedFiles['sertifikat'] = File('dummy_sertifikat.pdf');

      _originalData = _getCurrentData();
      _dataLoaded = true;
    }
  }

  Map<String, dynamic> _getCurrentData() {
    final dokumenData = ref.read(dokumenDataProvider);
    return {
      'cvUploaded': dokumenData.cvUploaded,
      'ijazahUploaded': dokumenData.ijazahUploaded,
      'transkripUploaded': dokumenData.transkripUploaded,
      'ktpUploaded': dokumenData.ktpUploaded,
      'kkUploaded': dokumenData.kkUploaded,
      'suratLamaranUploaded': dokumenData.suratLamaranUploaded,
      'fotoUploaded': dokumenData.fotoUploaded,
      'sertifikatUploaded': dokumenData.sertifikatUploaded,
      'uploadedFilesCount': _uploadedFiles.length,
    };
  }

  bool _hasUnsavedChangesInternal() {
    final currentData = _getCurrentData();
    bool hasChanges = false;

    _originalData.forEach((key, value) {
      if (currentData[key] != value) {
        hasChanges = true;
      }
    });

    return hasChanges;
  }

  void _updateUnsavedChanges() {
    setState(() {
      _hasUnsavedChanges = _hasUnsavedChangesInternal();
    });
  }

  void _restoreOriginalData() {
    _uploadedFiles.clear();

    final savedData = ref.read(dokumenDataProvider);
    if (savedData.ktpUploaded) _uploadedFiles['ktp'] = File('dummy_ktp.pdf');
    if (savedData.kkUploaded) _uploadedFiles['kk'] = File('dummy_kk.pdf');
    if (savedData.ijazahUploaded) _uploadedFiles['ijazah'] = File('dummy_ijazah.pdf');
    if (savedData.transkripUploaded) _uploadedFiles['transkrip'] = File('dummy_transkrip.pdf');
    if (savedData.cvUploaded) _uploadedFiles['cv'] = File('dummy_cv.pdf');
    if (savedData.suratLamaranUploaded) _uploadedFiles['surat_lamaran'] = File('dummy_surat_lamaran.pdf');
    if (savedData.fotoUploaded) _uploadedFiles['foto'] = File('dummy_foto.jpg');
    if (savedData.sertifikatUploaded) _uploadedFiles['sertifikat'] = File('dummy_sertifikat.pdf');

    setState(() {
      _hasUnsavedChanges = false;
    });
  }

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
          _hasUnsavedChanges = _hasUnsavedChangesInternal();
        });
      }
    } catch (e) {
      ErrorUploadDialogCard.show(
        context,
        title: 'Gagal Memilih File',
        message: 'Terjadi kesalahan saat memilih file: $e',
        onConfirm: () {
        },
      );
    }
  }

  Future<void> _uploadFile(String documentId) async {
    if (_uploadedFiles[documentId] == null) {
      ErrorUploadDialogCard.show(
        context,
        title: 'File Belum Dipilih',
        message: 'Silakan pilih file terlebih dahulu',
        onConfirm: () {
        },
      );
      return;
    }

    setState(() {
      _uploading[documentId] = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      await ProfileCompletionNotifierCard.show(
        context,
        title: 'Upload Berhasil',
        message: 'File berhasil diupload.',
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green[600],
        onConfirm: () {
        },
      );
      setState(() {
        _hasUnsavedChanges = _hasUnsavedChangesInternal();
      });
    } catch (e) {
      ErrorUploadDialogCard.show(
        context,
        title: 'Gagal Mengupload File',
        message: 'Terjadi kesalahan saat mengupload file: $e',
        onConfirm: () {
        },
      );
    } finally {
      setState(() {
        _uploading[documentId] = false;
      });
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);
    return await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan Dokumen',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        _restoreOriginalData();
        notification.NotificationUtils.showWarning(
          context,
          'Perubahan pada data dokumen telah dibatalkan',
        );
      },
      onCancel: () {},
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else if (context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Unggah Dokumen',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveData(context, theme);
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
          const SizedBox(height: 16),
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
                      color: isUploaded ? Colors.green[300]! : theme.primarySwatch,
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
                  onPressed: isUploading ? null : () => _uploadFile(document.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isUploading
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

  Future<void> _saveData(BuildContext context, dynamic theme) async {
    final currentData = ref.read(dokumenDataProvider);
    DokumenData newData = currentData.copyWith(
      cvUploaded: _uploadedFiles.containsKey('cv'),
      ijazahUploaded: _uploadedFiles.containsKey('ijazah'),
      transkripUploaded: _uploadedFiles.containsKey('transkrip'),
      ktpUploaded: _uploadedFiles.containsKey('ktp'),
      kkUploaded: _uploadedFiles.containsKey('kk'),
      suratLamaranUploaded: _uploadedFiles.containsKey('surat_lamaran'),
      fotoUploaded: _uploadedFiles.containsKey('foto'),
      sertifikatUploaded: _uploadedFiles.containsKey('sertifikat'),
    );

    ref.read(dokumenDataProvider.notifier).updateData(newData);
    ref.read(profileCompletionProvider.notifier).markCompleted('dokumen');

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool('dokumen_has_changes', false),
      prefs.setBool('dokumen_just_saved', true),
      prefs.setBool('dokumen_user_saved', true),
    ]);

    _originalData = _getCurrentData();

    await ProfileCompletionNotifierCard.show(
      context,
      title: 'Berhasil Menyimpan Dokumen',
      message: 'Data dokumen Anda telah diperbarui dan tersimpan dengan sukses.',
      onConfirm: () {
        notification.NotificationUtils.showSuccess(
          context,
          'Data dokumen telah disimpan',
        );
        if (context.mounted) {
          context.pop('saved');
        }
      },
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green[600],
    );

    if (context.mounted) {
      setState(() {
        _hasUnsavedChanges = false;
      });
    }
  }
}

class DocumentItem {
  final String id;
  final String title;
  final bool isRequired;

  DocumentItem(this.id, this.title, this.isRequired);
}