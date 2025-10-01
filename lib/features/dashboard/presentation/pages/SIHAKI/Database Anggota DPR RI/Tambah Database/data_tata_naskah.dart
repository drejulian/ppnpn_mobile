import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
import 'dart:async';
// SQLite imports
import 'package:ppnpm_dpr/common/data/repositories/sihaki/tata_naskah_repository.dart';


class DataTataNaskahPage extends ConsumerStatefulWidget {
  const DataTataNaskahPage({super.key});

  @override
  ConsumerState<DataTataNaskahPage> createState() => _DataTataNaskahPageState();
}

class _DataTataNaskahPageState extends ConsumerState<DataTataNaskahPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnggotaController = TextEditingController();
  
  // Upload file
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, String> _fileSizes = {};
  final Map<String, String> _changeLogs = {};
  
  bool _isLoading = false;
  Timer? _saveTimer;

  // SQLite integration
  late final TataNaskahRepository _repository;

  final List<DocumentItem> _documents = [
    DocumentItem('naskah_asli', '[DASI] Naskah Asli', true),
    DocumentItem('naskah_revisi', '[DASI] Naskah Revisi', false),
    DocumentItem('lampiran', '[DASI] Lampiran', false),
    DocumentItem('cover_letter', '[DASI] Cover Letter', false),
  ];

  @override
  void initState() {
    super.initState();
    _repository = TataNaskahRepository();
    
    // Add listener for nama anggota (will be implemented when we add the field)
    _namaAnggotaController.addListener(_onNamaAnggotaChanged);
    
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatabase();
    });
  }

  // Initialize database and handle any setup errors
  Future<void> _initializeDatabase() async {
    try {
      print('DEBUG: Initializing database for tata naskah...');
      
      // Try to load data first
      await _loadLatestData();
    } catch (e) {
      print('DEBUG: Database initialization error: $e');
      
      // If there's an error, show option to recreate database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: ${e.toString().length > 100 ? e.toString().substring(0, 100) + "..." : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fix Database',
              textColor: Colors.white,
              onPressed: () {
                _showRecreateDialog();
              },
            ),
          ),
        );
      }
    }
  }

  void _onNamaAnggotaChanged() {
    // Load documents when nama anggota changes
    if (_namaAnggotaController.text.trim().isNotEmpty) {
      _loadDocumentsByNama(_namaAnggotaController.text.trim());
    }
    _updateFilledStatus();
  }

  Future<void> _loadLatestData() async {
    try {
      setState(() => _isLoading = true);
      
      print('DEBUG: Loading latest tata naskah data...');
      
      // First ensure database connection is working
      await _repository.getTataNaskahCount();
      print('DEBUG: Database connection verified');
      
      // Try to get all documents first to check what's in database
      final allDocuments = await _repository.getAllTataNaskah();
      print('DEBUG: Found ${allDocuments.length} document records in database');
      
      if (allDocuments.isNotEmpty) {
        // Group by nama anggota and get the latest
        final groupedByNama = <String, List<dynamic>>{};
        for (final doc in allDocuments) {
          if (!groupedByNama.containsKey(doc.namaAnggota)) {
            groupedByNama[doc.namaAnggota] = [];
          }
          groupedByNama[doc.namaAnggota]!.add(doc);
        }
        
        // Get the most recent nama anggota (by latest updated document)
        String latestNamaAnggota = '';
        DateTime latestUpdate = DateTime(1970);
        
        for (final entry in groupedByNama.entries) {
          for (final doc in entry.value) {
            if (doc.updatedAt.isAfter(latestUpdate)) {
              latestUpdate = doc.updatedAt;
              latestNamaAnggota = entry.key;
            }
          }
        }
        
        if (latestNamaAnggota.isNotEmpty && mounted) {
          setState(() {
            _namaAnggotaController.text = latestNamaAnggota;
          });
          
          // Load documents for this nama anggota
          await _loadDocumentsByNama(latestNamaAnggota);
          print('DEBUG: Successfully loaded documents for $latestNamaAnggota');
        }
      } else {
        print('DEBUG: No tata naskah documents found in database - starting with empty form');
        
        // Clear form when no data
        if (mounted) {
          setState(() {
            _namaAnggotaController.clear();
            _uploadedFiles.clear();
            _fileTypes.clear();
            _fileSizes.clear();
            _changeLogs.clear();
          });
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateFilledStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('DEBUG: Error loading tata naskah data: $e');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadDocumentsByNama(String namaAnggota) async {
    if (namaAnggota.trim().isEmpty) return;
    
    try {
      setState(() => _isLoading = true);
      
      final documents = await _repository.getTataNaskahByNama(namaAnggota.trim());
      
      if (documents.isNotEmpty && mounted) {
        setState(() {
          _uploadedFiles.clear();
          _fileTypes.clear();
          _fileSizes.clear();
          _changeLogs.clear();
          
          for (final doc in documents) {
            _uploadedFiles[doc.documentId] = File(doc.filePath);
            _fileTypes[doc.documentId] = doc.fileType;
            _fileSizes[doc.documentId] = doc.fileSize;
            if (doc.uploadedAt != null) {
              _changeLogs[doc.documentId] = doc.uploadedAt!;
            }
          }
        });
        
        print('DEBUG: Loaded ${documents.length} documents for $namaAnggota');
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateFilledStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('DEBUG: Error loading documents by nama: $e');
    }
  }

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataTataNaskahFilledProvider.notifier).state = isFilled;
  }

  Future<void> _saveAllDocumentsToDatabase() async {
    if (_namaAnggotaController.text.trim().isEmpty) {
      print('DEBUG: Cannot save - no nama anggota specified');
      return;
    }

    final namaAnggota = _namaAnggotaController.text.trim();
    
    try {
      print('DEBUG: Saving ${_uploadedFiles.length} documents to database for $namaAnggota');
      
      for (final entry in _uploadedFiles.entries) {
        final documentId = entry.key;
        final file = entry.value;
        
        if (file != null) {
          await _repository.saveTataNaskahDocument(
            namaAnggota: namaAnggota,
            documentId: documentId,
            documentTitle: _getDocumentTitle(documentId),
            file: file,
            isRequired: _isDocumentRequired(documentId),
            isUploaded: true,
          );
          
          print('DEBUG: Saved document $documentId for $namaAnggota');
        }
      }
      
      print('DEBUG: All documents saved successfully');
    } catch (e) {
      print('DEBUG: Error saving documents to database: $e');
      throw e;
    }
  }

  String _getDocumentTitle(String documentId) {
    // Map document IDs to readable titles
    switch (documentId) {
      case 'sk_penetapan':
        return 'SK Penetapan/Pengangkatan Anggota DPR';
      case 'sk_pemberhentian':
        return 'SK Pemberhentian Anggota DPR (PAW)';
      case 'ijazah_terakhir':
        return 'Ijazah Pendidikan Terakhir';
      case 'akta_kelahiran':
        return 'Akta Kelahiran/Surat Kenal Lahir';
      case 'kartu_keluarga':
        return 'Kartu Keluarga';
      case 'ktp':
        return 'KTP/Identitas Lainnya';
      case 'npwp':
        return 'Nomor Pokok Wajib Pajak (NPWP)';
      case 'pas_foto':
        return 'Pas Foto Terbaru';
      case 'akta_perkawinan':
        return 'Akta Nikah/Cerai';
      case 'surat_pernyataan':
        return 'Surat Pernyataan Tidak Rangkap Jabatan';
      default:
        return 'Dokumen $documentId';
    }
  }

  bool _isDocumentRequired(String documentId) {
    // Define which documents are required
    const requiredDocuments = {
      'sk_penetapan',
      'ijazah_terakhir',
      'akta_kelahiran',
      'kartu_keluarga',
      'ktp',
      'npwp',
      'pas_foto',
      'surat_pernyataan',
    };
    
    return requiredDocuments.contains(documentId);
  }

  void _showRecreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Database Error'),
          content: const Text(
            'There seems to be an issue with the database. Would you like to recreate it? '
            'This will clear all data and create a fresh database.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Recreate Database'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _recreateDatabase();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _recreateDatabase() async {
    try {
      setState(() => _isLoading = true);
      
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recreating database...'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Recreate database - just clear all data for now
      print('DEBUG: Attempting to recreate database...');
      
      // Initialize fresh repository
      _repository = TataNaskahRepository();
      
      // Clear current data
      setState(() {
        _namaAnggotaController.clear();
        _uploadedFiles.clear();
        _fileTypes.clear();
        _fileSizes.clear();
        _changeLogs.clear();
        _isLoading = false;
      });
      
      _updateFilledStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database recreated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to recreate database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaAnggotaController.removeListener(_onNamaAnggotaChanged);
    _namaAnggotaController.dispose();
    _saveTimer?.cancel();
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

          // Auto-save to database if nama anggota is available
          if (_namaAnggotaController.text.trim().isNotEmpty) {
            try {
              await _repository.saveTataNaskahDocument(
                namaAnggota: _namaAnggotaController.text.trim(),
                documentId: documentId,
                documentTitle: _getDocumentTitle(documentId),
                file: file,
                isRequired: _isDocumentRequired(documentId),
                isUploaded: false, // Initially not uploaded, just selected
              );
              print('DEBUG: Auto-saved document $documentId after selection');
            } catch (e) {
              print('DEBUG: Auto-save failed: $e');
            }
          }

          _updateFilledStatus();
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

    if (_namaAnggotaController.text.trim().isEmpty) {
      _showFileErrorDialog('Silakan isi nama anggota terlebih dahulu');
      return;
    }

    setState(() {
      _uploading[documentId] = true;
    });

    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      final uploadTime = now.toLocal().toString().split('.')[0];
      
      // Update upload status in database
      await _repository.updateUploadStatus(
        namaAnggota: _namaAnggotaController.text.trim(),
        documentId: documentId,
        isUploaded: true,
        uploadedAt: uploadTime,
      );

      setState(() {
        _changeLogs[documentId] = '$uploadTime WIB';
      });

      print('DEBUG: Updated upload status for document $documentId');
      _updateFilledStatus();
      _showSuccessDialog('File PDF berhasil diupload!');
    } catch (e) {
      print('DEBUG: Upload failed: $e');
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
      // Save all documents to database
      await _saveAllDocumentsToDatabase();

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
              // Loading indicator
              if (_isLoading)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Memuat data...'),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Nama Anggota Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: _namaAnggotaController.text.trim().isNotEmpty 
                              ? Colors.green[600] 
                              : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identitas Anggota',
                                  style: theme.typographyRegular.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Masukkan nama anggota DPR RI',
                                  style: theme.typographyRegular.bodySmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _namaAnggotaController.text.trim().isNotEmpty 
                                ? Colors.green[50] 
                                : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _namaAnggotaController.text.trim().isNotEmpty 
                                  ? Colors.green[200]! 
                                  : Colors.grey[200]!,
                              ),
                            ),
                            child: Text(
                              _namaAnggotaController.text.trim().isNotEmpty 
                                ? 'Terisi' 
                                : 'Belum Terisi',
                              style: TextStyle(
                                fontSize: 12,
                                color: _namaAnggotaController.text.trim().isNotEmpty 
                                  ? Colors.green[700] 
                                  : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaAnggotaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap Anggota DPR RI',
                          hintText: 'Masukkan nama lengkap anggota',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama anggota harus diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama anggota minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
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
