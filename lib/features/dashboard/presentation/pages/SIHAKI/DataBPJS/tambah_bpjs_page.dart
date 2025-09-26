import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_pengajuan_BPJS.dart' show BPJSData, bpjsDataProvider;

class TambahBpjsPage extends ConsumerStatefulWidget {
  const TambahBpjsPage({super.key});

  @override
  ConsumerState<TambahBpjsPage> createState() => _TambahBpjsPageState();
}

class _TambahBpjsPageState extends ConsumerState<TambahBpjsPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noBPJSController = TextEditingController();
  final _nikController = TextEditingController();
  final _hubunganKeluargaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _namaFaskesTingkat1Controller = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noBPJSController.dispose();
    _nikController.dispose();
    _hubunganKeluargaController.dispose();
    _tanggalLahirController.dispose();
    _namaFaskesTingkat1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Tambah Data BPJS',
        onBackPressed: () => context.pop(),
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
                title: 'Form Tambah BPJS',
                titleIcon: Icons.medical_services,
                fields: [
                  FormFieldConfig(
                    label: 'Nama',
                    icon: Icons.person,
                    controller: _namaController,
                    hintText: 'Nama lengkap',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Nomor BPJS',
                    icon: Icons.confirmation_num,
                    controller: _noBPJSController,
                    hintText: 'Nomor BPJS',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'NIK',
                    icon: Icons.badge,
                    controller: _nikController,
                    hintText: 'Nomor Induk Kependudukan',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'Hubungan Keluarga',
                    icon: Icons.family_restroom,
                    controller: _hubunganKeluargaController,
                    hintText: 'Kepala Keluarga/Suami/Istri/Anak',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Tanggal Lahir',
                    icon: Icons.cake,
                    controller: _tanggalLahirController,
                    hintText: 'dd-mm-yyyy',
                    type: FormFieldType.datePicker,
                    suffixIcon: Icons.calendar_today,
                    isRequired: true,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Nama Faskes Tingkat 1',
                    icon: Icons.local_hospital,
                    controller: _namaFaskesTingkat1Controller,
                    hintText: 'Nama Puskesmas/Klinik',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                ],
                onSave: () {
                  if (!_formKey.currentState!.validate()) return;
                  ref
                      .read(bpjsDataProvider.notifier)
                      .addBPJSData(
                        BPJSData(
                          nama: _namaController.text.trim(),
                          noBPJS: _noBPJSController.text.trim(),
                          nik: _nikController.text.trim(),
                          hubunganKeluarga:
                              _hubunganKeluargaController.text.trim(),
                          tanggalLahir: _tanggalLahirController.text.trim(),
                          namaFaskesTingkat1:
                              _namaFaskesTingkat1Controller.text.trim(),
                        ),
                      );
                  context.pop();
                },
                saveButtonText: 'TAMBAH DATA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
