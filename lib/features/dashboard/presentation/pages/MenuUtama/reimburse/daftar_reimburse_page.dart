import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:intl/intl.dart';

class ReimburseNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ReimburseNotifier()
    : super([
        {
          'id': 'R-001',
          'category': 'Transport',
          'amount': 100000,
          'description': 'Perjalanan dinas ke Jakarta',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'status': 'Disetujui',
          'fileName': 'nota_transport.pdf',
        },
        {
          'id': 'R-002',
          'category': 'Makan',
          'amount': 75000,
          'description': 'Makan siang rapat dengan klien',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'status': 'Menunggu Persetujuan',
          'fileName': 'struk_restaurant.jpg',
        },
        {
          'id': 'R-003',
          'category': 'Hotel',
          'amount': 350000,
          'description': 'Menginap hotel untuk dinas luar kota',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'status': 'Ditolak',
          'fileName': 'invoice_hotel.pdf',
        },
      ]);

  void addReimburse(Map<String, dynamic> reimburse) {
    state = [...state, reimburse];
  }

  void updateReimburse(int index, Map<String, dynamic> updatedReimburse) {
    final newState = [...state];
    newState[index] = updatedReimburse;
    state = newState;
  }

  void removeAt(int index) => state = [...state]..removeAt(index);
}

final reimburseProvider =
    StateNotifierProvider<ReimburseNotifier, List<Map<String, dynamic>>>(
      (ref) => ReimburseNotifier(),
    );

final reimburseSearchProvider = StateProvider<String>((ref) => '');
final reimburseStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredReimburseProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final list = ref.watch(reimburseProvider);
  final query = ref.watch(reimburseSearchProvider).toLowerCase().trim();
  final status = ref.watch(reimburseStatusFilterProvider);

  return list.where((item) {
    final matchesQuery = query.isEmpty ||
        (item['category']?.toString().toLowerCase().contains(query) ?? false) ||
        (item['description']?.toString().toLowerCase().contains(query) ?? false) ||
        (item['id']?.toString().toLowerCase().contains(query) ?? false);
    final matchesStatus = status == 'Semua' || item['status'] == status;
    return matchesQuery && matchesStatus;
  }).toList();
});

class DaftarReimbursePage extends ConsumerStatefulWidget {
  const DaftarReimbursePage({super.key});

  @override
  ConsumerState<DaftarReimbursePage> createState() => _DaftarReimbursePageState();
}

class _DaftarReimbursePageState extends ConsumerState<DaftarReimbursePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDetailDialog(Map<String, dynamic> reimburse) {
    final theme = ref.read(themeProvider);
    final statusColor = _getStatusColor(reimburse['status']);
    final canEdit = _canEdit(reimburse);

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
              colors: [Colors.white, theme.primarySwatch.withValues(alpha: 0.05)],
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
                      'Detail Reimburse',
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
                      color: theme.primarySwatch.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatusField(
                        'Status Pengajuan',
                        reimburse['status'] ?? '',
                        statusColor,
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Reimburse',
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
                      color: theme.primarySwatch.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('ID', reimburse['id'] ?? '', theme),
                      _buildTextField(
                        'Tanggal',
                        reimburse['date'] != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID').format(reimburse['date'])
                            : '',
                        theme,
                      ),
                      _buildTextField('Kategori', reimburse['category'] ?? '', theme),
                      _buildTextField(
                        'Jumlah', 
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(reimburse['amount'] ?? 0), 
                        theme
                      ),
                      _buildTextField(
                        'Deskripsi',
                        reimburse['description'] ?? '',
                        theme,
                        isLast: reimburse['fileName'] == null,
                      ),
                      if (reimburse['fileName'] != null)
                        _buildTextField(
                          'Berkas',
                          reimburse['fileName'],
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
                          label: const Text('Edit Reimburse'),
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
                            _navigateToEdit(reimburse);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Hapus Reimburse'),
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
                            _confirmDelete(reimburse);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, dynamic theme, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value.isNotEmpty ? value : '-',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField(
    String label,
    String value,
    Color color,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: theme.typographyBold.bodySmall?.copyWith(color: color),
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

  Color _getStatusColor(String? status) {
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

  bool _canEdit(Map<String, dynamic> reimburse) {
    final status = reimburse['status'];
    return status == 'Menunggu Persetujuan' || status == 'Ditolak';
  }

  void _navigateToEdit(Map<String, dynamic> reimburse) {
    context.push('/edit-reimburse', extra: reimburse);
  }

  void _confirmDelete(Map<String, dynamic> reimburse) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengajuan Reimburse'),
        content: Text('Yakin menghapus pengajuan reimburse ${reimburse['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final reimburseList = ref.read(reimburseProvider.notifier);
              final index = ref.read(reimburseProvider).indexWhere((item) => item['id'] == reimburse['id']);
              if (index != -1) {
                reimburseList.removeAt(index);
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengajuan reimburse dihapus')),
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
    final filteredList = ref.watch(filteredReimburseProvider);
    final statusFilter = ref.watch(reimburseStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Reimburse',
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
                  labelText: 'Cari reimburse...',
                  hintText: 'Masukkan ID, kategori, atau deskripsi reimburse',
                  headerTitle: 'Pencarian & Filter',
                  hasActiveFilters: statusFilter != 'Semua',
                  onChanged: (value) => ref.read(reimburseSearchProvider.notifier).state = value,
                  onReset: () {
                    _searchController.clear();
                    ref.read(reimburseSearchProvider.notifier).state = '';
                    ref.read(reimburseStatusFilterProvider.notifier).state = 'Semua';
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
                            .map((statusOption) => FilterChip(
                                  label: Text(statusOption),
                                  selected: statusFilter == statusOption,
                                  onSelected: (_) => ref.read(reimburseStatusFilterProvider.notifier).state = statusOption,
                                  selectedColor: theme.primarySwatch.withValues(alpha: 0.2),
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
          
          // Tambah Reimburse button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/tambah-reimburse'),
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
          
          // List Section
          Expanded(
            child: filteredList.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final reimburse = filteredList[index];
                      return TransactionCardHelper.reimburse(
                        data: reimburse,
                        onDetail: () => _showDetailDialog(reimburse),
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
