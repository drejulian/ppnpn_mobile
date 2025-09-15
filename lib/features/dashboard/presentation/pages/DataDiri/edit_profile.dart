import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _bidangKeahlianController = TextEditingController();
  final _toeflController = TextEditingController();

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
  void initState() {
    super.initState();
    // Data akan diload dari provider di didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data from provider when page is loaded
    final savedData = ref.read(editProfileDataProvider);
    
    // Only set data if controllers are empty (not already set)
    if (_nikController.text.isEmpty) {
      _nikController.text = savedData.nik.isNotEmpty 
        ? savedData.nik 
        : '13-0265';
      _namaController.text = savedData.nama.isNotEmpty 
        ? savedData.nama 
        : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
      _bidangKeahlianController.text = savedData.bidangKeahlian.isNotEmpty 
        ? savedData.bidangKeahlian 
        : 'MAGISTER TEKNOLOGI INFORMASI';
      _toeflController.text = savedData.toefl.isNotEmpty 
        ? savedData.toefl 
        : '450';
      _selectedPendidikan = savedData.pendidikan.isNotEmpty 
        ? savedData.pendidikan 
        : 'Master/S2';
    }
  }

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
          onPressed: () async {
            // Check if there are unsaved changes
            if (_hasUnsavedChanges()) {
              final shouldLeave = await _showUnsavedChangesDialog(context, theme);
              if (shouldLeave) {
                Navigator.pop(context, false);
              }
            } else {
              Navigator.pop(context, false);
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
              const SizedBox(height: 20), 
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

      // Save data to provider
      final editProfileData = EditProfileData(
        nik: _nikController.text,
        nama: _namaController.text,
        bidangKeahlian: _bidangKeahlianController.text,
        toefl: _toeflController.text,
        pendidikan: _selectedPendidikan,
      );
      
      ref.read(editProfileDataProvider.notifier).updateData(editProfileData);

      // Show success dialog
      NotificationUtils.showSuccessDialog(
        context,
        title: 'Simpan Profil',
        message: 'Profil berhasil disimpan.',
        onPressed: () => context.pop('saved'), // Return 'saved' to indicate data was saved
      );
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    NotificationUtils.showErrorDialog(
      context,
      title: 'Error',
      message: message,
    );
  }

  // Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    final savedData = ref.read(editProfileDataProvider);
    
    // Default values yang diset di controller
    final defaultNik = '13-0265';
    final defaultNama = 'Airlangga Eka Wardhana, S.Kom, M.T.I';
    final defaultBidang = 'MAGISTER TEKNOLOGI INFORMASI';
    final defaultToefl = '450';
    final defaultPendidikan = 'Master/S2';
    
    // Ambil nilai yang seharusnya (dari saved data atau default)
    final expectedNik = savedData.nik.isNotEmpty ? savedData.nik : defaultNik;
    final expectedNama = savedData.nama.isNotEmpty ? savedData.nama : defaultNama;
    final expectedBidang = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : defaultBidang;
    final expectedToefl = savedData.toefl.isNotEmpty ? savedData.toefl : defaultToefl;
    final expectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : defaultPendidikan;
    
    // Debug print untuk melihat perbandingan data
    print('=== CHECKING UNSAVED CHANGES ===');
    print('Controller NIK: "${_nikController.text}" vs Expected: "$expectedNik"');
    print('Controller Nama: "${_namaController.text}" vs Expected: "$expectedNama"');
    print('Controller Bidang: "${_bidangKeahlianController.text}" vs Expected: "$expectedBidang"');
    print('Controller TOEFL: "${_toeflController.text}" vs Expected: "$expectedToefl"');
    print('Selected Pendidikan: "$_selectedPendidikan" vs Expected: "$expectedPendidikan"');
    
    final hasChanges = _nikController.text.trim() != expectedNik.trim() ||
           _namaController.text.trim() != expectedNama.trim() ||
           _bidangKeahlianController.text.trim() != expectedBidang.trim() ||
           _toeflController.text.trim() != expectedToefl.trim() ||
           _selectedPendidikan != expectedPendidikan;
           
    print('Has changes: $hasChanges');
    print('================================');
    
    return hasChanges;
  }

  // Show unsaved changes dialog
  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final result = await NotificationUtils.showConfirmationDialog(
      context,
      title: 'Perubahan Belum Disimpan',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmButtonText: 'Keluar Tanpa Menyimpan',
      cancelButtonText: 'Batal',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );
    return result ?? false;
  }
}
