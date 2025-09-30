import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'providers/profile_data_provider.dart';

class IdCardPage extends ConsumerStatefulWidget {
  const IdCardPage({super.key});

  @override
  ConsumerState<IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends ConsumerState<IdCardPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
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
        } else {
          // Clear invalid path from provider
          ref.read(idCardDataProvider.notifier).updateData(
            IdCardData(fotoPath: '', isUploaded: false)
          );
        }
      }
      
      // Backup original data for change detection
      _originalData = _getCurrentData();
      _dataLoaded = true;
    }
  }
  
  Map<String, dynamic> _getCurrentData() {
    return {
      'fotoPath': _selectedImage?.path ?? '',
      'isUploaded': _selectedImage != null && _isValidImageFile(_selectedImage!),
    };
  }
  
  bool _isValidImageFile(File file) {
    try {
      // Check if file exists and is readable
      if (!file.existsSync()) {
        return false;
      }
      
      // Check file extension
      final String extension = file.path.toLowerCase();
      if (!extension.endsWith('.jpg') && 
          !extension.endsWith('.jpeg') && 
          !extension.endsWith('.png')) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    return _originalData['fotoPath'] != currentData['fotoPath'] ||
           _originalData['isUploaded'] != currentData['isUploaded'];
  }
  
  void _restoreOriginalData() {
    if (_originalData['fotoPath'].isNotEmpty) {
      final File potentialFile = File(_originalData['fotoPath']);
      if (_isValidImageFile(potentialFile)) {
        _selectedImage = potentialFile;
      } else {
        _selectedImage = null;
      }
    } else {
      _selectedImage = null;
    }
    setState(() {});
  }

 Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        
        if (!_isValidImageFile(imageFile)) {
          ErrorUploadDialogCard.show(
            context,
            title: 'File Tidak Valid',
            message: 'File yang dipilih tidak valid atau rusak. Silakan pilih file gambar lain.',
            onConfirm: () {
            },
          );
          return;
        }
        
        final int fileSizeInBytes = await imageFile.length();
        final double fileSizeInKB = fileSizeInBytes / 1024;

        if (fileSizeInKB < 500) {
          ErrorUploadDialogCard.show(
            context,
            title: 'Ukuran File Tidak Memenuhi Syarat',
            message: 'Ukuran file harus di atas 500 KB.\nUkuran file saat ini: ${fileSizeInKB.toStringAsFixed(2)} KB',
            onConfirm: () {
            },
          );
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      ErrorUploadDialogCard.show(
        context,
        title: 'Gagal Memilih Gambar',
        message: 'Terjadi kesalahan saat memilih gambar: $e',
        onConfirm: () {
        },
      );
    }
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
          final shouldLeave = await _showUnsavedChangesDialog(context, theme);
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else {
          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'ID Card',
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
              _buildIdCardForm(theme),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final result = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan ID Card', 
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600], 
      isDestructive: true, 
      onConfirm: () {
        _restoreOriginalData();
        if (context.mounted) {
          notification.NotificationUtils.showWarning(
            context,
            'Perubahan pada ID Card telah dibatalkan',
          );
        }
      },
    );
    return result ?? false;
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

          _buildCurrentPhotoSection(theme),
          const SizedBox(height: 24),

          _buildPhotoRequirements(theme),
          const SizedBox(height: 24),

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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedImage = null;
                            });
                          });
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 80, color: Colors.red[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal Memuat Gambar',
                                style: theme.typographyRegular.bodySmall.copyWith(
                                  color: Colors.red[500],
                                ),
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
              color: _isValidImageFile(_selectedImage!) ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isValidImageFile(_selectedImage!) ? Colors.green[200]! : Colors.red[200]!
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isValidImageFile(_selectedImage!) ? Icons.check_circle : Icons.error,
                  color: _isValidImageFile(_selectedImage!) ? Colors.green[600] : Colors.red[600],
                  size: 20
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isValidImageFile(_selectedImage!) 
                      ? 'Foto dipilih: ${_selectedImage!.path.split('/').last}'
                      : 'File tidak valid atau rusak: ${_selectedImage!.path.split('/').last}',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: _isValidImageFile(_selectedImage!) ? Colors.green[700] : Colors.red[700],
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
    // Validate image before saving
    String validatedPath = '';
    bool isValidImage = false;
    
    if (_selectedImage != null) {
      if (_isValidImageFile(_selectedImage!)) {
        validatedPath = _selectedImage!.path;
        isValidImage = true;
      } else {
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

    // Show immediate feedback with SnackBar
    notification.NotificationUtils.showSuccess(
      context,
      'Data ID Card telah disimpan',
    );

    // Show success dialog with delay to ensure SnackBar is visible first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && context.mounted) {
        ProfileCompletionNotifierCard.show(
          context,
          title: 'Berhasil Menyimpan ID Card',
          message: 'Data ID Card Anda telah diperbarui dan tersimpan dengan sukses.',
          onConfirm: () {
            // Update original data to clear unsaved changes flag
            _originalData = _getCurrentData();
            
            // Safe navigation back to previous page
            if (Navigator.canPop(context)) {
              Navigator.pop(context, 'saved');
            } else {
              context.go('/profile-sections');
            }
          },
        );
      }
    });
  }
}