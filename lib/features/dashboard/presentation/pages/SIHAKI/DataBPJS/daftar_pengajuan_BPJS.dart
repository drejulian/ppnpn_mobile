import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/bpjs_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/bpjs_model.dart';

class DaftarPengajuanBPJS extends ConsumerStatefulWidget {
  const DaftarPengajuanBPJS({super.key});

  @override
  ConsumerState<DaftarPengajuanBPJS> createState() => _DaftarPengajuanBPJSState();
}

class _DaftarPengajuanBPJSState extends ConsumerState<DaftarPengajuanBPJS> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    // Load data BPJS saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bpjsProvider.notifier).loadBPJS();
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
    final bpjsState = ref.watch(bpjsProvider);
    final filteredData = _filterData(bpjsState.bpjsList);

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
            // Search Bar dengan Filter Status
            AppFilterBar(
              controller: _searchController,
              labelText: 'Cari Data BPJS',
              hintText: 'Nama, nomor BPJS, NIK...',
              onChanged: (_) => setState(() {}),
              onClear: () {
                _searchController.clear();
                setState(() {});
              },
              cardMargin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
            ),
            const SizedBox(height: 12),
            
            // Status Filter
            Row(
              children: [
                Text(
                  'Filter Status: ',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: ['Semua', 'aktif', 'non-aktif', 'pending']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status == 'Semua' ? status : status.toUpperCase(),
                                    style: theme.typographyRegular.bodySmall,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Button with modern styling
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
                onPressed: () async {
                  final result = await context.pushNamed(Routes.tambahBPJS.name);
                  if (mounted && result == true) {
                    // Refresh data setelah kembali dari tambah page
                    ref.read(bpjsProvider.notifier).loadBPJS();
                  }
                },
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
              child: _buildContent(filteredData, bpjsState.isLoading, theme),
            ),
          ],
        ),
      ),
    );
  }

  List<BPJSModel> _filterData(List<BPJSModel> data) {
    var filtered = data;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        final query = _searchController.text.toLowerCase();
        return item.nama.toLowerCase().contains(query) ||
               item.noBPJS.toLowerCase().contains(query) ||
               item.nik.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != 'Semua') {
      filtered = filtered.where((item) => item.status == _selectedStatus).toList();
    }

    return filtered;
  }

  Widget _buildContent(List<BPJSModel> data, bool isLoading, dynamic theme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.primarySwatch,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data BPJS...',
              style: theme.typographyRegular.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return _buildBpjsCard(item, theme);
      },
    );
  }

  Widget _buildBpjsCard(BPJSModel item, dynamic theme) {
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
        _buildStatusChip(item.status, theme),
      ],
    );
  }

  Widget _buildStatusChip(String status, dynamic theme) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case 'aktif':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'non-aktif':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BPJSModel item, dynamic theme) {
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
        SIHAKIDialogField(label: 'Status', value: item.status.toUpperCase()),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Edit Data',
          backgroundColor: Colors.orange[600],
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editBPJS(item);
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
            _confirmDelete(item);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }

  void _editBPJS(BPJSModel item) async {
    final result = await context.pushNamed(
      Routes.editBPJS.name,
      pathParameters: {'index': '0'}, // Parameter untuk routing
      extra: item, // Data BPJS untuk edit
    );
    if (mounted && result == true) {
      // Refresh data setelah kembali dari edit page
      ref.read(bpjsProvider.notifier).loadBPJS();
    }
  }

  void _confirmDelete(BPJSModel item) {
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
      onConfirm: () async {
        if (item.id != null) {
          final success = await ref.read(bpjsProvider.notifier).deleteBPJS(item.id!);
          if (success && mounted) {
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
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Gagal menghapus data BPJS'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
