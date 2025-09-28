import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/kegiatan_rumah_aspirasi_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kegiatan_rumah_aspirasi_model.dart';

// Provider untuk search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider untuk filtered kegiatan rumah aspirasi yang menggunakan SQLite
final filteredKegiatanRumahAspirasiProvider = Provider<List<KegiatanRumahAspirasiModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final kegiatanState = ref.watch(kegiatanRumahAspirasiProvider);

  if (query.isEmpty) return kegiatanState.kegiatanList;

  return kegiatanState.kegiatanList.where((kegiatan) {
    return kegiatan.namaKegiatan.toLowerCase().contains(query) ||
        kegiatan.tanggalKegiatan.toLowerCase().contains(query) ||
        kegiatan.tempat.toLowerCase().contains(query) ||
        kegiatan.pic.toLowerCase().contains(query) ||
        kegiatan.status.toLowerCase().contains(query) ||
        (kegiatan.deskripsi?.toLowerCase().contains(query) ?? false);
  }).toList();
});

class DaftarPengajuanRumahAspirasiPage extends ConsumerStatefulWidget {
  const DaftarPengajuanRumahAspirasiPage({super.key});

  @override
  ConsumerState<DaftarPengajuanRumahAspirasiPage> createState() =>
      _DaftarPengajuanRumahAspirasiPageState();
}

class _DaftarPengajuanRumahAspirasiPageState
    extends ConsumerState<DaftarPengajuanRumahAspirasiPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kegiatanRumahAspirasiProvider.notifier).loadKegiatan();
    });
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredItems = ref.watch(filteredKegiatanRumahAspirasiProvider);
    final isLoading = ref.watch(kegiatanRumahAspirasiProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kegiatan Rumah Aspirasi',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Modern Search Bar
            AppFilterBar(
              controller: _searchController,
              labelText: 'Cari Kegiatan Rumah Aspirasi',
              hintText: 'Nama kegiatan, tanggal, tempat, PIC...',
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              cardMargin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
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
                  // Navigate dan tunggu hasil, lalu refresh data
                  final result = await context.pushNamed(Routes.tambahRumahAspirasi.name);
                  // Refresh data setelah kembali dari tambah kegiatan jika ada perubahan
                  if (mounted && result == true) {
                    await ref.read(kegiatanRumahAspirasiProvider.notifier).loadKegiatan();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(
                  'TAMBAH KEGIATAN',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data kegiatan rumah aspirasi',
                                style: theme.typographyRegular.bodyLarge
                                    .copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildRumahAspirasiCard(item, theme);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRumahAspirasiCard(KegiatanRumahAspirasiModel item, dynamic theme) {
    return AppListCard(
      onTap: () => _showDetailDialog(item, theme),
      leftAccentColor: theme.primarySwatch,
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
              theme.primarySwatch.withValues(alpha: 0.2),
              theme.primarySwatch.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primarySwatch.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.business_center,
          color: theme.primarySwatch,
          size: 24,
        ),
      ),
      title: item.namaKegiatan,
      subtitle: 'ID: ${item.id} | Tanggal: ${item.tanggalKegiatan}',
      chips: [
        AppPillChip(
          icon: Icons.calendar_today_rounded,
          label: item.tanggalKegiatan,
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.location_on_rounded,
          label: item.tempat,
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: Icons.person_rounded,
          label: item.pic,
          color: Colors.green[600],
        ),
      ],
    );
  }

  void _showDetailDialog(KegiatanRumahAspirasiModel item, dynamic theme) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Kegiatan Rumah Aspirasi - ${item.namaKegiatan}',
      fields: [
        SIHAKIDialogField(label: 'ID', value: item.id.toString()),
        SIHAKIDialogField(label: 'Nama Kegiatan', value: item.namaKegiatan),
        SIHAKIDialogField(label: 'Tanggal Kegiatan', value: item.tanggalKegiatan),
        SIHAKIDialogField(label: 'Tempat', value: item.tempat),
        SIHAKIDialogField(label: '', value: ''), // Spacer
        SIHAKIDialogField(label: 'PIC', value: item.pic),
        SIHAKIDialogField(label: 'Status', value: item.status),
        if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
          SIHAKIDialogField(label: '', value: ''), // Spacer
          SIHAKIDialogField(label: 'Deskripsi', value: item.deskripsi!),
        ],
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Edit Kegiatan',
          backgroundColor: Colors.orange[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editRumahAspirasi.name, extra: item).then((result) {
              // Refresh data setelah kembali dari edit kegiatan jika ada perubahan
              if (mounted && result == true) {
                ref.read(kegiatanRumahAspirasiProvider.notifier).loadKegiatan();
              }
            });
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Kegiatan',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(item);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  // Helper method untuk konfirmasi hapus
  void _confirmDelete(KegiatanRumahAspirasiModel item) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Kegiatan',
      message:
          'Apakah Anda yakin ingin menghapus kegiatan "${item.namaKegiatan}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () async {
        try {
          await ref
              .read(kegiatanRumahAspirasiProvider.notifier)
              .deleteKegiatan(item.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Kegiatan "${item.namaKegiatan}" berhasil dihapus',
                ),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menghapus kegiatan: $e'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
