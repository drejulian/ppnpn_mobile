import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/lembur_provider.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/lembur_model.dart';
import 'package:intl/intl.dart';

class DaftarLemburPage extends ConsumerStatefulWidget {
  const DaftarLemburPage({super.key});

  @override
  ConsumerState<DaftarLemburPage> createState() => _DaftarLemburPageState();
}

class _DaftarLemburPageState extends ConsumerState<DaftarLemburPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _showDetailDialog(LemburModel lembur) {
    final theme = ref.read(themeProvider);
    final statusColor = _statusColor(lembur.uiStatus);
    final canEdit = _canEdit(lembur);
    
    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: lembur.uiStatus,
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Lembur',
        value: lembur.id?.toString() ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Jenis Lembur',
        value: lembur.type,
      ),
      SIHAKIDialogField(
        label: 'Tanggal Lembur',
        value: DateFormat('dd MMMM yyyy', 'id_ID').format(lembur.date),
      ),
      SIHAKIDialogField(
        label: 'Durasi',
        value: lembur.duration,
      ),
      SIHAKIDialogField(
        label: 'Jam Mulai',
        value: lembur.startTime,
      ),
      SIHAKIDialogField(
        label: 'Jam Selesai',
        value: lembur.endTime,
      ),
      SIHAKIDialogField(
        label: 'Kegiatan',
        value: lembur.reason,
      ),
      if (lembur.fileName != null)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: lembur.fileName!,
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];
    
    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Edit Lembur',
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pop();
            context.push('/edit-lembur', extra: lembur);
          },
        ),
        SIHAKIDialogAction(
          label: 'Hapus Lembur',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(lembur);
          },
        ),
      ]);
    } else {
      actions.add(
        SIHAKIDialogAction(
          label: 'Hapus Lembur',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(lembur);
          },
        ),
      );
    }

    final dialogData = SIHAKIDialogData(
      title: 'Detail Lembur',
      fields: allFields,
      actions: actions,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  bool _canEdit(LemburModel lembur) {
    final status = lembur.uiStatus;
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(LemburModel lembur) {
    final id = lembur.id?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Lembur',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan lembur $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        if (lembur.id != null) {
          try {
            await ref.read(lemburProvider.notifier).deleteLembur(lembur.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pengajuan lembur berhasil dihapus'),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menghapus lembur: $e'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredLemburProvider);
    final statusFilter = ref.watch(lemburStatusFilterProvider);
    final isLoading = ref.watch(lemburLoadingProvider);
    final error = ref.watch(lemburErrorProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Lembur',
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
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                AppFilterBar(
                  controller: _searchController,
                  labelText: 'Cari lembur...',
                  hintText: 'Masukkan ID, jenis, atau kegiatan lembur',
                  headerTitle: 'Pencarian & Filter',
                  hasActiveFilters: statusFilter != 'Semua',
                  onChanged: (value) => ref.read(lemburSearchProvider.notifier).state = value,
                  onReset: () {
                    _searchController.clear();
                    ref.read(lemburSearchProvider.notifier).state = '';
                    ref.read(lemburStatusFilterProvider.notifier).state = 'Semua';
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
                                  onSelected: (_) => ref.read(lemburStatusFilterProvider.notifier).state = status,
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
          
          // Tambah Lembur button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/tambah-lembur'),
                icon: const Icon(Icons.add_circle, size: 20),
                label: Text(
                  'AJUKAN LEMBUR',
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan: $error',
                              style: TextStyle(color: Colors.red[600], fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(lemburProvider.notifier).loadLembur(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada data lembur',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final lembur = filteredList[index];
                              final statusColor = _statusColor(lembur.uiStatus);
                              
                              return AppListCard(
                                title: lembur.type,
                                subtitle: lembur.id?.toString() ?? 'N/A',
                                leading: CircleAvatar(
                                  backgroundColor: theme.primarySwatch.withOpacity(0.1),
                                  child: Icon(
                                    Icons.schedule,
                                    color: theme.primarySwatch,
                                    size: 20,
                                  ),
                                ),
                                trailing: AppStatusChip(
                                  label: lembur.uiStatus,
                                  color: statusColor,
                                ),
                                chips: [
                                  AppPillChip(
                                    icon: Icons.access_time,
                                    label: '${lembur.startTime} - ${lembur.endTime}',
                                  ),
                                  AppPillChip(
                                    icon: Icons.timer,
                                    label: lembur.duration,
                                  ),
                                  AppPillChip(
                                    icon: Icons.description,
                                    label: lembur.reason,
                                  ),
                                ],
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 20),
                                    onPressed: () => _showDetailDialog(lembur),
                                    tooltip: 'Lihat Detail',
                                    style: IconButton.styleFrom(
                                      backgroundColor: theme.primarySwatch.withOpacity(0.1),
                                      foregroundColor: theme.primarySwatch,
                                    ),
                                  ),
                                ],
                                onTap: () => _showDetailDialog(lembur),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}