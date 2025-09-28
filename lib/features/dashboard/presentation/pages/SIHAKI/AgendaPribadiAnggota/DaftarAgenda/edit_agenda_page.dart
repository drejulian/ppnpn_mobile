import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/agenda_pribadi_anggota_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/agenda_pribadi_anggota_model.dart';

class EditAgendaPage extends ConsumerStatefulWidget {
  final AgendaPribadiAnggotaModel agendaItem;

  const EditAgendaPage({super.key, required this.agendaItem});
  @override
  ConsumerState<EditAgendaPage> createState() => _EditAgendaPageState();
}

class _EditAgendaPageState extends ConsumerState<EditAgendaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _agendaController;
  late TextEditingController _keteranganController;
  late TextEditingController _tanggalController;
  late TextEditingController _waktuController;
  late TextEditingController _tempatController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _waktuController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _agendaController = TextEditingController(text: widget.agendaItem.agenda);
    _keteranganController = TextEditingController(
      text: widget.agendaItem.keterangan ?? '',
    );
    _tanggalController = TextEditingController(
      text: widget.agendaItem.tanggal,
    );
    _waktuController = TextEditingController(text: widget.agendaItem.waktu);
    _tempatController = TextEditingController(text: widget.agendaItem.tempat);
  }

  @override
  void dispose() {
    _agendaController.dispose();
    _keteranganController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    _tempatController.dispose();
    super.dispose();
  }

  Future<void> _updateAgenda() async {
    // Simple validation
    if (_agendaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agenda tidak boleh kosong')),
      );
      return;
    }
    if (_tanggalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal tidak boleh kosong')),
      );
      return;
    }
    if (_waktuController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu tidak boleh kosong')),
      );
      return;
    }
    if (_tempatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempat tidak boleh kosong')),
      );
      return;
    }

    // Check if ID exists
    final agendaId = widget.agendaItem.id;
    if (agendaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID agenda tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated agenda
      final updatedAgenda = widget.agendaItem.copyWith(
        agenda: _agendaController.text.trim(),
        tanggal: _tanggalController.text.trim(),
        waktu: _waktuController.text.trim(),
        tempat: _tempatController.text.trim(),
        keterangan: _keteranganController.text.trim().isNotEmpty 
            ? _keteranganController.text.trim() 
            : null,
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(agendaPribadiProvider.notifier)
          .updateAgenda(updatedAgenda);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agenda "${updatedAgenda.agenda}" berhasil diperbarui'),
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
            content: const Text('Gagal memperbarui agenda'),
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
          'Ubah Agenda Pribadi',
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
                title: 'Form Edit Agenda',
                titleIcon: Icons.edit_note,
                fields: [
                  FormFieldConfig(
                    label: 'ID Agenda',
                    icon: Icons.tag,
                    controller: TextEditingController(
                      text: widget.agendaItem.id?.toString() ?? 'NO-ID',
                    ),
                    hintText: 'ID Agenda',
                    type: FormFieldType.text,
                    enabled: false, // ID tidak bisa diedit
                    isRequired: false,
                  ),
                  FormFieldConfig(
                    label: 'Tanggal',
                    icon: Icons.calendar_today,
                    controller: _tanggalController,
                    hintText: 'dd-mm-yyyy',
                    type: FormFieldType.datePicker,
                    suffixIcon: Icons.calendar_today,
                    isRequired: true,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Waktu',
                    icon: Icons.access_time,
                    controller: _waktuController,
                    hintText: 'HH:MM',
                    type: FormFieldType.text,
                    suffixIcon: Icons.access_time,
                    isRequired: true,
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
                    controller: _agendaController,
                    hintText: 'Masukkan nama agenda',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Tempat',
                    icon: Icons.location_on,
                    controller: _tempatController,
                    hintText: 'Masukkan lokasi/tempat',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Keterangan',
                    icon: Icons.description,
                    controller: _keteranganController,
                    hintText: 'Tuliskan keterangan agenda (opsional)',
                    type: FormFieldType.multiline,
                    maxLines: 3,
                    isLast: true,
                    isRequired: false,
                  ),
                ],
                onSave: _isLoading ? null : () => _updateAgenda(),
                saveButtonText: _isLoading ? 'MENYIMPAN...' : 'SIMPAN PERUBAHAN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
