import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/izin_provider.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/izin_model.dart';
import 'package:intl/intl.dart';

class DaftarIzinPage extends ConsumerStatefulWidget {
  const DaftarIzinPage({super.key});

  @override
  ConsumerState<DaftarIzinPage> createState() => _DaftarIzinPageState();
}

class _DaftarIzinPageState extends ConsumerState<DaftarIzinPage> {
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

  void _showDetailDialog(IzinModel izin) {
    final theme = ref.read(themeProvider);
    final statusColor = _statusColor(izin.uiStatus);
    final canEdit = _canEdit(izin);
    
    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: izin.uiStatus,
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Izin',
        value: izin.id?.toString() ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Jenis Izin',
        value: izin.type,
      ),
      SIHAKIDialogField(
        label: 'Tanggal Izin',
        value: DateFormat('dd MMMM yyyy', 'id_ID').format(izin.date),
      ),
      SIHAKIDialogField(
        label: 'Durasi',
        value: izin.duration,
      ),
      SIHAKIDialogField(
        label: 'Alasan',
        value: izin.reason,
      ),
      if (izin.fileName != null)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: izin.fileName!,
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];

    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Ubah Izin',
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pop();
            // Convert IzinModel to Map for compatibility with EditIzinPage
            context.push('/edit-izin', extra: izin.toMap());
          },
        ),
        SIHAKIDialogAction(
          label: 'Hapus Izin',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(izin);
          },
        ),
      ]);
    } else {
      actions.add(
        SIHAKIDialogAction(
          label: 'Hapus Izin',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(izin);
          },
        ),
      );
    }

    final dialogData = SIHAKIDialogData(
      title: 'Detail Izin',
      fields: allFields,
      actions: actions,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  bool _canEdit(IzinModel izin) {
    final status = izin.uiStatus;
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(IzinModel izin) {
    final id = izin.id?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Izin',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan izin $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        if (izin.id != null) {
          try {
            await ref.read(izinProvider.notifier).deleteIzin(izin.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pengajuan izin berhasil dihapus'),
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
                content: Text('Gagal menghapus izin: $e'),
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
    final izinState = ref.watch(izinProvider);
    final filteredList = ref.watch(filteredIzinProvider);
    final statusFilter = ref.watch(izinStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Daftar Izin',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Column(
        children: [
          // Search Section with Filter
          Container(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID, jenis, atau alasan izin...',
              margin: const EdgeInsets.all(16),
              hasActiveFilters: statusFilter != 'Semua',
              onChanged:
                  (value) =>
                      ref.read(izinSearchProvider.notifier).state = value,
              onFilterReset: () {
                _searchController.clear();
                ref.read(izinSearchProvider.notifier).state = '';
                ref.read(izinStatusFilterProvider.notifier).state = 'Semua';
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
                    children:
                        [
                              'Semua',
                              'Menunggu Persetujuan',
                              'Disetujui',
                              'Ditolak',
                            ]
                            .map(
                              (status) => FilterChip(
                                label: Text(status),
                                selected: statusFilter == status,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              izinStatusFilterProvider.notifier,
                                            )
                                            .state = status,
                                selectedColor: theme.primarySwatch.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: theme.primarySwatch,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Tambah Izin button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/tambah-izin'),
                icon: const Icon(Icons.add_circle, size: 20),
                label: Text(
                  'AJUKAN IZIN',
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
            child: izinState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : izinState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan: ${izinState.error}',
                              style: TextStyle(color: Colors.red[600], fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(izinProvider.notifier).loadIzin(),
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
                                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada data izin',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final izin = filteredList[index];
                              final statusColor = _statusColor(izin.uiStatus);
                              
                              return AppListCard(
                                title: izin.type,
                                subtitle: izin.id?.toString() ?? 'N/A',
                                leading: CircleAvatar(
                                  backgroundColor: theme.primarySwatch.withOpacity(0.1),
                                  child: Icon(
                                    Icons.assignment_ind,
                                    color: theme.primarySwatch,
                                    size: 20,
                                  ),
                                ),
                                trailing: AppStatusChip(
                                  label: izin.uiStatus,
                                  color: statusColor,
                                ),
                                chips: [
                                  AppPillChip(
                                    icon: Icons.calendar_today,
                                    label: izin.duration,
                                  ),
                                  AppPillChip(
                                    icon: Icons.description,
                                    label: izin.reason,
                                  ),
                                ],
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 20),
                                    onPressed: () => _showDetailDialog(izin),
                                    tooltip: 'Lihat Detail',
                                    style: IconButton.styleFrom(
                                      backgroundColor: theme.primarySwatch.withOpacity(0.1),
                                      foregroundColor: theme.primarySwatch,
                                    ),
                                  ),
                                ],
                                onTap: () => _showDetailDialog(izin),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
