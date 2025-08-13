import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'agenda_model.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:intl/intl.dart';

class DaftarAgendaPage extends ConsumerStatefulWidget {
  const DaftarAgendaPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DaftarAgendaPage> createState() => _DaftarAgendaPageState();
}

class _DaftarAgendaPageState extends ConsumerState<DaftarAgendaPage> {
  final List<AgendaItem> agendaList = [
    AgendaItem(
      id: '1',
      judul: 'Rapat Koordinasi',
      deskripsi: 'Membahas persiapan acara internal.',
      tanggal: '2025-08-10',
      waktu: '10:00',
    ),
    AgendaItem(
      id: '2',
      judul: 'Evaluasi Program',
      deskripsi: 'Menilai keberhasilan program semester lalu.',
      tanggal: '2025-08-12',
      waktu: '13:30',
    ),
    AgendaItem(
      id: '3',
      judul: 'Pelatihan Karyawan',
      deskripsi: 'Pelatihan soft skills untuk seluruh staf.',
      tanggal: '2025-08-15',
      waktu: '09:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final colorTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Daftar Agenda',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: theme.primarySwatch,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header + count (mirip daftar_lembur)
            Row(
              children: [
                Text(
                  'Daftar Agenda',
                  style:
                      theme.typographyRegular.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${agendaList.length} data',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List or empty state
            Expanded(
              child: agendaList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Data tidak ditemukan',
                            style: theme.typographyRegular.bodyMedium
                                .copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: agendaList.length,
                      itemBuilder: (context, index) {
                        final agenda = agendaList[index];
                        return _buildAgendaCard(context, agenda, theme, colorTheme, index);
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Button Tambah (sama style dengan daftar_lembur)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(Routes.tambahAgenda.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_circle, size: 20),
                label: Text(
                  'TAMBAH AGENDA',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard(
    BuildContext context,
    AgendaItem agenda,
    dynamic theme,
    ThemeData colorTheme,
    int index,
  ) {
    final stripeColor = theme.primarySwatch;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.pushNamed(Routes.detailAgenda.name, extra: agenda),
        child: Stack(
          children: [
            // Left colored stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: stripeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: tanggal & ID (mirip struktur lembur)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal ${_formatDate(agenda.tanggal)}',
                              style: theme.typographyBold.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ID: ${agenda.id}',
                              style: theme.typographyRegular.bodyExtraSmall
                                  .copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      // Small time badge on the right (instead of status chip)
                      _buildTimeBadge(_formatTime(agenda.waktu), stripeColor, theme),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 12),

                  // Judul & Deskripsi
                  Text(
                    agenda.judul,
                    style: theme.typographyBold.bodySmall?.copyWith(fontSize: 15.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    agenda.deskripsi,
                    style: theme.typographyRegular.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Action buttons (edit & delete) aligned to right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: Icon(Icons.edit, color: theme.primarySwatch),
                        onPressed: () => context.pushNamed(Routes.editAgenda.name, extra: agenda),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _tampilkanDialogKonfirmasi(context, agenda, index),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBadge(String text, Color color, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: theme.typographyBold.bodySmall?.copyWith(color: color),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = DateFormat("HH:mm").parse(timeString);
      return DateFormat('HH.mm').format(time) + ' WIB';
    } catch (e) {
      return timeString;
    }
  }

  void _tampilkanDialogKonfirmasi(BuildContext context, AgendaItem agenda, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Konfirmasi Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            "Apakah kamu yakin ingin menghapus agenda \"${agenda.judul}\"?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () {
                setState(() => agendaList.removeAt(index));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agenda "${agenda.judul}" telah dihapus'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
