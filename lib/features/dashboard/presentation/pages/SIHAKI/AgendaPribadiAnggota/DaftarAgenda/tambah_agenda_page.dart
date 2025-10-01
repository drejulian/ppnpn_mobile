import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/agenda_pribadi_anggota_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/agenda_pribadi_anggota_model.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';

class TambahAgendaPage extends ConsumerStatefulWidget {
  const TambahAgendaPage({super.key});

  @override
  ConsumerState<TambahAgendaPage> createState() => _TambahAgendaPageState();
}

class _TambahAgendaPageState extends ConsumerState<TambahAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _waktuController = TextEditingController();
  final _agendaController = TextEditingController();
  final _tempatController = TextEditingController();
  final _keteranganController = TextEditingController();
  bool _isLoading = false;

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
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      _waktuController.text = _formatTime(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _waktuController.dispose();
    _agendaController.dispose();
    _tempatController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _saveAgenda() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final agenda = AgendaPribadiAnggotaModel(
        agenda: _agendaController.text.trim(),
        tanggal: _tanggalController.text.trim(),
        waktu: _waktuController.text.trim(),
        tempat: _tempatController.text.trim(),
        keterangan: _keteranganController.text.trim().isNotEmpty 
            ? _keteranganController.text.trim() 
            : null,
      );

      final success = await ref
          .read(agendaPribadiProvider.notifier)
          .addAgenda(agenda);

      if (success && mounted) {
        // Tambah notifikasi in-app
        ref.read(notificationProvider.notifier).addAgendaNotification(
          namaAcara: agenda.agenda,
          tanggal: agenda.tanggal,
          waktu: agenda.waktu,
          deskripsi: agenda.keterangan ?? 'Agenda pribadi di ${agenda.tempat}',
        );
        
        // Kirim notifikasi lokal setelah 2 detik
        await NotificationService.scheduleTaskReminder(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Agenda Pribadi Berhasil Ditambahkan',
          body: '${agenda.agenda} pada ${agenda.tanggal} pukul ${agenda.waktu} telah berhasil dijadwalkan.',
          scheduledDate: DateTime.now().add(const Duration(seconds: 2)),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agenda "${agenda.agenda}" berhasil ditambahkan dan notifikasi akan segera muncul'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menambahkan agenda'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Tambah Agenda',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
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
                    type: FormFieldType.datePicker,
                    controller: _waktuController,
                    isRequired: true,
                    hintText: 'Pilih waktu (contoh: 10:00)',
                    suffixIcon: Icons.access_time,
                    onTap: () => _pickTime(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih waktu agenda';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Agenda',
                    icon: Icons.event,
                    type: FormFieldType.textRequired,
                    controller: _agendaController,
                    isRequired: true,
                    hintText: 'Masukkan nama agenda',
                  ),
                  FormFieldConfig(
                    label: 'Tempat',
                    icon: Icons.location_on,
                    type: FormFieldType.textRequired,
                    controller: _tempatController,
                    isRequired: true,
                    hintText: 'Masukkan lokasi/tempat',
                  ),
                  FormFieldConfig(
                    label: 'Keterangan',
                    icon: Icons.description,
                    type: FormFieldType.multiline,
                    controller: _keteranganController,
                    isRequired: false,
                    hintText: 'Tuliskan keterangan agenda (opsional)',
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
                onSave: _isLoading ? null : _saveAgenda,
                saveButtonText: _isLoading ? 'MENYIMPAN...' : 'TAMBAH AGENDA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
