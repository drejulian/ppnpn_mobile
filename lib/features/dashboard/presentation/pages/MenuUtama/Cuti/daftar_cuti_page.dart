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
          // Keep old format for backward compatibility
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
          // Keep old format for backward compatibility
          'jenis': 'Cuti Sakit',
          'tanggal_awal': '02-07-2025',
          'tanggal_akhir': '04-07-2025',
          'alasan': 'Demam tinggi',
        },
      ]);

  // Validasi data cuti sebelum menambahkan
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
    // Validasi format tanggal untuk backward compatibility
    if (data['tanggal_awal'] == null || data['tanggal_awal'].toString().isEmpty) {
      return 'Tanggal awal wajib diisi';
    }
    if (data['tanggal_akhir'] == null || data['tanggal_akhir'].toString().isEmpty) {
      return 'Tanggal akhir wajib diisi';
    }
    return null; // Valid
  }

  // Validasi data untuk update - lebih fleksibel
  String? _validateUpdateData(Map<String, dynamic> data) {
    // Hanya validasi field yang ada dan tidak kosong
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
    return null; // Valid
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
    print('Attempting to update cuti with id: $id and data: $updated'); // Debug log
    final validationError = _validateUpdateData(updated);
    if (validationError != null) {
      print('Validation error: $validationError'); // Debug log
      throw Exception('Validasi gagal: $validationError');
    }
    
    final i = state.indexWhere((e) => e['id'] == id);
    if (i == -1) {
      print('Cuti with id $id not found'); // Debug log
      return;
    }
    
    print('Found cuti at index $i, updating...'); // Debug log
    final list = [...state];
    list[i] = {...state[i], ...updated};
    state = list;
    print('Cuti updated successfully'); // Debug log
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
        // Also search in old format for backward compatibility
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
                      return TransactionCardHelper.cuti(
                        data: cuti,
                        onDetail: () => _showDetailDialog(cuti),
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
                      'Detail Cuti',
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
                
                // Peringatan jika ada field yang belum diisi
                if (missingFields.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
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
                  ),
                ],
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
                        cuti['status'],
                        statusColor,
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Cuti',
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
                      _buildTextField('ID', cuti['id'], theme),
                      _buildTextField(
                        'Tanggal',
                        cuti['duration'] ?? '${cuti['tanggal_awal']} s/d ${cuti['tanggal_akhir']}',
                        theme,
                      ),
                      _buildTextField('Jenis Cuti', cuti['type'] ?? cuti['jenis'], theme),
                      _buildTextField('Durasi', cuti['duration'] ?? 'N/A', theme),
                      _buildTextField(
                        'Alasan',
                        cuti['reason'] ?? cuti['alasan'],
                        theme,
                        isLast: cuti['fileName'] == null,
                      ),
                      if (cuti['fileName'] != null)
                        _buildTextField(
                          'Berkas',
                          cuti['fileName'],
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
                          label: const Text('Edit Cuti'),
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
                            context.pushNamed(Routes.editCuti.name, extra: cuti);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Hapus Cuti'),
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
                            _confirmDelete(cuti);
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
                        label: const Text('Hapus Cuti'),
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
                          _confirmDelete(cuti);
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
    final isRequired = ['ID', 'Jenis Cuti', 'Durasi', 'Alasan'].contains(label);
    final isEmpty = value.isEmpty || value == 'N/A' || value == 'null';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired && isEmpty) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.error,
                size: 12,
                color: Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                '(Wajib diisi)',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isRequired && isEmpty) ? Colors.red.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: (isRequired && isEmpty) 
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Text(
            isEmpty ? '(Belum diisi)' : value,
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: isEmpty ? Colors.red : Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
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

  bool _canEdit(Map<String, dynamic> cuti) {
    final status = cuti['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _confirmDelete(Map<String, dynamic> cuti) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengajuan Cuti'),
        content: Text('Yakin menghapus pengajuan cuti ${cuti['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final cutiList = ref.read(cutiProvider.notifier);
              final index = ref.read(cutiProvider).indexWhere((item) => item['id'] == cuti['id']);
              if (index != -1) {
                cutiList.removeAt(index);
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengajuan cuti dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}