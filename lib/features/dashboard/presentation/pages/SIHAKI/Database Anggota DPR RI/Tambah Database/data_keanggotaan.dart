import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKeanggotaanPage extends ConsumerStatefulWidget {
  const DataKeanggotaanPage({super.key});

  @override
  ConsumerState<DataKeanggotaanPage> createState() =>
      _DataKeanggotaanPageState();
}

class _DataKeanggotaanPageState extends ConsumerState<DataKeanggotaanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noAnggotaController = TextEditingController();
  final _fraksiController = TextEditingController();
  final _dapilController = TextEditingController();
  final _areaController = TextEditingController();
  final _noRekeningController = TextEditingController();
  final _namaRekeningController = TextEditingController();
  bool _isEditing = false;

  // Simulasi memori lokal untuk menyimpan data antar sesi
  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    // Memuat data persisten saat halaman dimuat
    setState(() {
      _namaController.text = _persistentData['nama'] ?? '';
      _noAnggotaController.text = _persistentData['noAnggota'] ?? '';
      _fraksiController.text = _persistentData['fraksi'] ?? '';
      _dapilController.text = _persistentData['dapil'] ?? '';
      _areaController.text = _persistentData['area'] ?? '';
      _noRekeningController.text = _persistentData['noRekening'] ?? '';
      _namaRekeningController.text = _persistentData['namaRekening'] ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataKeanggotaanFilledProvider.notifier).state = true;
      } else {
        ref.read(dataKeanggotaanFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noAnggotaController.dispose();
    _fraksiController.dispose();
    _dapilController.dispose();
    _areaController.dispose();
    _noRekeningController.dispose();
    _namaRekeningController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaController.text.isNotEmpty &&
        _noAnggotaController.text.isNotEmpty &&
        _fraksiController.text.isNotEmpty &&
        _dapilController.text.isNotEmpty &&
        _areaController.text.isNotEmpty &&
        _namaRekeningController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_namaController.text.isEmpty) {
        errors.add('Nama harus diisi');
      }
      if (_noAnggotaController.text.isEmpty) {
        errors.add('No. Anggota harus diisi');
      }
      if (_fraksiController.text.isEmpty) {
        errors.add('Fraksi harus diisi');
      }
      if (_dapilController.text.isEmpty) {
        errors.add('Dapil harus diisi');
      }
      if (_areaController.text.isEmpty) {
        errors.add('Area harus diisi');
      }
      if (_namaRekeningController.text.isEmpty) {
        errors.add('Nama Rekening harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      // Simpan data ke memori persisten
      _persistentData['nama'] = _namaController.text;
      _persistentData['noAnggota'] = _noAnggotaController.text;
      _persistentData['fraksi'] = _fraksiController.text;
      _persistentData['dapil'] = _dapilController.text;
      _persistentData['area'] = _areaController.text;
      _persistentData['noRekening'] = _noRekeningController.text;
      _persistentData['namaRekening'] = _namaRekeningController.text;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Keanggotaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data keanggotaan berhasil disimpan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      await Future.delayed(Duration.zero, () {
        ref.read(dataKeanggotaanFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-keanggotaan'},
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Database Anggota DPR RI (DASI)',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/dataKomisi');
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Keanggotaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Data Pribadi Anggota',
                titleIcon: Icons.person_outline,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nama',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaController,
                    hintText: 'Masukkan nama lengkap anggota DPR',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'No. Anggota',
                    icon: Icons.badge,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noAnggotaController,
                    hintText: 'Masukkan nomor anggota',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Fraksi',
                    icon: Icons.group_work,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _fraksiController,
                    hintText: 'Masukkan nama fraksi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Dapil',
                    icon: Icons.location_on,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _dapilController,
                    hintText: 'Masukkan daerah pemilihan',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Area',
                    icon: Icons.map,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _areaController,
                    hintText: 'Masukkan area/wilayah yang diwakili',
                    maxLines: 3,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Data Rekening',
                titleIcon: Icons.account_balance_wallet,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'No. Rekening',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.text
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _noRekeningController,
                    hintText: 'Masukkan nomor rekening bank',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  FormFieldConfig(
                    label: 'Nama Rekening',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaRekeningController,
                    hintText: 'Masukkan nama pemilik rekening',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol EDIT dan SIMPAN
              Column(
                children: [
                  if (!_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'EDIT',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveData(context, ref, theme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'SIMPAN',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
