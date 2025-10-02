import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/common/data/models/menuutama/reimburse_model.dart';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';

class ReimburseListNotifier extends AsyncNotifier<List<ReimburseModel>> {
  @override
  Future<List<ReimburseModel>> build() async {
    return await _loadReimburse();
  }

  Future<List<ReimburseModel>> _loadReimburse() async {
    try {
      final dbHelper = AppDatabaseHelper();
      final reimburseData = await dbHelper.getAllReimburse();
      return reimburseData.map((data) => ReimburseModel.fromMap(data)).toList();
    } catch (e) {
      print('Error loading reimburse: $e');
      return [];
    }
  }

  Future<void> addReimburse(ReimburseModel reimburse) async {
    state = const AsyncValue.loading();
    try {
      final dbHelper = AppDatabaseHelper();
      await dbHelper.insertReimburse(reimburse.toMap());
      state = AsyncValue.data(await _loadReimburse());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateReimburse(ReimburseModel reimburse) async {
    state = const AsyncValue.loading();
    try {
      final dbHelper = AppDatabaseHelper();
      await dbHelper.updateReimburse(reimburse.id!, reimburse.toMap());
      state = AsyncValue.data(await _loadReimburse());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteReimburse(int id) async {
    state = const AsyncValue.loading();
    try {
      final dbHelper = AppDatabaseHelper();
      await dbHelper.deleteReimburse(id);
      state = AsyncValue.data(await _loadReimburse());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshReimburse() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _loadReimburse());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final reimburseListProvider = AsyncNotifierProvider<ReimburseListNotifier, List<ReimburseModel>>(
  () => ReimburseListNotifier(),
);

final reimburseSearchProvider = StateProvider<String>((ref) => '');
final reimburseStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredReimburseProvider = Provider<AsyncValue<List<ReimburseModel>>>((ref) {
  final reimburseAsync = ref.watch(reimburseListProvider);
  final query = ref.watch(reimburseSearchProvider).toLowerCase().trim();
  final status = ref.watch(reimburseStatusFilterProvider);

  return reimburseAsync.when(
    data: (list) {
      final filtered = list.where((item) {
        final matchesQuery = query.isEmpty ||
            item.category.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.id.toString().contains(query);
        final matchesStatus = status == 'Semua' || item.uiStatus == status;
        return matchesQuery && matchesStatus;
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class DaftarReimbursePage extends ConsumerStatefulWidget {
  const DaftarReimbursePage({super.key});

  @override
  ConsumerState<DaftarReimbursePage> createState() =>
      _DaftarReimbursePageState();
}

class _DaftarReimbursePageState extends ConsumerState<DaftarReimbursePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDetailDialog(ReimburseModel reimburse) {
    final theme = ref.read(themeProvider);
    final statusColor = _getStatusColor(reimburse.uiStatus);
    final canEdit = _canEdit(reimburse.uiStatus);
    
    // Validasi kelengkapan data
    final List<String> missingFields = [];
    if (reimburse.id == null) missingFields.add('ID');
    if (reimburse.category.isEmpty) missingFields.add('Kategori');
    if (reimburse.description.isEmpty) missingFields.add('Deskripsi');
    if (reimburse.amount <= 0) missingFields.add('Jumlah');

    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: reimburse.uiStatus,
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final formattedAmount = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(reimburse.amount);

    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Reimburse',
        value: reimburse.id?.toString() ?? 'Auto-generated',
      ),
      SIHAKIDialogField(
        label: 'Kategori',
        value: reimburse.category,
      ),
      SIHAKIDialogField(label: 'Jumlah', value: formattedAmount),
      SIHAKIDialogField(
        label: 'Tanggal',
        value: DateFormat('dd MMMM yyyy', 'id_ID').format(reimburse.date),
      ),
      SIHAKIDialogField(
        label: 'Deskripsi',
        value: reimburse.description,
      ),
      if (reimburse.fileName != null && reimburse.fileName!.isNotEmpty)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: reimburse.fileName!,
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];

    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Ubah Reimburse',
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pop();
            _navigateToEdit(reimburse);
          },
        ),
        SIHAKIDialogAction(
          label: 'Hapus Reimburse',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(reimburse);
          },
        ),
      ]);
    } else {
      actions.add(
        SIHAKIDialogAction(
          label: 'Hapus Reimburse',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(reimburse);
          },
        ),
      );
    }

    // Additional content untuk warning jika ada field kosong
    Widget? additionalContent;
    if (missingFields.isNotEmpty) {
      additionalContent = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Data tidak lengkap: ${missingFields.join(', ')} belum diisi',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dialogData = SIHAKIDialogData(
      title: 'Detail Reimburse',
      fields: allFields,
      actions: actions,
      additionalContent: additionalContent,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Menunggu Persetujuan':
      default:
        return Colors.orange;
    }
  }

  bool _canEdit(String status) {
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _navigateToEdit(ReimburseModel reimburse) {
    context.push('/edit-reimburse', extra: reimburse.toLegacyMap());
  }

  void _confirmDelete(ReimburseModel reimburse) {
    final id = reimburse.id?.toString() ?? 'Unknown';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Reimburse',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan reimburse $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        try {
          if (reimburse.id != null) {
            await ref.read(reimburseListProvider.notifier).deleteReimburse(reimburse.id!);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Pengajuan reimburse berhasil dihapus'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menghapus reimburse: $e'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredListAsync = ref.watch(filteredReimburseProvider);
    final statusFilter = ref.watch(reimburseStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Daftar Reimburse',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Column(
        children: [
          // Search Section with Filter
          Container(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID, kategori, atau deskripsi...',
              margin: const EdgeInsets.all(16),
              hasActiveFilters: statusFilter != 'Semua',
              onChanged:
                  (value) =>
                      ref.read(reimburseSearchProvider.notifier).state = value,
              onFilterReset: () {
                _searchController.clear();
                ref.read(reimburseSearchProvider.notifier).state = '';
                ref.read(reimburseStatusFilterProvider.notifier).state =
                    'Semua';
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
                              (statusOption) => FilterChip(
                                label: Text(statusOption),
                                selected: statusFilter == statusOption,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              reimburseStatusFilterProvider
                                                  .notifier,
                                            )
                                            .state = statusOption,
                                selectedColor: theme.primarySwatch.withValues(
                                  alpha: 0.2,
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

          // Tambah Reimburse button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await context.push('/tambah-reimburse');
                  if (result == true) {
                    // Refresh data setelah berhasil menambah reimburse
                    ref.invalidate(reimburseListProvider);
                  }
                },
                icon: const Icon(Icons.add_circle, size: 20),
                label: Text(
                  'AJUKAN REIMBURSE',
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
          
          // List Section with AsyncValue handling
          Expanded(
            child: filteredListAsync.when(
              data: (filteredList) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(reimburseListProvider);
                },
                child: filteredList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada data reimburse',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final reimburse = filteredList[index];
                    final statusColor = _getStatusColor(reimburse.uiStatus);
                    final formattedAmount = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(reimburse.amount);
                    
                    return AppListCard(
                      title: reimburse.category,
                      subtitle: reimburse.id?.toString() ?? 'Auto-generated',
                      leading: CircleAvatar(
                        backgroundColor: theme.primarySwatch.withOpacity(0.1),
                        child: Icon(
                          Icons.receipt,
                          color: theme.primarySwatch,
                          size: 20,
                        ),
                      ),
                      trailing: AppStatusChip(
                        label: reimburse.uiStatus,
                        color: statusColor,
                      ),
                      chips: [
                        AppPillChip(
                          icon: Icons.attach_money,
                          label: formattedAmount,
                        ),
                        AppPillChip(
                          icon: Icons.description,
                          label: reimburse.description,
                        ),
                        if (reimburse.fileName != null && reimburse.fileName!.isNotEmpty)
                          AppPillChip(
                            icon: Icons.attach_file,
                            label: reimburse.fileName!,
                          ),
                      ],
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          onPressed: () => _showDetailDialog(reimburse),
                          tooltip: 'Lihat Detail',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.primarySwatch.withOpacity(0.1),
                            foregroundColor: theme.primarySwatch,
                          ),
                        ),
                      ],
                      onTap: () => _showDetailDialog(reimburse),
                    );
                  },
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
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
                      onPressed: () => ref.invalidate(reimburseListProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
