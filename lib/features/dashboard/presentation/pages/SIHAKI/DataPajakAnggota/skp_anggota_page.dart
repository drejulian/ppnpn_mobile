import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class SuratKeteranganPenghasilanAnggotaPage extends ConsumerStatefulWidget {
  const SuratKeteranganPenghasilanAnggotaPage({Key? key}) : super(key: key);

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
    final isTablet = MediaQuery.of(context).size.width > 600;

    final filteredData =
        SuratKeteranganPenghasilanAnggotaPage.skpAnggotaData.where((row) {
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
        title: 'Data Pajak Anggota',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SIHAKIPageHeader(
              title: 'SKP Anggota',
              subtitle: 'Surat Keterangan Penghasilan',
              icon: Icons.receipt_long_rounded,
              isTablet: isTablet,
              quickActions: [
                SIHAKIActionButton(
                  icon: Icons.description_rounded,
                  label: 'Bukti Potong Final',
                  isTablet: isTablet,
                  onTap: () => context.pushNamed(Routes.ppfAnggota.name),
                ),
                SIHAKIActionButton(
                  icon: Icons.assignment_rounded,
                  label: 'Bukti Potong A2',
                  isTablet: isTablet,
                  onTap: () => context.pushNamed(Routes.ppaAnggota.name),
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
                    'Total ${filteredData.length} dokumen SKP tersedia',
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
              hintText: 'Cari tahun, bulan, jenis penghasilan...',
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
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 48 : 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      hasActiveFilters
                          ? Icons.search_off_rounded
                          : Icons.inbox_rounded,
                      size: isTablet ? 64 : 56,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Text(
                      hasActiveFilters ? 'Tidak ada hasil' : 'Belum ada data',
                      style: theme.typographyRegular.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontSize: isTablet ? 18.0 : 16.0,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      hasActiveFilters
                          ? 'Coba ubah kata kunci pencarian'
                          : 'Data SKP belum tersedia',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: Colors.grey[500],
                        fontSize: isTablet ? 14.0 : 13.0,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      SizedBox(height: isTablet ? 20 : 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          searchController.clear();
                          setState(() => _currentPage = 1);
                        },
                        icon: Icon(Icons.clear_rounded, color: Colors.white),
                        label: Text(
                          'Reset Pencarian',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],
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
            if (totalPages > 1) ...[
              SizedBox(height: isTablet ? 24 : 20),
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
        title: 'Detail SKP ${bulanNames[row['bulan']]} ${row['tahun']}',
        fields: [
          SIHAKIDialogField(label: 'Tahun', value: row['tahun']!),
          SIHAKIDialogField(
            label: 'Bulan',
            value: '${bulanNames[row['bulan']]} (${row['bulan']})',
          ),
          SIHAKIDialogField(
            label: 'Jenis Penghasilan',
            value: row['penghasilan']!,
          ),
        ],
        actions: [
          SIHAKIDialogAction(
            label: 'Cetak SKP',
            icon: Icons.print_rounded,
            backgroundColor: Colors.blue[600],
            onTap: () {
              Navigator.of(context).pop();
              _showPrintConfirmation(context, row['tahun']!, row['bulan']!);
            },
          ),
          SIHAKIDialogAction(
            label: 'Kirim WhatsApp',
            icon: Icons.phone_android_rounded,
            backgroundColor: Colors.green[600],
            onTap: () {
              Navigator.of(context).pop();
              _showWhatsappConfirmation(context, row['tahun']!, row['bulan']!);
            },
          ),
          SIHAKIDialogAction(
            label: 'Unduh PDF',
            icon: Icons.download_rounded,
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
      title: 'Konfirmasi Cetak SKP',
      message:
          'Apakah Anda yakin ingin mencetak dokumen SKP ${bulanNames[bulan]} $tahun?',
      confirmText: 'Ya, Cetak Sekarang',
      cancelText: 'Batal',
      icon: Icons.print_rounded,
      iconColor: Colors.blue,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKP ${bulanNames[bulan]} $tahun sedang dicetak...'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
          'Apakah Anda yakin ingin mengirim dokumen SKP ${bulanNames[bulan]} $tahun melalui WhatsApp?',
      confirmText: 'Ya, Kirim Sekarang',
      cancelText: 'Batal',
      icon: Icons.phone_android_rounded,
      iconColor: Colors.green,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKP ${bulanNames[bulan]} $tahun sedang dikirim...'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
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
      title: 'Unduh SKP',
      message:
          'Apakah Anda yakin ingin mengunduh dokumen SKP ${bulanNames[bulan]} $tahun dalam format PDF?',
      confirmText: 'Ya, Unduh Sekarang',
      cancelText: 'Batal',
      icon: Icons.download_rounded,
      iconColor: Colors.orange,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKP ${bulanNames[bulan]} $tahun sedang diunduh...'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
