import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import '../../../providers/MenuUtama/cuti_provider.dart';
import '../../../../../../common/data/models/menuutama/cuti_model.dart';

class DaftarCutiPage extends ConsumerStatefulWidget {
  const DaftarCutiPage({super.key});

  @override
  ConsumerState<DaftarCutiPage> createState() => _DaftarCutiPageState();
}

class _DaftarCutiPageState extends ConsumerState<DaftarCutiPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final cutiState = ref.watch(cutiProvider);
    final filteredList = ref.watch(filteredCutiProvider);
    final statusFilter = ref.watch(cutiStatusFilterProvider);
    final searchQuery = ref.watch(cutiSearchProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Cuti',
          style: theme.typographyBold.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(cutiProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  AppFilterBar(
                    controller: _searchController,
                    labelText: 'Cari cuti...',
                    hintText: 'Masukkan ID, jenis, atau alasan cuti',
                    headerTitle: 'Pencarian & Filter',
                    hasActiveFilters: statusFilter != 'Semua' || searchQuery.isNotEmpty,
                    onChanged: (value) {
                      ref.read(cutiSearchProvider.notifier).state = value;
                    },
                    onReset: () {
                      _searchController.clear();
                      ref.read(cutiSearchProvider.notifier).state = '';
                      ref.read(cutiStatusFilterProvider.notifier).state = 'Semua';
                    },
                    filterSection: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Status',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['Semua', 'Menunggu Persetujuan', 'Disetujui', 'Ditolak']
                              .map((status) => FilterChip(
                                    label: Text(status),
                                    selected: statusFilter == status,
                                    onSelected: (_) {
                                      ref.read(cutiStatusFilterProvider.notifier).state = status;
                                    },
                                    selectedColor: theme.primarySwatch.withOpacity(0.2),
                                    checkmarkColor: theme.primarySwatch,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tambah Cuti button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed(Routes.tambahCuti.name),
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: Text(
                    'AJUKAN CUTI',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: theme.primarySwatch,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            
            // List Section
            Expanded(
              child: _buildContent(context, theme, cutiState, filteredList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic theme, CutiState cutiState, List<CutiModel> filteredList) {
    // Show loading
    if (cutiState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data cuti...'),
          ],
        ),
      );
    }

    // Show error
    if (cutiState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${cutiState.error}',
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(cutiProvider.notifier).refresh();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              cutiState.cutiList.isEmpty 
                ? 'Belum ada data cuti'
                : 'Tidak ada data cuti yang cocok',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (cutiState.cutiList.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ajukan cuti pertama Anda',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ],
        ),
      );
    }

    // Show cuti list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final cuti = filteredList[index];
        return _buildCutiCard(cuti, theme);
      },
    );
  }

  Widget _buildCutiCard(CutiModel cuti, dynamic theme) {
    return AppListCard(
      title: cuti.type.label,
      subtitle: cuti.cutiId,
      leading: CircleAvatar(
        backgroundColor: theme.primarySwatch.withOpacity(0.1),
        child: Icon(
          Icons.event_available,
          color: theme.primarySwatch,
          size: 20,
        ),
      ),
      trailing: AppStatusChip(
        label: cuti.status.label,
        color: cuti.status.color,
      ),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today,
          label: cuti.formattedDuration,
        ),
        AppPillChip(
          icon: Icons.description,
          label: cuti.alasan,
        ),
        if (cuti.fileName != null)
          AppPillChip(
            icon: Icons.attach_file,
            label: 'Ada lampiran',
            color: Colors.blue,
          ),
      ],
      actions: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          onPressed: () => _showDetailDialog(cuti),
          tooltip: 'Lihat Detail',
          style: IconButton.styleFrom(
            backgroundColor: theme.primarySwatch.withOpacity(0.1),
            foregroundColor: theme.primarySwatch,
          ),
        ),
      ],
      onTap: () => _showDetailDialog(cuti),
    );
  }

  void _showDetailDialog(CutiModel cuti) {
    final theme = ref.read(themeProvider);
    
    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: cuti.status.label,
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: cuti.status.color),
      valueColor: cuti.status.color,
    );

    // Data fields
    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Cuti',
        value: cuti.cutiId,
      ),
      SIHAKIDialogField(
        label: 'Jenis Cuti',
        value: cuti.type.label,
      ),
      SIHAKIDialogField(
        label: 'Tanggal Mulai',
        value: cuti.formattedTanggalMulai,
      ),
      SIHAKIDialogField(
        label: 'Tanggal Selesai',
        value: cuti.formattedTanggalSelesai,
      ),
      SIHAKIDialogField(
        label: 'Durasi',
        value: cuti.formattedDuration,
      ),
      SIHAKIDialogField(
        label: 'Alasan',
        value: cuti.alasan,
      ),
      if (cuti.fileName != null)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: cuti.fileName!,
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];
    
    if (cuti.canEdit) {
      actions.add(
        SIHAKIDialogAction(
          label: 'Edit Cuti',
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editCuti.name, extra: cuti.toLegacyMap());
          },
        ),
      );
    }
    
    actions.add(
      SIHAKIDialogAction(
        label: 'Hapus Cuti',
        icon: Icons.delete,
        isDestructive: true,
        onTap: () {
          Navigator.of(context).pop();
          _confirmDelete(cuti);
        },
      ),
    );

    // Additional content untuk edit lock info
    Widget? additionalContent;
    if (cuti.isLocked) {
      additionalContent = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cuti yang sudah disetujui tidak dapat diedit',
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

    final dialogData = SIHAKIDialogData(
      title: 'Detail Cuti',
      fields: allFields,
      actions: actions,
      additionalContent: additionalContent,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _confirmDelete(CutiModel cuti) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Cuti',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan cuti ${cuti.cutiId}? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        final success = await ref.read(cutiProvider.notifier).deleteCuti(cuti.cutiId);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pengajuan cuti berhasil dihapus'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          final error = ref.read(cutiProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus cuti: ${error ?? "Unknown error"}'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }
}