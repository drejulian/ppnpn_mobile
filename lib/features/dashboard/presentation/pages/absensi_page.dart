import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

const double OFFICE_LATITUDE = -6.208983491481962;
const double OFFICE_LONGITUDE = 106.79966809090786;
const double OFFICE_RADIUS_METERS = 5000.0;

final selectedImageProvider = StateProvider<dynamic>((ref) => null);
final selectedImageBytesProvider = StateProvider<Uint8List?>((ref) => null);
final currentLocationProvider = StateProvider<Position?>((ref) => null);
final isLoadingLocationProvider = StateProvider<bool>((ref) => false);
final absensiTypeProvider = StateProvider<String>((ref) => 'checkin');

class AbsensiData {
  final String type;
  final DateTime time;
  final Position location;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String status;

  AbsensiData({
    required this.type,
    required this.time,
    required this.location,
    this.imagePath,
    this.imageBytes,
    required this.status,
  });
}

final absensiDataProvider = StateProvider<Map<String, AbsensiData?>>(
  (ref) => {'checkin': null, 'checkout': null},
);

double calculateDistanceFromOffice(Position currentPosition) {
  return Geolocator.distanceBetween(
    OFFICE_LATITUDE,
    OFFICE_LONGITUDE,
    currentPosition.latitude,
    currentPosition.longitude,
  );
}

bool isWithinOfficeRadius(Position currentPosition) {
  final distance = calculateDistanceFromOffice(currentPosition);
  return distance <= OFFICE_RADIUS_METERS;
}

String getLocationStatus(Position currentPosition) {
  final distance = calculateDistanceFromOffice(currentPosition);
  if (distance <= OFFICE_RADIUS_METERS) {
    return 'Di Area Kantor (${(distance / 100).toStringAsFixed(1)} dari pusat)';
  } else {
    final hectares = distance / 100;
    return 'Di Luar Area Kantor (${hectares.toStringAsFixed(1)} dari kantor)';
  }
}

