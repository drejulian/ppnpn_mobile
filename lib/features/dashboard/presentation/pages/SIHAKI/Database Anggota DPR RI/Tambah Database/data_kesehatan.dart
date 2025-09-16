import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKesehatanPage extends ConsumerStatefulWidget {
  const DataKesehatanPage({super.key});

  @override
  ConsumerState<DataKesehatanPage> createState() => _DataKesehatanPageState();
}

class _DataKesehatanPageState extends ConsumerState<DataKesehatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _golonganDarahController = TextEditingController();
  final _riwayatPenyakitController = TextEditingController();
  final _alergiController = TextEditingController();
  bool _isEditing = false;

 
  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {

    setState(() {
      _beratBadanController.text = _persistentData['beratBadan'] ?? '';
      _tinggiBadanController.text = _persistentData['tinggiBadan'] ?? '';
      _golonganDarahController.text = _persistentData['golonganDarah'] ?? '';
      _riwayatPenyakitController.text =
          _persistentData['riwayatPenyakit'] ?? '';
      _alergiController.text = _persistentData['alergi'] ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataKesehatanFilledProvider.notifier).state = true;
      } else {
        ref.read(dataKesehatanFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    _golonganDarahController.dispose();
    _riwayatPenyakitController.dispose();
    _alergiController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _beratBadanController.text.isNotEmpty &&
        _tinggiBadanController.text.isNotEmpty &&
        _golonganDarahController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_beratBadanController.text.isEmpty) {
        errors.add('Berat Badan harus diisi');
      }
      if (_tinggiBadanController.text.isEmpty) {
        errors.add('Tinggi Badan harus diisi');
      }
      if (_golonganDarahController.text.isEmpty) {
        errors.add('Golongan Darah harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

 
      _persistentData['beratBadan'] = _beratBadanController.text;
      _persistentData['tinggiBadan'] = _tinggiBadanController.text;
      _persistentData['golonganDarah'] = _golonganDarahController.text;
      _persistentData['riwayatPenyakit'] = _riwayatPenyakitController.text;
      _persistentData['alergi'] = _alergiController.text;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Kesehatan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data kesehatan berhasil disimpan.'),
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
        ref.read(dataKesehatanFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-kesehatan'},
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
                'Data Kesehatan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Data Kesehatan',
                titleIcon: Icons.health_and_safety,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Berat Badan (kg)',
                    icon: Icons.monitor_weight,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _beratBadanController,
                    hintText: 'Masukkan berat badan dalam kg',
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
                    label: 'Tinggi Badan (cm)',
                    icon: Icons.height,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _tinggiBadanController,
                    hintText: 'Masukkan tinggi badan dalam cm',
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
                    label: 'Golongan Darah',
                    icon: Icons.bloodtype,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _golonganDarahController,
                    hintText: 'Masukkan golongan darah (A, B, AB, O)',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Riwayat Penyakit',
                    icon: Icons.medical_information,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _riwayatPenyakitController,
                    hintText: 'Masukkan riwayat penyakit (opsional)',
                    maxLines: 3,
                  ),
                  FormFieldConfig(
                    label: 'Alergi',
                    icon: Icons.warning,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _alergiController,
                    hintText: 'Masukkan informasi alergi (opsional)',
                    maxLines: 3,
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
