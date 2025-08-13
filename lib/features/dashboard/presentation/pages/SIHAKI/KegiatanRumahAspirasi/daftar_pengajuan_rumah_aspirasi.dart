import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'dart:async';

// StateNotifier for managing RumahAspirasi list
class RumahAspirasiNotifier extends StateNotifier<List<RumahAspirasi>> {
  RumahAspirasiNotifier() : super([
    RumahAspirasi(
      nama: 'Alfian Kadang, M.M.',
      npwp: '81894097956000',
      tanggalSurat: '31-07-2025',
      tahunSidang: '2024-2025',
      noAnggota: '12345',
      nikAnggota: '1234567890123456',
      fraksiAnggota: 'Fraksi A',
      dapilAnggota: 'Dapil Jakarta I',
      rekening: '1234567890',
      kodeBank: '014',
      namaBank: 'Bank BCA',
    ),
    RumahAspirasi(
      nama: 'Budi Santoso',
      npwp: '9876543210987654',
      tanggalSurat: '15-06-2025',
      tahunSidang: '2023-2024',
      noAnggota: '67890',
      nikAnggota: '9876543210987654',
      fraksiAnggota: 'Fraksi B',
      dapilAnggota: 'Dapil Jakarta II',
      rekening: '0987654321',
      kodeBank: '008',
      namaBank: 'Bank Mandiri',
    ),
  ]);

  void addRumahAspirasi(RumahAspirasi rumahAspirasi) {
    state = [...state, rumahAspirasi];
  }

  void removeRumahAspirasi(int index) {
    state = [...state]..removeAt(index);
  }
}

final rumahAspirasiDataProvider = StateNotifierProvider<RumahAspirasiNotifier, List<RumahAspirasi>>((ref) => RumahAspirasiNotifier());

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredRumahAspirasiProvider = Provider<List<RumahAspirasi>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allItems = ref.watch(rumahAspirasiDataProvider);

  if (query.isEmpty) return allItems;

  return allItems.where((item) {
    return item.tahunSidang.toLowerCase().contains(query) ||
           item.fraksiAnggota.toLowerCase().contains(query) ||
           item.noAnggota.toLowerCase().contains(query) ||
           item.nikAnggota.toLowerCase().contains(query) ||
           item.dapilAnggota.toLowerCase().contains(query) ||
           item.namaBank.toLowerCase().contains(query) ||
           item.tanggalSurat.toLowerCase().contains(query) ||
           item.rekening.toLowerCase().contains(query) ||
           item.kodeBank.toLowerCase().contains(query) ||
           item.nama.toLowerCase().contains(query) ||
           item.npwp.toLowerCase().contains(query);
  }).toList();
});

class RumahAspirasi {
  final String nama;
  final String npwp;
  final String tanggalSurat;
  final String tahunSidang;
  final String noAnggota;
  final String nikAnggota;
  final String fraksiAnggota;
  final String dapilAnggota;
  final String rekening;
  final String kodeBank;
  final String namaBank;

  RumahAspirasi({
    required this.nama,
    required this.npwp,
    required this.tanggalSurat,
    required this.tahunSidang,
    required this.noAnggota,
    required this.nikAnggota,
    required this.fraksiAnggota,
    required this.dapilAnggota,
    required this.rekening,
    required this.kodeBank,
    required this.namaBank,
  });
}

class DaftarPengajuanRumahAspirasiPage extends ConsumerStatefulWidget {
  const DaftarPengajuanRumahAspirasiPage({super.key});

  @override
  _DaftarPengajuanRumahAspirasiPageState createState() =>
      _DaftarPengajuanRumahAspirasiPageState();
}

class _DaftarPengajuanRumahAspirasiPageState
    extends ConsumerState<DaftarPengajuanRumahAspirasiPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Sync controller with provider
    _searchController.text = ref.read(searchQueryProvider);
    _searchController.addListener(_onSearchChanged);

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
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
    _animationController?.dispose();
    super.dispose();
  }

  // Method to show the detail dialog
  void _showDetailDialog(BuildContext context, RumahAspirasi rumahAspirasi, dynamic theme) {
    _animationController?.forward();
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: _scaleAnimation!,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        'Detail Rumah Aspirasi',
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
                  // Data Pajak Section
                  Text(
                    'Data Pajak',
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
                      border: Border.all(color: theme.primarySwatch.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'Nama',
                          rumahAspirasi.nama,
                          theme,
                        ),
                        _buildTextField(
                          'NPWP',
                          rumahAspirasi.npwp,
                          theme,
                        ),
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
                      border: Border.all(color: theme.primarySwatch.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'Tanggal Surat',
                          rumahAspirasi.tanggalSurat,
                          theme,
                        ),
                        _buildTextField(
                          'Tahun Sidang',
                          rumahAspirasi.tahunSidang,
                          theme,
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
                      border: Border.all(color: theme.primarySwatch.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'No. Anggota',
                          rumahAspirasi.noAnggota,
                          theme,
                        ),
                        _buildTextField(
                          'NIK Anggota',
                          rumahAspirasi.nikAnggota,
                          theme,
                        ),
                        _buildTextField(
                          'Fraksi Anggota',
                          rumahAspirasi.fraksiAnggota,
                          theme,
                        ),
                        _buildTextField(
                          'Dapil Anggota',
                          rumahAspirasi.dapilAnggota,
                          theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Data Bank Section
                  Text(
                    'Data Bank',
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
                      border: Border.all(color: theme.primarySwatch.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'Rekening',
                          rumahAspirasi.rekening,
                          theme,
                        ),
                        _buildTextField(
                          'Kode Bank',
                          rumahAspirasi.kodeBank,
                          theme,
                        ),
                        _buildTextField(
                          'Nama Bank',
                          rumahAspirasi.namaBank,
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
      ),
    ).then((_) => _animationController?.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredRumahAspirasiProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Rumah Aspirasi',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
            // Search Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan tahun sidang, fraksi, atau nama bank...',
                  hintStyle: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[500],
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.primarySwatch),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: theme.primarySwatch),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(Routes.tambahRumahAspirasi.name),
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
                  'TAMBAH RUMAH ASPIRASI',
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
                  'Daftar Rumah Aspirasi',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

            // Rumah Aspirasi List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Tidak ada data rumah aspirasi'
                                : 'Data tidak ditemukan',
                            style: theme.typographyRegular.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primarySwatch,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
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
                        final rumahAspirasi = filteredList[index];
                        return InkWell(
                          onTap: () => _showDetailDialog(context, rumahAspirasi, theme),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Tanggal Surat: ${rumahAspirasi.tanggalSurat}',
                                          style: theme.typographyRegular.bodySmall.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: theme.primarySwatch,
                                              size: 20,
                                            ),
                                            onPressed: () => context.push(
                                              '/rumah-aspirasi/edit',
                                              extra: rumahAspirasi,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[600],
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              ref.read(rumahAspirasiDataProvider.notifier).removeRumahAspirasi(index);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Data berhasil dihapus'),
                                                  backgroundColor: Colors.red[600],
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildCardItem(
                                    'Tahun Sidang',
                                    rumahAspirasi.tahunSidang,
                                  ),
                                  _buildCardItem(
                                    'Nama',
                                    rumahAspirasi.nama,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
          Divider(
            color: Colors.grey[200],
            thickness: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}