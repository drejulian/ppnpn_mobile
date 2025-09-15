import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKontakPage extends ConsumerStatefulWidget {
  const DataKontakPage({super.key});

  @override
  ConsumerState<DataKontakPage> createState() => _DataKontakPageState();
}

class _DataKontakPageState extends ConsumerState<DataKontakPage> {
  final _formKey = GlobalKey<FormState>();
  final _noKontakController = TextEditingController();
  final _namaKontakController = TextEditingController();
  String? _hubunganKontak;
  bool _isEditing = false;

 
  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _noKontakController.dispose();
    _namaKontakController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
 
    setState(() {
      _noKontakController.text = _persistentData['noKontak'] ?? '';
      _namaKontakController.text = _persistentData['namaKontak'] ?? '';
      _hubunganKontak = _persistentData['hubunganKontak'];
      if (_noKontakController.text.isNotEmpty &&
          _namaKontakController.text.isNotEmpty &&
          _hubunganKontak != null) {
        ref.read(dataKontakFilledProvider.notifier).state = true;
      } else {
        ref.read(dataKontakFilledProvider.notifier).state = false;
      }
    });
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_noKontakController.text.isEmpty) {
        errors.add('No Kontak Darurat harus diisi');
      }
      if (_namaKontakController.text.isEmpty) {
        errors.add('Nama Kontak Darurat harus diisi');
      }
      if (_hubunganKontak == null) {
        errors.add('Hubungan Kontak Darurat harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }


      _persistentData['noKontak'] = _noKontakController.text;
      _persistentData['namaKontak'] = _namaKontakController.text;
      _persistentData['hubunganKontak'] = _hubunganKontak!;

      ref.read(dataKontakFilledProvider.notifier).state = true;

      await _showSuccessDialog(context, theme);

      setState(() {
        _isEditing = false;
      });

      context.go(
        '/dataKomisi',
        extra: {'justSaved': true, 'sourcePage': '/data-kontak'},
      );
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

  Future<void> _showSuccessDialog(BuildContext context, dynamic theme) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Simpan Data Kontak',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text('Data kontak berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
                'Data Kontak',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Kontak Darurat',
                titleIcon: Icons.contact_phone,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'No Kontak Darurat',
                    icon: Icons.phone,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noKontakController,
                    hintText: 'Masukkan nomor kontak darurat',
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
                    label: 'Nama Kontak Darurat',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaKontakController,
                    hintText: 'Masukkan nama kontak darurat',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Hubungan Kontak Darurat',
                    icon: Icons.family_restroom,
                    type:
                        _isEditing
                            ? FormFieldType.dropdown
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    value: _hubunganKontak,
                    options: const [
                      'Orang Tua',
                      'Suami/Istri',
                      'Anak',
                      'Saudara',
                      'Kerabat',
                      'Teman',
                      'Rekan Kerja',
                      'Lainnya',
                    ],
                    hintText: 'Pilih hubungan dengan kontak darurat',
                    onChanged: (value) {
                      setState(() {
                        _hubunganKontak = value;
                      });
                    },
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
