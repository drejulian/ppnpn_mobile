import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/widgets/sihaki_table.dart';

class BuktiPotongPajakFinalPage extends ConsumerWidget {
  const BuktiPotongPajakFinalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    // Sample data
    final List<Map<String, dynamic>> buktiPotongData = [
      {
        'tahun': '2025',
        'bulan': '01',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
        'jumlah_penghasilan_bruto': '11.800.000',
        'tarif': '15',
        'pph_dipotong': '472.000',
      },
      {
        'tahun': '2025',
        'bulan': '02',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
        'jumlah_penghasilan_bruto': '11.800.000',
        'tarif': '15',
        'pph_dipotong': '472.000',
      },
      {
        'tahun': '2025',
        'bulan': '03',
        'penghasilan':
            'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA); TUNJANGAN HARI RAYA (THR) TENAGA AHLI ANGGOTA DPR RI (TAA)',
        'jumlah_penghasilan_bruto': '19.564.100',
        'tarif': '15',
        'pph_dipotong': '588.461',
      },
      // ... data lainnya sesuai kebutuhan
    ];

    // Definisi kolom untuk table dengan styling baru
    final List<TableColumn> columns = [
      const TableColumn(key: 'tahun', label: 'Tahun', expanded: true),
      const TableColumn(key: 'bulan', label: 'Bulan', expanded: true),
      const TableColumn(
        key: 'penghasilan',
        label: 'Penghasilan',
        width: 200,
        expanded: true,
      ),
      const TableColumn(
        key: 'jumlah_penghasilan_bruto',
        label: 'Jumlah Penghasilan Bruto',
        expanded: true,
      ),
      const TableColumn(key: 'tarif', label: 'Tarif', expanded: true),
      const TableColumn(
        key: 'pph_dipotong',
        label: 'PPh Dipotong',
        expanded: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bukti Potong Pajak Final',
          style: theme.typographyBold.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Bukti Potong Pajak Final',
              style: theme.typographyRegular.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            // Menggunakan simple DataTable dengan background putih
            Card(
              elevation: 2,
              color: Colors.white, // Background card putih
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GenericDataTable(
                  title: '[PPNPN] Daftar Bukti Potong Pajak Final',
                  data: buktiPotongData,
                  columns: columns,
                  showBorder: true,
                  cardBackgroundColor: Colors.white, // Background table putih
                  headerTextStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  actionBuilder:
                      (row) => [
                        TableAction(
                          label: 'CETAK',
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          icon: Icons.print,
                          onPressed: () {
                            TableActionHelpers.showPrintConfirmation(
                              context,
                              'Konfirmasi Cetak',
                              'Anda yakin ingin mencetak Bukti Potong Pajak Final untuk bulan ${row['bulan']} tahun ${row['tahun']}?',
                              () {
                                debugPrint(
                                  'Mencetak untuk ${row['bulan']}/${row['tahun']}',
                                );
                                TableActionHelpers.showSnackBar(
                                  context,
                                  'File Bukti Potong Pajak Final untuk ${row['bulan']}/${row['tahun']} sedang dicetak.',
                                );
                              },
                            );
                          },
                        ),
                        TableAction(
                          label: 'WHATSAPP',
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.message,
                          onPressed: () {
                            TableActionHelpers.showWhatsAppConfirmation(
                              context,
                              'Konfirmasi WhatsApp',
                              'Anda yakin ingin mengirim Bukti Potong Pajak Final untuk bulan ${row['bulan']} tahun ${row['tahun']} via WhatsApp?',
                              () {
                                debugPrint(
                                  'Mengirim via WhatsApp untuk ${row['bulan']}/${row['tahun']}',
                                );
                                TableActionHelpers.showSnackBar(
                                  context,
                                  'File Bukti Potong Pajak Final untuk ${row['bulan']}/${row['tahun']} sedang dikirim via WhatsApp.',
                                );
                              },
                            );
                          },
                        ),
                      ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
