import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class SuratKeteranganPenghasilanAnggotaPage extends ConsumerStatefulWidget {
  const SuratKeteranganPenghasilanAnggotaPage({Key? key}) : super(key: key);

  // Static data for SKP
  static final List<Map<String, String>> skpAnggotaData = [
    {
      'tahun': '2024',
      'bulan': '01',
      'nama_bulan': 'Januari',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '02',
      'nama_bulan': 'Februari',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '03',
      'nama_bulan': 'Maret',
      'penghasilan':
          'TUNJANGAN HARI RAYA (THR) TENAGA AHLI ANGGOTA DPR RI (TAA); HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '04',
      'nama_bulan': 'April',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '05',
      'nama_bulan': 'Mei',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '06',
      'nama_bulan': 'Juni',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '07',
      'nama_bulan': 'Juli',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '08',
      'nama_bulan': 'Agustus',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '09',
      'nama_bulan': 'September',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '10',
      'nama_bulan': 'Oktober',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '11',
      'nama_bulan': 'November',
      'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
    {
      'tahun': '2024',
      'bulan': '12',
      'nama_bulan': 'Desember',
      'penghasilan':
          'TUNJANGAN NATAL TENAGA AHLI ANGGOTA DPR RI (TAA); HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
    },
  ];

  @override
  _SuratKeteranganPenghasilanPageState createState() =>
      _SuratKeteranganPenghasilanPageState();
}

class _SuratKeteranganPenghasilanPageState
    extends ConsumerState<SuratKeteranganPenghasilanAnggotaPage> {
  final TextEditingController searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getPaginatedData(List<Map<String, String>> data) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= data.length) return [];
    return data.sublist(
      startIndex,
      startIndex + _itemsPerPage > data.length
          ? data.length
          : startIndex + _itemsPerPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final primaryColor = theme.primarySwatch;
    final textColor = Colors.grey[800];
    final secondaryTextColor = Colors.grey[600];
    final dividerColor = Colors.grey[200];

    final filteredData =
        SuratKeteranganPenghasilanAnggotaPage.skpAnggotaData.where((row) {
          final searchTerm = searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;
          return row.values.any((v) => v.toLowerCase().contains(searchTerm));
        }).toList();

    final paginatedData = _getPaginatedData(filteredData);
    final totalPages = (filteredData.length / _itemsPerPage).ceil();

    // Check if there are active filters
    final hasActiveFilters = searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Pajak Anggota',
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
      body: Container(
        color: const Color(0xFFF8F9FA),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surat Keterangan Penghasilan (SKP)',
                    style: theme.typographyBold.bodyLarge.copyWith(
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed:
                            () => context.pushNamed(Routes.ppfAnggota.name),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Daftar Bukti Potong Pajak Final',
                          style: theme.typographyRegular.bodyExtraSmall
                              .copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed:
                            () => context.pushNamed(Routes.ppaAnggota.name),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Daftar Bukti Potong Pajak A2',
                          style: theme.typographyRegular.bodyExtraSmall
                              .copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search + Filter using AppFilterBar
            AppFilterBar(
              controller: searchController,
              labelText: 'Pencarian SKP Anggota',
              hintText: 'Cari tahun, bulan, atau jenis penghasilan...',
              onChanged: (_) => setState(() => _currentPage = 1),
              onClear: () => setState(() => _currentPage = 1),
              headerTitle: 'Pencarian',
              hasActiveFilters: hasActiveFilters,
              onReset:
                  hasActiveFilters
                      ? () {
                        searchController.clear();
                        setState(() => _currentPage = 1);
                      }
                      : null,
            ),
            const SizedBox(height: 20),

            // Data List Header
            Row(
              children: [
                Text(
                  'Daftar SKP',
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
                    '${filteredData.length} data',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Divider
            Divider(color: dividerColor, thickness: 1, height: 1),
            const SizedBox(height: 8),

            // Data List
            if (paginatedData.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Data tidak ditemukan',
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      if (searchController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() => _currentPage = 1);
                          },
                          child: const Text('Reset Pencarian'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedData.length,
                  itemBuilder: (context, index) {
                    final row = paginatedData[index];
                    return _buildDataCard(row, theme, primaryColor);
                  },
                ),
              ),

            // Pagination
            if (filteredData.length > _itemsPerPage)
              _buildPaginationControls(totalPages, theme, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
    Map<String, String> row,
    dynamic theme,
    Color primaryColor,
  ) {
    return AppListCard(
      onTap: () => _showDetailDialog(row, theme),
      leftAccentColor: primaryColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50] ?? Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Icon(Icons.receipt_long, size: 18, color: primaryColor),
      ),
      title: '${row['nama_bulan']} ${row['tahun']}',
      subtitle: row['penghasilan']!,
      chips: [
        AppPillChip(icon: Icons.calendar_today, label: 'Bulan ${row['bulan']}'),
      ],
      actions: [
        _buildActionButton(
          icon: Icons.print,
          label: 'Cetak',
          color: Colors.blue,
          onPressed:
              () =>
                  _showPrintConfirmation(context, row['tahun']!, row['bulan']!),
        ),
        _buildActionButton(
          icon: Icons.phone,
          label: 'WhatsApp',
          color: Colors.green,
          onPressed:
              () => _showWhatsappConfirmation(
                context,
                row['tahun']!,
                row['bulan']!,
              ),
        ),
      ],
    );
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

  Widget _buildPaginationControls(
    int totalPages,
    dynamic theme,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed:
                _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_currentPage/$totalPages',
              style: theme.typographyBold.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed:
                _currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, String> row, dynamic theme) {
    final bulanNames = {
      '01': 'Januari',
      '02': 'Februari',
      '03': 'Maret',
      '04': 'April',
      '05': 'Mei',
      '06': 'Juni',
      '07': 'Juli',
      '08': 'Agustus',
      '09': 'September',
      '10': 'Oktober',
      '11': 'November',
      '12': 'Desember',
    };

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

                    // Data Period Section
                    Text(
                      'Periode',
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
                          _buildTextField('Tahun', row['tahun']!, theme),
                          _buildTextField(
                            'Bulan',
                            '${bulanNames[row['bulan']]} (${row['bulan']})',
                            theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Income Details Section
                    Text(
                      'Rincian Penghasilan',
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
                            'Jenis Penghasilan',
                            row['penghasilan']!,
                            theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons Section
                    Text(
                      'Aksi',
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.print, size: 18),
                              label: const Text('Cetak SKP'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showPrintConfirmation(
                                  context,
                                  row['tahun']!,
                                  row['bulan']!,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Kirim via WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showWhatsappConfirmation(
                                  context,
                                  row['tahun']!,
                                  row['bulan']!,
                                );
                              },
                            ),
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

  void _showPrintConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Cetak'),
            content: Text('Cetak SKP untuk $bulan/$tahun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('SKP $bulan/$tahun sedang dicetak...'),
                    ),
                  );
                },
                child: const Text(
                  'Cetak',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showWhatsappConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kirim via WhatsApp'),
            content: Text('Kirim SKP $bulan/$tahun via WhatsApp?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('SKP $bulan/$tahun sedang dikirim...'),
                    ),
                  );
                },
                child: const Text(
                  'Kirim',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
