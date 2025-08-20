import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_lembur_page.dart';

class TambahLemburPage extends ConsumerStatefulWidget {
  const TambahLemburPage({super.key});

  @override
  ConsumerState<TambahLemburPage> createState() => _TambahLemburPageState();
}

class _TambahLemburPageState extends ConsumerState<TambahLemburPage> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalCtrl = TextEditingController();
  final _mulaiCtrl = TextEditingController();
  final _selesaiCtrl = TextEditingController();
  final _kegiatanCtrl = TextEditingController();

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  @override
  void dispose() {
    _tanggalCtrl.dispose();
    _mulaiCtrl.dispose();
    _selesaiCtrl.dispose();
    _kegiatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajukan Lembur',
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
                title: 'Data Lembur',
                titleIcon: Icons.schedule,
                fields: [
                  FormFieldConfig(
                    label: 'Tanggal',
                    icon: Icons.event,
                    type: FormFieldType.datePicker,
                    controller: _tanggalCtrl,
                    isRequired: true,
                    hintText: 'dd-mm-yyyy',
                    suffixIcon: Icons.calendar_today,
                    onTap: () => _pickDate(_tanggalCtrl),
                  ),
                  FormFieldConfig(
                    label: 'Jam Mulai',
                    icon: Icons.access_time,
                    type: FormFieldType.textRequired,
                    controller: _mulaiCtrl,
                    isRequired: true,
                    hintText: '19:00',
                  ),
                  FormFieldConfig(
                    label: 'Jam Selesai',
                    icon: Icons.schedule,
                    type: FormFieldType.textRequired,
                    controller: _selesaiCtrl,
                    isRequired: true,
                    hintText: '22:00',
                  ),
                  FormFieldConfig(
                    label: 'Kegiatan',
                    icon: Icons.assignment,
                    type: FormFieldType.multiline,
                    controller: _kegiatanCtrl,
                    isRequired: true,
                    hintText: 'Tuliskan kegiatan',
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
                onSave: () {
                  if (!_formKey.currentState!.validate()) return;
                  final id = 'L-${DateTime.now().millisecondsSinceEpoch}';
                  ref.read(lemburProvider.notifier).add({
                    'id': id,
                    'tanggal': _tanggalCtrl.text.trim(),
                    'mulai': _mulaiCtrl.text.trim(),
                    'selesai': _selesaiCtrl.text.trim(),
                    'kegiatan': _kegiatanCtrl.text.trim(),
                    'status': 'Menunggu',
                  });
                  context.pop();
                },
                saveButtonText: 'KIRIM PENGAJUAN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
