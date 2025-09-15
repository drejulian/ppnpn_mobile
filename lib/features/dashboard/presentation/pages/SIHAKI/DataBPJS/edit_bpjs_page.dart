import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_pengajuan_BPJS.dart' show BPJSData, bpjsDataProvider;

class EditBpjsPage extends ConsumerStatefulWidget {
  final BPJSData bpjsItem;
  final int index;
  const EditBpjsPage({super.key, required this.bpjsItem, required this.index});
  @override
  ConsumerState<EditBpjsPage> createState() => _EditBpjsPageState();
}

class _EditBpjsPageState extends ConsumerState<EditBpjsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _noBPJSController;
  late TextEditingController _nikController;
  late TextEditingController _hubunganKeluargaController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _namaFaskesTingkat1Controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.bpjsItem.nama);
    _noBPJSController = TextEditingController(text: widget.bpjsItem.noBPJS);
    _nikController = TextEditingController(text: widget.bpjsItem.nik);
    _hubunganKeluargaController = TextEditingController(
      text: widget.bpjsItem.hubunganKeluarga,
    );
    _tanggalLahirController = TextEditingController(
      text: widget.bpjsItem.tanggalLahir,
    );
    _namaFaskesTingkat1Controller = TextEditingController(
      text: widget.bpjsItem.namaFaskesTingkat1,
    );
  }

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
      appBar: AppBar(
        title: Text(
          'Edit Data BPJS',
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
                title: 'Form Edit BPJS',
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
                      .updateBPJSData(
                        widget.index,
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
                saveButtonText: 'SIMPAN PERUBAHAN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
