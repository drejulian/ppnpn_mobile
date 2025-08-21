import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_cuti_page.dart';

class TambahCutiPage extends ConsumerStatefulWidget {
  const TambahCutiPage({super.key});

  @override
  ConsumerState<TambahCutiPage> createState() => _TambahCutiPageState();
}

class _TambahCutiPageState extends ConsumerState<TambahCutiPage> {
  final _formKey = GlobalKey<FormState>();
  final _jenisCtrl = TextEditingController();
  final _awalCtrl = TextEditingController();
  final _akhirCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

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
    _jenisCtrl.dispose();
    _awalCtrl.dispose();
    _akhirCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajukan Cuti',
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
                title: 'Data Cuti',
                titleIcon: Icons.event_available,
                fields: [
                  FormFieldConfig(
                    label: 'Jenis Cuti',
                    icon: Icons.category,
                    type: FormFieldType.textRequired,
                    controller: _jenisCtrl,
                    isRequired: true,
                    hintText: 'Cuti Tahunan',
                  ),
                  FormFieldConfig(
                    label: 'Tanggal Mulai',
                    icon: Icons.event,
                    type: FormFieldType.datePicker,
                    controller: _awalCtrl,
                    isRequired: true,
                    hintText: 'dd-mm-yyyy',
                    suffixIcon: Icons.calendar_today,
                    onTap: () => _pickDate(_awalCtrl),
                  ),
                  FormFieldConfig(
                    label: 'Tanggal Selesai',
                    icon: Icons.event,
                    type: FormFieldType.datePicker,
                    controller: _akhirCtrl,
                    isRequired: true,
                    hintText: 'dd-mm-yyyy',
                    suffixIcon: Icons.calendar_today,
                    onTap: () => _pickDate(_akhirCtrl),
                  ),
                  FormFieldConfig(
                    label: 'Alasan',
                    icon: Icons.assignment,
                    type: FormFieldType.multiline,
                    controller: _alasanCtrl,
                    isRequired: true,
                    hintText: 'Tuliskan alasan',
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
                onSave: () {
                  if (!_formKey.currentState!.validate()) return;
                  final id = 'C-${DateTime.now().millisecondsSinceEpoch}';
                  ref.read(cutiProvider.notifier).add({
                    'id': id,
                    'jenis': _jenisCtrl.text.trim(),
                    'tanggal_awal': _awalCtrl.text.trim(),
                    'tanggal_akhir': _akhirCtrl.text.trim(),
                    'alasan': _alasanCtrl.text.trim(),
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
