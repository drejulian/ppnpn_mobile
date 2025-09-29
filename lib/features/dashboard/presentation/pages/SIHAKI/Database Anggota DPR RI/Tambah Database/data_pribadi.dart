import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataPribadiPage extends ConsumerStatefulWidget {
  const DataPribadiPage({super.key});

  @override
  ConsumerState<DataPribadiPage> createState() => _DataPribadiPageState();
}

class _DataPribadiPageState extends ConsumerState<DataPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final _handphoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _telponRuanganController = TextEditingController();
  final _ruangKerjaController = TextEditingController();
  final _bahasaAsingController = TextEditingController();
  final _alamatRumahController = TextEditingController();
  final _keteranganDomisiliController = TextEditingController();
  final _namaAyahKandungController = TextEditingController();
  final _namaIbuKandungController = TextEditingController();
  final _noRekeningMitraController = TextEditingController();
  final _namaRekeningMitraController = TextEditingController();
  bool _isEditing = false;

 
  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _handphoneController.text = _persistentData['handphone'] ?? '';
      _emailController.text = _persistentData['email'] ?? '';
      _telponRuanganController.text = _persistentData['telponRuangan'] ?? '';
      _ruangKerjaController.text = _persistentData['ruangKerja'] ?? '';
      _bahasaAsingController.text = _persistentData['bahasaAsing'] ?? '';
      _alamatRumahController.text = _persistentData['alamatRumah'] ?? '';
      _keteranganDomisiliController.text =
          _persistentData['keteranganDomisili'] ?? '';
      _namaAyahKandungController.text =
          _persistentData['namaAyahKandung'] ?? '';
      _namaIbuKandungController.text = _persistentData['namaIbuKandung'] ?? '';
      _noRekeningMitraController.text =
          _persistentData['noRekeningMitra'] ?? '';
      _namaRekeningMitraController.text =
          _persistentData['namaRekeningMitra'] ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataPribadiFilledProvider.notifier).state = true;
      } else {
        ref.read(dataPribadiFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _handphoneController.dispose();
    _emailController.dispose();
    _telponRuanganController.dispose();
    _ruangKerjaController.dispose();
    _bahasaAsingController.dispose();
    _alamatRumahController.dispose();
    _keteranganDomisiliController.dispose();
    _namaAyahKandungController.dispose();
    _namaIbuKandungController.dispose();
    _noRekeningMitraController.dispose();
    _namaRekeningMitraController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _handphoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _telponRuanganController.text.isNotEmpty &&
        _ruangKerjaController.text.isNotEmpty &&
        _bahasaAsingController.text.isNotEmpty &&
        _alamatRumahController.text.isNotEmpty &&
        _keteranganDomisiliController.text.isNotEmpty &&
        _namaAyahKandungController.text.isNotEmpty &&
        _namaIbuKandungController.text.isNotEmpty &&
        _noRekeningMitraController.text.isNotEmpty &&
        _namaRekeningMitraController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
        title: 'Data Pribadi',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
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
              AppFormCard(
                title: 'Data Pribadi Utama',
                titleIcon: Icons.person_outline,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Handphone',
                    icon: Icons.phone_android,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _handphoneController,
                    hintText: 'Masukkan nomor handphone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Email',
                    icon: Icons.email,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _emailController,
                    hintText: 'Masukkan alamat email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Telepon Ruangan',
                    icon: Icons.phone,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _telponRuanganController,
                    hintText: 'Masukkan nomor telepon ruangan',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Ruang Kerja',
                    icon: Icons.work,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _ruangKerjaController,
                    hintText: 'Masukkan ruang kerja',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Bahasa Asing',
                    icon: Icons.language,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _bahasaAsingController,
                    hintText: 'Masukkan bahasa asing yang dikuasai',
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
                title: 'Data Tambahan',
                titleIcon: Icons.info_outline,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Alamat Rumah',
                    icon: Icons.home,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _alamatRumahController,
                    hintText: 'Masukkan alamat rumah',
                    maxLines: 3,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Keterangan Domisili',
                    icon: Icons.location_city,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _keteranganDomisiliController,
                    hintText: 'Masukkan keterangan domisili',
                    maxLines: 3,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nama Ayah Kandung',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaAyahKandungController,
                    hintText: 'Masukkan nama ayah kandung',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nama Ibu Kandung',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaIbuKandungController,
                    hintText: 'Masukkan nama ibu kandung',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'No. Rekening Mitra',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noRekeningMitraController,
                    hintText: 'Masukkan nomor rekening mitra',
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
                    label: 'Nama Rekening Mitra',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaRekeningMitraController,
                    hintText: 'Masukkan nama rekening mitra',
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

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_handphoneController.text.isEmpty) {
        errors.add('Handphone harus diisi');
      }
      if (_emailController.text.isEmpty) {
        errors.add('Email harus diisi');
      }
      if (_telponRuanganController.text.isEmpty) {
        errors.add('Telepon Ruangan harus diisi');
      }
      if (_ruangKerjaController.text.isEmpty) {
        errors.add('Ruang Kerja harus diisi');
      }
      if (_bahasaAsingController.text.isEmpty) {
        errors.add('Bahasa Asing harus diisi');
      }
      if (_alamatRumahController.text.isEmpty) {
        errors.add('Alamat Rumah harus diisi');
      }
      if (_keteranganDomisiliController.text.isEmpty) {
        errors.add('Keterangan Domisili harus diisi');
      }
      if (_namaAyahKandungController.text.isEmpty) {
        errors.add('Nama Ayah Kandung harus diisi');
      }
      if (_namaIbuKandungController.text.isEmpty) {
        errors.add('Nama Ibu Kandung harus diisi');
      }
      if (_noRekeningMitraController.text.isEmpty) {
        errors.add('No. Rekening Mitra harus diisi');
      }
      if (_namaRekeningMitraController.text.isEmpty) {
        errors.add('Nama Rekening Mitra harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      // Simpan data ke memori
      _persistentData['handphone'] = _handphoneController.text;
      _persistentData['email'] = _emailController.text;
      _persistentData['telponRuangan'] = _telponRuanganController.text;
      _persistentData['ruangKerja'] = _ruangKerjaController.text;
      _persistentData['bahasaAsing'] = _bahasaAsingController.text;
      _persistentData['alamatRumah'] = _alamatRumahController.text;
      _persistentData['keteranganDomisili'] =
          _keteranganDomisiliController.text;
      _persistentData['namaAyahKandung'] = _namaAyahKandungController.text;
      _persistentData['namaIbuKandung'] = _namaIbuKandungController.text;
      _persistentData['noRekeningMitra'] = _noRekeningMitraController.text;
      _persistentData['namaRekeningMitra'] = _namaRekeningMitraController.text;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Pribadi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data pribadi berhasil disimpan.'),
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
        ref.read(dataPribadiFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-pribadi'},
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
}
