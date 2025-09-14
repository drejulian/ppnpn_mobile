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
    final matchesQuery = q.isEmpty ||
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

  void _showDetailDialog(Map<String, dynamic> izin) {
    final theme = ref.read(themeProvider);
    final statusColor = izin['statusColor'] as Color;
    final canEdit = _canEdit(izin);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, theme.primarySwatch.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Izin',
                      style: theme.typographyRegular.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primarySwatch,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.primarySwatch,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Status',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primarySwatch.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatusField(
                        'Status Pengajuan',
                        izin['status'],
                        statusColor,
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Izin',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primarySwatch.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('ID', izin['id'], theme),
                      _buildTextField(
                        'Tanggal',
                        DateFormat('dd MMMM yyyy', 'id_ID').format(izin['date'] as DateTime),
                        theme,
                      ),
                      _buildTextField('Jenis Izin', izin['type'], theme),
                      _buildTextField('Durasi', izin['duration'], theme),
                      _buildTextField(
                        'Alasan',
                        izin['reason'],
                        theme,
                        isLast: izin['fileName'] == null,
                      ),
                      if (izin['fileName'] != null)
                        _buildTextField(
                          'Berkas',
                          izin['fileName'],
                          theme,
                          isLast: true,
                        ),
                    ],
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Izin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primarySwatch,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/edit-izin', extra: izin);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Hapus Izin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _confirmDelete(izin);
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Hapus Izin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmDelete(izin);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    dynamic theme, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.typographyRegular.bodyMedium.copyWith(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildStatusField(
    String label,
    String value,
    Color color,
    dynamic theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: theme.typographyBold.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  bool _canEdit(Map<String, dynamic> izin) {
    final status = izin['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(Map<String, dynamic> izin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengajuan Izin'),
        content: Text('Yakin menghapus pengajuan izin ${izin['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final izinList = ref.read(izinProvider.notifier);
              final index = ref.read(izinProvider).indexWhere((item) => item['id'] == izin['id']);
              if (index != -1) {
                izinList.removeAt(index);
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengajuan izin dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredIzinProvider);
    final statusFilter = ref.watch(izinStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Izin',
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
                  labelText: 'Cari izin...',
                  hintText: 'Masukkan ID, jenis, atau alasan izin',
                  headerTitle: 'Pencarian & Filter',
                  hasActiveFilters: statusFilter != 'Semua',
                  onChanged: (value) => ref.read(izinSearchProvider.notifier).state = value,
                  onReset: () {
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
                        children: ['Semua', 'Menunggu Persetujuan', 'Disetujui', 'Ditolak']
                            .map((status) => FilterChip(
                                  label: Text(status),
                                  selected: statusFilter == status,
                                  onSelected: (_) => ref.read(izinStatusFilterProvider.notifier).state = status,
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
          
          // Tambah Izin button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
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
            child: filteredList.isEmpty
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
                      return TransactionCardHelper.izin(
                        data: izin,
                        onDetail: () => _showDetailDialog(izin),
                        showEdit: false,
                        showDownload: false,
                        showDetail: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
