import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController(text: '13-0265');
  final _namaController = TextEditingController(
    text: 'Airlangga Eka Wardhana, S.Kom, M.T.I',
  );
  final _bidangKeahlianController = TextEditingController(
    text: 'MAGISTER TEKNOLOGI INFORMASI',
  );
  final _toeflController = TextEditingController(text: '450');

  String _selectedPendidikan = 'Master/S2';

  final List<String> _pendidikanOptions = [
    'SMA/SMK',
    'Diploma',
    'Sarjana/S1',
    'Master/S2',
    'Doktor/S3',
  ];

  final List<String> _bidangKeahlianSuggestions = [
    'MAGISTER TEKNOLOGI INFORMASI',
    'MAGISTER MANAJEMEN',
    'MAGISTER HUKUM',
    'MAGISTER EKONOMI',
    'MAGISTER TEKNIK',
  ];

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _bidangKeahlianController.dispose();
    _toeflController.dispose();
    super.dispose();
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
          'EDIT PROFIL',
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
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
              // Form Edit Profile using AppFormCard component
              AppFormCard(
                title: 'Edit Profil',
                titleIcon: Icons.edit,
                fields: [
                  FormFieldConfig(
                    label: 'NIK',
                    icon: Icons.credit_card,
                    type: FormFieldType.disabled,
                    controller: _nikController,
                    hintText: 'NIK tidak dapat diubah',
                    enabled: false,
                  ),
                  FormFieldConfig(
                    label: 'Nama',
                    icon: Icons.person,
                    type: FormFieldType.textRequired,
                    controller: _namaController,
                    isRequired: true,
                    hintText: 'Masukkan nama lengkap',
                  ),
                  FormFieldConfig(
                    label: 'Pendidikan Terakhir',
                    icon: Icons.school,
                    type: FormFieldType.dropdown,
                    value: _selectedPendidikan,
                    options: _pendidikanOptions,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedPendidikan = value!;
                      });
                    },
                  ),
                  FormFieldConfig(
                    label: 'Bidang Keahlian',
                    icon: Icons.work,
                    type: FormFieldType.autocomplete,
                    controller: _bidangKeahlianController,
                    options: _bidangKeahlianSuggestions,
                    isRequired: true,
                    hintText: 'Masukkan atau pilih bidang keahlian',
                  ),
                  FormFieldConfig(
                    label: 'TOEFL',
                    icon: Icons.language,
                    type: FormFieldType.textRequired,
                    controller: _toeflController,
                    isRequired: true,
                    hintText: 'Masukkan skor TOEFL',
                    keyboardType: TextInputType.number,
                    helperText:
                        'Wajib diisi untuk Tenaga Ahli Fraksi & Tenaga Ahli Alat Kelengkapan Dewan',
                    isLast: true,
                  ),
                ],
                onSave: () => _saveProfile(context, ref.watch(themeProvider)),
                saveButtonText: 'SIMPAN',
              ),
              const SizedBox(height: 20), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile(BuildContext context, dynamic theme) {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      List<String> errors = [];

      if (_namaController.text.isEmpty) {
        errors.add('Nama harus diisi');
      }
      if (_selectedPendidikan.isEmpty) {
        errors.add('Pendidikan Terakhir harus dipilih');
      }
      if (_bidangKeahlianController.text.isEmpty) {
        errors.add('Bidang Keahlian harus diisi');
      }
      if (_toeflController.text.isEmpty) {
        errors.add('TOEFL harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      // Show success dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Profil',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Profil berhasil disimpan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
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
}
