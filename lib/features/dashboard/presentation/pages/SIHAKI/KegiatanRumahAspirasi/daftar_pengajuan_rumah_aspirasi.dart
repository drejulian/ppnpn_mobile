import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class RumahAspirasiNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  int _nextId = 3;

  RumahAspirasiNotifier()
    : super([
        {
          'id': 1,
          'tanggalSurat': '31-07-2025',
          'tahunSidang': '2024-2025',
          'anggota': 'Alfian Kadang, M.M.',
          'noAnggota': '12345',
          'nikAnggota': '1234567890123456',
          'fraksiAnggota': 'Fraksi A',
          'dapilAnggota': 'Dapil Jakarta I',
          'rekening': '1234567890',
          'namaRekening': 'Alfian Kadang',
          'kodeBank': '014',
          'namaBank': 'Bank BCA',
        },
        {
          'id': 2,
          'tanggalSurat': '15-06-2025',
          'tahunSidang': '2023-2024',
          'anggota': 'Budi Santoso',
          'noAnggota': '67890',
          'nikAnggota': '9876543210987654',
          'fraksiAnggota': 'Fraksi B',
          'dapilAnggota': 'Dapil Jakarta II',
          'rekening': '0987654321',
          'namaRekening': 'Budi Santoso',
          'kodeBank': '008',
          'namaBank': 'Bank Mandiri',
        },
      ]);

  void addRumahAspirasi(Map<String, dynamic> rumahAspirasi) {
    final newItem = {...rumahAspirasi, 'id': _nextId++};
    state = [...state, newItem];
  }

  void updateRumahAspirasi(int id, Map<String, dynamic> updatedData) {
    state = [
      for (final item in state)
        if (item['id'] == id) {...item, ...updatedData} else item,
    ];
  }

  void removeRumahAspirasi(int id) {
    state = state.where((item) => item['id'] != id).toList();
  }
}

final rumahAspirasiDataProvider =
    StateNotifierProvider<RumahAspirasiNotifier, List<Map<String, dynamic>>>(
      (ref) => RumahAspirasiNotifier(),
    );

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredRumahAspirasiProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allItems = ref.watch(rumahAspirasiDataProvider);

  if (query.isEmpty) return allItems;

  return allItems.where((item) {
    return item['tahunSidang'].toString().toLowerCase().contains(query) ||
        item['fraksiAnggota'].toString().toLowerCase().contains(query) ||
        item['noAnggota'].toString().toLowerCase().contains(query) ||
        item['nikAnggota'].toString().toLowerCase().contains(query) ||
        item['dapilAnggota'].toString().toLowerCase().contains(query) ||
        item['namaBank'].toString().toLowerCase().contains(query) ||
        item['tanggalSurat'].toString().toLowerCase().contains(query) ||
        item['rekening'].toString().toLowerCase().contains(query) ||
        item['kodeBank'].toString().toLowerCase().contains(query) ||
        item['anggota'].toString().toLowerCase().contains(query) ||
        item['namaRekening'].toString().toLowerCase().contains(query);
  }).toList();
});

class DaftarPengajuanRumahAspirasiPage extends ConsumerStatefulWidget {
  const DaftarPengajuanRumahAspirasiPage({super.key});

  @override
  ConsumerState<DaftarPengajuanRumahAspirasiPage> createState() =>
      _DaftarPengajuanRumahAspirasiPageState();
}

class _DaftarPengajuanRumahAspirasiPageState
    extends ConsumerState<DaftarPengajuanRumahAspirasiPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredItems = ref.watch(filteredRumahAspirasiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Kegiatan Rumah Aspirasi',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari anggota, tahun sidang, fraksi...',
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              margin: EdgeInsets.zero,
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
                    () => context.pushNamed(Routes.tambahRumahAspirasi.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(
                  'TAMBAH KEGIATAN',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child:
                  filteredItems.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_center_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data kegiatan rumah aspirasi',
                              style: theme.typographyRegular.bodyLarge.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildRumahAspirasiCard(item, theme);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRumahAspirasiCard(Map<String, dynamic> item, dynamic theme) {
    return AppListCard(
      onTap: () => _showDetailDialog(item, theme),
      leftAccentColor: theme.primarySwatch,
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
              theme.primarySwatch.withValues(alpha: 0.2),
              theme.primarySwatch.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primarySwatch.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.business_center,
          color: theme.primarySwatch,
          size: 24,
        ),
      ),
      title: item['anggota'].toString(),
      subtitle: 'ID: ${item['id']} | Tahun: ${item['tahunSidang']}',
      chips: [
        AppPillChip(
          icon: Icons.calendar_today_rounded,
          label: item['tanggalSurat'],
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.groups_rounded,
          label: item['fraksiAnggota'],
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: Icons.account_balance_rounded,
          label: item['namaBank'],
          color: Colors.green[600],
        ),
      ],
      actions: [
        AppViewDetailButton(
          onPressed: () => _showDetailDialog(item, theme),
          tooltip: 'Lihat Detail',
        ),
      ],
    );
  }

  void _showDetailDialog(Map<String, dynamic> item, dynamic theme) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Kegiatan Rumah Aspirasi - ${item['anggota']}',
      fields: [
        SIHAKIDialogField(label: 'ID', value: item['id'].toString()),
        SIHAKIDialogField(label: 'Nama Anggota', value: item['anggota']),
        SIHAKIDialogField(label: 'Tanggal Surat', value: item['tanggalSurat']),
        SIHAKIDialogField(label: 'Tahun Sidang', value: item['tahunSidang']),
        SIHAKIDialogField(label: '', value: ''),
        SIHAKIDialogField(label: 'No. Anggota', value: item['noAnggota']),
        SIHAKIDialogField(label: 'NIK Anggota', value: item['nikAnggota']),
        SIHAKIDialogField(
          label: 'Fraksi Anggota',
          value: item['fraksiAnggota'],
        ),
        SIHAKIDialogField(label: 'Dapil Anggota', value: item['dapilAnggota']),
        SIHAKIDialogField(label: '', value: ''),
        SIHAKIDialogField(label: 'No. Rekening', value: item['rekening']),
        SIHAKIDialogField(label: 'Nama Rekening', value: item['namaRekening']),
        SIHAKIDialogField(label: 'Kode Bank', value: item['kodeBank']),
        SIHAKIDialogField(label: 'Nama Bank', value: item['namaBank']),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Ubah Kegiatan',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editRumahAspirasi.name, extra: item);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Kegiatan',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(item);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _confirmDelete(Map<String, dynamic> item) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Kegiatan',
      message:
          'Apakah Anda yakin ingin menghapus kegiatan rumah aspirasi untuk anggota "${item['anggota']}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        ref
            .read(rumahAspirasiDataProvider.notifier)
            .removeRumahAspirasi(item['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kegiatan rumah aspirasi untuk "${item['anggota']}" berhasil dihapus',
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
