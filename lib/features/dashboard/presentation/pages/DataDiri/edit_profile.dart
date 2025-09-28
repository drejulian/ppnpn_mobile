import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences.getInstance().then((prefs) {
      final hasChanges = prefs.getBool('edit_profile_has_changes') ?? false;
      if (hasChanges && mounted) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
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
              if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
                final shouldLeave = await _showUnsavedChangesDialog(context, theme);
                if (shouldLeave && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
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
      List<String> errors = [];
      if (_namaController.text.isEmpty) errors.add('Nama harus diisi');
      if (_selectedPendidikan.isEmpty) errors.add('Pendidikan Terakhir harus dipilih');
      if (_bidangKeahlianController.text.isEmpty) errors.add('Bidang Keahlian harus diisi');
      if (_toeflController.text.isEmpty) errors.add('TOEFL harus diisi');
      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      final editProfileData = EditProfileData(
        nik: _nikController.text,
        nama: _namaController.text,
        bidangKeahlian: _bidangKeahlianController.text,
        toefl: _toeflController.text,
        pendidikan: _selectedPendidikan,
      );

      ref.read(editProfileDataProvider.notifier).updateData(editProfileData);
      ref.read(profileCompletionProvider.notifier).markCompleted('editProfile');

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('edit_profile_has_changes', false),
        prefs.setBool('edit_profile_just_saved', true),
        prefs.setBool('edit_profile_user_saved', true),
      ]);

      await ProfileCompletionNotifierCard.show(
        context,
        title: 'Berhasil Menyimpan Profil',
        message: 'Data profil Anda telah diperbarui dan tersimpan dengan sukses.',
        onConfirm: () {
          NotificationUtils.showSuccess(
            context,
            'Data profil telah disimpan',
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
    final savedData = ref.read(editProfileDataProvider);
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
          _nikController.text = savedData.nik.isNotEmpty ? savedData.nik : '13-0265';
          _namaController.text = savedData.nama.isNotEmpty ? savedData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
          _bidangKeahlianController.text = savedData.bidangKeahlian.isNotEmpty ? savedData.bidangKeahlian : 'MAGISTER TEKNOLOGI INFORMASI';
          _toeflController.text = savedData.toefl.isNotEmpty ? savedData.toefl : '450';
          _selectedPendidikan = savedData.pendidikan.isNotEmpty ? savedData.pendidikan : 'Master/S2';

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