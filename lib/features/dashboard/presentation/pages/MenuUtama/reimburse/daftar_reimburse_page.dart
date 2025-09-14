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
    
    // Validasi kelengkapan data
    final List<String> missingFields = [];
    if (reimburse['id'] == null || reimburse['id'].toString().isEmpty) missingFields.add('ID');
    if (reimburse['category'] == null || reimburse['category'].toString().isEmpty) missingFields.add('Kategori');
    if (reimburse['description'] == null || reimburse['description'].toString().isEmpty) missingFields.add('Deskripsi');
    if (reimburse['amount'] == null) missingFields.add('Jumlah');

    // Status field untuk header
    final statusField = SIHAKIDialogField(
      label: 'Status Pengajuan',
      value: reimburse['status'] ?? 'N/A',
      valueStyle: theme.typographyBold.bodyMedium.copyWith(color: statusColor),
      valueColor: statusColor,
    );

    // Data fields
    final amount = reimburse['amount'] as int? ?? 0;
    final formattedAmount = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);

    final dataFields = [
      SIHAKIDialogField(
        label: 'ID Reimburse',
        value: reimburse['id'] ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Kategori',
        value: reimburse['category'] ?? 'N/A',
      ),
      SIHAKIDialogField(
        label: 'Jumlah',
        value: formattedAmount,
      ),
      SIHAKIDialogField(
        label: 'Tanggal',
        value: DateFormat('dd MMMM yyyy', 'id_ID').format(reimburse['date'] as DateTime? ?? DateTime.now()),
      ),
      SIHAKIDialogField(
        label: 'Deskripsi',
        value: reimburse['description'] ?? 'N/A',
      ),
      if (reimburse['fileName'] != null)
        SIHAKIDialogField(
          label: 'Berkas Lampiran',
          value: reimburse['fileName'],
        ),
    ];

    // Gabungkan semua fields
    final allFields = [statusField, ...dataFields];

    // Actions
    final actions = <SIHAKIDialogAction>[];
    
    if (canEdit) {
      actions.addAll([
        SIHAKIDialogAction(
          label: 'Edit Reimburse',
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
    final id = reimburse['id']?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan Reimburse',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan reimburse $id? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () {
        final reimburseList = ref.read(reimburseProvider.notifier);
        final index = ref.read(reimburseProvider).indexWhere((item) => item['id'] == reimburse['id']);
        if (index != -1) {
          reimburseList.removeAt(index);
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
        Navigator.of(context).pop();
      },
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
                      final statusColor = _getStatusColor(reimburse['status']);
                      final amount = reimburse['amount'] as int? ?? 0;
                      final formattedAmount = NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(amount);
                      
                      return AppListCard(
                        title: reimburse['category'] ?? 'N/A',
                        subtitle: reimburse['id'] ?? 'N/A',
                        leading: CircleAvatar(
                          backgroundColor: theme.primarySwatch.withOpacity(0.1),
                          child: Icon(
                            Icons.receipt,
                            color: theme.primarySwatch,
                            size: 20,
                          ),
                        ),
                        trailing: AppStatusChip(
                          label: reimburse['status'] ?? 'N/A',
                          color: statusColor,
                        ),
                        chips: [
                          AppPillChip(
                            icon: Icons.attach_money,
                            label: formattedAmount,
                          ),
                          AppPillChip(
                            icon: Icons.description,
                            label: reimburse['description'] ?? 'N/A',
                          ),
                          if (reimburse['fileName'] != null)
                            AppPillChip(
                              icon: Icons.attach_file,
                              label: reimburse['fileName'],
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
        ],
      ),
    );
  }
}
