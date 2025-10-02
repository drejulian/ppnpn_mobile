import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// SQLite imports
import 'package:ppnpm_dpr/common/services/profile_service.dart';

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
  bool _hasUnsavedChanges = false;
  
  // SQLite service
  final ProfileService _profileService = ProfileService();

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
    _nikController.addListener(_updateUnsavedChanges);
    _namaController.addListener(_updateUnsavedChanges);
    _bidangKeahlianController.addListener(_updateUnsavedChanges);
    _toeflController.addListener(_updateUnsavedChanges);

    // Initialize SQLite and load data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAndLoadData();
      
      SharedPreferences.getInstance().then((prefs) {
        final hasChanges = prefs.getBool('edit_profile_has_changes') ?? false;
        if (hasChanges && mounted) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedData = ref.read(editProfileDataProvider);
    if (_nikController.text.isEmpty) {
      _nikController.text = savedData.nik.isNotEmpty ? savedData.nik : '13-0265';
      _namaController.text = savedData.nama.isNotEmpty ? savedData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
      _bidangKeahlianController.text = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : 'MAGISTER TEKNOLOGI INFORMASI';
      _toeflController.text = savedData.toefl.isNotEmpty ? savedData.toefl : '450';
      _selectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : 'Master/S2';
    }
  }

  /// Initialize SQLite service and load data
  Future<void> _initializeAndLoadData() async {
    try {
      print('EditProfilePage: Initializing SQLite...');
      
      // Initialize ProfileService
      await _profileService.initialize();
      
      // Load data from SQLite first
      await _loadDataFromSQLite();
      
      print('EditProfilePage: SQLite initialization completed');
    } catch (e) {
      print('EditProfilePage: Error initializing SQLite: $e');
    }
  }

  /// Load data from SQLite database
  Future<void> _loadDataFromSQLite() async {
    try {
      print('EditProfilePage: Loading data from SQLite...');
      
      // Get profile data from SQLite
      final profileData = await _profileService.getCurrentEditProfile();
      
      if (profileData != null && mounted) {
        // Update controllers with SQLite data
        setState(() {
          _nikController.text = profileData.nik;
          _namaController.text = profileData.nama;
          _bidangKeahlianController.text = profileData.bidangKeahlian;
          _toeflController.text = profileData.toefl;
          _selectedPendidikan = profileData.pendidikan;
        });

        // Update Riverpod provider with SQLite data
        final editProfileData = EditProfileData(
          nik: profileData.nik,
          nama: profileData.nama,
          bidangKeahlian: profileData.bidangKeahlian,
          toefl: profileData.toefl,
          pendidikan: profileData.pendidikan,
        );
        
        ref.read(editProfileDataProvider.notifier).updateData(editProfileData);
        ref.read(profileCompletionProvider.notifier).markCompleted('editProfile');

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('edit_profile_user_saved', true);

        print('EditProfilePage: Data loaded from SQLite successfully');
        print('  - NIK: ${profileData.nik}');
        print('  - Nama: ${profileData.nama}');
        print('  - Pendidikan: ${profileData.pendidikan}');
        print('  - Bidang Keahlian: ${profileData.bidangKeahlian}');
        print('  - TOEFL: ${profileData.toefl}');
      } else {
        print('EditProfilePage: No data found in SQLite, using defaults');
        
        // Use default values if no data in SQLite
        final savedData = ref.read(editProfileDataProvider);
        if (_nikController.text.isEmpty) {
          _nikController.text = savedData.nik.isNotEmpty ? savedData.nik : '13-0265';
          _namaController.text = savedData.nama.isNotEmpty ? savedData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
          _bidangKeahlianController.text = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : 'MAGISTER TEKNOLOGI INFORMASI';
          _toeflController.text = savedData.toefl.isNotEmpty ? savedData.toefl : '450';
          _selectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : 'Master/S2';
        }
      }
    } catch (e) {
      print('EditProfilePage: Error loading data from SQLite: $e');
    }
  }

  @override
  void dispose() {
    _nikController.removeListener(_updateUnsavedChanges);
    _namaController.removeListener(_updateUnsavedChanges);
    _bidangKeahlianController.removeListener(_updateUnsavedChanges);
    _toeflController.removeListener(_updateUnsavedChanges);
    _nikController.dispose();
    _namaController.dispose();
    _bidangKeahlianController.dispose();
    _toeflController.dispose();
    super.dispose();
  }

  void _updateUnsavedChanges() {
    final hasChanges = _hasUnsavedChangesInternal();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('edit_profile_has_changes', hasChanges);
    });
    setState(() {
      _hasUnsavedChanges = hasChanges;
    });
  }

  bool _hasUnsavedChangesInternal() {
    final savedData = ref.read(editProfileDataProvider);
    final expectedNik = savedData.nik.isNotEmpty ? savedData.nik : '13-0265';
    final expectedNama = savedData.nama.isNotEmpty ? savedData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
    final expectedBidang = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : 'MAGISTER TEKNOLOGI INFORMASI';
    final expectedToefl = savedData.toefl.isNotEmpty ? savedData.toefl : '450';
    final expectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : 'Master/S2';

    return _nikController.text.trim() != expectedNik.trim() ||
        _namaController.text.trim() != expectedNama.trim() ||
        _bidangKeahlianController.text.trim() != expectedBidang.trim() ||
        _toeflController.text.trim() != expectedToefl.trim() ||
        _selectedPendidikan != expectedPendidikan;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
          final shouldLeave = await _showUnsavedChangesDialog(context, theme);
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ubah Profil',
        onBackPressed: () => Navigator.of(context).pop(),
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
                          _hasUnsavedChanges = _hasUnsavedChangesInternal();
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
                      helperText: 'Wajib diisi untuk Tenaga Ahli Fraksi & Tenaga Ahli Alat Kelengkapan Dewan',
                      isLast: true,
                    ),
                  ],
                  onSave: () => _saveProfile(context, theme),
                  saveButtonText: 'SIMPAN',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context, dynamic theme) async {
    if (_formKey.currentState!.validate()) {
      // Validate data using ProfileService
      final errors = _profileService.getEditProfileValidationErrors(
        nik: _nikController.text,
        nama: _namaController.text,
        pendidikan: _selectedPendidikan,
        bidangKeahlian: _bidangKeahlianController.text,
        toefl: _toeflController.text,
      );

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        // Save to SQLite first
        print('EditProfilePage: Saving data to SQLite...');
        final sqliteSuccess = await _profileService.saveEditProfile(
          nik: _nikController.text,
          nama: _namaController.text,
          pendidikan: _selectedPendidikan,
          bidangKeahlian: _bidangKeahlianController.text,
          toefl: _toeflController.text,
        );

        if (!sqliteSuccess) {
          _showErrorDialog(context, theme, 'Gagal menyimpan data ke database. Silakan coba lagi.');
          return;
        }

        print('EditProfilePage: Data saved to SQLite successfully');

        // Update Riverpod provider
        final editProfileData = EditProfileData(
          nik: _nikController.text,
          nama: _namaController.text,
          bidangKeahlian: _bidangKeahlianController.text,
          toefl: _toeflController.text,
          pendidikan: _selectedPendidikan,
        );

        ref.read(editProfileDataProvider.notifier).updateData(editProfileData);
        ref.read(profileCompletionProvider.notifier).markCompleted('editProfile');

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setBool('edit_profile_has_changes', false),
          prefs.setBool('edit_profile_just_saved', true),
          prefs.setBool('edit_profile_user_saved', true),
        ]);

        print('EditProfilePage: All data saved successfully');

        // Show success dialog
        await ProfileCompletionNotifierCard.show(
          context,
          title: 'Berhasil Menyimpan Profil',
          message: 'Data profil Anda telah diperbarui dan tersimpan dengan sukses di database.',
          onConfirm: () {
            NotificationUtils.showSuccess(
              context,
              'Data profil telah disimpan ke database',
            );
            if (context.mounted) {
              context.pop('saved');
            }
          },
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green[600],
        );

        if (context.mounted) {
          setState(() {
            _hasUnsavedChanges = false;
          });
        }
      } catch (e) {
        print('EditProfilePage: Error saving profile: $e');
        _showErrorDialog(context, theme, 'Terjadi kesalahan saat menyimpan data. Silakan coba lagi.');
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    NotificationUtils.showErrorDialog(
      context,
      title: 'Gagal Menyimpan',
      message: 'Terjadi kesalahan saat menyimpan profil: $message',
    );
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final result = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan Profil',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () async {
        if (context.mounted) {
          try {
            // Reload data from SQLite to restore last saved state
            await _loadDataFromSQLite();
          } catch (e) {
            print('EditProfilePage: Error reloading data from SQLite: $e');
            
            // Fallback to provider data
            final savedData = ref.read(editProfileDataProvider);
            _nikController.text = savedData.nik.isNotEmpty ? savedData.nik : '13-0265';
            _namaController.text = savedData.nama.isNotEmpty ? savedData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
            _bidangKeahlianController.text = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : 'MAGISTER TEKNOLOGI INFORMASI';
            _toeflController.text = savedData.toefl.isNotEmpty ? savedData.toefl : '450';
            _selectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : 'Master/S2';
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('edit_profile_has_changes', false);

          setState(() {
            _hasUnsavedChanges = false;
          });

          NotificationUtils.showWarning(
            context,
            'Perubahan pada profil telah dibatalkan',
          );

          if (context.mounted) {
            context.pop();
          }
        }
      },
      onCancel: () {},
    );
    return result ?? false;
  }
}