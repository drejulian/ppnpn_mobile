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
final selectedStatusProvider = StateProvider<String>((ref) => 'Semua Status');

final filteredKunkerProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(selectedStatusProvider);
  final allItems = ref.watch(kunkerDataProvider);

  return allItems.where((item) {
    // Filter by status
    if (statusFilter != 'Semua Status' &&
        item['status_pengajuan'] != statusFilter) {
      return false;
    }

    // Filter by search query
    if (query.isEmpty) return true;

    return item['no_surat'].toString().toLowerCase().contains(query) ||
        item['anggota'].toString().toLowerCase().contains(query) ||
        item['tenaga_ahli'].toString().toLowerCase().contains(query) ||
        item['dapil'].toString().toLowerCase().contains(query) ||
        item['jenis_perjadin'].toString().toLowerCase().contains(query) ||
        item['tanggal_awal'].toString().toLowerCase().contains(query) ||
        item['tanggal_akhir'].toString().toLowerCase().contains(query) ||
        item['status_pengajuan'].toString().toLowerCase().contains(query) ||
        item['status_pencairan'].toString().toLowerCase().contains(query);
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
    final selectedStatus = ref.watch(selectedStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Kunker Perorangan',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go("/home"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search + Filter (Cuti-style)
            AppFilterBar(
              controller: _searchController,
              labelText: 'Cari Pengajuan Kunker',
              hintText: 'No. surat, anggota, TA, dapil, tanggal, status...',
              headerTitle: 'Pencarian & Filter',
              hasActiveFilters:
                  _searchController.text.trim().isNotEmpty ||
                  selectedStatus != 'Semua Status',
              onReset: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(selectedStatusProvider.notifier).state =
                    'Semua Status';
              },
              filterSection: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final opt in const [
                      'Semua Status',
                      'Menunggu Konfirmasi',
                      'Konfirmasi',
                    ])
                      ChoiceChip(
                        avatar: Icon(
                          opt == 'Semua Status'
                              ? Icons.filter_alt
                              : opt == 'Menunggu Konfirmasi'
                              ? Icons.hourglass_bottom
                              : Icons.check_circle,
                          size: 16,
                          color:
                              selectedStatus == opt
                                  ? Colors.white
                                  : theme.primarySwatch,
                        ),
                        label: Text(opt),
                        selected: selectedStatus == opt,
                        onSelected:
                            (_) =>
                                ref
                                    .read(selectedStatusProvider.notifier)
                                    .state = opt,
                        selectedColor: theme.primarySwatch,
                        backgroundColor: Colors.grey[100],
                        labelStyle: theme.typographyRegular.bodyExtraSmall
                            .copyWith(
                              color:
                                  selectedStatus == opt
                                      ? Colors.white
                                      : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                        side: BorderSide(
                          color:
                              selectedStatus == opt
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
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              cardMargin: EdgeInsets.zero,
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    () => context.pushNamed(Routes.tambahKunkerPerorangan.name),
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
                  'TAMBAH PENGAJUAN KUNKER',
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
                  'Daftar Pengajuan Kunker',
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
                    color: theme.primarySwatch.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredList.length} data',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Kunker List
            Expanded(
              child:
                  filteredList.isEmpty
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
                              _searchController.text.isEmpty
                                  ? 'Tidak ada data kunker'
                                  : 'Data tidak ditemukan',
                              style: theme.typographyRegular.bodyMedium
                                  .copyWith(color: Colors.grey[600]),
                            ),
                            if (_searchController.text.isNotEmpty ||
                                ref.read(selectedStatusProvider) !=
                                    'Semua Status') ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primarySwatch,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                  ref
                                      .read(selectedStatusProvider.notifier)
                                      .state = 'Semua Status';
                                },
                                child: const Text('Reset Pencarian'),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusPengajuanColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.assignment, color: statusPengajuanColor),
      ),
      title: kunker['no_surat'].toString(),
      subtitle: kunker['jenis_perjadin'].toString(),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStatusChip(
            kunker['status_pengajuan'],
            statusPengajuanColor,
            theme,
          ),
          if (kunker['status_pencairan'] != '-') ...[
            const SizedBox(height: 8),
            _buildStatusChip(
              kunker['status_pencairan'],
              statusPencairanColor,
              theme,
            ),
          ],
        ],
      ),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today,
          label: '${kunker['tanggal_awal']} - ${kunker['tanggal_akhir']}',
        ),
        AppPillChip(
          icon: Icons.place,
          label: (kunker['dapil'] ?? '-').toString(),
        ),
        AppPillChip(icon: Icons.group, label: kunker['anggota'].toString()),
        AppPillChip(
          icon: Icons.engineering,
          label: kunker['tenaga_ahli'].toString(),
        ),
      ],
      actions: [
        if (isSuccess) ...[
          _buildActionButton(
            icon: Icons.download,
            label: 'Transfer Anggota',
            color: Colors.green,
            onPressed: () => _downloadBuktiTransfer(kunker),
          ),
          _buildActionButton(
            icon: Icons.download,
            label: 'Transfer TA',
            color: Colors.green,
            onPressed: () => _downloadBuktiTransferTA(kunker),
          ),
        ],
        IconButton(
          tooltip: isSuccess ? 'Tidak dapat diedit' : 'Edit',
          icon: Icon(
            Icons.edit,
            color: isSuccess ? Colors.grey : theme.primarySwatch,
          ),
          onPressed: isSuccess ? null : () => _navigateToEditPage(kunker),
        ),
        IconButton(
          tooltip: 'Hapus',
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _confirmDelete(kunker),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: theme.typographyBold.bodySmall?.copyWith(color: color),
      ),
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
    final statusPengajuanColor = _getStatusPengajuanColor(
      kunker['status_pengajuan'],
    );
    final statusPencairanColor =
        kunker['status_pencairan'] != '-'
            ? _getStatusPencairanColor(kunker['status_pencairan'])
            : Colors.transparent;

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
                    // Title
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

                    // Status Section
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
                            kunker['status_pengajuan'],
                            statusPengajuanColor,
                            theme,
                          ),
                          if (kunker['status_pencairan'] != '-') ...[
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[200], thickness: 1),
                            const SizedBox(height: 16),
                            _buildStatusField(
                              'Status Pencairan',
                              kunker['status_pencairan'],
                              statusPencairanColor,
                              theme,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Data Surat Section
                    Text(
                      'Data Surat',
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
                          _buildTextField(
                            'No. Surat',
                            kunker['no_surat'],
                            theme,
                          ),
                          _buildTextField(
                            'Jenis Perjadin',
                            kunker['jenis_perjadin'],
                            theme,
                          ),
                          _buildTextField(
                            'Tanggal',
                            '${kunker['tanggal_awal']} s/d ${kunker['tanggal_akhir']}',
                            theme,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Data Anggota Section
                    Text(
                      'Data Anggota',
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
                          _buildTextField('Anggota', kunker['anggota'], theme),
                          _buildTextField(
                            'Tenaga Ahli',
                            kunker['tenaga_ahli'],
                            theme,
                          ),
                          _buildTextField(
                            'Dapil',
                            kunker['dapil'],
                            theme,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons (if status is Disetujui)
                    if (isSuccess) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Unduh Bukti Transfer Anggota'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _downloadBuktiTransfer(kunker),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Unduh Bukti Transfer TA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _downloadBuktiTransferTA(kunker),
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

  void _downloadBuktiTransfer(Map<String, dynamic> kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer Anggota untuk ${kunker['no_surat']}',
        ),
      ),
    );
  }

  void _downloadBuktiTransferTA(Map<String, dynamic> kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer TA untuk ${kunker['no_surat']}',
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> kunker) {
    final noSurat = kunker['no_surat']?.toString() ?? '';
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Pengajuan'),
            content: Text('Yakin menghapus $noSurat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  final list = ref.read(kunkerDataProvider);
                  final idx = list.indexWhere((e) => e['no_surat'] == noSurat);
                  if (idx != -1) {
                    ref.read(kunkerDataProvider.notifier).removeKunker(idx);
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
