import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:intl/intl.dart';

class IzinNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  IzinNotifier()
    : super([
        {
          'id': 'I-001',
          'type': 'Izin Sakit',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'duration': '1 hari',
          'reason': 'Sakit demam',
          'status': 'Disetujui',
          'statusColor': Colors.green,
          'fileName': null,
        },
        {
          'id': 'I-002',
          'type': 'Izin Pribadi',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'duration': '2 hari',
          'reason': 'Urusan keluarga',
          'status': 'Menunggu Persetujuan',
          'statusColor': Colors.orange,
          'fileName': null,
        },
        {
          'id': 'I-003',
          'type': 'Izin Lainnya',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'duration': '1 hari',
          'reason': 'Kegiatan komunitas',
          'status': 'Ditolak',
          'statusColor': Colors.red,
          'fileName': null,
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

final izinProvider =
    StateNotifierProvider<IzinNotifier, List<Map<String, dynamic>>>(
      (ref) => IzinNotifier(),
    );
final izinSearchProvider = StateProvider<String>((ref) => '');
final izinStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredIzinProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final list = ref.watch(izinProvider);
  final q = ref.watch(izinSearchProvider).toLowerCase().trim();
  final status = ref.watch(izinStatusFilterProvider);
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

  void _showDetailDialog(Map<String, dynamic> izin) {
    final theme = ref.read(themeProvider);
    final statusColor =
        izin['statusColor'] as Color? ?? _statusColor(izin['status']);
    final canEdit = _canEdit(izin);

    // Validasi kelengkapan data
    final List<String> missingFields = [];
    if (izin['id'] == null || izin['id'].toString().isEmpty)
      missingFields.add('ID');
    if (izin['type'] == null || izin['type'].toString().isEmpty)
      missingFields.add('Jenis Izin');
    if (izin['reason'] == null || izin['reason'].toString().isEmpty)
      missingFields.add('Alasan');
    if (izin['duration'] == null || izin['duration'].toString().isEmpty)
      missingFields.add('Durasi');

    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: izin['status'] ?? 'N/A',
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final dataFields = [
      SIHAKIDialogField(label: 'ID Izin', value: izin['id'] ?? 'N/A'),
      SIHAKIDialogField(label: 'Jenis Izin', value: izin['type'] ?? 'N/A'),
      SIHAKIDialogField(
        label: 'Tanggal Izin',
        value:
            izin['date'] != null
                ? DateFormat('dd MMMM yyyy', 'id_ID').format(izin['date'])
                : 'N/A',
      ),
      SIHAKIDialogField(label: 'Durasi', value: izin['duration'] ?? 'N/A'),
      SIHAKIDialogField(label: 'Alasan', value: izin['reason'] ?? 'N/A'),
      if (izin['fileName'] != null)
        SIHAKIDialogField(label: 'Berkas Lampiran', value: izin['fileName']),
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
            context.push('/edit-izin', extra: izin);
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
      title: 'Detail Izin',
      fields: allFields,
      actions: actions,
      additionalContent: additionalContent,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  bool _canEdit(Map<String, dynamic> izin) {
    final status = izin['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(Map<String, dynamic> izin) {
    final id = izin['id']?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Izin',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan izin $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () {
        final izinList = ref.read(izinProvider.notifier);
        final index = ref
            .read(izinProvider)
            .indexWhere((item) => item['id'] == izin['id']);
        if (index != -1) {
          izinList.removeAt(index);
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
        }
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
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
            child:
                filteredList.isEmpty
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
                            'Tidak ada data izin',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final izin = filteredList[index];
                        final statusColor =
                            izin['statusColor'] as Color? ??
                            _statusColor(izin['status']);

                        return AppListCard(
                          title: izin['type'] ?? 'N/A',
                          subtitle: izin['id'] ?? 'N/A',
                          leading: CircleAvatar(
                            backgroundColor: theme.primarySwatch.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.assignment_ind,
                              color: theme.primarySwatch,
                              size: 20,
                            ),
                          ),
                          trailing: AppStatusChip(
                            label: izin['status'] ?? 'N/A',
                            color: statusColor,
                          ),
                          chips: [
                            AppPillChip(
                              icon: Icons.calendar_today,
                              label: izin['duration'] ?? 'N/A',
                            ),
                            AppPillChip(
                              icon: Icons.description,
                              label: izin['reason'] ?? 'N/A',
                            ),
                          ],
                          actions: [
                            AppViewDetailButton(
                              onPressed: () => _showDetailDialog(izin),
                              tooltip: 'Lihat Detail',
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
