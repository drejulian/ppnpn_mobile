import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class BuktiPotongPajakA1Page extends ConsumerStatefulWidget {
  const BuktiPotongPajakA1Page({Key? key}) : super(key: key);

  static final List<Map<String, String>> a1Data = [
    {
      'tahun': '2024',
      'bulan': '01',
      'nama_bulan': 'Januari',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '02',
      'nama_bulan': 'Februari',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '03',
      'nama_bulan': 'Maret',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '04',
      'nama_bulan': 'April',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '05',
      'nama_bulan': 'Mei',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '06',
      'nama_bulan': 'Juni',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '07',
      'nama_bulan': 'Juli',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
    {
      'tahun': '2024',
      'bulan': '08',
      'nama_bulan': 'Agustus',
      'penghasilan': 'GAJI, HONORARIUM DAN SEJENISNYA',
      'jumlah_penghasilan_bruto': '45.000.000',
      'pkp': '41.580.000',
      'tarif': '5',
      'pph_dipotong': '2.079.000',
    },
  ];

  @override
  ConsumerState<BuktiPotongPajakA1Page> createState() =>
      _BuktiPotongPajakA2PageState();
}

class _BuktiPotongPajakA2PageState
    extends ConsumerState<BuktiPotongPajakA1Page> {
  final TextEditingController searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  bool get hasActiveFilters => searchController.text.isNotEmpty;

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
    final isTablet = MediaQuery.of(context).size.width > 600;

    final filteredData =
        BuktiPotongPajakA1Page.a1Data.where((row) {
          final searchTerm = searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;
          return row.values.any((v) => v.toLowerCase().contains(searchTerm));
        }).toList();

    final paginatedData = _getPaginatedData(filteredData);
    final totalPages = (filteredData.length / _itemsPerPage).ceil();

    final hasActiveFilters = searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Pajak PPNPN',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SIHAKIPageHeader(
              title: 'PPA PPNPN',
              subtitle: 'Bukti Potong Pajak A1',
              icon: Icons.assignment_rounded,
              isTablet: isTablet,
              quickActions: [
                SIHAKIActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'Surat Keterangan',
                  isTablet: isTablet,
                  onTap: () => context.pushNamed(Routes.skp.name),
                ),
                SIHAKIActionButton(
                  icon: Icons.description_rounded,
                  label: 'Bukti Potong Final',
                  isTablet: isTablet,
                  onTap: () => context.pushNamed(Routes.ppf.name),
                ),
              ],
              statsSection: Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: isTablet ? 20 : 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    'Total ${filteredData.length} data tersedia',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: isTablet ? 14.0 : 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),

            AppSearchBar(
              controller: searchController,
              hintText: 'Cari tahun, bulan, penghasilan...',
              onChanged: (_) => setState(() => _currentPage = 1),
              onClear: () => setState(() => _currentPage = 1),
              hasActiveFilters: hasActiveFilters,
              onFilterReset:
                  hasActiveFilters
                      ? () {
                        searchController.clear();
                        setState(() => _currentPage = 1);
                      }
                      : null,
              margin: EdgeInsets.zero,
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Data List
            if (paginatedData.isEmpty)
              Container(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Data tidak ditemukan',
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (searchController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primarySwatch,
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
              Column(
                children:
                    paginatedData.map((row) {
                      return SIHAKICard(
                        title: '${row['nama_bulan']} ${row['tahun']}',
                        periode: '${row['nama_bulan']} ${row['tahun']}',
                        penghasilan: row['penghasilan']!,
                        tahun: row['tahun']!,
                        bulan: row['bulan']!,
                        isTablet: isTablet,
                        onTap: () => _showDetailDialog(row, theme),
                        onPrint:
                            () => _showPrintConfirmation(
                              context,
                              row['tahun']!,
                              row['bulan']!,
                            ),
                        onWhatsApp:
                            () => _showWhatsappConfirmation(
                              context,
                              row['tahun']!,
                              row['bulan']!,
                            ),
                      );
                    }).toList(),
              ),

            // Pagination
            if (filteredData.length > _itemsPerPage)
              SIHAKIPagination(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPrevious:
                    _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                onNext:
                    _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                primaryColor: theme.primarySwatch,
                theme: theme,
                isTablet: isTablet,
              ),
          ],
        ),
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

    SIHAKIDetailDialog.show(
      context,
      SIHAKIDialogData(
        title: 'Detail PPA ${bulanNames[row['bulan']]} ${row['tahun']}',
        fields: [
          SIHAKIDialogField(
            label: 'Tahun Pajak',
            value: row['tahun']!,
            labelColor: Colors.grey[600],
            valueColor: Colors.grey[800],
          ),
          SIHAKIDialogField(
            label: 'Periode Bulan',
            value: '${bulanNames[row['bulan']]} (${row['bulan']})',
            labelColor: Colors.grey[600],
            valueColor: Colors.grey[800],
          ),
          SIHAKIDialogField(
            label: 'Jenis Penghasilan',
            value: row['penghasilan']!,
            labelColor: Colors.grey[600],
            valueColor: Colors.grey[800],
          ),
          SIHAKIDialogField(
            label: 'Jumlah Penghasilan Bruto',
            value: 'Rp ${_formatCurrency(row['jumlah_penghasilan_bruto']!)}',
            labelColor: Colors.grey[600],
            valueColor: Colors.blue[700],
          ),
          SIHAKIDialogField(
            label: 'Penghasilan Kena Pajak (PKP)',
            value: 'Rp ${_formatCurrency(row['pkp']!)}',
            labelColor: Colors.grey[600],
            valueColor: Colors.blue[700],
          ),
          SIHAKIDialogField(
            label: 'Tarif PPh',
            value: '${row['tarif']}%',
            labelColor: Colors.grey[600],
            valueColor: Colors.orange[700],
          ),
          SIHAKIDialogField(
            label: 'PPh yang Dipotong',
            value: 'Rp ${_formatCurrency(row['pph_dipotong']!)}',
            labelColor: Colors.grey[600],
            valueColor: Colors.red[700],
          ),
          SIHAKIDialogField(
            label: 'Status Dokumen',
            value: 'Tersedia untuk dicetak',
            labelColor: Colors.grey[600],
            valueColor: Colors.green[700],
          ),
        ],
        actions: [
          SIHAKIDialogAction(
            label: 'Cetak Dokumen PPA',
            icon: Icons.print_rounded,
            backgroundColor: Colors.blue[600],
            onTap: () {
              Navigator.of(context).pop();
              _showPrintConfirmation(context, row['tahun']!, row['bulan']!);
            },
          ),
          SIHAKIDialogAction(
            label: 'Kirim via WhatsApp',
            icon: Icons.phone_android_rounded,
            backgroundColor: Colors.green[600],
            onTap: () {
              Navigator.of(context).pop();
              _showWhatsappConfirmation(context, row['tahun']!, row['bulan']!);
            },
          ),
          SIHAKIDialogAction(
            label: 'Unduh PDF',
            icon: Icons.file_download_rounded,
            backgroundColor: Colors.orange[600],
            onTap: () {
              Navigator.of(context).pop();
              _showDownloadConfirmation(context, row['tahun']!, row['bulan']!);
            },
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String amount) {
    final cleanAmount = amount.replaceAll('.', '');
    final num = int.tryParse(cleanAmount) ?? 0;
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showDownloadConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
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

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Unduh Dokumen PPA',
      message:
          'Apakah Anda yakin ingin mengunduh dokumen PPA ${bulanNames[bulan]} $tahun dalam format PDF?',
      confirmText: 'Ya, Unduh Sekarang',
      cancelText: 'Batal',
      icon: Icons.file_download_rounded,
      iconColor: Colors.orange[600],
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PPA ${bulanNames[bulan]} $tahun berhasil diunduh',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _showPrintConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
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

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Konfirmasi Cetak PPA',
      message:
          'Apakah Anda yakin ingin mencetak dokumen PPA ${bulanNames[bulan]} $tahun? Pastikan printer sudah terhubung dan siap digunakan.',
      confirmText: 'Ya, Cetak Sekarang',
      cancelText: 'Batal',
      icon: Icons.print_rounded,
      iconColor: Colors.blue[600],
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.print_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PPA ${bulanNames[bulan]} $tahun sedang dicetak...',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _showWhatsappConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
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

    SIHAKIConfirmationDialog.show(
      context,
      title: 'Kirim via WhatsApp',
      message:
          'Apakah Anda yakin ingin mengirim dokumen PPA ${bulanNames[bulan]} $tahun melalui WhatsApp? Dokumen akan dikirim dalam format PDF.',
      confirmText: 'Ya, Kirim Sekarang',
      cancelText: 'Batal',
      icon: Icons.phone_android_rounded,
      iconColor: Colors.green[600],
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PPA ${bulanNames[bulan]} $tahun sedang dikirim...',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }
}
