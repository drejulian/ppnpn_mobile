import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/nav_bar.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'dart:convert';
import '../DataDiri/providers/profile_data_provider.dart';
import '../DataDiri/keluarga_page.dart';
import 'dart:io';
import '../../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  List<Map<String, String>> _educationData = [];
  bool _educationDataLoaded = false;
  bool _educationUserSaved = false;
  bool _workHistoryUserSaved = false;
  bool _familyUserSaved = false;
  List<Widget> _workHistoryItems = [];
  bool _workHistoryLoaded = false;

  bool _isProcessingImmediateFlagDetection = false;
  Set<String> _recentlyEditedViNavigation = <String>{};

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () async {
      await _checkFreshLoginAndReset();
      _loadEducationData();
      _loadUserSavedFlags().then((_) {
        _reloadWorkHistoryData();
      });
    });
  }

  Future<void> _debugAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('ProfilePage: Debugging all SharedPreferences data');
    } catch (e) {
      // Tangani error tanpa print
    }
  }

  Future<void> _checkFreshLoginAndReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      debugPrint('ProfilePage: isLoggedOut=$isLoggedOut');

      final hasWorkHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
      final workHistoryDataList = prefs.getStringList('work_history_data') ?? [];
      final hasActualWorkData = workHistoryDataList.isNotEmpty;

      final educationDataList = prefs.getStringList('education_data') ?? [];
      final hasEducationUserSaved = prefs.getBool('education_user_saved') ?? false;
      final pendidikanData = ref.read(pendidikanDataProvider);
      final hasPendidikanData = pendidikanData.tingkatPendidikan.isNotEmpty ||
          pendidikanData.namaInstitusi.isNotEmpty ||
          pendidikanData.jurusan.isNotEmpty ||
          pendidikanData.tahunLulus.isNotEmpty;

      final editProfileData = ref.read(editProfileDataProvider);
      final hasEditProfileData = editProfileData.nama.isNotEmpty ||
          editProfileData.nik.isNotEmpty ||
          editProfileData.bidangKeahlian.isNotEmpty ||
          editProfileData.toefl.isNotEmpty;

      if (isLoggedOut) {
        await prefs.setBool('edit_profile_user_saved', false);
        await prefs.setBool('family_user_saved', false);
        await prefs.setBool('education_user_saved', false);
        await prefs.remove('education_data');
        await prefs.remove('family_data');
        await prefs.remove('work_history_data');
        // Reset provider
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        ref.read(editProfileDataProvider.notifier).updateData(EditProfileData());
        ref.read(pribadiDataProvider.notifier).updateData(PribadiData());
        ref.read(honorariumDataProvider.notifier).updateData(HonorariumData());
        ref.read(dataLamaranDataProvider.notifier).updateData(DataLamaranData());
        ref.read(dokumenDataProvider.notifier).updateData(DokumenData());
        ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());
        ref.read(idCardDataProvider.notifier).updateData(IdCardData());
        // Reset completion status
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('editProfile');
        completionNotifier.markIncomplete('identitasDiri');
        completionNotifier.markIncomplete('honorarium');
        completionNotifier.markIncomplete('keluarga');
        completionNotifier.markIncomplete('pasFoto');
        completionNotifier.markIncomplete('dokumen');
        completionNotifier.markIncomplete('pendidikan');
        completionNotifier.markIncomplete('riwayatPekerjaan');
        completionNotifier.markIncomplete('dataLamaran');

        ref.read(bottomNavIndexProvider.notifier).state = 0;

        final delayedPrefs = await SharedPreferences.getInstance();
        Future.delayed(const Duration(seconds: 3), () async {
          await delayedPrefs.remove('is_logged_out');
        });
      }

      final currentFamilyUserSaved = prefs.getBool('family_user_saved') ?? false;
      final familyMembers = ref.read(familyDataProvider);
      final keluargaData = ref.read(keluargaDataProvider);
      final hasRealFamilyData = keluargaData.namaPasangan.isNotEmpty ||
          keluargaData.namaAnak.isNotEmpty ||
          keluargaData.namaAyah.isNotEmpty ||
          keluargaData.namaIbu.isNotEmpty ||
          familyMembers.isNotEmpty;

      if (!hasRealFamilyData && !currentFamilyUserSaved) {
        await prefs.setBool('family_user_saved', false);
      }

      if (!hasEditProfileData && !prefs.getBool('edit_profile_user_saved')!) {
        await prefs.setBool('edit_profile_user_saved', false);
      }

      if (educationDataList.isNotEmpty) {
        try {
          final List<Map<String, String>> userEducationOnly = [];

          for (String jsonStr in educationDataList) {
            final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
            final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));

            if (educationMap['isDummy'] != 'true') {
              userEducationOnly.add(educationMap);
            }
          }

          if (userEducationOnly.isEmpty && !hasPendidikanData) {
            await prefs.remove('education_data');
            await prefs.remove('education_user_saved');
            await prefs.remove('education_has_changes');
            await prefs.remove('education_just_saved');
          } else {
            final userEducationJson = userEducationOnly.map((education) => jsonEncode(education)).toList();
            await prefs.setStringList('education_data', userEducationJson);
          }
        } catch (e) {
          await prefs.remove('education_data');
          await prefs.remove('education_user_saved');
          await prefs.remove('education_has_changes');
          await prefs.remove('education_just_saved');
        }
      }

      if (!hasEducationUserSaved && !hasPendidikanData) {
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('pendidikan');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _reloadWorkHistoryData() async {
    _workHistoryLoaded = false;
    _workHistoryItems.clear();

    final theme = ref.read(themeProvider);
    await _loadWorkHistoryItems(theme);

    if (mounted) {
      setState(() {
        _workHistoryLoaded = true;
      });
    }
  }

  Future<void> _checkForWorkHistoryChanges() async {
    if (_isProcessingImmediateFlagDetection) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasChanges = prefs.getBool('work_history_has_changes') ?? false;
      final justSaved = prefs.getBool('work_history_just_saved') ?? false;

      if (hasChanges || justSaved) {
        _isProcessingImmediateFlagDetection = true;
        await Future.delayed(const Duration(milliseconds: 200));
        await prefs.remove('work_history_has_changes');
        await _reloadWorkHistoryData();
        await Future.delayed(const Duration(milliseconds: 100));
        _isProcessingImmediateFlagDetection = false;
      }
    } catch (e) {
      _isProcessingImmediateFlagDetection = false;
    }
  }

  Future<void> _loadUserSavedFlags() async {
    if (_isProcessingImmediateFlagDetection) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final previousWorkHistoryUserSaved = _workHistoryUserSaved;

      await _checkFlagsImmediatelyAfterNavigation();
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _educationUserSaved = prefs.getBool('education_user_saved') ?? false;
        _workHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
        _familyUserSaved = prefs.getBool('family_user_saved') ?? false;
        debugPrint('ProfilePage: Loaded flags - edit_profile_user_saved=${prefs.getBool('edit_profile_user_saved')}, family_user_saved=$_familyUserSaved, education_user_saved=$_educationUserSaved, work_history_user_saved=$_workHistoryUserSaved');
      });

      if (previousWorkHistoryUserSaved != _workHistoryUserSaved) {
        _workHistoryLoaded = false;
        _workHistoryItems.clear();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _checkFlagsImmediatelyAfterNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('profile_processing_flag_protection') == true) {
        return;
      }

      final sections = ['edit_profile', 'education', 'work_history', 'family', 'honorarium'];
      for (String section in sections) {
        final recentlyEdited = _recentlyEditedViNavigation.contains(section);
        if (recentlyEdited) {
          debugPrint('ProfilePage: Section $section recently edited');
        }
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        _recentlyEditedViNavigation.clear();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        NotificationUtils.showLoadingDialog(context, message: 'Mengeluarkan...');
      }

      await Future.wait([
        prefs.remove('edit_profile_data'),
        prefs.remove('edit_profile_user_saved'),
        prefs.remove('edit_profile_has_changes'),
        prefs.remove('edit_profile_just_saved'),
        prefs.remove('pribadi_data'),
        prefs.remove('pribadi_user_saved'),
        prefs.remove('pribadi_has_changes'),
        prefs.remove('pribadi_just_saved'),
        prefs.remove('honorarium_data'),
        prefs.remove('honorarium_user_saved'),
        prefs.remove('honorarium_has_changes'),
        prefs.remove('honorarium_just_saved'),
        prefs.remove('keluarga_data'),
        prefs.remove('family_user_saved'),
        prefs.remove('family_has_changes'),
        prefs.remove('family_just_saved'),
        prefs.remove('pendidikan_data'),
        prefs.remove('education_user_saved'),
        prefs.remove('education_has_changes'),
        prefs.remove('education_just_saved'),
        prefs.remove('riwayat_pekerjaan_data'),
        prefs.remove('work_history_user_saved'),
        prefs.remove('work_history_has_changes'),
        prefs.remove('work_history_just_saved'),
        prefs.remove('data_lamaran_data'),
        prefs.remove('data_lamaran_user_saved'),
        prefs.remove('data_lamaran_has_changes'),
        prefs.remove('data_lamaran_just_saved'),
        prefs.remove('dokumen_data'),
        prefs.remove('id_card_data'),
        prefs.remove('profile_completion_status'),
        prefs.setStringList('education_data', []),
        prefs.setStringList('work_history_data', []),
        prefs.remove('family_members_data'),
        prefs.remove('editProfile_completed'),
        prefs.remove('identitasDiri_completed'),
        prefs.remove('honorarium_completed'),
        prefs.remove('keluarga_completed'),
        prefs.remove('pasFoto_completed'),
        prefs.remove('dokumen_completed'),
        prefs.remove('pendidikan_completed'),
        prefs.remove('riwayatPekerjaan_completed'),
        prefs.remove('dataLamaran_completed'),
      ]);

      await prefs.setBool('is_logged_out', true);

      List<String> statusKeys = [
        'edit_profile_status',
        'pribadi_status',
        'honorarium_status',
        'keluarga_status',
        'pendidikan_status',
        'riwayat_pekerjaan_status',
        'data_lamaran_status',
        'foto_status',
        'dokumen_status'
      ];

      for (String key in statusKeys) {
        await prefs.remove(key);
      }

      ref.read(editProfileDataProvider.notifier).updateData(EditProfileData());
      ref.read(pribadiDataProvider.notifier).updateData(PribadiData());
      ref.read(honorariumDataProvider.notifier).updateData(HonorariumData());
      ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());
      ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
      ref.read(dataLamaranDataProvider.notifier).updateData(DataLamaranData());
      ref.read(idCardDataProvider.notifier).updateData(IdCardData(fotoPath: '', isUploaded: false));
      ref.read(dokumenDataProvider.notifier).updateData(DokumenData());
      ref.read(familyDataProvider.notifier).state = [];

      final completionNotifier = ref.read(profileCompletionProvider.notifier);
      completionNotifier.markIncomplete('editProfile');
      completionNotifier.markIncomplete('identitasDiri');
      completionNotifier.markIncomplete('honorarium');
      completionNotifier.markIncomplete('keluarga');
      completionNotifier.markIncomplete('pasFoto');
      completionNotifier.markIncomplete('dokumen');
      completionNotifier.markIncomplete('pendidikan');
      completionNotifier.markIncomplete('riwayatPekerjaan');
      completionNotifier.markIncomplete('dataLamaran');

      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reset bottom navigation ke home tab
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      
      // Perform logout using secure storage
      await ref.read(authProvider.notifier).signOut();
      
      // Close loading dialog dan navigate ke welcome
      if (mounted) {
        NotificationUtils.hideLoadingDialog(context); // Close loading dialog
        context.go('/welcome');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Logout berhasil'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationUtils.hideLoadingDialog(context);
        NotificationUtils.showError(context, 'Terjadi kesalahan saat logout');
      }
    }
  }

  Future<void> _loadEducationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final educationDataList = prefs.getStringList('education_data') ?? [];
      final pendidikanData = ref.read(pendidikanDataProvider);
      final hasPendidikanData = pendidikanData.tingkatPendidikan.isNotEmpty ||
          pendidikanData.namaInstitusi.isNotEmpty ||
          pendidikanData.jurusan.isNotEmpty ||
          pendidikanData.tahunLulus.isNotEmpty;

      if (educationDataList.isNotEmpty) {
        final List<Map<String, String>> loadedData = [];
        for (String jsonStr in educationDataList) {
          try {
            final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
            final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
            if (educationMap['isDummy'] != 'true') {
              loadedData.add(educationMap);
            }
          } catch (e) {
            // Handle parsing error silently
          }
        }

        setState(() {
          _educationData = loadedData;
          _educationDataLoaded = true;
        });

        if (loadedData.isEmpty && hasPendidikanData) {
          final fallbackEducation = {
            'jenjang': pendidikanData.tingkatPendidikan,
            'institusi': pendidikanData.namaInstitusi,
            'jurusan': pendidikanData.jurusan,
            'tahun_selesai': pendidikanData.tahunLulus,
            'ipk': pendidikanData.ipk,
            'isDummy': 'false',
            'id': 'fallback-${DateTime.now().millisecondsSinceEpoch}',
          };
          setState(() {
            _educationData = [fallbackEducation];
          });
          await prefs.setStringList('education_data', [jsonEncode(fallbackEducation)]);
          await prefs.setBool('education_user_saved', true);
        }
      } else {
        if (hasPendidikanData) {
          final fallbackEducation = {
            'jenjang': pendidikanData.tingkatPendidikan,
            'institusi': pendidikanData.namaInstitusi,
            'jurusan': pendidikanData.jurusan,
            'tahun_selesai': pendidikanData.tahunLulus,
            'ipk': pendidikanData.ipk,
            'isDummy': 'false',
            'id': 'fallback-${DateTime.now().millisecondsSinceEpoch}',
          };
          setState(() {
            _educationData = [fallbackEducation];
          });
          await prefs.setStringList('education_data', [jsonEncode(fallbackEducation)]);
          await prefs.setBool('education_user_saved', true);
        } else {
          setState(() {
            _educationDataLoaded = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _educationDataLoaded = true;
      });
    }
  }

  bool _isValidLocalFile(String path) {
    if (path.isEmpty) return false;
    try {
      final file = File(path);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  ImageProvider<Object>? _getImageProvider(String imagePath) {
    if (imagePath.isEmpty) return null;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    if (_isValidLocalFile(imagePath)) {
      return FileImage(File(imagePath));
    }

    return null;
  }

  Widget _buildInfoChip(IconData icon, String text, dynamic theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: theme.primarySwatch,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildProfileDetailPage(context, theme, isTablet),
    );
  }

  Widget _buildProfileDetailPage(BuildContext context, dynamic theme, bool isTablet) {
    final editProfileData = ref.watch(editProfileDataProvider);
    final pribadiData = ref.watch(pribadiDataProvider);
    final honorariumData = ref.watch(honorariumDataProvider);
    final keluargaData = ref.watch(keluargaDataProvider);
    final pendidikanData = ref.watch(pendidikanDataProvider);
    final riwayatPekerjaanData = ref.watch(riwayatPekerjaanDataProvider);
    final dokumenData = ref.watch(dokumenDataProvider);
    final dataLamaranData = ref.watch(dataLamaranDataProvider);
    final idCardData = ref.watch(idCardDataProvider);

    final now = DateTime.now();
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final dayName = dayNames[now.weekday - 1];
    final monthName = monthNames[now.month - 1];
    final currentDate = '$dayName, ${now.day} $monthName ${now.year}';

    const loginTime = '12:17';

    final displayName = editProfileData.nama.isNotEmpty 
        ? editProfileData.nama
        : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
    final displayJob = editProfileData.bidangKeahlian.isNotEmpty 
        ? editProfileData.bidangKeahlian 
        : '';
    final displayNik = editProfileData.nik.isNotEmpty 
        ? editProfileData.nik 
        : '';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.0 : 16.0, 
                vertical: 16.0
              ),
              child: HeaderCardProfileComponent(
                title: displayName,  
                subtitle: displayJob.isNotEmpty ? displayJob : 'Kelola data profil Anda!',  
                description: 'Kelola data pribadi, identitas, dan dokumen Anda dengan mudah dan efisien',  
                icon: null,  
                leadingWidget: _buildProfilePhoto(theme),
                nik: displayNik,
                isTablet: isTablet,
                isLargeTablet: MediaQuery.of(context).size.width > 900,
                theme: theme,
              ),
            ),

            _buildSectionCard('1. Edit Profil', [
              _buildInfoItem(Icons.person, 'Nama', editProfileData.nama.isNotEmpty ? editProfileData.nama : 'Belum diisi', theme, isMissing: editProfileData.nama.isEmpty),
              _buildInfoItem(Icons.work, 'Bidang Keahlian', editProfileData.bidangKeahlian.isNotEmpty ? editProfileData.bidangKeahlian : 'Belum diisi', theme, isMissing: editProfileData.bidangKeahlian.isEmpty),
              _buildInfoItem(Icons.school, 'Pendidikan', editProfileData.pendidikan.isNotEmpty ? editProfileData.pendidikan : 'Belum diisi', theme, isMissing: editProfileData.pendidikan.isEmpty),
            ], theme, isTablet),
            
            _buildSectionCard('2. Identitas Diri', [
              _buildInfoItem(Icons.email, 'Email', pribadiData.email.isNotEmpty ? pribadiData.email : 'Belum diisi', theme, isMissing: pribadiData.email.isEmpty),
              _buildInfoItem(Icons.phone, 'Handphone', pribadiData.handphone.isNotEmpty ? pribadiData.handphone : 'Belum diisi', theme, isMissing: pribadiData.handphone.isEmpty),
              _buildInfoItem(Icons.location_on, 'Alamat', pribadiData.address.isNotEmpty ? pribadiData.address : 'Belum diisi', theme, isMissing: pribadiData.address.isEmpty),
            ], theme, isTablet),
            
            _buildSectionCard('3. Honorarium', [
              _buildInfoItem(Icons.card_membership, 'KTP', honorariumData.ktp.isNotEmpty ? honorariumData.ktp : 'Belum diisi', theme, isMissing: honorariumData.ktp.isEmpty),
              _buildInfoItem(Icons.account_balance, 'Rekening', honorariumData.rekening.isNotEmpty ? honorariumData.rekening : 'Belum diisi', theme, isMissing: honorariumData.rekening.isEmpty),
              _buildInfoItem(Icons.receipt, 'NPWP', honorariumData.npwp.isNotEmpty ? honorariumData.npwp : 'Belum diisi', theme, isMissing: honorariumData.npwp.isEmpty),
            ], theme, isTablet),
            
            _buildSectionCard('4. Keluarga', _buildFamilyItems(theme), theme, isTablet),
            _buildSectionCard('5. PAS Foto', [
              _buildInfoItem(Icons.camera_alt, 'Status Upload', idCardData.isUploaded ? 'Sudah diupload' : 'Belum diupload', theme, isMissing: !idCardData.isUploaded),
            ], theme, isTablet),
            
            _buildSectionCard('6. Dokumen', _buildDokumenItems(theme), theme, isTablet),
            _buildSectionCard('7. Pendidikan', _buildEducationItems(theme), theme, isTablet),
            _buildSectionCard('8. Riwayat Pekerjaan', _buildWorkHistoryItems(theme), theme, isTablet),
            
            _buildSectionCard('9. Data Lamaran', [
              _buildInfoItem(Icons.assignment, 'Posisi', dataLamaranData.position.isNotEmpty ? dataLamaranData.position : 'Belum diisi', theme, isMissing: dataLamaranData.position.isEmpty),
              _buildInfoItem(Icons.location_on, 'Penempatan', dataLamaranData.placement.isNotEmpty ? dataLamaranData.placement : 'Belum diisi', theme, isMissing: dataLamaranData.placement.isEmpty),
            ], theme, isTablet),

            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/profile-sections'),
                icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/lupa-password'),
                icon: const Icon(Icons.lock_outline, color: Colors.white, size: 22),
                label: const Text(
                  'Ubah Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final shouldLogout = await NotificationUtils.showConfirmationDialog(
                            context,
                            title: 'Keluar dari Aplikasi',
                            message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
                            confirmButtonText: 'Keluar',
                            cancelButtonText: 'Batal',
                            isDangerous: true,
                            icon: Icons.logout_rounded,
                          );

                          if (shouldLogout == true) {
                            await _handleLogout();
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        label: const Text(
                          'Keluar dari Aplikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Colors.grey[200],
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: Colors.green[600],
                            size: 16.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sesi Login',
                                style: theme.typographyRegular.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                loginTime,
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.blue[600],
                            size: 16.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Akses',
                                style: theme.typographyRegular.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                currentDate,
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children, dynamic theme, bool isTablet) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 18.0 : 16.0,
                horizontal: isTablet ? 24.0 : 20.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.primarySwatch.withOpacity(0.08),
                    theme.primarySwatch.withOpacity(0.04),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: theme.primarySwatch.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                title,
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.primarySwatch,
                  fontSize: isTablet ? 18.0 : 16.0,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, dynamic theme, {bool isMissing = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isMissing ? Colors.red.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMissing ? Colors.red.withOpacity(0.1) : theme.primarySwatch.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isMissing ? Colors.red[600] : theme.primarySwatch,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMissing ? Colors.red[600] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isMissing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Perlu diisi',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Terisi',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFamilyItems(dynamic theme) {
    final keluargaData = ref.watch(keluargaDataProvider);
    final familyMembers = ref.watch(familyDataProvider);
    final hasFamilyData = keluargaData.namaPasangan.isNotEmpty ||
        keluargaData.namaAnak.isNotEmpty ||
        keluargaData.namaAyah.isNotEmpty ||
        keluargaData.namaIbu.isNotEmpty ||
        familyMembers.isNotEmpty;

    if (!_familyUserSaved || !hasFamilyData) {
      return [
        _buildInfoItem(Icons.family_restroom, 'Status Keluarga', 'Belum diisi', theme, isMissing: true),
      ];
    }

    List<Widget> familyWidgets = [];

    if (keluargaData.namaPasangan.isNotEmpty) {
      familyWidgets.add(
        _buildInfoItem(
          Icons.favorite,
          keluargaData.namaPasangan.toLowerCase().contains('istri') ? 'Istri' : 'Suami',
          keluargaData.namaPasangan,
          theme,
          isMissing: false,
        ),
      );
    }

    if (keluargaData.namaAyah.isNotEmpty) {
      familyWidgets.add(
        _buildInfoItem(
          Icons.man,
          'Ayah',
          keluargaData.namaAyah,
          theme,
          isMissing: false,
        ),
      );
    }

    if (keluargaData.namaIbu.isNotEmpty) {
      familyWidgets.add(
        _buildInfoItem(
          Icons.woman,
          'Ibu',
          keluargaData.namaIbu,
          theme,
          isMissing: false,
        ),
      );
    }

    if (keluargaData.namaAnak.isNotEmpty) {
      final anakList = keluargaData.namaAnak.split(', ').asMap();
      for (var i = 0; i < anakList.length && i < 3; i++) {
        final anakName = anakList[i]!.trim();
        familyWidgets.add(
          _buildInfoItem(
            Icons.child_care,
            'Anak ${i + 1}',
            anakName,
            theme,
            isMissing: false,
          ),
        );
      }
    }

    if (familyWidgets.isEmpty) {
      familyWidgets.add(
        _buildInfoItem(Icons.family_restroom, 'Status', 'Belum diisi', theme, isMissing: true),
      );
    }

    return familyWidgets;
  }

  List<Widget> _buildDokumenItems(dynamic theme) {
    final dokumenData = ref.watch(dokumenDataProvider);
    final List<Widget> dokumenWidgets = [];

    dokumenWidgets.add(
      _buildInfoItem(
        Icons.credit_card,
        'KTP',
        dokumenData.ktpUploaded ? 'Sudah diupload' : 'Belum diupload',
        theme,
        isMissing: !dokumenData.ktpUploaded,
      ),
    );

    dokumenWidgets.add(
      _buildInfoItem(
        Icons.description,
        'Ijazah',
        dokumenData.ijazahUploaded ? 'Sudah diupload' : 'Belum diupload',
        theme,
        isMissing: !dokumenData.ijazahUploaded,
      ),
    );

    return dokumenWidgets;
  }

  List<Widget> _buildEducationItems(dynamic theme) {
    final pendidikanData = ref.watch(pendidikanDataProvider);
    final hasPendidikanData = pendidikanData.tingkatPendidikan.isNotEmpty ||
        pendidikanData.namaInstitusi.isNotEmpty ||
        pendidikanData.jurusan.isNotEmpty ||
        pendidikanData.tahunLulus.isNotEmpty;

    if (!_educationDataLoaded) {
      return [
        _buildInfoItem(Icons.hourglass_empty, 'Status', 'Memuat...', theme),
      ];
    }

    if (_educationUserSaved && (_educationData.isNotEmpty)) {
      List<Widget> educationWidgets = [];

      if (_educationData.isNotEmpty) {
        educationWidgets.addAll(
          _educationData.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final education = entry.value;
            final jenjang = education['jenjang'] ?? 'Belum diisi';
            final institusi = education['institusi'] ?? 'Belum diisi';
            final jurusan = education['jurusan'] ?? 'Belum diisi';
            final tahun = education['tahun_selesai'] ?? education['tahun'] ?? 'Belum diisi';

            return _buildInfoItem(
              Icons.school,
              'Pendidikan $idx',
              '$jenjang - $jurusan ($institusi, $tahun)',
              theme,
              isMissing: jenjang == 'Belum diisi' ||
                  institusi == 'Belum diisi' ||
                  jurusan == 'Belum diisi' ||
                  tahun == 'Belum diisi',
            );
          }).toList(),
        );
      }

      return educationWidgets;
    }

    return [
      _buildInfoItem(Icons.school, 'Status', 'Belum diisi', theme, isMissing: true),
    ];
  }

  Future<void> _loadWorkHistoryItems(dynamic theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
      final justSaved = prefs.getBool('work_history_just_saved') ?? false;
      final workHistoryDataList = prefs.getStringList('work_history_data') ?? [];

      if (!workHistoryUserSaved && !justSaved && workHistoryDataList.isNotEmpty) {
        final List<Map<String, String>> tempWorkHistoryData = [];

        for (int i = 0; i < workHistoryDataList.length; i++) {
          final jsonStr = workHistoryDataList[i];
          try {
            final Map<String, dynamic> workMap = jsonDecode(jsonStr);
            final Map<String, String> workStringMap = workMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));

            final isDummyFlag = workStringMap['isDummy'] == 'true';
            final hasDummyId = workStringMap['id']?.startsWith('dummy') ?? false;

            if (!isDummyFlag && !hasDummyId) {
              tempWorkHistoryData.add(workStringMap);
            }
          } catch (e) {
            // Handle error silently
          }
        }

        if (tempWorkHistoryData.isNotEmpty) {
          _workHistoryItems = [];

          for (int i = 0; i < tempWorkHistoryData.length; i++) {
            final work = tempWorkHistoryData[i];
            final entryNumber = i + 1;

            if (_workHistoryItems.isNotEmpty) {
              _workHistoryItems.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  height: 1,
                  color: Colors.grey[300],
                ),
              );
            }

            _workHistoryItems.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: Text(
                  'Riwayat Pekerjaan $entryNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.primarySwatch,
                    fontSize: 14.0,
                  ),
                ),
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.business,
                'Perusahaan',
                work['company']?.isNotEmpty == true ? work['company']! : 'Belum diisi',
                theme,
                isMissing: work['company']?.isEmpty != false,
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work,
                'Posisi',
                work['position']?.isNotEmpty == true ? work['position']! : 'Belum diisi',
                theme,
                isMissing: work['position']?.isEmpty != false,
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.calendar_today,
                'Periode',
                '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}',
                theme,
                isMissing: work['startYear']?.isEmpty != false,
              ),
            );
          }

          return;
        }
      }

      if (!workHistoryUserSaved && !justSaved) {
        final hasChanges = prefs.getBool('work_history_has_changes') ?? false;

        if (hasChanges) {
          final riwayatPekerjaanData = ref.read(riwayatPekerjaanDataProvider);

          if (riwayatPekerjaanData.namaPerusahaan.isNotEmpty && riwayatPekerjaanData.posisi.isNotEmpty) {
            _workHistoryItems = [];
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work,
                'Riwayat Pekerjaan',
                '${riwayatPekerjaanData.posisi} - ${riwayatPekerjaanData.namaPerusahaan} (${riwayatPekerjaanData.tahunMulai}-${riwayatPekerjaanData.tahunSelesai})',
                theme,
                isMissing: false,
              ),
            );

            return;
          }
        }

        _workHistoryItems = [];
        _workHistoryItems.add(
          _buildInfoItem(
            Icons.work_off,
            'Riwayat Pekerjaan',
            'Belum diisi',
            theme,
            isMissing: true,
          ),
        );

        return;
      }

      if (justSaved) {
        // Proceed to load saved data
      }

      if (workHistoryDataList.isNotEmpty) {
        final List<Map<String, String>> workHistoryData = [];

        for (int i = 0; i < workHistoryDataList.length; i++) {
          final jsonStr = workHistoryDataList[i];
          try {
            final Map<String, dynamic> workMap = jsonDecode(jsonStr);
            final Map<String, String> workStringMap = workMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));

            final isDummyFlag = workStringMap['isDummy'] == 'true';
            final hasDummyId = workStringMap['id']?.startsWith('dummy') ?? false;

            if (!isDummyFlag && !hasDummyId) {
              workHistoryData.add(workStringMap);
            }
          } catch (e) {
            // Handle error silently
          }
        }

        if (workHistoryData.isNotEmpty) {
          _workHistoryItems = [];

          for (int i = 0; i < workHistoryData.length; i++) {
            final work = workHistoryData[i];
            final entryNumber = i + 1;

            if (_workHistoryItems.isNotEmpty) {
              _workHistoryItems.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  height: 1,
                  color: Colors.grey[300],
                ),
              );
            }

            _workHistoryItems.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: Text(
                  'Riwayat Pekerjaan $entryNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.primarySwatch,
                    fontSize: 14.0,
                  ),
                ),
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.business,
                'Perusahaan',
                work['company']?.isNotEmpty == true ? work['company']! : 'Belum diisi',
                theme,
                isMissing: work['company']?.isEmpty != false,
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work,
                'Posisi',
                work['position']?.isNotEmpty == true ? work['position']! : 'Belum diisi',
                theme,
                isMissing: work['position']?.isEmpty != false,
              ),
            );

            _workHistoryItems.add(
              _buildInfoItem(
                Icons.calendar_today,
                'Periode',
                '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}',
                theme,
                isMissing: work['startYear']?.isEmpty != false,
              ),
            );
          }

          if (justSaved) {
            await prefs.setBool('work_history_just_saved', false);
          }

          return;
        }
      }

      _workHistoryItems = [
        _buildInfoItem(Icons.work_off, 'Riwayat Pekerjaan', 'Belum diisi', theme, isMissing: true),
      ];
    } catch (e) {
      _workHistoryItems = [
        _buildInfoItem(Icons.work_off, 'Riwayat Pekerjaan', 'Belum diisi', theme, isMissing: true),
      ];
    }
  }

  List<Widget> _buildWorkHistoryItems(dynamic theme) {
    if (!_workHistoryLoaded) {
      return [
        _buildInfoItem(Icons.hourglass_empty, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }

    if (_workHistoryItems.isNotEmpty) {
      return _workHistoryItems;
    } else {
      return [
        _buildInfoItem(Icons.work, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }
  }

  Widget _buildProfilePhoto(dynamic theme) {
    final idCardData = ref.watch(idCardDataProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final size = isTablet ? 120.0 : 100.0;

    if (idCardData.fotoPath.isNotEmpty && _isValidLocalFile(idCardData.fotoPath)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(idCardData.fotoPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primarySwatch.withOpacity(0.1),
      ),
      child: Icon(
        Icons.person_outline,
        size: 20,
        color: theme.primarySwatch,
      ),
    );
  }
}