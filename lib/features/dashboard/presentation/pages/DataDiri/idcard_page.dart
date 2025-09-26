import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';

class IdCardPage extends ConsumerStatefulWidget {
  const IdCardPage({super.key});

  @override
  ConsumerState<IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends ConsumerState<IdCardPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Backup data for unsaved changes detection
  Map<String, dynamic> _originalData = {};
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dataLoaded) {
      // Load data from provider when page is loaded
      final savedData = ref.read(idCardDataProvider);

      // Only set data if not already set and data exists
      if (_selectedImage == null && savedData.fotoPath.isNotEmpty) {
        final File savedFile = File(savedData.fotoPath);
        if (_isValidImageFile(savedFile)) {
          _selectedImage = savedFile;
          print('Loaded valid image from provider: ${savedData.fotoPath}');
        } else {
          print('Saved image path is invalid, clearing: ${savedData.fotoPath}');
          // Clear invalid path from provider
          ref
              .read(idCardDataProvider.notifier)
              .updateData(IdCardData(fotoPath: '', isUploaded: false));
        }
      }

      // Backup original data for change detection
      _originalData = _getCurrentData();
      _dataLoaded = true;

      print('=== ID CARD PAGE LOADED ===');
      print('Original data backed up: $_originalData');
    }
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'fotoPath': _selectedImage?.path ?? '',
      'isUploaded':
          _selectedImage != null && _isValidImageFile(_selectedImage!),
    };
  }

  bool _isValidImageFile(File file) {
    try {
      // Check if file exists and is readable
      if (!file.existsSync()) {
        print('File does not exist: ${file.path}');
        return false;
      }

      // Check file extension
      final String extension = file.path.toLowerCase();
      if (!extension.endsWith('.jpg') &&
          !extension.endsWith('.jpeg') &&
          !extension.endsWith('.png')) {
        print('Invalid file extension: $extension');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    bool hasChanges = false;

    print('=== CHECKING FOR UNSAVED CHANGES ===');
    print('Original: $_originalData');
    print('Current: $currentData');

    // Check foto path
    if (_originalData['fotoPath'] != currentData['fotoPath']) {
      print(
        'Foto path changed: ${_originalData['fotoPath']} -> ${currentData['fotoPath']}',
      );
      hasChanges = true;
    }

    // Check upload status
    if (_originalData['isUploaded'] != currentData['isUploaded']) {
      print(
        'Upload status changed: ${_originalData['isUploaded']} -> ${currentData['isUploaded']}',
      );
      hasChanges = true;
    }

    print('Has unsaved changes: $hasChanges');
    return hasChanges;
  }

  void _restoreOriginalData() {
    print('=== RESTORING ORIGINAL DATA ===');
    if (_originalData['fotoPath'].isNotEmpty) {
      final File potentialFile = File(_originalData['fotoPath']);
      if (_isValidImageFile(potentialFile)) {
        _selectedImage = potentialFile;
      } else {
        print('Original file is not valid, clearing selection');
        _selectedImage = null;
      }
    } else {
      _selectedImage = null;
    }
    setState(() {});
    print('Data restored successfully');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Validate file first
        if (!_isValidImageFile(imageFile)) {
          _showErrorDialog(
            'File yang dipilih tidak valid atau rusak. Silakan pilih file gambar lain.',
          );
          return;
        }

        final int fileSizeInBytes = await imageFile.length();
        final double fileSizeInKB = fileSizeInBytes / 1024;

        // Check file size (must be above 500 KB)
        if (fileSizeInKB < 500) {
          _showErrorDialog(
            'Ukuran file harus di atas 500 KB. Ukuran file saat ini: ${fileSizeInKB.toStringAsFixed(2)} KB',
          );
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_hasUnsavedChanges()) {
          print('=== UNSAVED CHANGES DETECTED ON BACK ===');
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave == true && context.mounted) {
            Navigator.pop(context, false);
          }
        } else {
          print('=== NO UNSAVED CHANGES, SAFE TO LEAVE ===');
          if (context.mounted) {
            Navigator.pop(context, false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'ID Card',
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
            onPressed: () async {
              if (_hasUnsavedChanges()) {
                print('=== UNSAVED CHANGES DETECTED ON BACK BUTTON ===');
                final shouldLeave = await _showUnsavedChangesDialog();
                if (shouldLeave == true && context.mounted) {
                  Navigator.pop(context, false);
                }
              } else {
                print('=== NO UNSAVED CHANGES, SAFE TO LEAVE ===');
                Navigator.pop(context, false);
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
            children: [_buildIdCardForm(theme)],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Perubahan Belum Disimpan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            content: Text(
              'Anda memiliki perubahan yang belum disimpan. Apa yang ingin Anda lakukan?',
              style: theme.typographyRegular.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
              ),
              TextButton(
                onPressed: () {
                  _restoreOriginalData();
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Buang Perubahan',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  _saveData(context, theme);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Widget _buildIdCardForm(dynamic theme) {
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
                  Icons.credit_card,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ID Card',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Photo Section
          _buildCurrentPhotoSection(theme),
          const SizedBox(height: 24),

          // Photo Requirements
          _buildPhotoRequirements(theme),
          const SizedBox(height: 24),

          // Upload Section
          _buildUploadSection(theme),
        ],
      ),
    );
  }

  Widget _buildCurrentPhotoSection(dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Saat Ini untuk "Airlangga Eka Wardhana, S.Kom, M.T.I"',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foto ini akan digunakan untuk foto pada ID Card TA/SA/Staffsus Anda!',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Photo Display
        Center(
          child: Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child:
                _selectedImage != null && _isValidImageFile(_selectedImage!)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          // Clear invalid image
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedImage = null;
                            });
                          });
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error,
                                size: 80,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal Memuat Gambar',
                                style: theme.typographyRegular.bodySmall
                                    .copyWith(color: Colors.red[500]),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Foto Belum Tersedia',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoRequirements(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Ketentuan Pas Foto',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildRequirementItem(
            theme,
            'Pakaian dan Sikap Formal untuk Pas Foto Resmi',
            Icons.checkroom,
          ),
          _buildRequirementItem(
            theme,
            'Format file harus JPG/JPEG',
            Icons.image,
          ),
          _buildRequirementItem(
            theme,
            'Ukuran file harus diatas 500 KB',
            Icons.storage,
          ),
          _buildRequirementItem(
            theme,
            'Latar belakang warna Putih',
            Icons.palette,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    dynamic theme,
    String text,
    IconData icon, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Foto Baru',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        // Browse Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.folder_open),
            label: Text(
              _selectedImage != null ? 'Ganti Foto...' : 'Pilih Foto...',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primarySwatch,
              side: BorderSide(color: theme.primarySwatch),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _isValidImageFile(_selectedImage!)
                      ? Colors.green[50]
                      : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _isValidImageFile(_selectedImage!)
                        ? Colors.green[200]!
                        : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isValidImageFile(_selectedImage!)
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      _isValidImageFile(_selectedImage!)
                          ? Colors.green[600]
                          : Colors.red[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isValidImageFile(_selectedImage!)
                        ? 'Foto dipilih: ${_selectedImage!.path.split('/').last}'
                        : 'File tidak valid atau rusak: ${_selectedImage!.path.split('/').last}',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color:
                          _isValidImageFile(_selectedImage!)
                              ? Colors.green[700]
                              : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              print('=== SAVE BUTTON CLICKED ===');
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
              'UPLOAD',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveData(BuildContext context, dynamic theme) {
    print('=== CALLING _saveData ===');

    // Validate image before saving
    String validatedPath = '';
    bool isValidImage = false;

    if (_selectedImage != null) {
      if (_isValidImageFile(_selectedImage!)) {
        validatedPath = _selectedImage!.path;
        isValidImage = true;
        print('Image is valid: $validatedPath');
      } else {
        print('Image is invalid, not saving path');
        // Clear invalid image
        setState(() {
          _selectedImage = null;
        });
      }
    }

    // Save data to provider
    final idCardData = IdCardData(
      fotoPath: validatedPath,
      isUploaded: isValidImage,
    );

    ref.read(idCardDataProvider.notifier).updateData(idCardData);

    print('=== SAVED ID CARD DATA ===');
    print('Foto Path: ${idCardData.fotoPath}');
    print('Is Uploaded: ${idCardData.isUploaded}');
    print('==========================');

    // Show immediate feedback with SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Data ID Card berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('=== SHOWING SUCCESS DIALOG ===');
    // Show success dialog with delay to ensure SnackBar is visible first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && context.mounted) {
        NotificationUtils.showSuccessDialog(
          context,
          title: 'Simpan Data ID Card',
          message: 'Data ID Card berhasil disimpan.',
          onPressed: () {
            print('=== SUCCESS DIALOG BUTTON PRESSED ===');

            // Update original data to clear unsaved changes flag
            _originalData = _getCurrentData();

            // Safe navigation back to previous page
            if (Navigator.canPop(context)) {
              print('Using Navigator.pop');
              Navigator.pop(context, 'saved');
            } else {
              print('Using context.go');
              context.go('/profile-sections');
            }
          },
        );
        print('=== SUCCESS DIALOG COMPLETED ===');
      } else {
        print('=== CONTEXT NOT MOUNTED, SKIPPING DIALOG ===');
      }
    });
  }
}
