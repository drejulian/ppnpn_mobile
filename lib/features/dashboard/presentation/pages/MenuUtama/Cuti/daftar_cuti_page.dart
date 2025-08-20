import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class CutiNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CutiNotifier()
    : super([
        {
          'id': 'C-001',
          'jenis': 'Cuti Tahunan',
          'tanggal_awal': '12-08-2025',
          'tanggal_akhir': '14-08-2025',
          'alasan': 'Liburan keluarga',
          'status': 'Menunggu',
        },
        {
          'id': 'C-002',
          'jenis': 'Cuti Sakit',
          'tanggal_awal': '02-07-2025',
          'tanggal_akhir': '04-07-2025',
          'alasan': 'Demam tinggi',
          'status': 'Disetujui',
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

final cutiProvider =
    StateNotifierProvider<CutiNotifier, List<Map<String, dynamic>>>(
      (ref) => CutiNotifier(),
    );
final cutiSearchProvider = StateProvider<String>((ref) => '');
final cutiStatusFilterProvider = StateProvider<String>((ref) => 'Semua');

final filteredCutiProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final list = ref.watch(cutiProvider);
  final q = ref.watch(cutiSearchProvider).toLowerCase().trim();
  final status = ref.watch(cutiStatusFilterProvider);
  return list.where((e) {
    if (status != 'Semua' && e['status'] != status) return false;
    if (q.isEmpty) return true;
    return e.values.any((v) => v.toString().toLowerCase().contains(q));
  }).toList();
});

class DaftarCutiPage extends ConsumerWidget {
  const DaftarCutiPage({super.key});

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

  // Small rounded "pill" chip used in cards
  Widget _pillChip({
    required IconData icon,
    required String label,
    required dynamic theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primarySwatch),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.typographyRegular.bodyExtraSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Inclusive days between dd-mm-yyyy strings
  int? _daysBetweenStrings(String start, String end) {
    final a = _parseDate(start);
    final b = _parseDate(end);
    if (a == null || b == null) return null;
    final diff = b.difference(a).inDays;
    return diff >= 0 ? diff + 1 : null;
  }

  DateTime? _parseDate(String s) {
    final parts = s.split('-');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final data = ref.watch(filteredCutiProvider);
    final status = ref.watch(cutiStatusFilterProvider);
    final searchCtrl = TextEditingController(
      text: ref.read(cutiSearchProvider),
    );

    final hasActiveFilters =
        (ref.watch(cutiSearchProvider).trim().isNotEmpty) ||
        (status != 'Semua');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Cuti',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search + Filter using global AppFilterBar
            AppFilterBar(
              controller: searchCtrl,
              labelText: 'Pencarian & Filter',
              hintText: 'Cari jenis, alasan, atau tanggal... ',
              headerTitle: 'Pencarian & Filter',
              hasActiveFilters: hasActiveFilters,
              onReset: () {
                searchCtrl.clear();
                ref.read(cutiSearchProvider.notifier).state = '';
                ref.read(cutiStatusFilterProvider.notifier).state = 'Semua';
              },
              onChanged: (v) => ref.read(cutiSearchProvider.notifier).state = v,
              onClear: () => ref.read(cutiSearchProvider.notifier).state = '',
              filterSection: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final opt in const [
                      'Semua',
                      'Menunggu',
                      'Disetujui',
                      'Ditolak',
                    ])
                      ChoiceChip(
                        avatar: Icon(
                          opt == 'Semua'
                              ? Icons.filter_alt
                              : opt == 'Menunggu'
                              ? Icons.hourglass_bottom
                              : opt == 'Disetujui'
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color:
                              status == opt
                                  ? Colors.white
                                  : theme.primarySwatch,
                        ),
                        label: Text(opt),
                        selected: status == opt,
                        onSelected:
                            (_) =>
                                ref
                                    .read(cutiStatusFilterProvider.notifier)
                                    .state = opt,
                        selectedColor: theme.primarySwatch,
                        backgroundColor: Colors.grey[100],
                        labelStyle: theme.typographyRegular.bodyExtraSmall
                            .copyWith(
                              color:
                                  status == opt
                                      ? Colors.white
                                      : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                        side: BorderSide(
                          color:
                              status == opt
                                  ? theme.primarySwatch
                                  : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tambah Cuti button
            SizedBox(
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
            const SizedBox(height: 16),

            // List / Empty state
            Expanded(
              child:
                  data.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasActiveFilters
                                  ? 'Data tidak ditemukan'
                                  : 'Tidak ada data cuti',
                              style: theme.typographyRegular.bodySmall,
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(cutiSearchProvider.notifier).state =
                                      '';
                                  ref
                                      .read(cutiStatusFilterProvider.notifier)
                                      .state = 'Semua';
                                  searchCtrl.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primarySwatch,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Reset Pencarian'),
                              ),
                            ],
                          ],
                        ),
                      )
                      : ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder:
                            (ctx, i) =>
                                _buildCutiCard(context, ref, data[i], theme),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutiCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
    dynamic theme,
  ) {
    final statusColor = _statusColor(row['status']);

    return AppCard(
      onTap: () => _showDetailDialog(context, row, theme),
      leftAccentColor: statusColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row['jenis'], style: theme.typographyBold.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${row['id']}',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(row['status'], statusColor, theme),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.calendar_today,
                label: '${row['tanggal_awal']} - ${row['tanggal_akhir']}',
                theme: theme,
              ),
              if (_daysBetweenStrings(
                    row['tanggal_awal'].toString(),
                    row['tanggal_akhir'].toString(),
                  ) !=
                  null)
                _pillChip(
                  icon: Icons.timelapse,
                  label:
                      '${_daysBetweenStrings(row['tanggal_awal'], row['tanggal_akhir'])} hari',
                  theme: theme,
                ),
              _pillChip(icon: Icons.notes, label: row['alasan'], theme: theme),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip:
                    row['status'] == 'Disetujui'
                        ? 'Tidak dapat diedit'
                        : 'Edit',
                icon: Icon(
                  Icons.edit,
                  color:
                      row['status'] == 'Disetujui'
                          ? Colors.grey
                          : theme.primarySwatch,
                ),
                onPressed:
                    row['status'] == 'Disetujui'
                        ? null
                        : () => _navigateToEdit(context, row),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, row, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, dynamic theme) {
    IconData icon;
    switch (text) {
      case 'Disetujui':
        icon = Icons.check_circle;
        break;
      case 'Ditolak':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.hourglass_bottom;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.typographyBold.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Map<String, dynamic> row) {
    context.pushNamed(Routes.editCuti.name, extra: row);
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> row,
    dynamic theme,
  ) {
    final color = _statusColor(row['status']);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    theme.primarySwatch.withValues(alpha: 0.05),
                  ],
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
                          'Detail',
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
                      child: _buildStatusChip(row['status'], color, theme),
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
                          color: theme.primarySwatch.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID', row['id'], theme),
                          _detailRow('Jenis', row['jenis'], theme),
                          _detailRow(
                            'Tanggal',
                            '${row['tanggal_awal']} s/d ${row['tanggal_akhir']}',
                            theme,
                          ),
                          _detailRow(
                            'Alasan',
                            row['alasan'],
                            theme,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    dynamic theme, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    Map<String, dynamic> row,
    WidgetRef ref,
  ) {
    final id = row['id']?.toString() ?? '';
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Pengajuan'),
            content: Text('Yakin menghapus $id?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  final list = ref.read(cutiProvider);
                  final idx = list.indexWhere((e) => e['id'] == id);
                  if (idx != -1) {
                    ref.read(cutiProvider.notifier).removeAt(idx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data dihapus')),
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
