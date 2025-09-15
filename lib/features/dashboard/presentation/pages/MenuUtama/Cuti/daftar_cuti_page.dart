import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class DaftarCutiNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DaftarCutiNotifier()
    : super([
        {
          'id': 'C-001',
          'type': 'Cuti Tahunan',
          'date': DateTime(2025, 8, 12),
          'duration': '3 hari (12-14 Aug)',
          'reason': 'Liburan keluarga',
          'status': 'Menunggu Persetujuan',
          'statusColor': Colors.orange,
          'fileName': null,

          'jenis': 'Cuti Tahunan',
          'tanggal_awal': '12-08-2025',
          'tanggal_akhir': '14-08-2025',
          'alasan': 'Liburan keluarga',
        },
        {
          'id': 'C-002',
          'type': 'Cuti Sakit',
          'date': DateTime(2025, 7, 2),
          'duration': '3 hari (02-04 Jul)',
          'reason': 'Demam tinggi',
          'status': 'Disetujui',
          'statusColor': Colors.green,
          'fileName': null,
      
          'jenis': 'Cuti Sakit',
          'tanggal_awal': '02-07-2025',
          'tanggal_akhir': '04-07-2025',
          'alasan': 'Demam tinggi',
        },
      ]);


  String? _validateCutiData(Map<String, dynamic> data) {
    if (data['id'] == null || data['id'].toString().isEmpty) {
      return 'ID cuti wajib diisi';
    }
    if (data['type'] == null || data['type'].toString().isEmpty) {
      return 'Jenis cuti wajib diisi';
    }
    if (data['date'] == null) {
      return 'Tanggal cuti wajib diisi';
    }
    if (data['duration'] == null || data['duration'].toString().isEmpty) {
      return 'Durasi cuti wajib diisi';
    }
    if (data['reason'] == null || data['reason'].toString().isEmpty) {
      return 'Alasan cuti wajib diisi';
    }
    if (data['status'] == null || data['status'].toString().isEmpty) {
      return 'Status cuti wajib diisi';
    }

    if (data['tanggal_awal'] == null || data['tanggal_awal'].toString().isEmpty) {
      return 'Tanggal awal wajib diisi';
    }
    if (data['tanggal_akhir'] == null || data['tanggal_akhir'].toString().isEmpty) {
      return 'Tanggal akhir wajib diisi';
    }
    return null;
  }


  String? _validateUpdateData(Map<String, dynamic> data) {

    if (data.containsKey('type') && (data['type'] == null || data['type'].toString().isEmpty)) {
      return 'Jenis cuti tidak boleh kosong';
    }
    if (data.containsKey('reason') && (data['reason'] == null || data['reason'].toString().isEmpty)) {
      return 'Alasan cuti tidak boleh kosong';
    }
    if (data.containsKey('jenis') && (data['jenis'] == null || data['jenis'].toString().isEmpty)) {
      return 'Jenis cuti tidak boleh kosong';
    }
    if (data.containsKey('alasan') && (data['alasan'] == null || data['alasan'].toString().isEmpty)) {
      return 'Alasan cuti tidak boleh kosong';
    }
    return null;
  }

  void add(Map<String, dynamic> row) {
    final validationError = _validateCutiData(row);
    if (validationError != null) {
      throw Exception('Validasi gagal: $validationError');
    }
    state = [...state, row];
  }

  void removeAt(int index) => state = [...state]..removeAt(index);
  
  void update(String id, Map<String, dynamic> updated) {
    print('Attempting to update cuti with id: $id and data: $updated');
    final validationError = _validateUpdateData(updated);
    if (validationError != null) {
      print('Validation error: $validationError');
      throw Exception('Validasi gagal: $validationError');
    }
    
    final i = state.indexWhere((e) => e['id'] == id);
    if (i == -1) {
      print('Cuti with id $id not found');
      return;
    }
    
    print('Found cuti at index $i, updating...');
    final list = [...state];
    list[i] = {...state[i], ...updated};
    state = list;
    print('Cuti updated successfully');
  }
}

final cutiProvider =
    StateNotifierProvider<DaftarCutiNotifier, List<Map<String, dynamic>>>(
      (ref) => DaftarCutiNotifier(),
    );
