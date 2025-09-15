import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'daftar_agenda.dart' show agendaDataProvider;

class EditAgendaPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> agendaItem;

  const EditAgendaPage({super.key, required this.agendaItem});
  @override
  ConsumerState<EditAgendaPage> createState() => _EditAgendaPageState();
}

class _EditAgendaPageState extends ConsumerState<EditAgendaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _acaraController;
  late TextEditingController _deskripsiController;
  late TextEditingController _tanggalController;
  late TextEditingController _waktuController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
    _acaraController = TextEditingController(text: widget.agendaItem['acara']);
    _deskripsiController = TextEditingController(
      text: widget.agendaItem['deskripsi'],
    );
    _tanggalController = TextEditingController(
      text: widget.agendaItem['tanggal'],
    );
    _waktuController = TextEditingController(text: widget.agendaItem['waktu']);
  }

  @override
  void dispose() {
    _acaraController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    super.dispose();
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
                      text: widget.agendaItem['id']?.toString() ?? 'NO-ID',
                    ),
                    hintText: 'ID Agenda',
                    type: FormFieldType.text,
                    enabled: false,
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
                    label: 'Acara',
                    icon: Icons.event,
                    controller: _acaraController,
                    hintText: 'Masukkan nama acara',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Deskripsi',
                    icon: Icons.description,
                    controller: _deskripsiController,
                    hintText: 'Tuliskan deskripsi agenda',
                    type: FormFieldType.multiline,
                    maxLines: 3,
                    isLast: true,
                    isRequired: true,
                  ),
                ],
                onSave: () {
                  // Simple validation instead of form validation
                  if (_acaraController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Acara tidak boleh kosong')),
                    );
                    return;
                  }
                  if (_tanggalController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tanggal tidak boleh kosong'),
                      ),
                    );
                    return;
                  }
                  if (_waktuController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Waktu tidak boleh kosong')),
                    );
                    return;
                  }
                  if (_deskripsiController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deskripsi tidak boleh kosong'),
                      ),
                    );
                    return;
                  }

                  print('🚀 Starting edit agenda process...');
                  print('📝 Original agenda: ${widget.agendaItem}');

                  // Check if ID exists
                  final agendaId = widget.agendaItem['id'];
                  if (agendaId == null) {
                    print('❌ Error: Agenda ID is null!');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: ID agenda tidak ditemukan'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create updated agenda item
                  final updatedAgenda = {
                    'acara': _acaraController.text.trim(),
                    'deskripsi': _deskripsiController.text.trim(),
                    'tanggal': _tanggalController.text.trim(),
                    'waktu': _waktuController.text.trim(),
                  };

                  print('📋 Updated agenda data: $updatedAgenda');
                  print('🆔 Using ID: $agendaId');

                  ref
                      .read(agendaDataProvider.notifier)
                      .updateAgenda(agendaId, updatedAgenda);

                  print('✅ Update call completed');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Agenda berhasil diperbarui'),
                      backgroundColor: Colors.green[600],
                    ),
                  );

                  print('🏠 Navigating back...');

                  context.pop();
                },
                saveButtonText: 'SIMPAN PERUBAHAN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
