import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
// SQLite Integration imports
import 'package:ppnpm_dpr/common/data/models/sihaki/dokumen_anggota_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/dokumen_anggota_provider.dart';
import 'package:ppnpm_dpr/features/dashboard/services/file_storage_service.dart';
// SharedPreferences for persistence
import 'package:shared_preferences/shared_preferences.dart';

class DataDokumenAnggotaPage extends ConsumerStatefulWidget {
  const DataDokumenAnggotaPage({super.key});

  @override
  ConsumerState<DataDokumenAnggotaPage> createState() =>
      _DataDokumenAnggotaPageState();
}

class _DataDokumenAnggotaPageState
    extends ConsumerState<DataDokumenAnggotaPage> {
  final Map<String, File?> _uploadedFiles = {};
  final Map<String, bool> _uploading = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, String> _fileSizes = {};
  final Map<String, String> _changeLogs = {};
  final TextEditingController _memberNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoadingData = false;
  
  // SQLite integration
  late final FileStorageService _fileStorageService;

  @override
  void initState() {
    super.initState();
    _fileStorageService = FileStorageService();
    
    // Load persisted data immediately when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersistedData();
    });
  }

  // Load persisted data from SharedPreferences and database
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMemberName = prefs.getString('last_member_name') ?? '';
      
      print('DEBUG: _loadPersistedData called');
      print('DEBUG: Found saved member name: "$savedMemberName"');
      
      if (savedMemberName.isNotEmpty) {
        setState(() {
          _memberNameController.text = savedMemberName;
        });
        
        print('DEBUG: Loading persisted member name: $savedMemberName');
        
        // Load documents from database
        await _loadSavedDocuments();
      } else {
        print('DEBUG: No saved member name found, checking for any existing data in database');
        // Even if no name is saved, try to load any existing data
        await _loadAllAvailableDocuments();
      }
    } catch (e) {
      print('DEBUG: Error loading persisted data: $e');
    }
  }

  // Load all available documents to check if there's any data
  Future<void> _loadAllAvailableDocuments() async {
    try {
      print('DEBUG: Checking for any available documents in database');
      // Get all documents from database to see if there's any data
      final allDocuments = await ref.read(dokumenAnggotaRepositoryProvider).getAllDokumenAnggota();
      
      print('DEBUG: Found ${allDocuments.length} total documents in database');
      
      if (allDocuments.isNotEmpty) {
        // Get the most recent member name
        final recentDoc = allDocuments.first;
        final memberName = recentDoc.namaAnggota;
        
        print('DEBUG: Found recent data for member: $memberName');
        
        setState(() {
          _memberNameController.text = memberName;
        });
        
        // Save this name to preferences and load documents
        await _saveMemberNameToPrefs(memberName);
        await _loadSavedDocuments();
      } else {
        print('DEBUG: No documents found in database');
      }
    } catch (e) {
      print('DEBUG: Error loading all available documents: $e');
    }
  }

  // Save member name to SharedPreferences
  Future<void> _saveMemberNameToPrefs(String memberName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_member_name', memberName);
      print('DEBUG: Saved member name to SharedPreferences: $memberName');
    } catch (e) {
      print('DEBUG: Error saving member name to SharedPreferences: $e');
    }
  }

  // Load saved documents from database
  Future<void> _loadSavedDocuments() async {
    final memberName = _memberNameController.text.trim();
    if (memberName.isNotEmpty) {
      setState(() {
        _isLoadingData = true;
      });
      
      try {
        print('DEBUG: Loading documents for member: $memberName');
        
        final documents = await ref.read(dokumenAnggotaRepositoryProvider).getDokumenAnggotaByNama(memberName);
        
        print('DEBUG: Found ${documents.length} documents in database');
        
        setState(() {
          // Clear existing data first
          _uploadedFiles.clear();
          _fileTypes.clear();
          _fileSizes.clear();
          _changeLogs.clear();
          
          // Update UI with saved documents
          for (final doc in documents) {
            print('DEBUG: Loading document: ${doc.documentId} - ${doc.documentTitle}');
            print('DEBUG: File path: ${doc.filePath}');
            
            if (doc.filePath.isNotEmpty) {
              // Try to load the file even if it doesn't exist physically
              // This maintains the record in UI
              _uploadedFiles[doc.documentId] = File(doc.filePath);
              _fileTypes[doc.documentId] = doc.fileType;
              _fileSizes[doc.documentId] = _formatFileSize(int.tryParse(doc.fileSize) ?? 0);
              _changeLogs[doc.documentId] = _formatDateTime(DateTime.tryParse(doc.uploadedAt) ?? DateTime.now());
              
              if (File(doc.filePath).existsSync()) {
                print('DEBUG: ✅ Successfully loaded document: ${doc.documentId}');
              } else {
                print('DEBUG: ⚠️ Document record loaded but physical file not found: ${doc.documentId} at path: ${doc.filePath}');
              }
            } else {
              print('DEBUG: ❌ Empty file path for document: ${doc.documentId}');
            }
          }
        });
        
        _updateFilledStatus();
        
        // Save current member name to preferences
        await _saveMemberNameToPrefs(memberName);
        
      } catch (e) {
        print('DEBUG: Error loading saved documents: $e');
      } finally {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.toLocal().toString().split('.')[0]} WIB';
  }



  // Verify that data was actually saved to database
  Future<void> _verifyDataSaved(String memberName, String documentId) async {
    try {
      print('DEBUG: Verifying data was saved...');
      
      final documents = await ref.read(dokumenAnggotaRepositoryProvider).getDokumenAnggotaByNama(memberName);
      print('DEBUG: Found ${documents.length} documents for $memberName in verification');
      
      final foundDoc = documents.where((doc) => doc.documentId == documentId).firstOrNull;
      if (foundDoc != null) {
        print('DEBUG: ✅ Document $documentId verified as saved');
        print('DEBUG: Saved file path: ${foundDoc.filePath}');
      } else {
        print('DEBUG: ❌ Document $documentId NOT found in database!');
      }

      // Also verify SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('last_member_name');
      print('DEBUG: SharedPreferences saved name: "$savedName"');
      
    } catch (e) {
      print('DEBUG: Error verifying saved data: $e');
    }
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
    DocumentItem(
      'pasfoto_tanpapecidankacamata',
      '[DASI] Pas Foto (Tanpa Peci/Kacamata)',
      true,
    ),
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
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // Validasi ukuran file (maksimal 5MB)
        if (platformFile.size > 5 * 1024 * 1024) {
          _showErrorDialog('Ukuran file terlalu besar. Maksimal 5 MB.');
          return;
        }

        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final extension = platformFile.extension?.toLowerCase() ?? '';

          // Validasi hanya PDF
          if (extension != 'pdf') {
            _showErrorDialog(
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
            _updateFilledStatus();
          });

          // Auto-save to database immediately after file selection
          if (_memberNameController.text.trim().isNotEmpty) {
            await _uploadFile(documentId);
          } else {
            _showSuccessDialog('File PDF berhasil dipilih: ${platformFile.name}\nMasukkan nama anggota untuk menyimpan ke database.');
          }
        } else {
          _showErrorDialog('Path file tidak valid.');
        }
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih file: ${e.toString()}');
    }
  }

  Future<void> _uploadFile(String documentId) async {
    if (_uploadedFiles[documentId] == null) {
      _showErrorDialog('Silakan pilih file PDF terlebih dahulu');
      return;
    }
    
    if (_memberNameController.text.trim().isEmpty) {
      _showErrorDialog('Nama anggota wajib diisi sebelum upload');
      return;
    }

    setState(() {
      _uploading[documentId] = true;
    });

    try {
      final file = _uploadedFiles[documentId]!;
      final memberName = _memberNameController.text.trim();
      final originalFileName = file.path.split('/').last;
      
      // Save file to organized storage
      final savedFile = await _fileStorageService.saveUploadedFile(
        sourceFile: file,
        namaAnggota: memberName,
        documentId: documentId,
        originalFileName: originalFileName,
      );
      
      // Create document model
      final document = DokumenAnggotaModel(
        id: null,
        namaAnggota: memberName,
        documentId: documentId,
        documentTitle: _documents.firstWhere((doc) => doc.id == documentId).title,
        filePath: savedFile.path,
        fileName: originalFileName,
        fileType: _fileTypes[documentId] ?? 'PDF',
        fileSize: file.lengthSync().toString(),
        isRequired: _documents.firstWhere((doc) => doc.id == documentId).isRequired,
        uploadedAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      // Check if document already exists for this member and documentId
      final existingDocs = await ref.read(dokumenAnggotaRepositoryProvider).getDokumenAnggotaByNama(memberName);
      final existingDoc = existingDocs.where((doc) => doc.documentId == documentId).firstOrNull;
      
      // Save to database
      print('DEBUG: About to save document to database...');
      print('DEBUG: Document data:');
      print('  - namaAnggota: ${document.namaAnggota}');
      print('  - documentId: ${document.documentId}');
      print('  - filePath: ${document.filePath}');
      
      if (existingDoc != null) {
        // Update existing document
        final updatedDocument = document.copyWith(id: existingDoc.id);
        await ref.read(dokumenAnggotaRepositoryProvider).updateDokumenAnggota(updatedDocument);
        print('DEBUG: Updated existing document with ID: ${existingDoc.id}');
      } else {
        // Add new document
        final savedId = await ref.read(dokumenAnggotaRepositoryProvider).addDokumenAnggota(document);
        print('DEBUG: Added new document with ID: $savedId');
      }

      final now = DateTime.now();
      setState(() {
        _changeLogs[documentId] = '${now.toLocal().toString().split('.')[0]} WIB';
        _updateFilledStatus();
      });

      // Save member name to preferences after successful upload
      await _saveMemberNameToPrefs(memberName);
      print('DEBUG: Member name saved to SharedPreferences: $memberName');

      // Verify data was saved by reading it back
      await _verifyDataSaved(memberName, documentId);
      
      // Refresh the UI to show updated data
      await _loadSavedDocuments();

      _showSuccessDialog('✅ File PDF berhasil disimpan ke database!\n📁 ${_documents.firstWhere((doc) => doc.id == documentId).title}');
    } catch (e) {
      _showErrorDialog('Gagal mengupload file: ${e.toString()}');
      print('DEBUG: Upload error: $e');
    } finally {
      setState(() {
        _uploading[documentId] = false;
      });
    }
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing && _memberNameController.text.trim().isEmpty) {
        _showErrorDialog('Nama anggota wajib diisi.');
        return;
      }

      try {
        final memberName = _memberNameController.text.trim();
        
        print('DEBUG: Starting save process for member: $memberName');
        print('DEBUG: Number of uploaded files to save: ${_uploadedFiles.length}');
        
        // First, delete existing documents for this member to prevent duplicates
        final existingDocs = await ref.read(dokumenAnggotaRepositoryProvider).getDokumenAnggotaByNama(memberName);
        print('DEBUG: Found ${existingDocs.length} existing documents to update');
        
        for (final existingDoc in existingDocs) {
          await ref.read(dokumenAnggotaRepositoryProvider).deleteDokumenAnggota(existingDoc.id!);
          print('DEBUG: Deleted existing document: ${existingDoc.documentId}');
        }
        
        // Save all current documents to database
        for (final entry in _uploadedFiles.entries) {
          final documentId = entry.key;
          final file = entry.value;
          
          if (file != null) {
            // Get original filename
            final originalFileName = file.path.split('/').last;
            
            // Save file to organized storage
            final savedFile = await _fileStorageService.saveUploadedFile(
              sourceFile: file,
              namaAnggota: memberName,
              documentId: documentId,
              originalFileName: originalFileName,
            );
            
            // Create document model
            final document = DokumenAnggotaModel(
              id: null, // Auto-increment
              namaAnggota: memberName,
              documentId: documentId,
              documentTitle: _documents.firstWhere((doc) => doc.id == documentId).title,
              filePath: savedFile.path,
              fileName: originalFileName,
              fileType: _fileTypes[documentId] ?? 'PDF',
              fileSize: file.lengthSync().toString(),
              isRequired: _documents.firstWhere((doc) => doc.id == documentId).isRequired,
              uploadedAt: DateTime.now().toIso8601String(),
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
            
            // Save to database
            final savedId = await ref.read(dokumenAnggotaRepositoryProvider).addDokumenAnggota(document);
            
            print('DEBUG: Saved document $documentId for member $memberName with ID: $savedId');
          }
        }

        final isFilled = _isAllRequiredFilled();
        ref.read(dataDokumenAnggotaFilledProvider.notifier).state = isFilled;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Dokumen Anggota',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text('Data dokumen anggota berhasil disimpan ke database.'),
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

        // Save member name to SharedPreferences
        await _saveMemberNameToPrefs(memberName);
        
        // Reset editing mode after save
        setState(() {
          _isEditing = false;
        });

        // Reload data to show updated information
        await _loadSavedDocuments();
        
        print('DEBUG: Data saved successfully and reloaded');

        if (context.mounted) {
          context.go(
            '/home',
            extra: {
              'justSaved': true,
              'sourcePage': '/data-dokumen-anggota',
              'memberName': memberName,
              'uploadedDocuments': _uploadedFiles.length,
            },
          );
        }
      } catch (e) {
        _showErrorDialog('Gagal menyimpan data: ${e.toString()}');
        print('DEBUG: Error saving data: $e');
      }
    }
  }

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataDokumenAnggotaFilledProvider.notifier).state = isFilled;
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



  // Show debug information
  Future<void> _showDebugInfo() async {
    try {
      print('DEBUG: ========== DEBUG INFO START ==========');
      
      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('last_member_name') ?? '';
      print('DEBUG: SharedPreferences saved name: "$savedName"');
      
      // Check all documents in database
      final allDocs = await ref.read(dokumenAnggotaRepositoryProvider).getAllDokumenAnggota();
      print('DEBUG: Total documents in database: ${allDocs.length}');
      
      for (final doc in allDocs) {
        print('DEBUG: Document - ${doc.namaAnggota}: ${doc.documentId} (${doc.documentTitle})');
        print('DEBUG:   File path: ${doc.filePath}');
        print('DEBUG:   File exists: ${File(doc.filePath).existsSync()}');
      }
      
      // Check current UI state
      print('DEBUG: Current member name in UI: "${_memberNameController.text}"');
      print('DEBUG: Current uploaded files count: ${_uploadedFiles.length}');
      print('DEBUG: Is editing: $_isEditing');
      print('DEBUG: Is loading data: $_isLoadingData');
      
      print('DEBUG: ========== DEBUG INFO END ==========');
      
      // Show dialog with info
      final theme = ref.read(themeProvider);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Debug Information',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SharedPreferences: "$savedName"'),
                const SizedBox(height: 8),
                Text('Database docs: ${allDocs.length}'),
                const SizedBox(height: 8),
                Text('UI files: ${_uploadedFiles.length}'),
                const SizedBox(height: 8),
                Text('Member name: "${_memberNameController.text}"'),
                const SizedBox(height: 8),
                const Text('Check console for detailed logs'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('DEBUG: Error showing debug info: $e');
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
        title: 'Data Dokumen Anggota',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('DEBUG: Manual refresh triggered');
              await _loadSavedDocuments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil di-refresh'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
            tooltip: 'Debug Info',
          ),
        ],
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
              // Data persistence status banner
              if (_uploadedFiles.isNotEmpty && !_isLoadingData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[100]!, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Tersimpan',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ditemukan ${_uploadedFiles.length} dokumen untuk ${_memberNameController.text.trim()}',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Info Section with SIHAKI component
              SIHAKIDataCard(
                title: 'Informasi Penting',
                subtitle: 'Petunjuk Upload Dokumen Anggota',
                leadingIcon: Icons.info_outline,
                statusColor: Colors.blue[600],
                statusText: 'Panduan',
                fields: [
                  SIHAKIDataField(label: 'Format File', value: 'PDF'),
                  SIHAKIDataField(
                    label: 'Ukuran Maksimal',
                    value: '5 MB per file',
                  ),
                  SIHAKIDataField(
                    label: 'Keterangan',
                    value:
                        'Dokumen dapat diunggah untuk keperluan administrasi resmi. Pastikan dokumen telah disetujui oleh Bagian Tata Persuratan.',
                    isLast: true,
                  ),
                ],
                actions: [],
                isTablet: isTablet,
              ),
              const SizedBox(height: 20),

              AppFormCard(
                title: 'Data Pribadi Anggota',
                titleIcon: Icons.person_outline,
                fields: [
                  FormFieldConfig(
                    label: 'Nama Anggota',
                    icon: Icons.person,
                    controller: _memberNameController,
                    hintText: 'Masukkan nama lengkap anggota',
                    type: _isEditing ? FormFieldType.textRequired : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Nama anggota wajib diisi';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Save name to preferences immediately when changed
                      if (value != null && value.trim().isNotEmpty) {
                        _saveMemberNameToPrefs(value.trim());
                      }
                      
                      // Don't auto-load when in editing mode to prevent data loss
                      if (!_isEditing && value != null && value.trim().isNotEmpty) {
                        print('DEBUG: Name changed to: "$value", loading documents...');
                        // Add a small delay to prevent too frequent database calls
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (_memberNameController.text.trim() == value.trim() && mounted) {
                            _loadSavedDocuments();
                          }
                        });
                      } else if (_isEditing) {
                        print('DEBUG: In editing mode, not auto-loading to prevent data loss');
                      }
                    },
                    isLast: true,
                  ),
                ],
                showSaveButton: false,
              ),
              const SizedBox(height: 20),

              // Document Section with modern card
              SIHAKIDataCard(
                title: _isLoadingData ? 'Loading Data Dokumen...' : 'Data Dokumen Anggota',
                subtitle:
                    _memberNameController.text.trim().isNotEmpty
                        ? 'Anggota: ${_memberNameController.text.trim()}'
                        : 'Upload dokumen yang diperlukan',
                leadingIcon: _isLoadingData ? Icons.sync : Icons.file_upload,
                statusColor:
                    _isAllRequiredFilled()
                        ? Colors.green[600]
                        : Colors.orange[600],
                statusText:
                    _isLoadingData 
                        ? 'Loading...'
                        : _isAllRequiredFilled() ? 'Lengkap' : 'Belum Lengkap',
                fields: [
                  SIHAKIDataField(
                    label: 'Total Dokumen',
                    value: '${_documents.length} dokumen',
                  ),
                  SIHAKIDataField(
                    label: 'Dokumen Wajib',
                    value:
                        '${_documents.where((doc) => doc.isRequired).length} dokumen',
                  ),
                  SIHAKIDataField(
                    label: 'Sudah Upload',
                    value: '${_uploadedFiles.length} dokumen',
                  ),
                  if (_uploadedFiles.isNotEmpty) 
                    SIHAKIDataField(
                      label: 'Terakhir Upload',
                      value: _changeLogs.values.isNotEmpty 
                          ? _changeLogs.values.last 
                          : 'Belum ada upload',
                      isLast: true,
                    )
                  else
                    SIHAKIDataField(
                      label: 'Status',
                      value: _memberNameController.text.trim().isNotEmpty
                          ? 'Siap untuk upload'
                          : 'Masukkan nama anggota terlebih dahulu',
                      isLast: true,
                    ),
                ],
                actions: [],
                isTablet: isTablet,
              ),
              const SizedBox(height: 16),

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
                    // Header
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

                    // Document List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documents.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final document = _documents[index];
                        return _buildModernDocumentItem(
                          theme,
                          document,
                          isTablet,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tombol EDIT dan SIMPAN
              Column(
                children: [
                  if (!_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                          print('DEBUG: Entered editing mode, auto-loading disabled');
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
                  ],
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                _isEditing = false;
                              });
                              // Reload original data
                              await _loadSavedDocuments();
                              print('DEBUG: Cancelled editing, reloaded original data');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'BATAL',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
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
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDocumentItem(
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
          // Document Header
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

          // Upload Actions
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
                                    'SAVE TO DB',
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

          // File Details
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
