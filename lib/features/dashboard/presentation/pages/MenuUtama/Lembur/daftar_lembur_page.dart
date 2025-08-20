import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class LemburNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LemburNotifier()
    : super([
        {
          'id': 'L-001',
          'tanggal': '20-08-2025',
          'mulai': '19:00',
          'selesai': '22:00',
          'kegiatan': 'Support acara komisi',
          'status': 'Menunggu',
        },
        {
          'id': 'L-002',
          'tanggal': '05-07-2025',
          'mulai': '18:30',
          'selesai': '21:00',
          'kegiatan': 'Rekap data anggaran',
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
    if (status != 'Semua' && e['status'] != status) return false;
    if (q.isEmpty) return true;
    return e.values.any((v) => v.toString().toLowerCase().contains(q));
  }).toList();
});

class DaftarLemburPage extends ConsumerWidget {
  const DaftarLemburPage({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final data = ref.watch(filteredLemburProvider);
    final status = ref.watch(lemburStatusFilterProvider);
    final searchCtrl = TextEditingController(
      text: ref.read(lemburSearchProvider),
    );

    final hasActiveFilters =
        (ref.watch(lemburSearchProvider).trim().isNotEmpty) ||
        (status != 'Semua');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Lembur',
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
              hintText: 'Cari tanggal, jam, atau kegiatan... ',
              onChanged:
                  (v) => ref.read(lemburSearchProvider.notifier).state = v,
              onClear: () => ref.read(lemburSearchProvider.notifier).state = '',
              headerTitle: 'Pencarian & Filter',
              hasActiveFilters: hasActiveFilters,
              onReset: () {
                searchCtrl.clear();
                ref.read(lemburSearchProvider.notifier).state = '';
                ref.read(lemburStatusFilterProvider.notifier).state = 'Semua';
              },
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
                                    .read(lemburStatusFilterProvider.notifier)
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

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(Routes.tambahLembur.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_circle, size: 20),
                label: Text(
                  'AJUKAN LEMBUR',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Count
            Row(
              children: [
                Text(
                  'Daftar Pengajuan Lembur',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${data.length} data',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child:
                  data.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Data tidak ditemukan',
                              style: theme.typographyRegular.bodyMedium
                                  .copyWith(color: Colors.grey[600]),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(lemburSearchProvider.notifier)
                                      .state = '';
                                  ref
                                      .read(lemburStatusFilterProvider.notifier)
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
                        itemBuilder: (context, index) {
                          final row = data[index];
                          return _buildLemburCard(context, row, theme);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLemburCard(
    BuildContext context,
    Map<String, dynamic> row,
    dynamic theme,
  ) {
    final color = _statusColor(row['status']);
    return AppCard(
      onTap: () => _showDetailDialog(context, row, theme),
      leftAccentColor: color,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal ${row['tanggal']}',
                      style: theme.typographyBold.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${row['id']}',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(row['status'], color, theme),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.access_time,
                label: '${row['mulai']} - ${row['selesai']}',
                theme: theme,
              ),
              _pillChip(
                icon: Icons.notes,
                label: row['kegiatan'],
                theme: theme,
              ),
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

  // _buildInfoRow removed (not used in the updated design)

  void _navigateToEdit(BuildContext context, Map<String, dynamic> row) {
    context.pushNamed(Routes.editLembur.name, extra: row);
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
                      'Data Lembur',
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
                          _detailRow('Tanggal', row['tanggal'], theme),
                          _detailRow(
                            'Jam',
                            '${row['mulai']} s/d ${row['selesai']}',
                            theme,
                          ),
                          _detailRow(
                            'Kegiatan',
                            row['kegiatan'],
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
}
