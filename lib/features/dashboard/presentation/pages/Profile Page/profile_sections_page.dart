import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/nav_bar.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataDiri/providers/profile_data_provider.dart';
import 'dart:io';

// Lifecycle observer for detecting when app resumes
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;

  _AppLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

class ProfileSectionsPage extends ConsumerStatefulWidget {
  const ProfileSectionsPage({super.key});

  @override
  ConsumerState<ProfileSectionsPage> createState() =>
      _ProfileSectionsPageState();
}

class _ProfileSectionsPageState extends ConsumerState<ProfileSectionsPage> {
  final Set<String> _editedSections = {};
  final Set<String> _completedSections = {};
  bool _hasUnsavedChanges = false;
  bool _isProcessingImmediateFlagDetection = false; // Protection flag

  // CRITICAL FIX: Track sections that were just edited via navigation
  // to prevent _loadCompletionStatus from overriding them
  final Set<String> _recentlyEditedViNavigation = {};

  late final Map<String, dynamic> _originalData = {};
  late final _AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    print('=== PROFILE SECTIONS initState CALLED ===');

    // Setup lifecycle observer untuk mendeteksi app resume
    _lifecycleObserver = _AppLifecycleObserver(onResume: _handleAppResume);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    _loadCompletionStatus();
    _saveOriginalData();
    _validateIdCardData();
  }

  @override
  void dispose() {
    // Remove lifecycle observer saat widget di-dispose
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  // Handle app resume - reset data jika fresh login
  void _handleAppResume() async {
    print('=== APP RESUMED - CHECKING FOR FRESH LOGIN ===');

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;

      if (isLoggedOut) {
        print('🔄 FRESH LOGIN DETECTED ON APP RESUME');
        print('→ Clearing all profile data and flags');

        // Clear semua flags untuk fresh start
        await prefs.remove('education_has_changes');
        await prefs.remove('education_just_saved');
        await prefs.remove('education_user_saved');
        await prefs.remove('education_data');
        await prefs.remove('work_history_has_changes');
        await prefs.remove('work_history_just_saved');
        await prefs.remove('work_history_user_saved');
        await prefs.remove('work_history_data');
        await prefs.remove('family_has_changes');
        await prefs.remove('family_just_saved');
        await prefs.remove('family_user_saved');
        await prefs.remove('family_data');

        // Clear temporary flags juga
        await prefs.remove('_temp_skip_work_history_processing');

        // Clear completion provider - reset semua section ke incomplete
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

        // Reset provider data ke kondisi awal (empty)
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(RiwayatPekerjaanData());
        ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());

        // Reset UI state
        if (mounted) {
          setState(() {
            _editedSections.clear();
            _completedSections.clear();
            _hasUnsavedChanges = false;
          });
        }

        // Clear flag is_logged_out setelah cleanup selesai
        await prefs.setBool('is_logged_out', false);

        // Reload completion status untuk fresh start
        _loadCompletionStatus();

        print('✅ Fresh login reset completed - all data cleared');
        print('→ Profile sections page ready for fresh user session');
      } else {
        print('📱 App resumed - no fresh login detected');
      }
    } catch (e) {
      print('❌ Error during app resume fresh login check: $e');
    }

    print('=== END APP RESUME CHECK ===');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('=== PROFILE SECTIONS didChangeDependencies CALLED ===');

    ref.invalidate(pendidikanDataProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted && !_isProcessingImmediateFlagDetection) {
        print(
          '→ didChangeDependencies calling _loadCompletionStatus after delay',
        );
        _loadCompletionStatus();
      } else {
        print(
          '→ didChangeDependencies skipped _loadCompletionStatus (immediate detection in progress)',
        );
      }
    });
  }

  void _validateIdCardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        // Direct validation to avoid method lookup issues
        final idCardData = ref.read(idCardDataProvider);
        if (idCardData.fotoPath.isNotEmpty) {
          try {
            final file = File(idCardData.fotoPath);
            if (!file.existsSync()) {
              print(
                'IdCard: Cleaning invalid file path: ${idCardData.fotoPath}',
              );
              ref
                  .read(idCardDataProvider.notifier)
                  .updateData(IdCardData(fotoPath: '', isUploaded: false));
            } else {
              print('IdCard: File path is valid: ${idCardData.fotoPath}');
            }
          } catch (e) {
            print('IdCard: Error during file validation, clearing data: $e');
            ref
                .read(idCardDataProvider.notifier)
                .updateData(IdCardData(fotoPath: '', isUploaded: false));
          }
        } else {
          print('IdCard: No file path to validate');
        }
        print('IdCard data validation completed');
      } catch (e) {
        print('Error during IdCard validation: $e');
      }
    });
  }

  // Simpan data asli saat pertama kali load page
  void _saveOriginalData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Add mounted check

      _originalData['editProfile'] = ref.read(editProfileDataProvider);
      _originalData['identitasDiri'] = ref.read(pribadiDataProvider);
      _originalData['honorarium'] = ref.read(honorariumDataProvider);
      _originalData['dataLamaran'] = ref.read(dataLamaranDataProvider);
      _originalData['dokumen'] = ref.read(dokumenDataProvider);
      _originalData['keluarga'] = ref.read(keluargaDataProvider);
      _originalData['pendidikan'] = ref.read(pendidikanDataProvider);
      _originalData['riwayatPekerjaan'] = ref.read(
        riwayatPekerjaanDataProvider,
      );
      _originalData['idCard'] = ref.read(idCardDataProvider);
    });
  }

  // Load status completion dari provider
  void _loadCompletionStatus() {
    print('=== _loadCompletionStatus START ===');

    // Check if immediate flag detection is in progress
    if (_isProcessingImmediateFlagDetection) {
      print(
        '⚠️ SKIPPING _loadCompletionStatus: Immediate flag detection in progress',
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return; // Add mounted check

      // Double check protection flag inside postFrameCallback
      if (_isProcessingImmediateFlagDetection) {
        print(
          '⚠️ SKIPPING postFrameCallback: Immediate flag detection still in progress',
        );
        return;
      }

      // SAFETY CHECK: Pastikan kita tidak dalam kondisi fresh login atau data inconsistent
      final prefsCheck = await SharedPreferences.getInstance();
      final isLoggedOut = prefsCheck.getBool('is_logged_out') ?? false;
      final safetyWorkHistoryUserSaved =
          prefsCheck.getBool('work_history_user_saved') ?? false;
      final safetyWorkHistoryDataList =
          prefsCheck.getStringList('work_history_data') ?? [];

      print('=== SAFETY CHECK ===');
      print('isLoggedOut: $isLoggedOut');
      print('safetyWorkHistoryUserSaved: $safetyWorkHistoryUserSaved');
      print('safetyWorkHistoryDataList: $safetyWorkHistoryDataList');

      if (isLoggedOut) {
        print('=== FRESH LOGIN DETECTED - SKIPPING COMPLETION STATUS LOAD ===');
        // Jangan load completion status saat fresh login, tunggu sampai data di-clear dulu
        return;
      }

      // REMOVED AGGRESSIVE SAFETY CHECK: This was causing data loss during normal save operations
      // The aggressive clearing of work history data was interfering with legitimate save operations
      // Work history data management should only happen in riwayat_pekerjaan_page.dart

      print(
        'SAFETY CHECK: work_history_user_saved = $safetyWorkHistoryUserSaved',
      );
      print(
        'SAFETY CHECK: Allowing normal completion status processing to continue',
      );
      print(
        'SAFETY CHECK: Work history data management is handled by riwayat_pekerjaan_page only',
      );

      final completionStatus = ref.read(profileCompletionProvider);

      // DEBUG: Print completion status after potential clear
      print('=== COMPLETION STATUS DEBUG ===');
      print('completionStatus keys: ${completionStatus.keys.toList()}');
      print('riwayat_pekerjaan: ${completionStatus['riwayat_pekerjaan']}');
      print('riwayatPekerjaan: ${completionStatus['riwayatPekerjaan']}');
      print('=== END COMPLETION STATUS DEBUG ===');

      final editProfileData = ref.read(editProfileDataProvider);
      final pribadiData = ref.read(pribadiDataProvider);
      final honorariumData = ref.read(honorariumDataProvider);
      final dataLamaranData = ref.read(dataLamaranDataProvider);
      final dokumenData = ref.read(dokumenDataProvider);
      final keluargaData = ref.read(keluargaDataProvider);
      final pendidikanData = ref.read(
        pendidikanDataProvider,
      ); // Kembali ke read, sudah di-invalidate
      // final riwayatPekerjaanData = ref.read(riwayatPekerjaanDataProvider); // Tidak digunakan lagi
      final idCardData = ref.read(idCardDataProvider);

      // Load user saved flags for education and work history
      final prefs = await SharedPreferences.getInstance();
      final educationUserSaved = prefs.getBool('education_user_saved') ?? false;
      final workHistoryUserSaved =
          prefs.getBool('work_history_user_saved') ?? false;
      final familyUserSaved = prefs.getBool('family_user_saved') ?? false;

      // Check jika ada perubahan dari individual pages
      final educationHasChanges =
          prefs.getBool('education_has_changes') ?? false;
      final workHistoryHasChanges =
          prefs.getBool('work_history_has_changes') ?? false;
      final familyHasChanges = prefs.getBool('family_has_changes') ?? false;

      print('=== FLAGS CHECK SIMPLE ===');
      print('educationHasChanges: $educationHasChanges');
      print('workHistoryHasChanges: $workHistoryHasChanges');
      print('familyHasChanges: $familyHasChanges');
      print('==========================');

      // DEBUG: Print flags untuk work history
      print('=== WORK HISTORY FLAGS DEBUG ===');
      print('workHistoryUserSaved: $workHistoryUserSaved');
      print('workHistoryHasChanges: $workHistoryHasChanges');
      print(
        'work_history_data in storage: ${prefs.getStringList('work_history_data')}',
      );
      print('=== END DEBUG ===');

      print('=== FLAGS CHECK ===');
      print('educationUserSaved: $educationUserSaved');
      print('educationHasChanges: $educationHasChanges');
      print('workHistoryUserSaved: $workHistoryUserSaved');
      print('workHistoryHasChanges: $workHistoryHasChanges');
      print('familyUserSaved: $familyUserSaved');
      print('familyHasChanges: $familyHasChanges');
      print('==================');

      // Check jika user baru saja save dari individual pages
      final educationJustSaved = prefs.getBool('education_just_saved') ?? false;
      final workHistoryJustSaved =
          prefs.getBool('work_history_just_saved') ?? false;
      final familyJustSaved = prefs.getBool('family_just_saved') ?? false;

      print('=== CRITICAL EDUCATION FLAGS CHECK ===');
      print(
        'educationJustSaved: $educationJustSaved (this should trigger EDITED if true)',
      );
      print('educationHasChanges: $educationHasChanges');
      print('educationUserSaved: $educationUserSaved');
      print('========================================');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          final currentCompletedSections = Set<String>.from(_completedSections);
          print('=== DEBUG STATUS CHECK ===');
          print('Current completed sections: $currentCompletedSections');
          print('Current edited sections: $_editedSections');
          print('educationHasChanges: $educationHasChanges');
          print('workHistoryHasChanges: $workHistoryHasChanges');
          print('completionStatus: $completionStatus');

          _completedSections.clear();

          if (familyJustSaved) {
            if (!_editedSections.contains('Keluarga')) {
              _editedSections.add('Keluarga');
              _hasUnsavedChanges = true;
            }
            print(
              '→ Family just saved from individual page, marked as edited for profile sections save',
            );
          }

          if (editProfileData.nama.isNotEmpty ||
              editProfileData.nik.isNotEmpty) {
            if (_hasDataChangedSync('editProfile', editProfileData, true)) {
              if (!_editedSections.contains('Edit Profil')) {
                _editedSections.add('Edit Profil');
              }
            } else {
              if (completionStatus['editProfile'] == true) {
                _completedSections.add('Edit Profil');
              }
            }
          }

          if (pribadiData.tempatLahir.isNotEmpty ||
              pribadiData.email.isNotEmpty) {
            if (_hasDataChangedSync('identitasDiri', pribadiData, true)) {
              if (!_editedSections.contains('Identitas Diri')) {
                _editedSections.add('Identitas Diri');
              }
            } else {
              if (completionStatus['identitasDiri'] == true) {
                _completedSections.add('Identitas Diri');
              }
            }
          }

          if (honorariumData.kartuKeluarga.isNotEmpty ||
              honorariumData.ktp.isNotEmpty) {
            if (_hasDataChangedSync('honorarium', honorariumData, true)) {
              if (!_editedSections.contains('Honorarium')) {
                _editedSections.add('Honorarium');
              }
            } else {
              if (completionStatus['honorarium'] == true) {
                _completedSections.add('Honorarium');
              }
            }
          }

          if (dataLamaranData.position.isNotEmpty ||
              dataLamaranData.placement.isNotEmpty) {
            if (_hasDataChangedSync('dataLamaran', dataLamaranData, true)) {
              if (!_editedSections.contains('Data Lamaran')) {
                _editedSections.add('Data Lamaran');
              }
            } else {
              if (completionStatus['dataLamaran'] == true) {
                _completedSections.add('Data Lamaran');
              }
            }
          }

          if (dokumenData.cvUploaded || dokumenData.ktpUploaded) {
            if (_hasDataChangedSync('dokumen', dokumenData, true)) {
              if (!_editedSections.contains('Dokumen')) {
                _editedSections.add('Dokumen');
              }
            } else {
              if (completionStatus['dokumen'] == true) {
                _completedSections.add('Dokumen');
              }
            }
          }

          if (keluargaData.namaAyah.isNotEmpty ||
              keluargaData.namaIbu.isNotEmpty) {
            print('=== KELUARGA STATUS CHECK ===');
            print(
              'completionStatus[keluarga]: ${completionStatus['keluarga']}',
            );
            print('familyHasChanges: $familyHasChanges');

            if (completionStatus['keluarga'] == true) {
              _completedSections.add('Keluarga');
              print('→ Added to COMPLETED (provider status = true)');
            } else if (familyHasChanges) {
              if (!_editedSections.contains('Keluarga')) {
                _editedSections.add('Keluarga');
                _hasUnsavedChanges = true;
                print('→ Added to EDITED (flag = true)');
              }
            } else if (_hasDataChangedSync(
              'keluarga',
              keluargaData,
              familyUserSaved,
            )) {
              if (!_editedSections.contains('Keluarga')) {
                _editedSections.add('Keluarga');
                _hasUnsavedChanges = true;
                print('→ Added to EDITED (sync check = true)');
              }
            } else {
              print('→ No status (no conditions met)');
            }
          }

          print('=== PENDIDIKAN STATUS CHECK START ===');
          print(
            'completionStatus[pendidikan]: ${completionStatus['pendidikan']}',
          );
          print('educationHasChanges: $educationHasChanges');
          print('educationJustSaved: $educationJustSaved');
          print('educationUserSaved: $educationUserSaved');
          print(
            'pendidikanData: ${pendidikanData.tingkatPendidikan} - ${pendidikanData.namaInstitusi}',
          );
          print(
            '_editedSections contains Pendidikan: ${_editedSections.contains('Pendidikan')}',
          );
          print(
            '_completedSections contains Pendidikan: ${_completedSections.contains('Pendidikan')}',
          );
          print('Current _editedSections before check: $_editedSections');
          print('Current _completedSections before check: $_completedSections');

          final educationDataList = prefs.getStringList('education_data');
          final hasActualEducationData =
              educationDataList != null && educationDataList.isNotEmpty;
          print('hasActualEducationData in storage: $hasActualEducationData');
          print('educationDataList: $educationDataList');

          if (_recentlyEditedViNavigation.contains('Pendidikan')) {
            print(
              '→ PRESERVED: Pendidikan recently edited via navigation, keeping EDITED status',
            );
            if (!_editedSections.contains('Pendidikan')) {
              _editedSections.add('Pendidikan');
              _hasUnsavedChanges = true;
            }
          } else if (educationHasChanges) {
            print('→ CONDITION 1: educationHasChanges = true');
            if (!_editedSections.contains('Pendidikan')) {
              _editedSections.add('Pendidikan');
              _hasUnsavedChanges = true;
              print('→ Added Pendidikan to EDITED (has unsaved changes)');
            } else {
              print('→ Pendidikan already in EDITED sections');
            }
          } else if (educationJustSaved) {
            print('→ CONDITION 2: educationJustSaved = true');
            if (!_editedSections.contains('Pendidikan')) {
              _editedSections.add('Pendidikan');
              _hasUnsavedChanges = true;
              print(
                '→ Added Pendidikan to EDITED (just saved from individual page, need profile sections save)',
              );
            } else {
              print('→ Pendidikan already in EDITED sections');
            }
          } else if (educationUserSaved &&
              hasActualEducationData &&
              completionStatus['pendidikan'] == true) {
            print(
              '→ CONDITION 3: educationUserSaved = true AND hasActualEducationData = true AND completionStatus = true',
            );
            _completedSections.add('Pendidikan');
            print(
              '→ Added Pendidikan to COMPLETED (user has saved, has data, and provider status = true)',
            );
          } else {
            print('→ NO CONDITIONS MET - No status assigned');
            print('  - educationUserSaved: $educationUserSaved');
            print('  - educationHasChanges: $educationHasChanges');
            print('  - educationJustSaved: $educationJustSaved');
            print(
              '  - completionStatus[pendidikan]: ${completionStatus['pendidikan']}',
            );
            print(
              '  - has provider data: ${pendidikanData.tingkatPendidikan.isNotEmpty || pendidikanData.namaInstitusi.isNotEmpty}',
            );
          }

          print('FINAL AFTER PENDIDIKAN CHECK:');
          print('→ _editedSections: $_editedSections');
          print('→ _completedSections: $_completedSections');
          print('→ _hasUnsavedChanges: $_hasUnsavedChanges');
          print('=== PENDIDIKAN STATUS CHECK END ===');

          final skipWorkHistoryProcessing =
              prefs.getBool('_temp_skip_work_history_processing') ?? false;
          if (skipWorkHistoryProcessing) {
            Future.microtask(() async {
              await prefs.remove('_temp_skip_work_history_processing');
            });
            print('=== SKIPPING WORK HISTORY PROCESSING (TEMPORARY FLAG) ===');
            print('→ NOT added to any sections (temporary skip)');
          } else {
            print('=== RIWAYAT PEKERJAAN STATUS CHECK START ===');
            print('workHistoryHasChanges: $workHistoryHasChanges');
            print('workHistoryUserSaved: $workHistoryUserSaved');
            print('workHistoryJustSaved: $workHistoryJustSaved');
            print(
              'completionStatus[riwayatPekerjaan]: ${completionStatus['riwayatPekerjaan']}',
            );

            final workHistoryDataList = prefs.getStringList(
              'work_history_data',
            );
            final hasActualData =
                workHistoryDataList != null && workHistoryDataList.isNotEmpty;

            print('hasActualData in storage: $hasActualData');
            print('workHistoryDataList: $workHistoryDataList');
            print(
              '_editedSections contains Riwayat Pekerjaan: ${_editedSections.contains('Riwayat Pekerjaan')}',
            );
            print(
              '_completedSections contains Riwayat Pekerjaan: ${_completedSections.contains('Riwayat Pekerjaan')}',
            );
            print('Current _editedSections before check: $_editedSections');
            print(
              'Current _completedSections before check: $_completedSections',
            );

            // SAMA DENGAN PENDIDIKAN - Prioritas: work_history_has_changes > work_history_just_saved > work_history_user_saved + actual data + completed
            // Prioritas 1: Jika ada flag work_history_has_changes, mark as edited (perubahan baru yang belum disimpan)
            if (workHistoryHasChanges) {
              print('→ CONDITION 1: workHistoryHasChanges = true');
              if (!_editedSections.contains('Riwayat Pekerjaan')) {
                _editedSections.add('Riwayat Pekerjaan');
                _hasUnsavedChanges = true;
                print(
                  '→ Added Riwayat Pekerjaan to EDITED (has unsaved changes)',
                );
              } else {
                print('→ Riwayat Pekerjaan already in EDITED sections');
              }
            } else if (workHistoryJustSaved) {
              print('→ CONDITION 2: workHistoryJustSaved = true');
              if (!_editedSections.contains('Riwayat Pekerjaan')) {
                _editedSections.add('Riwayat Pekerjaan');
                _hasUnsavedChanges = true;
                print(
                  '→ Added Riwayat Pekerjaan to EDITED (just saved from individual page, need profile sections save)',
                );
              } else {
                print('→ Riwayat Pekerjaan already in EDITED sections');
              }
            } else if (workHistoryUserSaved &&
                hasActualData &&
                completionStatus['riwayatPekerjaan'] == true) {
              print(
                '→ CONDITION 3: workHistoryUserSaved = true AND hasActualData = true AND completionStatus = true',
              );
              _completedSections.add('Riwayat Pekerjaan');
              print(
                '→ Added Riwayat Pekerjaan to COMPLETED (user has saved, has data, and provider status = true)',
              );
            } else {
              print('→ NO CONDITIONS MET - No status assigned');
              print('  - workHistoryUserSaved: $workHistoryUserSaved');
              print('  - workHistoryHasChanges: $workHistoryHasChanges');
              print('  - workHistoryJustSaved: $workHistoryJustSaved');
              print(
                '  - completionStatus[riwayatPekerjaan]: ${completionStatus['riwayatPekerjaan']}',
              );
              print('  - hasActualData: $hasActualData');
            }

            print('FINAL AFTER RIWAYAT PEKERJAAN CHECK:');
            print('→ _editedSections: $_editedSections');
            print('→ _completedSections: $_completedSections');
            print('=== RIWAYAT PEKERJAAN STATUS CHECK END ===');
          }

          if (idCardData.fotoPath.isNotEmpty || idCardData.isUploaded) {
            if (_hasDataChangedSync('pasFoto', idCardData, true)) {
              if (!_editedSections.contains('PAS Foto')) {
                _editedSections.add('PAS Foto');
              }
            } else {
              if (completionStatus['pasFoto'] == true) {
                _completedSections.add('PAS Foto');
              }
            }
          }

          _hasUnsavedChanges = _editedSections.isNotEmpty;

          completionStatus.forEach((key, value) {
            if (value) {
              final sectionName = _getSectionNameFromKey(key);

              if (!_editedSections.contains(sectionName)) {
                _completedSections.add(sectionName);
              }
            }
          });

          for (String sectionName in currentCompletedSections) {
            if (!_editedSections.contains(sectionName)) {
              _completedSections.add(sectionName);
            }
          }

          print('=== FINAL STATUS ===');
          print('Final completed sections: $_completedSections');
          print('Final edited sections: $_editedSections');
          print('===================');
        });
      });
    });
  }

  // Helper method untuk cek apakah data berubah dari status yang tersimpan (sync version)
  bool _hasDataChangedSync(
    String section,
    dynamic currentData,
    bool userHasSaved,
  ) {
    print('=== _hasDataChangedSync DEBUG ===');
    print('section: $section');
    print('userHasSaved: $userHasSaved');

    // Cek apakah ada data yang diisi
    if (!_hasNonEmptyData(section, currentData)) {
      print('→ No non-empty data, returning false');
      return false; // Tidak ada data, tidak dalam status edited
    }
    print('→ Has non-empty data');

    // Untuk section pendidikan dan riwayat pekerjaan, cek flag user_saved
    if ((section == 'pendidikan' || section == 'riwayatPekerjaan') &&
        !userHasSaved) {
      print('→ User has not saved yet, returning false');
      return false; // Data dummy ada tapi user belum save = tidak ada status
    }
    print('→ User has saved');

    // Cek apakah section sudah di-mark completed di provider
    final completionStatus = ref.read(profileCompletionProvider);
    final isMarkedCompleted = completionStatus[section] == true;
    print('→ completionStatus[$section]: ${completionStatus[section]}');
    print('→ isMarkedCompleted: $isMarkedCompleted');

    // Jika sudah completed, maka section ini tidak dalam status "edited" lagi
    if (isMarkedCompleted) {
      print('→ Already completed, returning false');
      return false; // Sudah completed, tidak edited
    }

    // Jika belum completed dan ada data, maka statusnya edited
    print('→ Not completed but has data, returning true (EDITED)');
    return true; // Ada data tapi belum completed = edited
  }

  // Helper method untuk cek apakah data tidak kosong (indicating ada data baru)
  bool _hasNonEmptyData(String section, dynamic data) {
    try {
      switch (section) {
        case 'editProfile':
          return data.nama.isNotEmpty ||
              data.nik.isNotEmpty ||
              data.bidangKeahlian.isNotEmpty ||
              data.toefl.isNotEmpty;
        case 'identitasDiri':
          return data.tempatLahir.isNotEmpty ||
              data.email.isNotEmpty ||
              data.handphone.isNotEmpty ||
              data.address.isNotEmpty;
        case 'honorarium':
          return data.kartuKeluarga.isNotEmpty ||
              data.ktp.isNotEmpty ||
              data.rekening.isNotEmpty;
        case 'dataLamaran':
          return data.position.isNotEmpty || data.placement.isNotEmpty;
        case 'dokumen':
          return data.cvUploaded || data.ktpUploaded || data.kkUploaded;
        case 'keluarga':
          return data.namaAyah.isNotEmpty || data.namaIbu.isNotEmpty;
        case 'pendidikan':
          return data.tingkatPendidikan.isNotEmpty ||
              data.namaInstitusi.isNotEmpty;
        case 'riwayatPekerjaan':
          return data.namaPerusahaan.isNotEmpty || data.posisi.isNotEmpty;
        case 'pasFoto':
          return data.fotoPath.isNotEmpty || data.isUploaded;
        default:
          return false;
      }
    } catch (e) {
      print('Error checking non-empty data for section $section: $e');
      return false;
    }
  }

  // Helper untuk convert completion key ke section name
  String _getSectionNameFromKey(String key) {
    switch (key) {
      case 'editProfile':
        return 'Edit Profil';
      case 'identitasDiri':
        return 'Identitas Diri';
      case 'honorarium':
        return 'Honorarium';
      case 'keluarga':
        return 'Keluarga';
      case 'pasFoto':
        return 'PAS Foto';
      case 'dokumen':
        return 'Dokumen';
      case 'pendidikan':
        return 'Pendidikan';
      case 'riwayatPekerjaan':
        return 'Riwayat Pekerjaan';
      case 'dataLamaran':
        return 'Data Lamaran';
      default:
        return key;
    }
  }

  // Fungsi untuk navigasi dengan callback
  Future<void> _navigateToSection(String routeName, String sectionName) async {
    print('=== NAVIGATING TO SECTION: $sectionName ===');

    // Store status sebelum navigasi
    final completionStatus = ref.read(profileCompletionProvider);
    final wasCompleted =
        completionStatus[_getSectionKeyFromName(sectionName)] == true;

    print('Section before navigation - wasCompleted: $wasCompleted');
    print('_editedSections before: $_editedSections');
    print('_completedSections before: $_completedSections');

    // Navigasi ke halaman form
    final result = await context.pushNamed(routeName);

    print('Navigation result: $result');

    // CRITICAL FIX: Add longer delay to ensure SharedPreferences operations from child pages are completed
    // This is especially important for card-based pages that do async operations
    await Future.delayed(const Duration(milliseconds: 200));

    // CRITICAL FIX: SELALU panggil immediate flag detection, regardless of return value
    // Ini untuk mendeteksi add/edit/delete yang tidak return value tapi sudah set flag
    print('→ Calling immediate flag detection for $sectionName...');
    await _checkFlagsImmediatelyAfterNavigation(sectionName);

    // Jika form mengembalikan 'saved', berarti user menyimpan data (legacy support)
    if (result == 'saved' || result == true) {
      print('→ Legacy return value detected, additional handling...');
      setState(() {
        // Jika section sebelumnya sudah completed, ubah ke edited
        if (wasCompleted) {
          _completedSections.remove(sectionName);
          _editedSections.add(sectionName);
          _hasUnsavedChanges = true;

          // Unmark completed status
          final completionNotifier = ref.read(
            profileCompletionProvider.notifier,
          );
          completionNotifier.markIncomplete(
            _getSectionKeyFromName(sectionName),
          );

          // Reset flag user_saved untuk pendidikan dan riwayat pekerjaan jika mereka di-edit ulang
          _resetUserSavedFlagIfNeeded(sectionName);
        } else {
          // Jika belum completed, tambahkan ke edited
          _editedSections.add(sectionName);
          _hasUnsavedChanges = true;
        }
      });
    } else {
      print('→ No legacy return value, relying on immediate flag detection');
    }

    print('_editedSections after navigation: $_editedSections');
    print('_completedSections after navigation: $_completedSections');
    print('=== END NAVIGATION TO $sectionName ===');
  }

  // Check flags immediately after navigation to detect unsaved changes
  Future<void> _checkFlagsImmediatelyAfterNavigation(String sectionName) async {
    print('=== IMMEDIATE FLAG CHECK AFTER NAVIGATION ===');
    print('Section: $sectionName');

    // Set protection flag to prevent interference from _loadCompletionStatus
    _isProcessingImmediateFlagDetection = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Cek flag has_changes untuk section yang baru saja di-navigate
      bool hasChanges = false;
      String flagKey = '';

      if (sectionName == 'Pendidikan') {
        hasChanges = prefs.getBool('education_has_changes') ?? false;
        flagKey = 'education_has_changes';
      } else if (sectionName == 'Riwayat Pekerjaan') {
        hasChanges = prefs.getBool('work_history_has_changes') ?? false;
        flagKey = 'work_history_has_changes';
      } else if (sectionName == 'Keluarga') {
        hasChanges = prefs.getBool('family_has_changes') ?? false;
        flagKey = 'family_has_changes';
      }

      print('Flag $flagKey: $hasChanges');

      if (hasChanges && mounted) {
        print('→ Detected unsaved changes, updating status to EDITED');
        setState(() {
          // Remove from completed if it was there
          final sectionKey = _getSectionKeyFromName(sectionName);
          _completedSections.remove(sectionName);

          // Add to edited sections
          _editedSections.add(sectionName);
          _hasUnsavedChanges = true;

          // CRITICAL FIX: Track this section as recently edited via navigation
          // This prevents _loadCompletionStatus from overriding the status
          _recentlyEditedViNavigation.add(sectionName);

          // Unmark completed status in provider
          final completionNotifier = ref.read(
            profileCompletionProvider.notifier,
          );
          completionNotifier.markIncomplete(sectionKey);
        });

        print('→ Status updated to EDITED for $sectionName');
      } else {
        print('→ No unsaved changes detected');
      }
    } catch (e) {
      print('Error in immediate flag check: $e');
    } finally {
      // CRITICAL FIX: Hold protection flag longer to prevent didChangeDependencies
      // from interfering with our status update via _loadCompletionStatus
      Future.delayed(const Duration(milliseconds: 300), () {
        _isProcessingImmediateFlagDetection = false;
        print('→ Protection flag cleared after extended delay');
      });

      // Clear recently edited via navigation after longer delay to prevent status from being sticky
      Future.delayed(const Duration(milliseconds: 500), () {
        _recentlyEditedViNavigation.clear();
        print('→ Recently edited via navigation cleared');
      });
    }

    print('=== END IMMEDIATE FLAG CHECK (protection flag still active) ===');
  }

  // Helper function to reset user_saved flag if needed
  void _resetUserSavedFlagIfNeeded(String sectionName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (sectionName == 'Pendidikan') {
        await prefs.setBool('education_user_saved', false);
        print('Reset education_user_saved = false');
      } else if (sectionName == 'Riwayat Pekerjaan') {
        await prefs.setBool('work_history_user_saved', false);
        print('Reset work_history_user_saved = false');
      }
    } catch (e) {
      print('Error resetting user_saved flag: $e');
    }
  }

  // Helper untuk convert section name ke completion key
  String _getSectionKeyFromName(String sectionName) {
    switch (sectionName) {
      case 'Edit Profil':
        return 'editProfile';
      case 'Identitas Diri':
        return 'identitasDiri';
      case 'Honorarium':
        return 'honorarium';
      case 'Keluarga':
        return 'keluarga';
      case 'PAS Foto':
        return 'pasFoto';
      case 'Dokumen':
        return 'dokumen';
      case 'Pendidikan':
        return 'pendidikan';
      case 'Riwayat Pekerjaan':
        return 'riwayatPekerjaan';
      case 'Data Lamaran':
        return 'dataLamaran';
      default:
        return sectionName.toLowerCase();
    }
  }

  // Fungsi untuk menyimpan semua perubahan
  void _saveChanges() async {
    setState(() {
      // Pindahkan semua edited sections ke completed sections
      _completedSections.addAll(_editedSections);

      // Update completion status di provider untuk setiap edited section
      final completionNotifier = ref.read(profileCompletionProvider.notifier);
      for (String sectionName in _editedSections) {
        final sectionKey = _getSectionKeyFromName(sectionName);
        completionNotifier.markCompleted(sectionKey);
      }

      // Clear edited sections dan unsaved changes flag
      _editedSections.clear();
      _hasUnsavedChanges = false;
    });

    // Set flag user_saved untuk pendidikan dan riwayat pekerjaan jika ada perubahan
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cek apakah pendidikan atau riwayat pekerjaan ada di completed sections
      if (_completedSections.contains('Pendidikan')) {
        // JANGAN AUTO-SET education_user_saved flag di sini!
        // Flag ini hanya boleh di-set saat user explicitly save di pendidikan page
        // Kalau di-set di sini, akan menyebabkan data muncul di profile page padahal user belum save

        print(
          'Pendidikan in completed sections, but NOT setting education_user_saved flag',
        );
        print(
          'Flag education_user_saved should only be set from pendidikan page save',
        );

        // Clear flag education_has_changes karena sudah di-save di profile sections
        await prefs.setBool('education_has_changes', false);
        // Clear flag education_just_saved karena sudah di-save di profile sections
        await prefs.setBool('education_just_saved', false);
        print('Clear education_has_changes = false');
        print('Clear education_just_saved = false');
      }

      if (_completedSections.contains('Riwayat Pekerjaan')) {
        // JANGAN AUTO-SET work_history_user_saved flag di sini!
        // Flag ini hanya boleh di-set saat user explicitly save di riwayat pekerjaan page
        // Kalau di-set di sini, akan menyebabkan data muncul di profile page padahal user belum save

        print(
          'Riwayat Pekerjaan in completed sections, but NOT setting work_history_user_saved flag',
        );
        print(
          'Flag work_history_user_saved should only be set from riwayat pekerjaan page save',
        );

        // Clear flag work_history_has_changes karena sudah di-save di profile sections
        await prefs.setBool('work_history_has_changes', false);
        // CRITICAL: DON'T clear work_history_just_saved flag!
        // This flag is needed by profile_page to detect saved data properly
        // If we clear it here, profile_page will think user never saved and won't show data
        // await prefs.setBool('work_history_just_saved', false); // REMOVED
        print('Clear work_history_has_changes = false');
        print(
          'PRESERVED work_history_just_saved for profile_page data loading',
        );
      }

      if (_completedSections.contains('Keluarga')) {
        // JANGAN AUTO-SET family_user_saved flag di sini!
        // Flag ini hanya boleh di-set saat user explicitly save di keluarga page
        // Kalau di-set di sini, akan menyebabkan data muncul di profile page padahal user belum save

        print(
          'Keluarga in completed sections, but NOT setting family_user_saved flag',
        );
        print(
          'Flag family_user_saved should only be set from keluarga page save',
        );

        // Clear flag family_has_changes karena sudah di-save di profile sections
        await prefs.setBool('family_has_changes', false);
        // Clear flag family_just_saved karena sudah di-save di profile sections
        await prefs.setBool('family_just_saved', false);
        print('Clear family_has_changes = false');
        print('Clear family_just_saved = false');
      }
    } catch (e) {
      print('Error setting user_saved flags: $e');
    }

    // Update data original dengan data yang baru disimpan
    _saveOriginalData();

    // Status sudah diupdate dengan benar di setState() di atas
    // Tidak perlu refresh lagi untuk menghindari interference

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data profil berhasil disimpan!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi perubahan belum disimpan
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await NotificationUtils.showConfirmationDialog(
      context,
      title: 'Perubahan Belum Disimpan',
      message:
          'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmButtonText: 'Keluar Tanpa Menyimpan',
      cancelButtonText: 'Batal',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );
    return result ?? false;
  }

  // Fungsi untuk menangani tombol back
  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await _showUnsavedChangesDialog();
      if (shouldLeave) {
        // Restore data ke kondisi semula jika user pilih keluar tanpa menyimpan
        _restoreOriginalData();
      }
      return shouldLeave;
    }
    return true;
  }

  // Restore semua data ke kondisi asli
  void _restoreOriginalData() {
    print('=== RESTORING ORIGINAL DATA ===');
    print('Original data map: ${_originalData.keys}');

    if (_originalData.isNotEmpty) {
      // Restore data untuk setiap provider
      if (_originalData.containsKey('editProfile')) {
        print('Restoring editProfile data');
        ref
            .read(editProfileDataProvider.notifier)
            .updateData(_originalData['editProfile']);
      }
      if (_originalData.containsKey('identitasDiri')) {
        print('Restoring identitasDiri data');
        ref
            .read(pribadiDataProvider.notifier)
            .updateData(_originalData['identitasDiri']);
      }
      if (_originalData.containsKey('honorarium')) {
        print('Restoring honorarium data');
        ref
            .read(honorariumDataProvider.notifier)
            .updateData(_originalData['honorarium']);
      }
      if (_originalData.containsKey('dataLamaran')) {
        print('Restoring dataLamaran data');
        ref
            .read(dataLamaranDataProvider.notifier)
            .updateData(_originalData['dataLamaran']);
      }
      if (_originalData.containsKey('dokumen')) {
        print('Restoring dokumen data');
        ref
            .read(dokumenDataProvider.notifier)
            .updateData(_originalData['dokumen']);
      }
      if (_originalData.containsKey('keluarga')) {
        print('Restoring keluarga data');
        ref
            .read(keluargaDataProvider.notifier)
            .updateData(_originalData['keluarga']);
      }
      if (_originalData.containsKey('pendidikan')) {
        print('Restoring pendidikan data');
        ref
            .read(pendidikanDataProvider.notifier)
            .updateData(_originalData['pendidikan']);
      }
      if (_originalData.containsKey('riwayatPekerjaan')) {
        print('Restoring riwayatPekerjaan data');
        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(_originalData['riwayatPekerjaan']);
      }
      if (_originalData.containsKey('idCard')) {
        print('Restoring idCard data');
        ref
            .read(idCardDataProvider.notifier)
            .updateData(_originalData['idCard']);
      }

      // Reset status tracking
      setState(() {
        _editedSections.clear();
        _hasUnsavedChanges = false;
      });

      print('All data restored successfully');
    } else {
      print('No original data to restore');
    }
    print('===============================');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // REMOVED: Watch providers di build method - ini menyebabkan setState during build
    // Providers akan di-watch hanya saat diperlukan di dalam callback atau method terpisah

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Edit Profil',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: theme.primarySwatch,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldLeave = await _showUnsavedChangesDialog();
                if (shouldLeave && mounted) {
                  // Restore data ke kondisi semula jika user pilih keluar tanpa menyimpan
                  _restoreOriginalData();
                  // Set tab ke Profile (index 3) dan navigasi ke MainLayout
                  ref.read(bottomNavIndexProvider.notifier).state = 3;
                  context.go('/home');
                }
              } else {
                // Set tab ke Profile (index 3) dan navigasi ke MainLayout
                ref.read(bottomNavIndexProvider.notifier).state = 3;
                context.go('/home');
              }
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_completedSections.length}/9 Menu',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: _buildDataPribadiContent(theme, isTablet),
      ),
    );
  }

  Widget _buildDataPribadiContent(dynamic theme, bool isTablet) {
    final items = _getDataPribadiItems(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth > 900;

    return Column(
      children: [
        // Grid Menu Items
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeTablet ? 32 : (isTablet ? 24 : 16),
              vertical: isTablet ? 24 : 16,
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(screenWidth),
                childAspectRatio: _getChildAspectRatio(screenWidth),
                crossAxisSpacing: isTablet ? 20 : 16,
                mainAxisSpacing: isTablet ? 20 : 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isCompleted = _completedSections.contains(item.title);
                final isEdited = _editedSections.contains(item.title);

                return _buildMenuItem(
                  item.title,
                  item.icon,
                  item.color,
                  isCompleted,
                  isEdited,
                  item.onTap,
                  theme,
                );
              },
            ),
          ),
        ),

        // Tombol Simpan di bawah
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: ElevatedButton(
            onPressed: _hasUnsavedChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasUnsavedChanges ? theme.primarySwatch : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _hasUnsavedChanges ? 3 : 0,
            ),
            child: Text(
              _hasUnsavedChanges ? 'Simpan Perubahan' : 'Tidak Ada Perubahan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for responsive grid
  int _getCrossAxisCount(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    if (screenWidth > 1200) return 4; // Large desktop
    if (screenWidth > 900) {
      return isLandscape ? 4 : 3; // Tablet landscape/portrait
    }
    if (screenWidth > 600) return isLandscape ? 3 : 3; // Tablet
    return isLandscape ? 3 : 2; // Phone landscape/portrait
  }

  double _getChildAspectRatio(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    if (screenWidth > 1200) return 1.1; // Large desktop
    if (screenWidth > 900) {
      return isLandscape ? 0.95 : 1.0; // Tablet landscape/portrait
    }
    if (screenWidth > 600) return isLandscape ? 0.9 : 0.95; // Tablet
    if (screenWidth < 350)
      return isLandscape ? 0.9 : 1.1; // Small phone - taller cards
    return isLandscape ? 0.85 : 1.0; // Regular phone landscape/portrait
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    bool isCompleted,
    bool isEdited,
    VoidCallback onTap,
    dynamic theme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 350;

    // Responsive sizing
    final iconContainerSize = isSmallPhone ? 60.0 : (isTablet ? 80.0 : 70.0);
    final iconSize = isSmallPhone ? 28.0 : (isTablet ? 40.0 : 35.0);
    final fontSize = isSmallPhone ? 12.0 : (isTablet ? 14.0 : 13.0);
    final padding = isSmallPhone ? 12.0 : 16.0;
    final spacing = isSmallPhone ? 8.0 : 12.0;
    final statusSize = isSmallPhone ? 20.0 : 26.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color, // Use the section color as background
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3), // Shadow matches the color
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top spacer when there's status to push content up
              if (isEdited || isCompleted)
                const Expanded(flex: 1, child: SizedBox())
              else
                const Expanded(flex: 2, child: SizedBox()),

              // Icon with white background - Responsive size
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(icon, size: iconSize, color: Colors.white),
                ),
              ),
              SizedBox(height: spacing),

              // Title in white - Responsive text
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: fontSize,
                  height: 1.2,
                ),
              ),

              // Bottom spacer
              if (isEdited || isCompleted)
                const Expanded(flex: 1, child: SizedBox())
              else
                const Expanded(flex: 2, child: SizedBox()),

              // Status indicator - only when there's status
              if (isEdited || isCompleted)
                SizedBox(
                  height: statusSize,
                  child:
                      isEdited
                          ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallPhone ? 8 : 12,
                              vertical: isSmallPhone ? 3 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(
                                statusSize / 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: isSmallPhone ? 12.0 : 14.0,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Edited',
                                  style: theme.typographyRegular.bodySmall
                                      .copyWith(
                                        fontSize: isSmallPhone ? 9.0 : 11.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          )
                          : Container(
                            width: statusSize,
                            height: statusSize,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: isSmallPhone ? 14.0 : 18.0,
                              ),
                            ),
                          ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<MenuItemData> _getDataPribadiItems(BuildContext context) {
    return [
      MenuItemData(
        'Edit Profil',
        Icons.person,
        const Color(0xFFFF7B7B), // Coral red
        onTap: () async {
          await _navigateToSection('editProfile', 'Edit Profil');
        },
      ),
      MenuItemData(
        'Identitas Diri',
        Icons.badge,
        const Color(0xFF64D8CB), // Turquoise
        onTap: () async {
          await _navigateToSection('pribadi', 'Identitas Diri');
        },
      ),
      MenuItemData(
        'Honorarium',
        Icons.payments,
        const Color(0xFF5BA7F7), // Sky blue
        onTap: () async {
          await _navigateToSection('honorarium', 'Honorarium');
        },
      ),
      MenuItemData(
        'Keluarga',
        Icons.family_restroom,
        const Color(0xFF9BCF9B), // Light green
        onTap: () async {
          await _navigateToSection('keluarga', 'Keluarga');
        },
      ),
      MenuItemData(
        'PAS Foto',
        Icons.contact_phone,
        const Color(0xFFFFC85C), // Golden yellow
        onTap: () async {
          await _navigateToSection('idCard', 'PAS Foto');
        },
      ),
      MenuItemData(
        'Dokumen',
        Icons.folder,
        const Color(0xFF8B7CF6), // Purple
        onTap: () async {
          await _navigateToSection('dokumen', 'Dokumen');
        },
      ),
      MenuItemData(
        'Pendidikan',
        Icons.school,
        const Color(0xFFFF9999), // Light coral
        onTap: () async {
          await _navigateToSection('pendidikan', 'Pendidikan');
        },
      ),
      MenuItemData(
        'Riwayat Pekerjaan',
        Icons.work,
        const Color(0xFFFFB1B1), // Soft pink
        onTap: () async {
          await _navigateToSection('riwayatPekerjaan', 'Riwayat Pekerjaan');
        },
      ),
      MenuItemData(
        'Data Lamaran',
        Icons.card_membership,
        const Color(0xFF70D4AA), // Mint green
        onTap: () async {
          await _navigateToSection('dataLamaran', 'Data Lamaran');
        },
      ),
    ];
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuItemData(this.title, this.icon, this.color, {required this.onTap});
}
