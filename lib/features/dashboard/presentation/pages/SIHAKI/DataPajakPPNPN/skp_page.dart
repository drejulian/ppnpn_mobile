import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart'; // Assuming you have this theme file

class SuratKeteranganPenghasilanPage extends ConsumerWidget {
  const SuratKeteranganPenghasilanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    // Sample data based on the SIHAKI PPNPN UI.docx document
    // In a real application, this data would come from an API call or database.
    final List<Map<String, String>> skpData = [
      {
        'tahun': '2025',
        'bulan': '01',
        'penghasilan':
            'TUNJANGAN PERUMAHAN; UANG KOMUNIKASI INTENSIF DAN PENANGANAN PENGADUAN MASYARAKAT; TUNJANGAN KOMUNIKASI INTENSIF BAGI KETUA, WAKIL KETUA DAN ANGGOTA DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI ANGGARAN DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI LEGISLASI DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; GATI KEHORMATAN ANGGOTA DPR RI; TUNJANGAN UANG KEHORMATAN DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI ANGGARAN DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; TUNJANGAN UNTUK PENINGKATAN PELAKSANAAN FUNGSI PENGAWASAN DAN ANGGARAN SEBAGAI PELAKSANAAN KONSTITUSIONAL DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; TUNJANGAN KOMUNIKASI INTENSIF BAGI KETUA, WAKIL KETUA DAN ANGGOTA DEWAN PERWAKILAN RAKYAT INDONESIA; BANTUAN BIAYA TAGIHAN LISTRIK DAN TELEPON KEPADA ANGGOTA DEWAN PERWAKILAN RAKYAT INDONESIA',
      },
      {
        'tahun': '2025',
        'bulan': '02',
        'penghasilan':
            'GAJI KEHORMATAN ANGGOTA DPR RI; UANG KOMUNIKASI INTENSIF DAN PENANGANAN PENGADUAN MASYARAKAT; TUNJANGAN KOMUNIKASI INTENSIF BAGI KETUA, WAKIL KETUA DAN ANGGOTA DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI ANGGARAN DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI PENGAWASAN DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENINGKATAN FUNGSI LEGISLASI DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; TUNJANGAN UNTUK PENINGKATAN PELAKSANAAN FUNGSI PENGAWASAN DAN ANGGARAN SEBAGAI PELAKSANAAN KONSTITUSIONAL DEWAN PERWAKILAN RAKYAT REPUBLIK INDONESIA; KEGIATAN PENELITIAN DAN PEMANTAUAN PENINGKATAN FUNGSI KONSTITUSIONAL DEWAN KEPADA PIMPINAN ALAT KELENGKAPAN DEWAN PERWAKILAN RAKYAT INDONESIA',
      },
      // You can add more data as needed from the document
      {
        'tahun': '2024',
        'bulan': '01',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '02',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '03',
        'penghasilan':
            'TUNJANGAN HARI RAYA (THR) TENAGA AHLI ANGGOTA DPR RI (TAA); HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '04',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '05',
        'penghasilan':
            'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA); HONOR BULAN KE-13 TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '06',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '07',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '08',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '09',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '10',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '11',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2024',
        'bulan': '12',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2023',
        'bulan': '01',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
      {
        'tahun': '2023',
        'bulan': '05',
        'penghasilan': 'HONORARIUM TENAGA AHLI ANGGOTA DPR RI (TAA)',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surat Keterangan Penghasilan (SKP)',
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
              'Daftar Surat Keterangan Penghasilan',
              style: theme.typographyRegular.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            // Mengatur warna latar belakang tabel secara langsung
            Theme(
              // Menggunakan Theme untuk secara lokal menerapkan DataTableThemeData
              data: Theme.of(context).copyWith(
                dataTableTheme: DataTableThemeData(
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    // Ganti warna baris data di sini
                    if (states.contains(MaterialState.selected)) {
                      return const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withOpacity(0.5); // Warna saat dipilih
                    }
                    // Anda bisa membuat baris genap/ganjil memiliki warna berbeda
                    // Misalnya, baris genap merah gelap, baris ganjil merah lebih terang
                    if (skpData.indexOf(skpData[0]) % 2 == 0) {
                      // Ini hanya contoh, logika sebenarnya harus berdasarkan index di _DataSource
                      return const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ); // Merah gelap untuk baris genap
                    }
                    return const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ); // Merah standar untuk baris ganjil
                  }),
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    return const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ); // Merah sangat gelap untuk header
                  }),
                  // Border radius for table cells if desired, typically not directly on DataTableThemeData
                  // but rather on individual cells or rows if custom painting
                ),
              ),
              child: PaginatedDataTable(
                rowsPerPage: 10,
                headingRowColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  return Colors
                      .blue; // <-- Warna latar belakang header diubah menjadi biru
                }),
                columns: [
                  DataColumn(
                    label: Text(
                      'Tahun',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Sesuaikan warna teks agar kontras dengan latar belakang biru
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Bulan',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Sesuaikan warna teks agar kontras dengan latar belakang biru
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Penghasilan',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Sesuaikan warna teks agar kontras dengan latar belakang biru
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Sesuaikan warna teks agar kontras dengan latar belakang biru
                      ),
                    ),
                  ),
                ],
                source: _DataSource(skpData, context, theme),
                columnSpacing: 40,
                horizontalMargin: 10,
                showCheckboxColumn: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, String>> _data;
  final BuildContext context;
  final dynamic theme;

  _DataSource(this._data, this.context, this.theme);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }
    final row = _data[index];
    return DataRow(
      // Row color is now handled by DataTableThemeData or directly by PaginatedDataTable
      // but if you need to override per row, you can set 'color' here
      cells: [
        DataCell(
          Text(
            row['tahun']!,
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.black,
            ), // Teks di sel data putih
          ),
        ),
        DataCell(
          Text(
            row['bulan']!,
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.black,
            ), // Teks di sel data putih
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              row['penghasilan']!,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.black,
              ), // Teks di sel data putih
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showPrintConfirmation(context, row['tahun']!, row['bulan']!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Tombol putih
                  foregroundColor: Colors.white, // Teks tombol merah gelap
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text('CETAK', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _showWhatsappConfirmation(
                    context,
                    row['tahun']!,
                    row['bulan']!,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.lightGreen, // Tombol WhatsApp hijau terang
                  foregroundColor: Colors.white, // Teks tombol putih
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text('WHATSAPP', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  void _showPrintConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Cetak',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Anda yakin ingin mencetak Surat Keterangan Penghasilan untuk bulan $bulan tahun $tahun?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cetak'),
              onPressed: () {
                debugPrint('Mencetak SKP untuk $bulan/$tahun');
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File SKP untuk $bulan/$tahun sedang dicetak.',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showWhatsappConfirmation(
    BuildContext context,
    String tahun,
    String bulan,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi WhatsApp',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Anda yakin ingin mengirim Surat Keterangan Penghasilan untuk bulan $bulan tahun $tahun via WhatsApp?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                debugPrint('Mengirim SKP untuk $bulan/$tahun via WhatsApp');
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File SKP untuk $bulan/$tahun sedang dikirim via WhatsApp.',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
