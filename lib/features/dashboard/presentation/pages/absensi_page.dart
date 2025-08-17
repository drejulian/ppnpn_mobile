import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'dart:io';

import 'package:ppnpm_dpr/app/theme.dart';

// Providers
final selectedImageProvider = StateProvider<File?>((ref) => null);
final currentLocationProvider = StateProvider<Position?>((ref) => null);
final isLoadingLocationProvider = StateProvider<bool>((ref) => false);
final absensiTypeProvider = StateProvider<String>(
  (ref) => 'checkin',
); // checkin/checkout

class AbsensiPage extends ConsumerWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                // Status Card
                _buildStatusCard(theme, ref),
                const SizedBox(height: 24),

                // Absensi Form
                _buildAbsensiForm(theme, ref, context),
                const SizedBox(height: 24),

                // Riwayat Absensi
                _buildRiwayatAbsensi(theme, context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic theme, WidgetRef ref) {
    final now = DateTime.now();
    final currentLocation = ref.watch(currentLocationProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primarySwatch, theme.secondarySwatch],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Status Absensi Hari Ini',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now),
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Check In',
                  '08:15',
                  'Tepat Waktu',
                  Icons.login,
                  Colors.green,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusItem(
                  'Check Out',
                  '--:--',
                  'Belum Absen',
                  Icons.logout,
                  Colors.orange,
                  theme,
                ),
              ),
            ],
          ),
          if (currentLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lokasi: ${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String time,
    String status,
    IconData icon,
    Color statusColor,
    dynamic theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: theme.typographyRegular.bodyExtraSmall.copyWith(
                color: Colors.white,
                fontSize: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiForm(dynamic theme, WidgetRef ref, BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final isLoadingLocation = ref.watch(isLoadingLocationProvider);
    final absensiType = ref.watch(absensiTypeProvider);

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
          Text(
            'Form Absensi',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Pilih Jenis Absensi
          Row(
            children: [
              Expanded(
                child: _buildAbsensiTypeButton(
                  'Check In',
                  'checkin',
                  Icons.login,
                  theme,
                  ref,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAbsensiTypeButton(
                  'Check Out',
                  'checkout',
                  Icons.logout,
                  theme,
                  ref,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Upload Foto
          Text(
            'Foto Selfie',
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildPhotoSection(selectedImage, theme, ref, context),
          const SizedBox(height: 20),

          // Lokasi
          Text(
            'Lokasi',
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildLocationSection(currentLocation, isLoadingLocation, theme, ref),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedImage != null && currentLocation != null
                      ? () => _submitAbsensi(ref, context)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                absensiType == 'checkin'
                    ? 'Check In Sekarang'
                    : 'Check Out Sekarang',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiTypeButton(
    String title,
    String type,
    IconData icon,
    dynamic theme,
    WidgetRef ref,
  ) {
    final selectedType = ref.watch(absensiTypeProvider);
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () {
        ref.read(absensiTypeProvider.notifier).state = type;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.primarySwatch.withOpacity(0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primarySwatch : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primarySwatch : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? theme.primarySwatch : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(
    File? selectedImage,
    dynamic theme,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child:
          selectedImage != null
              ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedImageProvider.notifier).state = null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Ambil Foto Selfie',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPhotoButton(
                        'Kamera',
                        Icons.camera_alt,
                        () => _pickImage(ImageSource.camera, ref),
                        theme,
                      ),
                      const SizedBox(width: 12),
                      _buildPhotoButton(
                        'Galeri',
                        Icons.photo_library,
                        () => _pickImage(ImageSource.gallery, ref),
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildPhotoButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    dynamic theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.primarySwatch.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.primarySwatch.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primarySwatch, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: theme.primarySwatch,
                fontWeight: FontWeight.w500,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(
    Position? currentLocation,
    bool isLoading,
    dynamic theme,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          if (isLoading)
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primarySwatch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mendapatkan lokasi...',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          else if (currentLocation != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lokasi Berhasil Didapatkan',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lat: ${currentLocation.latitude.toStringAsFixed(6)}',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Lng: ${currentLocation.longitude.toStringAsFixed(6)}',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Akurasi: ${currentLocation.accuracy.toStringAsFixed(1)}m',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(Icons.location_off, color: Colors.grey[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  'Lokasi belum didapatkan',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _getCurrentLocation(ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location, size: 16),
                      const SizedBox(width: 6),
                      Text('Dapatkan Lokasi', style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatAbsensi(dynamic theme, BuildContext context) {
    final riwayatData = _generateRiwayatData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Absensi (12 Bulan Terakhir)',
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
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                riwayatData.map((data) {
                  return _buildRiwayatItem(data, theme);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatItem(Map<String, dynamic> data, dynamic theme) {
    final percentage = data['percentage'] as double;
    final month = data['month'] as String;
    final present = data['present'] as int;
    final total = data['total'] as int;

    Color getPercentageColor(double percentage) {
      if (percentage >= 90) return Colors.green;
      if (percentage >= 75) return Colors.orange;
      return Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getPercentageColor(percentage).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: getPercentageColor(percentage),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    getPercentageColor(percentage),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$present/$total hari',
                style: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateRiwayatData() {
    final now = DateTime.now();
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMMM yyyy', 'id_ID').format(month);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final workingDays = daysInMonth - 8; // Assume 8 weekend days
      final presentDays = workingDays - (i * 2); // Mock absent days
      final percentage = (presentDays / workingDays) * 100;

      data.add({
        'month': monthName,
        'present': presentDays,
        'total': workingDays,
        'percentage': percentage.clamp(0, 100),
      });
    }

    return data;
  }

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(selectedImageProvider.notifier).state = File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _getCurrentLocation(WidgetRef ref) async {
    try {
      ref.read(isLoadingLocationProvider.notifier).state = true;

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      ref.read(currentLocationProvider.notifier).state = position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Show error dialog or snackbar
    } finally {
      ref.read(isLoadingLocationProvider.notifier).state = false;
    }
  }

  void _submitAbsensi(WidgetRef ref, BuildContext context) {
    final selectedImage = ref.read(selectedImageProvider);
    final currentLocation = ref.read(currentLocationProvider);
    final absensiType = ref.read(absensiTypeProvider);

    try {
      // Here you would typically send the data to your backend
      debugPrint('Submitting absensi:');
      debugPrint('Type: $absensiType');
      debugPrint('Image: ${selectedImage?.path}');
      debugPrint(
        'Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}',
      );
      debugPrint('Time: ${DateTime.now()}');
      debugPrint('User: miftahul01');

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Berhasil!'),
              content: Text('$absensiType berhasil disimpan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    try {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context); // Go back to previous page
                      } else {
                        context.goNamed(Routes.home.name); // Fallback to home
                      }
                    } catch (e) {
                      debugPrint('Dialog navigation error: $e');
                      context.goNamed(Routes.home.name);
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      // Reset form
      ref.read(selectedImageProvider.notifier).state = null;
      ref.read(currentLocationProvider.notifier).state = null;
    } catch (e) {
      debugPrint('Submit absensi error: $e');
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Terjadi kesalahan saat menyimpan absensi.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}
