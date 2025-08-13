import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'agenda_model.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class DetailAgendaPage extends ConsumerStatefulWidget {
  final AgendaItem agenda;

  const DetailAgendaPage({Key? key, required this.agenda}) : super(key: key);

  @override
  ConsumerState<DetailAgendaPage> createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends ConsumerState<DetailAgendaPage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Detail Agenda',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Agenda
              Text(
                widget.agenda.judul,
                style: theme.typographyRegular.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    widget.agenda.tanggal,
                    style: theme.typographyRegular.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Waktu
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    widget.agenda.waktu,
                    style: theme.typographyRegular.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Label Deskripsi
              Text(
                'Deskripsi',
                style: theme.typographyRegular.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Isi Deskripsi
              Text(
                widget.agenda.deskripsi,
                style: theme.typographyRegular.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Kembali
              Center(
                child: FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
