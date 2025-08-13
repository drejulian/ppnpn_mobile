import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class TambahAgendaPage extends ConsumerStatefulWidget {
  const TambahAgendaPage({super.key});

  @override
  ConsumerState<TambahAgendaPage> createState() => _TambahAgendaPageState();
}

class _TambahAgendaPageState extends ConsumerState<TambahAgendaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    super.dispose();
  }

  void _updateTanggalController() {
    if (_selectedDate != null) {
      _tanggalController.text =
          '${_selectedDate!.day.toString().padLeft(2, '0')}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.year}';
    }
  }

  void _updateWaktuController() {
    if (_selectedTime != null) {
      _waktuController.text =
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
        _updateTanggalController();
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
        _updateWaktuController();
      });
    }
  }

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

  void _simpanAgenda() {
    if (_formKey.currentState!.validate()) {
      // TODO: logika simpan agenda ke backend
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tambah Agenda',
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
          key: _formKey,
          child: ListView(
            children: [
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

                    _labeledField(
                      leadingIcon: Icons.title,
                      label: 'Judul Kegiatan',
                      controller: _judulController,
                    ),
                    _labeledField(
                      leadingIcon: Icons.description,
                      label: 'Deskripsi',
                      controller: _deskripsiController,
                      maxLines: 3,
                      hintText: 'Tulis deskripsi agenda',
                    ),
                    _labeledField(
                      leadingIcon: Icons.calendar_today,
                      label: 'Tanggal',
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: _pickDate,
                      hintText: 'Pilih tanggal',
                      suffixIcon: Icons.calendar_month,
                    ),
                    _labeledField(
                      leadingIcon: Icons.access_time,
                      label: 'Waktu',
                      controller: _waktuController,
                      readOnly: true,
                      onTap: _pickTime,
                      hintText: 'Pilih waktu',
                      suffixIcon: Icons.access_time_filled,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _simpanAgenda,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Agenda'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
