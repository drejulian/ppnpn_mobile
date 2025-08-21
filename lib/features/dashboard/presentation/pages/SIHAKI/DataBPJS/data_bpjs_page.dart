import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/app/routes.dart'; // Assuming routes are defined here
import 'dart:async';

// StateNotifier for managing BPJSData list
class DataBpjsPage extends StateNotifier<List<BPJSData>> {
  DataBpjsPage() : super([
    BPJSData(
      nama: 'Alfian Kadang, M.M.',
      noBPJS: '000112233445566',
      tanggalBerlaku: '31-07-2025',
      jenisAnggota: 'Penerima Bantuan Iuran',
    ),
    BPJSData(
      nama: 'Budi Santoso',
      noBPJS: '000998877665544',
      tanggalBerlaku: '15-06-2025',
      jenisAnggota: 'Pekerja Penerima Upah',
    ),
  ]);

  void addBPJSData(BPJSData bpjsData) {
    state = [...state, bpjsData];
  }

  void removeBPJSData(int index) {
    state = [...state]..removeAt(index);
  }
}

final bpjsDataProvider = StateNotifierProvider<DataBpjsPage, List<BPJSData>>((ref) => DataBpjsPage());

final searchQueryBPJSProvider = StateProvider<String>((ref) => '');

final filteredBPJSProvider = Provider<List<BPJSData>>((ref) {
  final query = ref.watch(searchQueryBPJSProvider).toLowerCase().trim();
  final allItems = ref.watch(bpjsDataProvider);

  if (query.isEmpty) return allItems;

  return allItems.where((item) {
    return item.nama.toLowerCase().contains(query) ||
           item.noBPJS.toLowerCase().contains(query) ||
           item.tanggalBerlaku.toLowerCase().contains(query) ||
           item.jenisAnggota.toLowerCase().contains(query);
  }).toList();
});

class BPJSData {
  final String nama;
  final String noBPJS;
  final String tanggalBerlaku;
  final String jenisAnggota;

  BPJSData({
    required this.nama,
    required this.noBPJS,
    required this.tanggalBerlaku,
    required this.jenisAnggota,
  });
}

class DaftarBPJSPage extends ConsumerStatefulWidget {
  const DaftarBPJSPage({super.key});

  @override
  _DaftarBPJSPageState createState() => _DaftarBPJSPageState();
}

class _DaftarBPJSPageState
    extends ConsumerState<DaftarBPJSPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryBPJSProvider);
    _searchController.addListener(_onSearchChanged);

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
      ref.read(searchQueryBPJSProvider.notifier).state = _searchController.text;
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

  void _showDetailDialog(BuildContext context, BPJSData bpjsData, dynamic theme) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail BPJS',
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
                    'Data Pribadi',
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
                          bpjsData.nama,
                          theme,
                        ),
                        _buildTextField(
                          'Nomor BPJS',
                          bpjsData.noBPJS,
                          theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Data Keanggotaan',
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
                          'Tanggal Berlaku',
                          bpjsData.tanggalBerlaku,
                          theme,
                        ),
                        _buildTextField(
                          'Jenis Anggota',
                          bpjsData.jenisAnggota,
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
    final filteredList = ref.watch(filteredBPJSProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar BPJS',
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
                  hintText: 'Cari berdasarkan nama, nomor BPJS, atau jenis anggota...',
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
                      ref.read(searchQueryBPJSProvider.notifier).state = '';
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tambah Rumah Aspirasi Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(Routes.daftarPengajuanBPJS.name),
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
                  'Daftar BPJS Baru',
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
                  'Daftar BPJS',
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

            // BPJS Data List
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
                                ? 'Tidak ada data BPJS'
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
                                ref.read(searchQueryBPJSProvider.notifier).state = '';
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
                        final bpjsData = filteredList[index];
                        return InkWell(
                          onTap: () => _showDetailDialog(context, bpjsData, theme),
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
                                          'Tanggal Berlaku: ${bpjsData.tanggalBerlaku}',
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
                                              '/bpjs/edit',
                                              extra: bpjsData,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[600],
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              ref.read(bpjsDataProvider.notifier).removeBPJSData(index);
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
                                    'Nama',
                                    bpjsData.nama,
                                  ),
                                  _buildCardItem(
                                    'Nomor BPJS',
                                    bpjsData.noBPJS,
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