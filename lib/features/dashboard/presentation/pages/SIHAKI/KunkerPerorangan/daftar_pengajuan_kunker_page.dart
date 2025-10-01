import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import '../../../providers/sihaki/kunker_provider.dart';
import '../../../../../../common/data/models/sihaki/kunker_model.dart';
import 'dart:async';

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
    final kunkerState = ref.watch(kunkerProvider);
    final filteredList = ref.watch(filteredKunkerProvider);

    // Show loading indicator
    if (kunkerState.isLoading && kunkerState.kunkerList.isEmpty) {
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
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data kunker...'),
            ],
          ),
        ),
      );
    }

    // Show error if exists
    if (kunkerState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${kunkerState.error}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Tutup',
              textColor: Colors.white,
              onPressed: () => ref.read(kunkerProvider.notifier).clearError(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              hintText: 'Cari Pengajuan Kunker',
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                          style: theme.typographyBold.bodySmall.copyWith(
                            color: theme.primarySwatch,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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

  Widget _buildKunkerCard(KunkerModel kunker, dynamic theme) {
    final isSuccess = kunker.statusPencairan == 'Disetujui';
    final statusPengajuanColor = _getStatusPengajuanColor(
      kunker.statusPengajuan,
    );
    final statusPencairanColor =
        kunker.statusPencairan != '-'
            ? _getStatusPencairanColor(kunker.statusPencairan)
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
      title: kunker.noSurat,
      subtitle: kunker.jenisPerjadin,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusChip(
            label: kunker.statusPengajuan,
            color: statusPengajuanColor,
            icon:
                kunker.statusPengajuan == 'Menunggu Konfirmasi'
                    ? Icons.hourglass_bottom_rounded
                    : Icons.check_circle_rounded,
          ),
          if (kunker.statusPencairan != '-') ...[
            const SizedBox(height: 8),
            AppStatusChip(
              label: kunker.statusPencairan,
              color: statusPencairanColor,
              icon:
                  kunker.statusPencairan == 'Disetujui'
                      ? Icons.verified_rounded
                      : Icons.cancel_rounded,
            ),
          ],
        ],
      ),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today_rounded,
          label: '${kunker.tanggalAwal} - ${kunker.tanggalAkhir}',
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.place_rounded,
          label: kunker.dapil.isNotEmpty ? kunker.dapil : '-',
          color: Colors.blue[600],
        ),
        AppPillChip(
          icon: Icons.person_rounded,
          label:
              kunker.anggota.length > 25
                  ? '${kunker.anggota.substring(0, 25)}...'
                  : kunker.anggota,
          color: Colors.green[600],
        ),
        AppPillChip(
          icon: Icons.engineering_rounded,
          label:
              kunker.ta.length > 20
                  ? '${kunker.ta.substring(0, 20)}...'
                  : kunker.ta,
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

  void _navigateToEditPage(KunkerModel kunker) {
    context.pushNamed(Routes.editKunkerPerorangan.name, extra: kunker.toUIMap());
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
    KunkerModel kunker,
    dynamic theme,
  ) {
    final isSuccess = kunker.statusPencairan == 'Disetujui';

    final dialogData = SIHAKIDialogData(
      title: 'Detail Pengajuan - ${kunker.noSurat}',
      fields: [
        SIHAKIDialogField(label: 'No. Surat', value: kunker.noSurat),
        SIHAKIDialogField(
          label: 'Jenis Perjadin',
          value: kunker.jenisPerjadin,
        ),
        SIHAKIDialogField(
          label: 'Periode',
          value: '${kunker.tanggalAwal} s/d ${kunker.tanggalAkhir}',
          valueColor: Colors.blue[700],
        ),
        SIHAKIDialogField(label: 'Anggota DPR', value: kunker.anggota),
        SIHAKIDialogField(label: 'Tenaga Ahli', value: kunker.ta),
        SIHAKIDialogField(label: 'Daerah Pemilihan', value: kunker.dapil),
        SIHAKIDialogField(
          label: 'Status Pengajuan',
          value: kunker.statusPengajuan,
          valueColor: _getStatusPengajuanColor(kunker.statusPengajuan),
        ),
        if (kunker.statusPencairan != '-')
          SIHAKIDialogField(
            label: 'Status Pencairan',
            value: kunker.statusPencairan,
            valueColor: _getStatusPencairanColor(kunker.statusPencairan),
          ),
      ],
      actions: [
        if (!isSuccess)
          SIHAKIDialogAction(
            label: 'Edit Pengajuan',
            icon: Icons.edit_rounded,
            backgroundColor: Colors.orange[600],
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

  // Helper Methods untuk Dialog SIHAKI
  void _downloadBuktiTransfer(KunkerModel kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer Anggota untuk ${kunker.noSurat}',
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _downloadBuktiTransferTA(KunkerModel kunker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mengunduh Bukti Transfer TA untuk ${kunker.noSurat}',
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(KunkerModel kunker) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Pengajuan',
      message:
          'Apakah Anda yakin ingin menghapus pengajuan kunker ${kunker.noSurat}? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        final success = await ref.read(kunkerProvider.notifier).deleteKunkerByNoSurat(kunker.noSurat);
        if (success) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal menghapus pengajuan kunker'),
              backgroundColor: Colors.red[600],
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
