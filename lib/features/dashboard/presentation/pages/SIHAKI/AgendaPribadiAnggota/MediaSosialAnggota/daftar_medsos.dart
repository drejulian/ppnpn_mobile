import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/media_sosial_anggota_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/media_sosial_anggota_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'dart:async';

// Provider untuk search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider untuk filtered media sosial yang menggunakan SQLite
final filteredMediaSosialProvider = Provider<List<MediaSosialAnggotaModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final medsosState = ref.watch(mediaSosialAnggotaProvider);

  if (query.isEmpty) return medsosState.medsosList;

  return medsosState.medsosList.where((medsos) {
    return medsos.platform.toLowerCase().contains(query) ||
        medsos.username.toLowerCase().contains(query) ||
        medsos.url.toLowerCase().contains(query) ||
        medsos.status.toLowerCase().contains(query);
  }).toList();
});

class MediaSosialAnggota extends ConsumerStatefulWidget {
  const MediaSosialAnggota({super.key});

  @override
  ConsumerState<MediaSosialAnggota> createState() => _MediaSosialAnggotaState();
}

class _MediaSosialAnggotaState extends ConsumerState<MediaSosialAnggota> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load data dan check permission saat page dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(mediaSosialAnggotaProvider.notifier).loadMediaSosial();
      
      // Check notification permissions
      final hasPermission = await NotificationService.hasNotificationPermissions();
      print('DEBUG: 📱 Has notification permission: $hasPermission');
      
      if (!hasPermission && mounted) {
        final granted = await NotificationService.requestPermissionsWithDialog(context);
        print('DEBUG: 📱 Permission granted after request: $granted');
      }
    });
    
    _searchController.text = ref.read(searchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Method untuk mengirim notifikasi lokal delete
  Future<void> _showDeleteNotification(String platform, String username) async {
    try {
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil Dihapus',
        body: 'Akun $platform ($username) telah berhasil dihapus dari media sosial Anda.',
        payload: 'medsos_deleted_${platform}_$username',
      );
      print('DEBUG: 📱 Delete notification sent for $platform @$username');
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      print('DEBUG: ❌ Failed to send delete notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final medsosState = ref.watch(mediaSosialAnggotaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Media Sosial Anggota',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              print('DEBUG: 🧪 Testing notification...');
              await NotificationService.showTestNotification();
            },
            tooltip: 'Test Notification',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mediaSosialAnggotaProvider.notifier).loadMediaSosial(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(mediaSosialAnggotaProvider.notifier).loadMediaSosial();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID, platform, username...',
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.primarySwatch,
                    theme.primarySwatch.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await context.push('/tambah-media-sosial-anggota');
                  if (result == true) {
                    ref.read(mediaSosialAnggotaProvider.notifier).loadMediaSosial();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(
                  'TAMBAH MEDIA SOSIAL',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content area - show loading, error, or data
            Expanded(
              child: medsosState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : medsosState.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi kesalahan',
                                style: theme.typographyBold.bodyLarge.copyWith(
                                  color: Colors.red[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                medsosState.errorMessage!,
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(mediaSosialAnggotaProvider.notifier).loadMediaSosial();
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : Consumer(
                          builder: (context, ref, child) {
                            final filteredList = ref.watch(filteredMediaSosialProvider);
                            
                            if (filteredList.isEmpty) {
                              final searchQuery = ref.watch(searchQueryProvider);
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      searchQuery.isNotEmpty ? Icons.search_off : Icons.share,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'Tidak ada media sosial yang ditemukan'
                                          : 'Belum ada media sosial tersimpan',
                                      style: theme.typographyBold.bodyLarge.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'Coba kata kunci yang berbeda'
                                          : 'Tambahkan media sosial pertama Anda',
                                      style: theme.typographyRegular.bodyMedium.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final medsos = filteredList[index];
                                return _buildMediaSosialCard(medsos, theme);
                              },
                            );
                          },
                        ),
            ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildMediaSosialCard(MediaSosialAnggotaModel medsos, dynamic theme) {
    return AppListCard(
      onTap: () => _showDetailDialog(context, medsos, theme),
      leftAccentColor: _getPlatformColor(medsos.platform),
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getPlatformColor(medsos.platform).withValues(alpha: 0.2),
              _getPlatformColor(medsos.platform).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getPlatformColor(medsos.platform).withValues(alpha: 0.3)),
        ),
        child: Icon(_getIcon(medsos.platform), color: _getPlatformColor(medsos.platform), size: 24),
      ),
      title: medsos.platform,
      subtitle: 'ID: ${medsos.id}',
      chips: [
        AppPillChip(
          icon: Icons.link,
          label: medsos.url.length > 30 ? '${medsos.url.substring(0, 30)}...' : medsos.url,
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: medsos.isVerified ? Icons.verified : Icons.person,
          label: medsos.isVerified ? 'Verified' : 'Not Verified',
          color: medsos.isVerified ? Colors.green[600] : Colors.grey[600],
        ),
        AppPillChip(
          icon: Icons.people,
          label: '${medsos.followers} followers',
          color: Colors.purple[600],
        ),
      ],
      actions: [
        AppViewDetailButton(
          onPressed: () => _showDetailDialog(context, medsos, theme),
          tooltip: 'Lihat Detail',
        ),
      ],
    );
  }

  // Helper Methods untuk Dialog SIHAKI
  void _confirmDelete(MediaSosialAnggotaModel medsos) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Media Sosial',
      message:
          'Apakah Anda yakin ingin menghapus media sosial "${medsos.platform}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () async {
        if (medsos.id != null) {
          print('DEBUG: 🗑️ Deleting media sosial - Platform: ${medsos.platform}, Username: @${medsos.username}');
          
          final success = await ref
              .read(mediaSosialAnggotaProvider.notifier)
              .deleteMediaSosial(medsos.id!);
          
          if (success && mounted) {
            print('DEBUG: ✅ Media sosial deleted successfully');

            // Tambahkan notifikasi ke dalam app (page notifikasi)
            ref.read(notificationProvider.notifier).addDeleteMediaSosialNotification(
              platform: medsos.platform,
              username: medsos.username,
            );

            print('DEBUG: 🔔 Added delete notification to notification provider');

            // Kirim notifikasi lokal langsung
            await _showDeleteNotification(medsos.platform, medsos.username);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Media sosial "${medsos.platform}" berhasil dihapus dan notifikasi dikirim'),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else {
            print('DEBUG: ❌ Failed to delete media sosial');
          }
        }
      },
    );
  }

  void _showDetailDialog(
    BuildContext context,
    MediaSosialAnggotaModel medsos,
    dynamic theme,
  ) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Media Sosial - ${medsos.platform}',
      fields: [
        SIHAKIDialogField(label: 'ID', value: medsos.id?.toString() ?? '-'),
        SIHAKIDialogField(label: 'Platform', value: medsos.platform),
        SIHAKIDialogField(label: 'Username', value: medsos.username),
        SIHAKIDialogField(label: 'URL', value: medsos.url),
        SIHAKIDialogField(label: 'Followers', value: medsos.followers.toString()),
        SIHAKIDialogField(label: 'Verified', value: medsos.isVerified ? 'Ya' : 'Tidak'),
        SIHAKIDialogField(label: '', value: ''), // Spacer
        SIHAKIDialogField(label: 'Status', value: medsos.status),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Ubah Media Sosial',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editMediaSosialAnggota.name, extra: medsos);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Media Sosial',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(medsos);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  IconData? _getIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'website':
        return FontAwesomeIcons.globe;
      default:
        return FontAwesomeIcons.shareAlt;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'website':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9C27B0);
    }
  }
}
