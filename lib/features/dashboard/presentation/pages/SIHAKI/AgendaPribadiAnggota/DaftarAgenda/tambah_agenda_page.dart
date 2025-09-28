import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/providers/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'daftar_agenda.dart' show agendaDataProvider;

class TambahAgendaPage extends ConsumerStatefulWidget {
  const TambahAgendaPage({super.key});

  @override
  ConsumerState<TambahAgendaPage> createState() => _TambahAgendaPageState();
}

class _TambahAgendaPageState extends ConsumerState<TambahAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _waktuController = TextEditingController();
  final _acaraController = TextEditingController();
  final _deskripsiController = TextEditingController();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      _tanggalController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _waktuController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _waktuController.dispose();
    _acaraController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Agenda',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormCard(
                title: 'Form Tambah Agenda',
                titleIcon: Icons.event_note,
                fields: [
                  FormFieldConfig(
                    label: 'Tanggal',
                    icon: Icons.calendar_today,
                    type: FormFieldType.datePicker,
                    controller: _tanggalController,
                    isRequired: true,
                    hintText: 'dd-mm-yyyy',
                    suffixIcon: Icons.calendar_today,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Waktu',
                    icon: Icons.access_time,
                    type: FormFieldType.text,
                    controller: _waktuController,
                    isRequired: true,
                    hintText: 'HH:MM',
                    suffixIcon: Icons.access_time,
                    onTap: () => _pickTime(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'Acara',
                    icon: Icons.event,
                    type: FormFieldType.textRequired,
                    controller: _acaraController,
                    isRequired: true,
                    hintText: 'Masukkan nama acara',
                  ),
                  FormFieldConfig(
                    label: 'Deskripsi',
                    icon: Icons.description,
                    type: FormFieldType.multiline,
                    controller: _deskripsiController,
                    isRequired: true,
                    hintText: 'Tuliskan deskripsi agenda',
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
                onSave: () async {
                  if (!_formKey.currentState!.validate()) return;
                  
                  ref.read(agendaDataProvider.notifier).addAgenda({
                    'tanggal': _tanggalController.text.trim(),
                    'waktu': _waktuController.text.trim(),
                    'acara': _acaraController.text.trim(),
                    'deskripsi': _deskripsiController.text.trim(),
                  });
                  
                  // Tambahkan notifikasi ke dalam app (page notifikasi)
                  ref.read(notificationProvider.notifier).addAgendaNotification(
                    namaAcara: _acaraController.text.trim(),
                    tanggal: _tanggalController.text.trim(),
                    waktu: _waktuController.text.trim(),
                    deskripsi: _deskripsiController.text.trim(),
                  );
                  
                  // Kirim notifikasi lokal langsung
                  await _showLocalNotification();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agenda berhasil ditambahkan dan notifikasi dikirim'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.pop();
                  }
                },
                saveButtonText: 'TAMBAH AGENDA',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method untuk mengirim notifikasi lokal
  Future<void> _showLocalNotification() async {
    try {
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Agenda Pribadi Berhasil Ditambahkan',
        body: '${_acaraController.text.trim()} pada ${_tanggalController.text.trim()} pukul ${_waktuController.text.trim()} telah berhasil dijadwalkan.',
        payload: 'agenda_${_acaraController.text.trim()}',
      );
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      debugPrint('Gagal mengirim notifikasi: $e');
    }
  }
}
