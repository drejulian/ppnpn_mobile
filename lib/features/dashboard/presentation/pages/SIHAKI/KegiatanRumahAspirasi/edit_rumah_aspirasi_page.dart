import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_pengajuan_rumah_aspirasi.dart' show rumahAspirasiDataProvider;

class EditRumahAspirasiPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> rumahAspirasiItem;

  const EditRumahAspirasiPage({super.key, required this.rumahAspirasiItem});

  @override
  ConsumerState<EditRumahAspirasiPage> createState() =>
      _EditRumahAspirasiPageState();
}

class _EditRumahAspirasiPageState extends ConsumerState<EditRumahAspirasiPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tanggalSuratController;
  late TextEditingController _tahunSidangController;
  late TextEditingController _anggotaController;
  late TextEditingController _noAnggotaController;
  late TextEditingController _nikAnggotaController;
  late TextEditingController _fraksiAnggotaController;
  late TextEditingController _dapilAnggotaController;
  late TextEditingController _rekeningController;
  late TextEditingController _namaRekeningController;
  late TextEditingController _kodeBankController;
  late TextEditingController _namaBankController;

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
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _tanggalSuratController = TextEditingController(
      text: widget.rumahAspirasiItem['tanggalSurat'],
    );
    _tahunSidangController = TextEditingController(
      text: widget.rumahAspirasiItem['tahunSidang'],
    );
    _anggotaController = TextEditingController(
      text: widget.rumahAspirasiItem['anggota'],
    );
    _noAnggotaController = TextEditingController(
      text: widget.rumahAspirasiItem['noAnggota'],
    );
    _nikAnggotaController = TextEditingController(
      text: widget.rumahAspirasiItem['nikAnggota'],
    );
    _fraksiAnggotaController = TextEditingController(
      text: widget.rumahAspirasiItem['fraksiAnggota'],
    );
    _dapilAnggotaController = TextEditingController(
      text: widget.rumahAspirasiItem['dapilAnggota'],
    );
    _rekeningController = TextEditingController(
      text: widget.rumahAspirasiItem['rekening'],
    );
    _namaRekeningController = TextEditingController(
      text: widget.rumahAspirasiItem['namaRekening'],
    );
    _kodeBankController = TextEditingController(
      text: widget.rumahAspirasiItem['kodeBank'],
    );
    _namaBankController = TextEditingController(
      text: widget.rumahAspirasiItem['namaBank'],
    );
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
      appBar: AppBar(
        title: Text(
          'Edit Kegiatan Rumah Aspirasi',
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
              // ID Display
              AppFormCard(
                title: 'Informasi Item',
                titleIcon: Icons.info,
                fields: [
                  FormFieldConfig(
                    label: 'ID',
                    icon: Icons.tag,
                    controller: TextEditingController(
                      text:
                          widget.rumahAspirasiItem['id']?.toString() ?? 'NO-ID',
                    ),
                    hintText: 'ID Kegiatan',
                    type: FormFieldType.text,
                    enabled: false,
                    isRequired: false,
                    isLast: true,
                  ),
                ],
                onSave: null,
              ),
              const SizedBox(height: 16),

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
                onSave: null,
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

                  final rumahAspirasiId = widget.rumahAspirasiItem['id'];
                  if (rumahAspirasiId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: ID kegiatan tidak ditemukan'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final updatedData = {
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
                  };

                  ref
                      .read(rumahAspirasiDataProvider.notifier)
                      .updateRumahAspirasi(rumahAspirasiId, updatedData);

                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kegiatan rumah aspirasi berhasil diperbarui',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
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
