import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'dart:async';

class KunkerNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  KunkerNotifier()
    : super([
        {
          'no_surat': 'DPL-01-A425-2025',
          'jenis_perjadin': 'Dapil & setahim',
          'tanggal_awal': '14-02-2025',
          'tanggal_akhir': '16-02-2025',
          'anggota': 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
          'tenaga_ahli': 'Alfian Kadang, M.M. 19-0288',
          'dapil': 'Dapil SULAWESI SELATAN III',
          'status_pengajuan': 'Menunggu Konfirmasi',
          'status_pencairan': '-',
        },
        {
          'no_surat': 'DPL-02-A425-2025',
          'jenis_perjadin': 'Dapil & setahim',
          'tanggal_awal': '07-03-2025',
          'tanggal_akhir': '09-03-2025',
          'anggota': 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
          'tenaga_ahli': 'Frisko Pratama Satireea, M.Si 14-0547',
          'dapil': 'Dapil SULAWESI SELATAN III',
          'status_pengajuan': 'Konfirmasi',
          'status_pencairan': 'Disetujui',
        },
        {
          'no_surat': 'DPL-03-A425-2025',
          'jenis_perjadin': 'Dapil & setahim',
          'tanggal_awal': '14-03-2025',
          'tanggal_akhir': '16-03-2025',
          'anggota': 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
          'tenaga_ahli': 'Alfian Kadang, M.M. 19-0288',
          'dapil': 'Dapil SULAWESI SELATAN III',
          'status_pengajuan': 'Konfirmasi',
          'status_pencairan': 'Ditolak',
        },
        {
          'no_surat': 'DPL-04-A425-2025',
          'jenis_perjadin': 'Dapil & setahim',
          'tanggal_awal': '21-03-2025',
          'tanggal_akhir': '23-03-2025',
          'anggota': 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
          'tenaga_ahli': 'Budi Santoso, S.E. 20-0456',
          'dapil': 'Dapil SULAWESI SELATAN III',
          'status_pengajuan': 'Menunggu Konfirmasi',
          'status_pencairan': '-',
        },
        {
          'no_surat': 'DPL-05-A425-2025',
          'jenis_perjadin': 'Dapil & setahim',
          'tanggal_awal': '28-03-2025',
          'tanggal_akhir': '30-03-2025',
          'anggota': 'EVA STEVANY RATABA, S.H. A-425 Fraksi Partai NasDem',
          'tenaga_ahli': 'Citra Dewi, M.M. 18-0321',
          'dapil': 'Dapil SULAWESI SELATAN III',
          'status_pengajuan': 'Konfirmasi',
          'status_pencairan': 'Disetujui',
        },
      ]);

  void addKunker(Map<String, dynamic> kunker) {
    state = [...state, kunker];
  }

  void removeKunker(int index) {
    state = [...state]..removeAt(index);
  }

  void updateKunker(String noSurat, Map<String, dynamic> updated) {
    final idx = state.indexWhere((e) => e['no_surat'] == noSurat);
    if (idx == -1) return;
    final newList = [...state];
    newList[idx] = {...state[idx], ...updated};
    state = newList;
  }
}

final kunkerDataProvider =
    StateNotifierProvider<KunkerNotifier, List<Map<String, dynamic>>>(
      (ref) => KunkerNotifier(),
    );

final searchQueryProvider = StateProvider<String>((ref) => '');
final kunkerStatusPengajuanFilterProvider = StateProvider<String>(
  (ref) => 'Semua',
);
final kunkerStatusPencairanFilterProvider = StateProvider<String>(
  (ref) => 'Semua',
);

final filteredKunkerProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final statusPengajuan = ref.watch(kunkerStatusPengajuanFilterProvider);
  final statusPencairan = ref.watch(kunkerStatusPencairanFilterProvider);
  final allItems = ref.watch(kunkerDataProvider);

  return allItems.where((item) {
    final matchesQuery =
        query.isEmpty ||
        (item['no_surat'].toString().toLowerCase().contains(query) ||
            item['anggota'].toString().toLowerCase().contains(query) ||
            item['tenaga_ahli'].toString().toLowerCase().contains(query) ||
            item['dapil'].toString().toLowerCase().contains(query) ||
            item['jenis_perjadin'].toString().toLowerCase().contains(query) ||
            item['tanggal_awal'].toString().toLowerCase().contains(query) ||
            item['tanggal_akhir'].toString().toLowerCase().contains(query) ||
            item['status_pengajuan'].toString().toLowerCase().contains(query) ||
            item['status_pencairan'].toString().toLowerCase().contains(query));

    final matchesStatusPengajuan =
        statusPengajuan == 'Semua' ||
        item['status_pengajuan'] == statusPengajuan;

    final matchesStatusPencairan =
        statusPencairan == 'Semua' ||
        item['status_pencairan'] == statusPencairan;

    return matchesQuery && matchesStatusPengajuan && matchesStatusPencairan;
  }).toList();
});

