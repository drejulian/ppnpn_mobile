import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:intl/intl.dart';

class LemburNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LemburNotifier()
    : super([
        {
          'id': 'L-001',
          'type': 'Lembur Komisi',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'duration': '3 jam',
          'reason': 'Support acara komisi',
          'status': 'Menunggu Persetujuan',
          'statusColor': Colors.orange,
          'fileName': null,
          'jamMulai': '19:00',
          'jamSelesai': '22:00',
        },
        {
          'id': 'L-002',
          'type': 'Lembur Anggaran',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'duration': '2.5 jam',
          'reason': 'Rekap data anggaran',
          'status': 'Disetujui',
          'statusColor': Colors.green,
          'fileName': null,
          'jamMulai': '18:30',
          'jamSelesai': '21:00',
        },
      ]);

  void add(Map<String, dynamic> row) => state = [...state, row];
  void removeAt(int index) => state = [...state]..removeAt(index);
  void update(String id, Map<String, dynamic> updated) {
    final i = state.indexWhere((e) => e['id'] == id);
    if (i == -1) return;
    final list = [...state];
    list[i] = {...state[i], ...updated};
    state = list;
  }
}

final lemburProvider =
    StateNotifierProvider<LemburNotifier, List<Map<String, dynamic>>>(
      (ref) => LemburNotifier(),
    );
final lemburSearchProvider = StateProvider<String>((ref) => '');
final lemburStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredLemburProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final list = ref.watch(lemburProvider);
  final q = ref.watch(lemburSearchProvider).toLowerCase().trim();
  final status = ref.watch(lemburStatusFilterProvider);
  return list.where((e) {
    final matchesQuery =
        q.isEmpty ||
        (e['type']?.toString().toLowerCase().contains(q) ?? false) ||
        (e['reason']?.toString().toLowerCase().contains(q) ?? false) ||
        (e['id']?.toString().toLowerCase().contains(q) ?? false);
    final matchesStatus = status == 'Semua' || e['status'] == status;
    return matchesQuery && matchesStatus;
  }).toList();
});

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

  void _showDetailDialog(Map<String, dynamic> lembur) {
    final theme = ref.read(themeProvider);
    final statusColor =
        lembur['statusColor'] as Color? ?? _statusColor(lembur['status']);
    final canEdit = _canEdit(lembur);

    final List<String> missingFields = [];
    if (lembur['id'] == null || lembur['id'].toString().isEmpty)
      missingFields.add('ID');
    if (lembur['type'] == null || lembur['type'].toString().isEmpty)
      missingFields.add('Jenis Lembur');
    if (lembur['reason'] == null || lembur['reason'].toString().isEmpty)
      missingFields.add('Kegiatan');
    if (lembur['duration'] == null || lembur['duration'].toString().isEmpty)
      missingFields.add('Durasi');

    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: lembur['status'] ?? 'N/A',
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    final dataFields = [
      SIHAKIDialogField(label: 'ID Lembur', value: lembur['id'] ?? 'N/A'),
      SIHAKIDialogField(
        label: 'Tanggal',
        value: DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(lembur['date'] as DateTime? ?? DateTime.now()),
      ),
      SIHAKIDialogField(label: 'Jenis Lembur', value: lembur['type'] ?? 'N/A'),
      SIHAKIDialogField(label: 'Durasi', value: lembur['duration'] ?? 'N/A'),
      SIHAKIDialogField(label: 'Kegiatan', value: lembur['reason'] ?? 'N/A'),
      if (lembur['fileName'] != null)
        SIHAKIDialogField(label: 'Berkas Lampiran', value: lembur['fileName']),
    ];

    final allFields = [statusField, ...dataFields];

    final actions = <SIHAKIDialogAction>[];

    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Ubah Lembur',
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
      title: 'Detail Lembur',
      fields: allFields,
      actions: actions,
      additionalContent: additionalContent,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  bool _canEdit(Map<String, dynamic> lembur) {
    final status = lembur['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  String _formatTimeRange(Map<String, dynamic> row) {
    // Try new format first (jamMulai, jamSelesai)
    final jamMulai = row['jamMulai'];
    final jamSelesai = row['jamSelesai'];

    if (jamMulai != null && jamSelesai != null) {
      return '$jamMulai - $jamSelesai';
    }

    // Fallback to old format (mulai, selesai) with :00 suffix
    final mulai = row['mulai'];
    final selesai = row['selesai'];

    if (mulai != null && selesai != null) {
      return '$mulai:00 - $selesai:00';
    }

    return 'N/A';
  }

  void _confirmDelete(Map<String, dynamic> lembur) {
    final id = lembur['id']?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Lembur',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan lembur $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () {
        final lemburList = ref.read(lemburProvider.notifier);
        final index = ref
            .read(lemburProvider)
            .indexWhere((item) => item['id'] == lembur['id']);
        if (index != -1) {
          lemburList.removeAt(index);
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
        }
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final data = ref.watch(filteredLemburProvider);
    final status = ref.watch(lemburStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Daftar Lembur',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Column(
        children: [
          // Search Section with Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID, jenis, atau kegiatan lembur...',
              margin: const EdgeInsets.symmetric(vertical: 8),
              hasActiveFilters: status != 'Semua',
              onChanged:
                  (value) =>
                      ref.read(lemburSearchProvider.notifier).state = value,
              onFilterReset: () {
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
                      color: theme.primarySwatch,
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
                                label: Text(
                                  statusOption,
                                  style: TextStyle(color: theme.primarySwatch),
                                ),
                                selected: status == statusOption,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              lemburStatusFilterProvider
                                                  .notifier,
                                            )
                                            .state = statusOption,
                                selectedColor: theme.primarySwatch.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: theme.primarySwatch,
                                backgroundColor: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: theme.primarySwatch.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Tambah Lembur button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: theme.primarySwatch,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: theme.primarySwatch.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // List Section
          Expanded(
            child:
                data.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data lembur',
                            style: TextStyle(
                              color: theme.primarySwatch,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final row = data[index];
                        final statusColor =
                            row['statusColor'] as Color? ??
                            _statusColor(row['status']);

                        return AppListCard(
                          title: row['type'] ?? 'N/A',
                          subtitle: row['id'] ?? 'N/A',
                          leading: CircleAvatar(
                            backgroundColor: theme.primarySwatch.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: theme.primarySwatch,
                              size: 20,
                            ),
                          ),
                          trailing: AppStatusChip(
                            label: row['status'] ?? 'N/A',
                            color: statusColor,
                          ),
                          chips: [
                            AppPillChip(
                              icon: Icons.access_time,
                              label: _formatTimeRange(row),
                            ),
                            AppPillChip(
                              icon: Icons.timer,
                              label: row['duration'] ?? 'N/A',
                            ),
                            AppPillChip(
                              icon: Icons.description,
                              label: row['reason'] ?? 'N/A',
                            ),
                          ],
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: () => _showDetailDialog(row),
                              tooltip: 'Lihat Detail',
                              style: IconButton.styleFrom(
                                backgroundColor: theme.primarySwatch
                                    .withOpacity(0.1),
                                foregroundColor: theme.primarySwatch,
                              ),
                            ),
                          ],
                          onTap: () => _showDetailDialog(row),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
