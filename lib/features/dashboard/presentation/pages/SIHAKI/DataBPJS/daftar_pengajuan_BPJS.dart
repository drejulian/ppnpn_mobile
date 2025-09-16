import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class BPJSData {
  final String nama;
  final String noBPJS;
  final String nik;
  final String hubunganKeluarga;
  final String tanggalLahir;
  final String namaFaskesTingkat1;

  BPJSData({
    required this.nama,
    required this.noBPJS,
    required this.nik,
    required this.hubunganKeluarga,
    required this.tanggalLahir,
    required this.namaFaskesTingkat1,
  });
}

class DataBpjsPage extends StateNotifier<List<BPJSData>> {
  DataBpjsPage()
    : super([
        BPJSData(
          nama: 'Alfian Kadang, M.M.',
          noBPJS: '000112233445566',
          nik: '3174081234567890',
          hubunganKeluarga: 'Kepala Keluarga',
          tanggalLahir: '15-08-1985',
          namaFaskesTingkat1: 'Puskesmas Cikini',
        ),
        BPJSData(
          nama: 'Budi Santoso',
          noBPJS: '000998877665544',
          nik: '3174089876543210',
          hubunganKeluarga: 'Suami',
          tanggalLahir: '20-03-1980',
          namaFaskesTingkat1: 'Puskesmas Menteng',
        ),
      ]);

  void addBPJSData(BPJSData bpjsData) {
    state = [...state, bpjsData];
  }

  void updateBPJSData(int index, BPJSData updatedData) {
    if (index >= 0 && index < state.length) {
      final newState = [...state];
      newState[index] = updatedData;
      state = newState;
    }
  }

  void removeBPJSData(int index) {
    state = [...state]..removeAt(index);
  }
}

final bpjsDataProvider = StateNotifierProvider<DataBpjsPage, List<BPJSData>>(
  (ref) => DataBpjsPage(),
);

final searchBpjsQueryProvider = StateProvider<String>((ref) => '');

final filteredBpjsDataProvider = Provider<List<BPJSData>>((ref) {
  final query = ref.watch(searchBpjsQueryProvider).toLowerCase().trim();
  final allItems = ref.watch(bpjsDataProvider);
  if (query.isEmpty) return allItems;
  return allItems.where((item) {
    return item.nama.toLowerCase().contains(query) ||
        item.noBPJS.toLowerCase().contains(query) ||
        item.nik.toLowerCase().contains(query) ||
        item.hubunganKeluarga.toLowerCase().contains(query) ||
        item.tanggalLahir.toLowerCase().contains(query) ||
        item.namaFaskesTingkat1.toLowerCase().contains(query);
  }).toList();
});

class DaftarPengajuanBPJS extends ConsumerStatefulWidget {
  const DaftarPengajuanBPJS({super.key});

  @override
  ConsumerState<DaftarPengajuanBPJS> createState() =>
      _DaftarPengajuanBPJSState();
}

class _DaftarPengajuanBPJSState extends ConsumerState<DaftarPengajuanBPJS> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchBpjsQueryProvider.notifier).state = _searchController.text;
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
    final filteredItems = ref.watch(filteredBpjsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data BPJS',
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
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppFilterBar(
              controller: _searchController,
              labelText: 'Cari Data BPJS',
              hintText: 'Nama, nomor BPJS, tanggal, jenis...',
              onChanged: (_) {},
              onClear:
                  () => ref.read(searchBpjsQueryProvider.notifier).state = '',
              cardMargin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
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
                onPressed: () => context.pushNamed(Routes.tambahBPJS.name),
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
                  'TAMBAH DATA BPJS',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child:
                  filteredItems.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data BPJS',
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
                          return _buildBpjsCard(item, theme, index);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBpjsCard(BPJSData item, dynamic theme, int index) {
    return AppListCard(
      onTap: () => _showDetailDialog(item, theme, index),
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
          Icons.medical_services,
          color: theme.primarySwatch,
          size: 24,
        ),
      ),
      title: item.nama,
      subtitle: 'No BPJS: ${item.noBPJS}',
      chips: [
        AppPillChip(
          icon: Icons.confirmation_num_rounded,
          label: item.noBPJS,
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.badge_rounded,
          label: item.nik,
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: Icons.family_restroom_rounded,
          label: item.hubunganKeluarga,
          color: Colors.green[600],
        ),
      ],
    );
  }

  void _showDetailDialog(BPJSData item, dynamic theme, int index) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail BPJS - ${item.nama}',
      fields: [
        SIHAKIDialogField(label: 'Nama', value: item.nama),
        SIHAKIDialogField(label: 'Nomor BPJS', value: item.noBPJS),
        SIHAKIDialogField(label: 'NIK', value: item.nik),
        SIHAKIDialogField(
          label: 'Hubungan Keluarga',
          value: item.hubunganKeluarga,
        ),
        SIHAKIDialogField(label: 'Tanggal Lahir', value: item.tanggalLahir),
        SIHAKIDialogField(
          label: 'Nama Faskes Tingkat 1',
          value: item.namaFaskesTingkat1,
        ),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Edit Data',
          backgroundColor: Colors.orange[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(
              Routes.editBPJS.name,
              pathParameters: {'index': index.toString()},
              extra: item,
            );
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Data',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(item, index);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _confirmDelete(BPJSData item, int index) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Data BPJS',
      message:
          'Apakah Anda yakin ingin menghapus data BPJS untuk "${item.nama}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        ref.read(bpjsDataProvider.notifier).removeBPJSData(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data BPJS untuk "${item.nama}" berhasil dihapus'),
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