class DaftarPengajuanKunkerPage extends ConsumerStatefulWidget {
  const DaftarPengajuanKunkerPage({super.key});

  @override
  _DaftarPengajuanKunkerPageState createState() =>
      _DaftarPengajuanKunkerPageState();
}

class _DaftarPengajuanKunkerPageState
    extends ConsumerState<DaftarPengajuanKunkerPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  get isSuccess => null;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Color _getStatusPengajuanColor(String status) {
    if (status == 'Menunggu Konfirmasi') return Colors.orange;
    if (status == 'Konfirmasi') return Colors.blue;
    return Colors.grey;
  }

  Color _getStatusPencairanColor(String status) {
    if (status == 'Disetujui') return Colors.green;
    if (status == 'Ditolak') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredKunkerProvider);
    final statusPengajuan = ref.watch(kunkerStatusPengajuanFilterProvider);
    final statusPencairan = ref.watch(kunkerStatusPencairanFilterProvider);
    final hasActiveFilters =
        statusPengajuan != 'Semua' || statusPencairan != 'Semua';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Kunker Perorangan',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari no. surat, anggota, TA, dapil...',
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              margin: EdgeInsets.zero,
              hasActiveFilters: hasActiveFilters,
              onFilterReset: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(kunkerStatusPengajuanFilterProvider.notifier).state =
                    'Semua';
                ref.read(kunkerStatusPencairanFilterProvider.notifier).state =
                    'Semua';
              },
              filterSection: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Status Pengajuan',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        ['Semua', 'Menunggu Konfirmasi', 'Konfirmasi']
                            .map(
                              (status) => FilterChip(
                                label: Text(status),
                                selected: statusPengajuan == status,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              kunkerStatusPengajuanFilterProvider
                                                  .notifier,
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
                  const SizedBox(height: 16),
                  Text(
                    'Filter Status Pencairan',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        ['Semua', 'Disetujui', 'Ditolak', '-']
                            .map(
                              (status) => FilterChip(
                                label: Text(
                                  status == '-' ? 'Belum Ada' : status,
                                ),
                                selected: statusPencairan == status,
                                onSelected:
                                    (_) =>
                                        ref
                                            .read(
                                              kunkerStatusPencairanFilterProvider
                                                  .notifier,
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
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.primarySwatch,
                    theme.primarySwatch.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    () => context.pushNamed(Routes.tambahKunkerPerorangan.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(
                  'TAMBAH PENGAJUAN KUNKER',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daftar Pengajuan Kunker',
                        style: theme.typographyBold.bodyMedium.copyWith(
                          color: theme.primarySwatch,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.primarySwatch.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${filteredList.length} data',
                    style: theme.typographyBold.bodySmall.copyWith(
                      color: theme.primarySwatch,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kunker List
            Expanded(
              child:
                  filteredList.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Belum ada data pengajuan kunker'
                                  : 'Data tidak ditemukan',
                              style: theme.typographyRegular.bodyLarge.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Mulai dengan menambah pengajuan kunker baru'
                                  : 'Coba kata kunci yang berbeda',
                              style: theme.typographyRegular.bodyMedium
                                  .copyWith(color: Colors.grey[500]),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reset Pencarian'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primarySwatch,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final kunker = filteredList[index];
                          return _buildKunkerCard(kunker, theme);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKunkerCard(Map<String, dynamic> kunker, dynamic theme) {
    final isSuccess = kunker['status_pencairan'] == 'Disetujui';
    final statusPengajuanColor = _getStatusPengajuanColor(
      kunker['status_pengajuan'],
    );
    final statusPencairanColor =
        kunker['status_pencairan'] != '-'
            ? _getStatusPencairanColor(kunker['status_pencairan'])
            : Colors.transparent;

    return AppListCard(
      onTap: () => _showDetailDialog(context, kunker, theme),
      leftAccentColor: statusPengajuanColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusPengajuanColor.withValues(alpha: 0.2),
              statusPengajuanColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusPengajuanColor.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.assignment_outlined,
          color: statusPengajuanColor,
          size: 24,
        ),
      ),
      title: kunker['no_surat'].toString(),
      subtitle: kunker['jenis_perjadin'].toString(),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusChip(
            label: kunker['status_pengajuan'],
            color: statusPengajuanColor,
            icon:
                kunker['status_pengajuan'] == 'Menunggu Konfirmasi'
                    ? Icons.hourglass_bottom_rounded
                    : Icons.check_circle_rounded,
          ),
          if (kunker['status_pencairan'] != '-') ...[
            const SizedBox(height: 8),
            AppStatusChip(
              label: kunker['status_pencairan'],
              color: statusPencairanColor,
              icon:
                  kunker['status_pencairan'] == 'Disetujui'
                      ? Icons.verified_rounded
                      : Icons.cancel_rounded,
            ),
          ],
        ],
      ),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today_rounded,
          label: '${kunker['tanggal_awal']} - ${kunker['tanggal_akhir']}',
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.place_rounded,
          label: (kunker['dapil'] ?? '-').toString(),
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: Icons.person_rounded,
          label:
              kunker['anggota'].toString().length > 25
                  ? '${kunker['anggota'].toString().substring(0, 25)}...'
                  : kunker['anggota'].toString(),
          color: Colors.green[600],
        ),
        AppPillChip(
          icon: Icons.engineering_rounded,
          label:
              kunker['tenaga_ahli'].toString().length > 20
                  ? '${kunker['tenaga_ahli'].toString().substring(0, 20)}...'
                  : kunker['tenaga_ahli'].toString(),
          color: Colors.orange[600],
        ),
      ],
      actions: [
        if (isSuccess) ...[
          _buildActionButton(
            icon: Icons.download_rounded,
            label: 'Transfer Anggota',
            color: Colors.green[600]!,
            onPressed: () => _downloadBuktiTransfer(kunker),
          ),
          _buildActionButton(
            icon: Icons.download_rounded,
            label: 'Transfer TA',
            color: Colors.green[600]!,
            onPressed: () => _downloadBuktiTransferTA(kunker),
          ),
        ],
      ],
    );
  }

  void _navigateToEditPage(Map<String, dynamic> kunker) {
    context.pushNamed(Routes.editKunkerPerorangan.name, extra: kunker);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> kunker,
    dynamic theme,
  ) {
    final isSuccess = kunker['status_pencairan'] == 'Disetujui';

    final dialogData = SIHAKIDialogData(
      title: 'Detail Pengajuan - ${kunker['no_surat']}',
      fields: [
        SIHAKIDialogField(label: 'No. Surat', value: kunker['no_surat']),
        SIHAKIDialogField(
          label: 'Jenis Perjadin',
          value: kunker['jenis_perjadin'],
        ),
        SIHAKIDialogField(
          label: 'Periode',
          value: '${kunker['tanggal_awal']} s/d ${kunker['tanggal_akhir']}',
          valueColor: Colors.blue[700],
        ),
        SIHAKIDialogField(label: 'Anggota DPR', value: kunker['anggota']),
        SIHAKIDialogField(label: 'Tenaga Ahli', value: kunker['tenaga_ahli']),
        SIHAKIDialogField(label: 'Daerah Pemilihan', value: kunker['dapil']),
        SIHAKIDialogField(
          label: 'Status Pengajuan',
          value: kunker['status_pengajuan'],
          valueColor: _getStatusPengajuanColor(kunker['status_pengajuan']),
        ),
        if (kunker['status_pencairan'] != '-')
          SIHAKIDialogField(
            label: 'Status Pencairan',
            value: kunker['status_pencairan'],
            valueColor: _getStatusPencairanColor(kunker['status_pencairan']),
          ),
      ],
      actions: [
        if (!isSuccess)
          SIHAKIDialogAction(
            label: 'Ubah Pengajuan',
            icon: Icons.edit_rounded,
            textColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              _navigateToEditPage(kunker);
            },
          ),
        SIHAKIDialogAction(
          label: 'Hapus Pengajuan',
          icon: Icons.delete_rounded,
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            _confirmDelete(kunker);
          },
        ),
        if (isSuccess) ...[
          SIHAKIDialogAction(
            label: 'Bukti Transfer Anggota',
            icon: Icons.download_rounded,
            backgroundColor: Colors.green[600],
            textColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              _downloadBuktiTransfer(kunker);
            },
          ),
          SIHAKIDialogAction(
            label: 'Bukti Transfer TA',
            icon: Icons.download_rounded,
            backgroundColor: Colors.green[600],
            textColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              _downloadBuktiTransferTA(kunker);
            },
          ),
        ],
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _downloadBuktiTransfer(Map<String, dynamic> kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer Anggota untuk ${kunker['no_surat']}',
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _downloadBuktiTransferTA(Map<String, dynamic> kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer TA untuk ${kunker['no_surat']}',
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> kunker) {
    final noSurat = kunker['no_surat']?.toString() ?? '';

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan kunker $noSurat? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () {
        final list = ref.read(kunkerDataProvider);
        final idx = list.indexWhere((e) => e['no_surat'] == noSurat);
        if (idx != -1) {
          ref.read(kunkerDataProvider.notifier).removeKunker(idx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pengajuan kunker berhasil dihapus'),
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