final cutiSearchProvider = StateProvider<String>((ref) => '');
final cutiStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredCutiProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final list = ref.watch(cutiProvider);
  final q = ref.watch(cutiSearchProvider).toLowerCase().trim();
  final status = ref.watch(cutiStatusFilterProvider);
  return list.where((e) {
    final matchesQuery = q.isEmpty ||
        (e['type']?.toString().toLowerCase().contains(q) ?? false) ||
        (e['reason']?.toString().toLowerCase().contains(q) ?? false) ||
        (e['id']?.toString().toLowerCase().contains(q) ?? false) ||
      
        (e['jenis']?.toString().toLowerCase().contains(q) ?? false) ||
        (e['alasan']?.toString().toLowerCase().contains(q) ?? false);
    final matchesStatus = status == 'Semua' || e['status'] == status;
    return matchesQuery && matchesStatus;
  }).toList();
});

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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredCutiProvider);
    final statusFilter = ref.watch(cutiStatusFilterProvider);

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
                  labelText: 'Cari cuti...',
                  hintText: 'Masukkan ID, jenis, atau alasan cuti',
                  headerTitle: 'Pencarian & Filter',
                  hasActiveFilters: statusFilter != 'Semua',
                  onChanged: (value) => ref.read(cutiSearchProvider.notifier).state = value,
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
                                  onSelected: (_) => ref.read(cutiStatusFilterProvider.notifier).state = status,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada data cuti',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final cuti = filteredList[index];
                      final statusColor = cuti['statusColor'] as Color? ?? _statusColor(cuti['status']);
                      
                      return AppListCard(
                        title: cuti['type'] ?? cuti['jenis'] ?? 'N/A',
                        subtitle: cuti['id'] ?? 'N/A',
                        leading: CircleAvatar(
                          backgroundColor: theme.primarySwatch.withOpacity(0.1),
                          child: Icon(
                            Icons.event_available,
                            color: theme.primarySwatch,
                            size: 20,
                          ),
                        ),
                        trailing: AppStatusChip(
                          label: cuti['status'] ?? 'N/A',
                          color: statusColor,
                        ),
                        chips: [
                          AppPillChip(
                            icon: Icons.calendar_today,
                            label: cuti['duration'] ?? '${cuti['tanggal_awal']} s/d ${cuti['tanggal_akhir']}',
                          ),
                          AppPillChip(
                            icon: Icons.description,
                            label: cuti['reason'] ?? cuti['alasan'] ?? 'N/A',
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> cuti) {
    final theme = ref.read(themeProvider);
    final statusColor = cuti['statusColor'] as Color? ?? _statusColor(cuti['status']);
    final canEdit = _canEdit(cuti);
    
    // Validasi kelengkapan data
    final List<String> missingFields = [];
    if (cuti['id'] == null || cuti['id'].toString().isEmpty) missingFields.add('ID');
    if (cuti['type'] == null || cuti['type'].toString().isEmpty) missingFields.add('Jenis Cuti');
    if (cuti['reason'] == null || cuti['reason'].toString().isEmpty) missingFields.add('Alasan');
    if (cuti['duration'] == null || cuti['duration'].toString().isEmpty) missingFields.add('Durasi');

    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: cuti['status'] ?? 'N/A',
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Cuti',
        value: cuti['id'] ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Jenis Cuti',
        value: cuti['type'] ?? cuti['jenis'] ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Tanggal Cuti',
        value: cuti['duration'] ?? '${cuti['tanggal_awal']} s/d ${cuti['tanggal_akhir']}',
      ),
      SIHAKIDialogField(
        label: 'Durasi',
        value: cuti['duration'] ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Alasan',
        value: cuti['reason'] ?? cuti['alasan'] ?? 'N/A',
      ),
      if (cuti['fileName'] != null)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: cuti['fileName'],
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];
    
    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Edit Cuti',
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editCuti.name, extra: cuti);
          },
        ),
        SIHAKIDialogAction(
          label: 'Hapus Cuti',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(cuti);
          },
        ),
      ]);
    } else {
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
      title: 'Detail Cuti',
      fields: allFields,
      actions: actions,
      additionalContent: additionalContent,
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  bool _canEdit(Map<String, dynamic> cuti) {
    final status = cuti['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(Map<String, dynamic> cuti) {
    final id = cuti['id']?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Cuti',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan cuti $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () {
        final cutiList = ref.read(cutiProvider.notifier);
        final index = ref.read(cutiProvider).indexWhere((item) => item['id'] == cuti['id']);
        if (index != -1) {
          cutiList.removeAt(index);
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
        }
        Navigator.of(context).pop();
      },
    );
  }
}