import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'agenda_model.dart';

class EditAgendaPage extends ConsumerStatefulWidget {
  final AgendaItem agendaItem;
  const EditAgendaPage({super.key, required this.agendaItem});

  @override
  ConsumerState<EditAgendaPage> createState() => _EditAgendaPageState();
}

class _EditAgendaPageState extends ConsumerState<EditAgendaPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.agendaItem.judul);
    _descriptionController =
        TextEditingController(text: widget.agendaItem.deskripsi);
    _dateController = TextEditingController();
    _timeController = TextEditingController();

    // Parsing tanggal dd-MM-yyyy -> DateTime
    try {
      final p = widget.agendaItem.tanggal.split('-');
      final d = int.parse(p[0]), m = int.parse(p[1]), y = int.parse(p[2]);
      final parsed = DateTime(y, m, d);
      _selectedDate = parsed;
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    _selectedTime = TimeOfDay.now();
    _updateDateController();
    _updateTimeController();
  }

  void _updateDateController() {
    if (_selectedDate != null) {
      _dateController.text =
          '${_selectedDate!.day.toString().padLeft(2, '0')}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.year}';
    }
  }

  void _updateTimeController() {
    if (_selectedTime != null) {
      _timeController.text =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime!.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _updateDateController();
      });
    }
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _updateTimeController();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // ====== UI helper: field dengan ikon di luar border (kiri) ======
  Widget _labeledField({
    required IconData leadingIcon,
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Icon di luar border
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: theme.primarySwatch.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(leadingIcon, size: 18, color: theme.primarySwatch),
          ),
          // Field
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText,
                alignLabelWithHint: maxLines > 1,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primarySwatch, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:
                    suffixIcon != null ? Icon(suffixIcon) : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Agenda',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: ListView(
            children: [
              // Kartu seperti contoh screenshot
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header kartu
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.primarySwatch.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.event_note,
                              size: 18, color: theme.primarySwatch),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Data Agenda',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // === Urutan field TETAP seperti semula ===
                    _labeledField(
                      leadingIcon: Icons.title,
                      label: 'Judul Agenda',
                      controller: _titleController,
                    ),
                    _labeledField(
                      leadingIcon: Icons.calendar_today,
                      label: 'Tanggal',
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      hintText: 'Pilih tanggal',
                      suffixIcon: Icons.calendar_month,
                    ),
                    _labeledField(
                      leadingIcon: Icons.access_time,
                      label: 'Jam',
                      controller: _timeController,
                      readOnly: true,
                      onTap: _pickTime,
                      hintText: 'Pilih waktu',
                      suffixIcon: Icons.access_time_filled,
                    ),
                    _labeledField(
                      leadingIcon: Icons.description,
                      label: 'Deskripsi',
                      controller: _descriptionController,
                      maxLines: 3,
                      hintText: 'Tulis deskripsi agenda',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    if (Form.of(context).validate()) {
                      // TODO: simpan perubahan ke backend/provider
                      context.pop();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
