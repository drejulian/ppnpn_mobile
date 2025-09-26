import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_pengajuan_rumah_aspirasi.dart' show rumahAspirasiDataProvider;

class TambahRumahAspirasiPage extends ConsumerStatefulWidget {
  const TambahRumahAspirasiPage({super.key});

  @override
  ConsumerState<TambahRumahAspirasiPage> createState() =>
      _TambahRumahAspirasiPageState();
}

class _TambahRumahAspirasiPageState
    extends ConsumerState<TambahRumahAspirasiPage> {
  final _formKey = GlobalKey<FormState>();

  final _tanggalSuratController = TextEditingController();
  final _tahunSidangController = TextEditingController();
  final _anggotaController = TextEditingController();
  final _noAnggotaController = TextEditingController();
  final _nikAnggotaController = TextEditingController();
  final _fraksiAnggotaController = TextEditingController();
  final _dapilAnggotaController = TextEditingController();
  final _rekeningController = TextEditingController();
  final _namaRekeningController = TextEditingController();
  final _kodeBankController = TextEditingController();
  final _namaBankController = TextEditingController();

  DateTime? _selectedDate;

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
        _tanggalSuratController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _tanggalSuratController.dispose();
    _tahunSidangController.dispose();
    _anggotaController.dispose();
    _noAnggotaController.dispose();
    _nikAnggotaController.dispose();
    _fraksiAnggotaController.dispose();
    _dapilAnggotaController.dispose();
    _rekeningController.dispose();
    _namaRekeningController.dispose();
    _kodeBankController.dispose();
    _namaBankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Tambah kegiatan Rumah Aspirasi',
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
              // Data Surat Section
              AppFormCard(
                title: 'Data Surat',
                titleIcon: Icons.description,
                fields: [
                  FormFieldConfig(
                    label: 'Tanggal Surat',
                    icon: Icons.calendar_today,
                    controller: _tanggalSuratController,
                    hintText: 'dd-mm-yyyy',
                    type: FormFieldType.datePicker,
                    suffixIcon: Icons.calendar_today,
                    isRequired: true,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Tahun Sidang',
                    icon: Icons.event_note,
                    controller: _tahunSidangController,
                    hintText: 'Contoh: 2024-2025',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    isLast: true,
                  ),
                ],
                onSave: null, 
              ),
              const SizedBox(height: 16),

              // Data Anggota Section
              AppFormCard(
                title: 'Data Anggota',
                titleIcon: Icons.person,
                fields: [
                  FormFieldConfig(
                    label: 'Anggota',
                    icon: Icons.person,
                    controller: _anggotaController,
                    hintText: 'Nama lengkap anggota',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'No. Anggota',
                    icon: Icons.badge,
                    controller: _noAnggotaController,
                    hintText: 'Nomor anggota',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'NIK Anggota',
                    icon: Icons.credit_card,
                    controller: _nikAnggotaController,
                    hintText: '16 digit NIK',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'Fraksi Anggota',
                    icon: Icons.groups,
                    controller: _fraksiAnggotaController,
                    hintText: 'Nama fraksi',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Dapil Anggota',
                    icon: Icons.location_on,
                    controller: _dapilAnggotaController,
                    hintText: 'Daerah pemilihan',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    isLast: true,
                  ),
                ],
                onSave: null, // No save button for this section
              ),
              const SizedBox(height: 16),

              // Data Bank Section
              AppFormCard(
                title: 'Data Bank',
                titleIcon: Icons.account_balance,
                fields: [
                  FormFieldConfig(
                    label: 'Rekening',
                    icon: Icons.account_balance_wallet,
                    controller: _rekeningController,
                    hintText: 'Nomor rekening',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'Nama Rekening',
                    icon: Icons.person_outline,
                    controller: _namaRekeningController,
                    hintText: 'Nama pemilik rekening',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Kode Bank',
                    icon: Icons.pin,
                    controller: _kodeBankController,
                    hintText: 'Kode bank (3 digit)',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  FormFieldConfig(
                    label: 'Nama Bank',
                    icon: Icons.account_balance,
                    controller: _namaBankController,
                    hintText: 'Nama bank',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    isLast: true,
                  ),
                ],
                onSave: () {
                  if (!_formKey.currentState!.validate()) return;

                  ref
                      .read(rumahAspirasiDataProvider.notifier)
                      .addRumahAspirasi({
                        'tanggalSurat': _tanggalSuratController.text.trim(),
                        'tahunSidang': _tahunSidangController.text.trim(),
                        'anggota': _anggotaController.text.trim(),
                        'noAnggota': _noAnggotaController.text.trim(),
                        'nikAnggota': _nikAnggotaController.text.trim(),
                        'fraksiAnggota': _fraksiAnggotaController.text.trim(),
                        'dapilAnggota': _dapilAnggotaController.text.trim(),
                        'rekening': _rekeningController.text.trim(),
                        'namaRekening': _namaRekeningController.text.trim(),
                        'kodeBank': _kodeBankController.text.trim(),
                        'namaBank': _namaBankController.text.trim(),
                      });

                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kegiatan rumah aspirasi berhasil ditambahkan',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                saveButtonText: 'TAMBAH KEGIATAN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
