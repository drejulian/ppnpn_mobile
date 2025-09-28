import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/agenda_pribadi_anggota_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/agenda_pribadi_anggota_model.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agenda "${agenda.agenda}" berhasil ditambahkan'),
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