class AbsensiPage extends ConsumerWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initializeDateFormatting('id_ID', null);

    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                AppCard(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primarySwatch,
                      theme.primarySwatch.withValues(alpha: 0.8),
                      theme.secondarySwatch,
                    ],
                  ),
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: _buildStatusCard(theme, ref),
                ),
                const SizedBox(height: 20),
                AppCard(
                  radius: 20,
                  padding: const EdgeInsets.all(16),
                  child: _buildAbsensiForm(theme, ref, context),
                ),
                const SizedBox(height: 20),
                AppCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: _buildRiwayatAbsensi(theme, context),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic theme) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primarySwatch, theme.secondarySwatch],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.access_time_filled,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sistem Absensi',
                    style: theme.typographyRegular.headingSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now),
                    style: theme.typographyRegular.bodyLarge.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getTimeStatusColor(now).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTimeStatusColor(now).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                DateFormat('HH:mm').format(now),
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getTimeStatusColor(now),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTimeStatusIndicator(theme, now),
      ],
    );
  }

  Color _getTimeStatusColor(DateTime time) {
    final hour = time.hour;
    if (hour < 8) {
      return const Color(0xFF10B981);
    } else if (hour == 8 && time.minute <= 30) {
      return const Color(0xFF3B82F6);
    } else {
      return const Color(0xFFF59E0B);
    }
  }

  Widget _buildTimeStatusIndicator(dynamic theme, DateTime now) {
    final hour = now.hour;
    final minute = now.minute;
    String status;
    String description;
    IconData icon;
    Color statusColor = _getTimeStatusColor(now);

    if (hour < 8) {
      status = 'Waktu Ideal';
      description = 'Anda masih memiliki waktu untuk bersiap-siap';
      icon = Icons.schedule;
    } else if (hour == 8 && minute <= 30) {
      status = 'Tepat Waktu';
      description = 'Waktu yang tepat untuk melakukan absensi masuk';
      icon = Icons.check_circle_outline;
    } else {
      status = 'Terlambat';
      description = 'Anda terlambat dari jadwal masuk pukul 08:00';
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(dynamic theme, WidgetRef ref) {
    final now = DateTime.now();
    final currentLocation = ref.watch(currentLocationProvider);
    final absensiData = ref.watch(absensiDataProvider);
    final checkinData = absensiData['checkin'];
    final checkoutData = absensiData['checkout'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(Icons.today, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Absensi Hari Ini',
                    style: theme.typographyRegular.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now),
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildStatusItem(
                'Check In',
                checkinData != null
                    ? DateFormat('HH:mm').format(checkinData.time)
                    : '--:--',
                checkinData?.status ?? 'Belum Absen',
                Icons.login,
                checkinData != null ? Colors.green : Colors.orange,
                theme,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatusItem(
                'Check Out',
                checkoutData != null
                    ? DateFormat('HH:mm').format(checkoutData.time)
                    : '--:--',
                checkoutData?.status ?? 'Belum Absen',
                Icons.logout,
                checkoutData != null ? Colors.green : Colors.orange,
                theme,
              ),
            ),
          ],
        ),
        if (currentLocation != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Terdeteksi',
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}',
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        'Akurasi: ${currentLocation.accuracy.toStringAsFixed(1)}m',
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            time,
            style: theme.typographyRegular.headingSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: theme.typographyRegular.bodyExtraSmall.copyWith(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiForm(dynamic theme, WidgetRef ref, BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    final selectedImageBytes = ref.watch(selectedImageBytesProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final isLoadingLocation = ref.watch(isLoadingLocationProvider);
    final absensiType = ref.watch(absensiTypeProvider);
    final absensiData = ref.watch(absensiDataProvider);

    final hasImage =
        (kIsWeb && selectedImageBytes != null) ||
        (!kIsWeb && selectedImage != null);

    final canCheckIn =
        absensiType == 'checkin' && absensiData['checkin'] == null;
    final canCheckOut =
        absensiType == 'checkout' &&
        absensiData['checkin'] != null &&
        absensiData['checkout'] == null;
    final canSubmit =
        (canCheckIn || canCheckOut) &&
        hasImage &&
        currentLocation != null &&
        isWithinOfficeRadius(currentLocation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primarySwatch.withValues(alpha: 0.1),
                    theme.secondarySwatch.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.edit_calendar,
                color: theme.primarySwatch,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Form Absensi',
              style: theme.typographyRegular.headingSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Jenis Absensi',
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildAbsensiTypeButton(
                'Check In',
                'checkin',
                Icons.login,
                theme,
                ref,
                absensiData['checkin'] != null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAbsensiTypeButton(
                'Check Out',
                'checkout',
                Icons.logout,
                theme,
                ref,
                absensiData['checkin'] == null ||
                    absensiData['checkout'] != null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Upload Foto
        Text(
          'Foto Selfie',
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        _buildPhotoSection(selectedImage, theme, ref, context),
        const SizedBox(height: 16),

        Text(
          'Lokasi',
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),
        _buildLocationSection(currentLocation, isLoadingLocation, theme, ref),

        if (!canCheckIn && !canCheckOut) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    absensiType == 'checkout' && absensiData['checkin'] == null
                        ? 'Silakan check in terlebih dahulu'
                        : absensiData[absensiType] != null
                        ? 'Anda sudah melakukan $absensiType hari ini'
                        : currentLocation != null &&
                            !isWithinOfficeRadius(currentLocation)
                        ? 'Anda harus berada di area kantor untuk melakukan absensi'
                        : 'Lengkapi foto dan lokasi untuk melanjutkan',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _submitAbsensi(ref, context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canSubmit ? theme.primarySwatch : const Color(0xFFE2E8F0),
              foregroundColor:
                  canSubmit ? Colors.white : const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: canSubmit ? 8 : 0,
              shadowColor: theme.primarySwatch.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  absensiType == 'checkin' ? Icons.login : Icons.logout,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  absensiType == 'checkin'
                      ? 'Check In Sekarang'
                      : 'Check Out Sekarang',
                  style: theme.typographyRegular.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiTypeButton(
    String title,
    String type,
    IconData icon,
    dynamic theme,
    WidgetRef ref, [
    bool disabled = false,
  ]) {
    final selectedType = ref.watch(absensiTypeProvider);
    final isSelected = selectedType == type;
    final absensiData = ref.watch(absensiDataProvider);

    final isCompleted = absensiData[type] != null;

    return GestureDetector(
      onTap:
          disabled
              ? null
              : () {
                ref.read(absensiTypeProvider.notifier).state = type;
              },
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          gradient:
              disabled
                  ? null
                  : isSelected
                  ? LinearGradient(
                    colors: [
                      theme.primarySwatch.withValues(alpha: 0.1),
                      theme.secondarySwatch.withValues(alpha: 0.1),
                    ],
                  )
                  : null,
          color:
              disabled
                  ? const Color(0xFFF1F5F9)
                  : isSelected
                  ? null
                  : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                disabled
                    ? const Color(0xFFE2E8F0)
                    : isSelected
                    ? theme.primarySwatch
                    : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with checkmark overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      disabled
                          ? const Color(0xFF94A3B8)
                          : isSelected
                          ? theme.primarySwatch
                          : const Color(0xFF64748B),
                  size: 16,
                ),

                if (isCompleted)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.0,
                    color:
                        disabled
                            ? const Color(0xFF94A3B8)
                            : isSelected
                            ? theme.primarySwatch
                            : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(
    dynamic selectedImage,
    dynamic theme,
    WidgetRef ref,
    BuildContext context,
  ) {
    final selectedImageBytes = ref.watch(selectedImageBytesProvider);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
      ),
      child:
          selectedImage != null || selectedImageBytes != null
              ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child:
                        kIsWeb
                            ? (selectedImageBytes != null
                                ? Image.memory(
                                  selectedImageBytes,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ))
                            : (selectedImage != null
                                ? Image.file(
                                  selectedImage as File,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                )),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedImageProvider.notifier).state = null;
                        ref.read(selectedImageBytesProvider.notifier).state =
                            null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primarySwatch.withValues(alpha: 0.1),
                            theme.secondarySwatch.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 28,
                        color: theme.primarySwatch,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ambil Foto Selfie',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pastikan wajah terlihat jelas',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Camera Button
                    ElevatedButton.icon(
                      onPressed: () => _openCamera(ref),
                      icon: Icon(Icons.camera_alt, size: 16),
                      label: Text('Ambil Foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primarySwatch,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _openCamera(WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          ref.read(selectedImageBytesProvider.notifier).state = bytes;
          ref.read(selectedImageProvider.notifier).state = null;
        } else {
          ref.read(selectedImageProvider.notifier).state = File(image.path);
          ref.read(selectedImageBytesProvider.notifier).state = null;
        }

        debugPrint('📸 Foto berhasil diambil');
      } else {
        debugPrint('📸 User membatalkan pengambilan foto');
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
    }
  }

  Widget _buildLocationSection(
    Position? currentLocation,
    bool isLoading,
    dynamic theme,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primarySwatch,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mendapatkan lokasi...',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else if (currentLocation != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isWithinOfficeRadius(currentLocation)
                                ? [
                                  Colors.green.withValues(alpha: 0.1),
                                  Colors.green.withValues(alpha: 0.2),
                                ]
                                : [
                                  Colors.orange.withValues(alpha: 0.1),
                                  Colors.orange.withValues(alpha: 0.2),
                                ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isWithinOfficeRadius(currentLocation)
                          ? Icons.location_on
                          : Icons.location_off,
                      color:
                          isWithinOfficeRadius(currentLocation)
                              ? Colors.green
                              : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getLocationStatus(currentLocation),
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color:
                          isWithinOfficeRadius(currentLocation)
                              ? Colors.green
                              : Colors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (!isWithinOfficeRadius(currentLocation))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Anda berada di luar area kantor',
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${currentLocation.latitude.toStringAsFixed(6)}',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 9.0,
                    ),
                  ),
                  Text(
                    'Lng: ${currentLocation.longitude.toStringAsFixed(6)}',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 9.0,
                    ),
                  ),
                  Text(
                    'Akurasi: ${currentLocation.accuracy.toStringAsFixed(1)}m',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 9.0,
                    ),
                  ),
                ],
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primarySwatch.withValues(alpha: 0.1),
                          theme.secondarySwatch.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_off,
                      color: theme.primarySwatch,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dapatkan Lokasi',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lokasi diperlukan untuk absensi',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _getCurrentLocation(ref),
                    icon: Icon(Icons.my_location, size: 16),
                    label: Text('Dapatkan Lokasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primarySwatch,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
          ],
        ),
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
          style: theme.typographyRegular.headingSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children:
              riwayatData.map((data) {
                return _buildRiwayatItem(data, theme);
              }).toList(),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getPercentageColor(percentage).withValues(alpha: 0.05),
            getPercentageColor(percentage).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getPercentageColor(percentage).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getPercentageColor(percentage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getPercentageColor(percentage),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$present/$total hari',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
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

  Future<void> _getCurrentLocation(WidgetRef ref) async {
    try {
      ref.read(isLoadingLocationProvider.notifier).state = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable location services.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Location permission denied. Please allow location access in app settings.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Please enable location permission in device settings.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      ref.read(currentLocationProvider.notifier).state = position;

      debugPrint('📍 Location obtained successfully:');
      debugPrint('📍 Lat: ${position.latitude}, Lng: ${position.longitude}');
      debugPrint('📍 Accuracy: ${position.accuracy}m');
    } catch (e) {
      debugPrint('Error getting location: $e');

      // Show error message
      String errorMessage = 'Terjadi kesalahan saat mendapatkan lokasi.';
      if (e.toString().contains('Location services are disabled')) {
        errorMessage =
            'Layanan lokasi dimatikan. Silakan aktifkan GPS/Location di pengaturan perangkat.';
      } else if (e.toString().contains('Location permission denied')) {
        errorMessage =
            'Izin lokasi ditolak. Silakan berikan izin akses lokasi di pengaturan aplikasi.';
      } else if (e.toString().contains('permanently denied')) {
        errorMessage =
            'Izin lokasi ditolak permanen. Silakan aktifkan izin lokasi di pengaturan perangkat.';
      } else if (e.toString().contains('No location permissions are defined')) {
        errorMessage =
            'Konfigurasi izin lokasi belum lengkap. Silakan restart aplikasi.';
      }

      debugPrint('📍 Location error message: $errorMessage');
    } finally {
      ref.read(isLoadingLocationProvider.notifier).state = false;
    }
  }

  void _submitAbsensi(WidgetRef ref, BuildContext context) {
    final selectedImage = ref.read(selectedImageProvider);
    final selectedImageBytes = ref.read(selectedImageBytesProvider);
    final currentLocation = ref.read(currentLocationProvider);
    final absensiType = ref.read(absensiTypeProvider);

    if (currentLocation == null) {
      _showErrorDialog(
        context,
        'Lokasi belum tersedia. Silakan dapatkan lokasi terlebih dahulu.',
      );
      return;
    }

    try {
      final now = DateTime.now();

      // JAM KERJA 08:00 - 16:00
      String status;
      if (absensiType == 'checkin') {
        final hour = now.hour;
        final minute = now.minute;

        if (hour < 8) {
          status = 'Tepat Waktu';
        } else if (hour == 8 && minute <= 0) {
          status = 'Tepat Waktu';
        } else if (hour == 8 && minute <= 30) {
          status = 'Terlambat';
        } else {
          status = 'Sangat Terlambat';
        }
      } else {
        // For checkout - JAM PULANG 16:00
        final hour = now.hour;
        if (hour >= 16) {
          status = 'Tepat Waktu';
        } else if (hour >= 15) {
          status = 'Pulang Cepat';
        } else {
          status = 'Pulang Sangat Cepat';
        }
      }

      // Create absensi data
      final absensiData = AbsensiData(
        type: absensiType,
        time: now,
        location: currentLocation,
        imagePath: !kIsWeb ? selectedImage?.path : null,
        imageBytes: kIsWeb ? selectedImageBytes : null,
        status: status,
      );

      // Save to provider
      final currentData = ref.read(absensiDataProvider);
      final updatedData = Map<String, AbsensiData?>.from(currentData);
      updatedData[absensiType] = absensiData;
      ref.read(absensiDataProvider.notifier).state = updatedData;

      debugPrint('✅ Absensi berhasil disimpan:');
      debugPrint('📍 Type: $absensiType');
      debugPrint('⏰ Time: ${DateFormat('HH:mm:ss').format(now)}');
      debugPrint('📍 Status: $status');
      debugPrint(
        '📍 Location: ${currentLocation.latitude}, ${currentLocation.longitude}',
      );

      if (kIsWeb && selectedImageBytes != null) {
        debugPrint('📸 Image: Web bytes (${selectedImageBytes.length} bytes)');
      } else if (!kIsWeb && selectedImage != null) {
        debugPrint('📸 Image: ${selectedImage.path}');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.green.shade400],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Absensi Berhasil!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${absensiType == 'checkin' ? 'Check In' : 'Check Out'} berhasil disimpan pada ${DateFormat('HH:mm:ss').format(now)}.',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          status.contains('Tepat Waktu')
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          status.contains('Tepat Waktu')
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            status.contains('Tepat Waktu')
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              status.contains('Tepat Waktu')
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color:
                                  status.contains('Tepat Waktu')
                                      ? Colors.green
                                      : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    status.contains('Tepat Waktu')
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 Lokasi: ${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '📍 Akurasi: ${currentLocation.accuracy.toStringAsFixed(1)}m',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        Navigator.of(dialogContext).pop();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.goNamed(Routes.home.name);
                        }
                      } catch (e) {
                        debugPrint('Dialog navigation error: $e');
                        context.goNamed(Routes.home.name);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );

      // Reset form
      ref.read(selectedImageProvider.notifier).state = null;
      ref.read(selectedImageBytesProvider.notifier).state = null;
      ref.read(currentLocationProvider.notifier).state = null;
    } catch (e) {
      debugPrint('Submit absensi error: $e');
      _showErrorDialog(
        context,
        'Terjadi kesalahan saat menyimpan absensi: ${e.toString()}',
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.red.shade400],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.error, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(color: const Color(0xFF64748B), fontSize: 16.0),
            ),
            actions: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
