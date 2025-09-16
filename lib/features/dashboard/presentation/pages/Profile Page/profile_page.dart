import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/nav_bar.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../DataDiri/providers/profile_data_provider.dart'; 
import '../DataDiri/keluarga_page.dart'; 
import 'dart:io';

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
  
  // Protection flags untuk prevent race condition dengan profile sections page
  bool _isProcessingImmediateFlagDetection = false;
  Set<String> _recentlyEditedViNavigation = <String>{}; 
  
  @override
  void initState() {
    super.initState();
    print('=== PROFILE PAGE INIT STATE CALLED ===');
    
    // Add delay to prevent race conditions with riwayat_pekerjaan_page save operations
    Future.delayed(const Duration(milliseconds: 100), () async {
      print('=== PROFILE PAGE DELAYED INIT START ===');
      
      // CRITICAL DEBUG: Check current state before any operations
      final prefs = await SharedPreferences.getInstance();
      final currentData = prefs.getStringList('work_history_data');
      final currentUserSaved = prefs.getBool('work_history_user_saved');
      final currentJustSaved = prefs.getBool('work_history_just_saved');
      final currentHasChanges = prefs.getBool('work_history_has_changes');
      
      print('=== PROFILE PAGE INIT - CURRENT STATE ===');
      print('work_history_data: $currentData');
      print('work_history_user_saved: $currentUserSaved');
      print('work_history_just_saved: $currentJustSaved');  
      print('work_history_has_changes: $currentHasChanges');
      
      await _checkFreshLoginAndReset();
      
      // DEBUG: Check state after fresh login check
      final prefsAfter = await SharedPreferences.getInstance();
      final dataAfterCheck = prefsAfter.getStringList('work_history_data');
      print('=== AFTER FRESH LOGIN CHECK ===');
      print('work_history_data after check: $dataAfterCheck');
      
      _loadEducationData();
      _loadUserSavedFlags().then((_) {
        // Setelah flags loaded, reload work history data
        _reloadWorkHistoryData();
        // Debug all stored data
        _debugAllData();
      });
    });
  }

  Future<void> _debugAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('=== DEBUG ALL STORED DATA ===');
      print('work_history_user_saved: ${prefs.getBool('work_history_user_saved')}');
      print('work_history_has_changes: ${prefs.getBool('work_history_has_changes')}');
      print('work_history_just_saved: ${prefs.getBool('work_history_just_saved')}');
      print('work_history_data: ${prefs.getStringList('work_history_data')}');
      print('_workHistoryUserSaved: $_workHistoryUserSaved');
      print('_workHistoryLoaded: $_workHistoryLoaded');
      print('_workHistoryItems.length: ${_workHistoryItems.length}');
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error debugging data: $e');
    }
  }

  // Check if this is a fresh login after logout, atau fresh app start
  Future<void> _checkFreshLoginAndReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      

      final hasWorkHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
      final workHistoryDataList = prefs.getStringList('work_history_data') ?? [];
      final hasActualWorkData = workHistoryDataList.isNotEmpty;
      
      print('=== FRESH LOGIN CHECK ===');
      print('isLoggedOut: $isLoggedOut');
      print('hasWorkHistoryUserSaved: $hasWorkHistoryUserSaved');
      print('hasActualWorkData: $hasActualWorkData');
      print('workHistoryDataList: $workHistoryDataList');
      print('workHistoryDataList.length: ${workHistoryDataList.length}');
      
      // CRITICAL: Profile page should NEVER modify work history data
      // All work history data management should ONLY happen in riwayat_pekerjaan_page.dart
      // Profile page is READ-ONLY for work history data
      print('Profile page: SKIPPING all work history data filtering and modification');
      print('Work history data management is exclusively handled by riwayat_pekerjaan_page.dart');
      
      // DEBUG: Check current state of work history data
      print('=== PROFILE PAGE DEBUG - WORK HISTORY STATE ===');
      print('Current work_history_data in SharedPreferences: $workHistoryDataList');
      print('Current work_history_user_saved flag: $hasWorkHistoryUserSaved');
      print('Profile page will NOT modify any of this data');
      
      // ALSO CLEAR EDUCATION DATA FROM PREVIOUS SESSIONS
      final educationDataList = prefs.getStringList('education_data') ?? [];
      final hasEducationUserSaved = prefs.getBool('education_user_saved') ?? false;

      // Tambahan: Jika fresh login, pastikan flag family_user_saved direset agar card keluarga tetap kosong
      if (isLoggedOut) {
        await prefs.setBool('family_user_saved', false);
        print('Reset flag family_user_saved = false (fresh login)');
      }
      
      // ALWAYS reset family_user_saved jika belum ada data user yang valid
      final currentFamilyUserSaved = prefs.getBool('family_user_saved') ?? false;
      print('=== FAMILY FLAG CHECK ===');
      print('Current family_user_saved: $currentFamilyUserSaved');
      
      // Jika tidak ada data keluarga yang valid di provider, reset flag
      final familyMembers = ref.read(familyDataProvider);
      final hasRealFamilyData = familyMembers.any((member) => 
        !(member.id == '1' && member.nama.trim().toUpperCase() == 'RENI GUMILA DEWI') &&
        !(member.id == '2' && member.nama.trim().toUpperCase() == 'ARVIE PRAMATYA ALGHANI') &&
        !(member.id == '3' && member.nama.trim().toUpperCase() == 'DYLAN PRADIPTA ALGHANI') &&
        !(member.id == '4' && member.nama.trim().toLowerCase() == 'nadine rafarindya alghani')
      );
      
      print('Has real family data (non-dummy): $hasRealFamilyData');
      
      if (!hasRealFamilyData) {
        await prefs.setBool('family_user_saved', false);
        print('Reset family_user_saved = false (no real family data found)');
      }
      
      if (educationDataList.isNotEmpty) {
        try {
          // Filter out any education dummy data
          final List<Map<String, String>> userEducationOnly = [];
          
          for (String jsonStr in educationDataList) {
            final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
            final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
            
            // Filter out dummy data
            if (educationMap['isDummy'] != 'true') {
              userEducationOnly.add(educationMap);
            }
          }
          
          print('Original education data count: ${educationDataList.length}');
          print('User education data count after filtering: ${userEducationOnly.length}');
          
          if (userEducationOnly.isEmpty) {
            // No user education data, clear everything
            await prefs.remove('education_data');
            await prefs.remove('education_user_saved');
            await prefs.remove('education_has_changes');
            await prefs.remove('education_just_saved');
            print('Cleared all education data - only dummy data found');
          } else {
            // Save only user education data back
            final userEducationJson = userEducationOnly.map((education) => jsonEncode(education)).toList();
            await prefs.setStringList('education_data', userEducationJson);
            print('Filtered and saved user education data only');
          }
        } catch (e) {
          print('Error parsing education data, clearing: $e');
          await prefs.remove('education_data');
          await prefs.remove('education_user_saved');
          await prefs.remove('education_has_changes');
          await prefs.remove('education_just_saved');
        }
      }
      
      // CRITICAL: DO NOT touch work history data or providers
      // Work history is EXCLUSIVELY managed by riwayat_pekerjaan_page.dart
      if (!hasWorkHistoryUserSaved) {
        print('User has never saved work history, but SKIPPING any clearing operations');
        print('Profile page will NOT modify work history data or providers');
        print('Work history state is EXCLUSIVELY managed by riwayat_pekerjaan_page.dart');
      }
      
      // Clear education data if user has never saved
      if (!hasEducationUserSaved) {
        print('User has never saved education, ensuring clean state');
        
        // Clear pendidikanDataProvider untuk fresh start
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        print('Cleared pendidikanDataProvider (user never saved)');
        
        // Clear completion status untuk pendidikan juga
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('pendidikan');
        print('Marked pendidikan as incomplete');
      }
      
      // REMOVED: Auto-restore logic for work_history_user_saved flag
      // Flag ini sekarang hanya di-set saat user explicitly save data, bukan auto-restore
      
      if (isLoggedOut) {
        // This means user just logged back in after logout
        // JANGAN hapus flag is_logged_out dulu - biarkan halaman lain mendeteksi fresh login
        
        print('=== FRESH LOGIN DETECTED IN PROFILE_PAGE - CLEARING NON-WORK-HISTORY DATA ===');
        print('Profile page is handling fresh login clearing (EXCLUDING work history management)');
        
        // CRITICAL: DO NOT touch work_history_* flags or data
        // Work history is EXCLUSIVELY managed by riwayat_pekerjaan_page.dart
        print('SKIPPING work_history_data clearing - managed by riwayat_pekerjaan_page.dart');
        print('SKIPPING work_history_user_saved clearing - managed by riwayat_pekerjaan_page.dart');
        print('SKIPPING work_history_has_changes clearing - managed by riwayat_pekerjaan_page.dart');
        print('SKIPPING work_history_just_saved clearing - managed by riwayat_pekerjaan_page.dart');
        
        await prefs.remove('education_data');
        await prefs.remove('education_user_saved');
        await prefs.remove('education_has_changes');
        await prefs.remove('education_just_saved');
        
        await prefs.remove('family_user_saved');
        await prefs.remove('family_has_changes');
        await prefs.remove('family_just_saved');
        
        print('Cleared non-work-history SharedPreferences data for fresh login after logout');
        
        // CRITICAL: DO NOT clear riwayatPekerjaanDataProvider
        // Work history provider is EXCLUSIVELY managed by riwayat_pekerjaan_page.dart
        print('SKIPPING riwayatPekerjaanDataProvider clearing - managed by riwayat_pekerjaan_page.dart');
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        ref.read(editProfileDataProvider.notifier).updateData(EditProfileData());
        ref.read(pribadiDataProvider.notifier).updateData(PribadiData());
        ref.read(honorariumDataProvider.notifier).updateData(HonorariumData());
        ref.read(dataLamaranDataProvider.notifier).updateData(DataLamaranData());
        ref.read(dokumenDataProvider.notifier).updateData(DokumenData());
        ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());
        ref.read(idCardDataProvider.notifier).updateData(IdCardData());
        
        // Clear completion status untuk fresh start (EXCEPT riwayat pekerjaan)
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('editProfile');
        completionNotifier.markIncomplete('identitasDiri');
        completionNotifier.markIncomplete('honorarium');
        completionNotifier.markIncomplete('keluarga');
        completionNotifier.markIncomplete('pasFoto');
        completionNotifier.markIncomplete('dokumen');
        completionNotifier.markIncomplete('pendidikan');
        // CRITICAL: DO NOT mark riwayatPekerjaan as incomplete
        // Riwayat pekerjaan completion is EXCLUSIVELY managed by riwayat_pekerjaan_page.dart
        print('SKIPPING riwayatPekerjaan completion clearing - managed by riwayat_pekerjaan_page.dart');
        completionNotifier.markIncomplete('dataLamaran');
        
        // Reset bottom navigation to home tab to ensure fresh start
        ref.read(bottomNavIndexProvider.notifier).state = 0;
        
        // Hapus flag is_logged_out dengan delay agar halaman lain sempat mendeteksi
        final delayedPrefs = await SharedPreferences.getInstance();
        Future.delayed(const Duration(seconds: 3), () async {
          await delayedPrefs.remove('is_logged_out');
          print('Delayed removal of is_logged_out flag completed after 3 seconds');
        });
        
        print('Fresh login detected - ALL data and status reset complete');
      }
    } catch (e) {
      print('Error checking fresh login: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('=== PROFILE PAGE DID CHANGE DEPENDENCIES ===');
    
    // Add delay untuk avoid race condition dengan profile sections page
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isProcessingImmediateFlagDetection) {
        // Reload education data when returning to this page
        _loadEducationData();
        
        // Always reload user saved flags to check for changes
        _loadUserSavedFlags().then((_) {
          // Setelah flags loaded, reload work history data
          _reloadWorkHistoryData();
        });
        
        // Check if there are recent changes to work history that need refresh
        _checkForWorkHistoryChanges();
      }
    });
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('=== PROFILE PAGE DID UPDATE WIDGET ===');
    
    // Add delay untuk avoid race condition dengan profile sections page
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isProcessingImmediateFlagDetection) {
        // Force reload when widget updates (navigating back to this page)
        _loadUserSavedFlags().then((_) {
          _reloadWorkHistoryData();
        });
      }
    });
  }

  Future<void> _reloadWorkHistoryData() async {
    print('=== RELOADING WORK HISTORY DATA ===');
    print('Before reload - _workHistoryLoaded: $_workHistoryLoaded, items: ${_workHistoryItems.length}');
    
    _workHistoryLoaded = false;
    _workHistoryItems.clear();
    
    final theme = ref.read(themeProvider);
    await _loadWorkHistoryItems(theme);
    
    print('After reload - _workHistoryLoaded: true, items: ${_workHistoryItems.length}');
    
    if (mounted) {
      setState(() {
        _workHistoryLoaded = true;
      });
      print('setState called - UI should refresh now');
    }
  }

  Future<void> _checkForWorkHistoryChanges() async {
    if (_isProcessingImmediateFlagDetection) {
      print('Flag detection in progress, skipping work history check');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasChanges = prefs.getBool('work_history_has_changes') ?? false;
      final justSaved = prefs.getBool('work_history_just_saved') ?? false;
      
      print('=== CHECKING WORK HISTORY CHANGES ===');
      print('has_changes: $hasChanges, just_saved: $justSaved');
      
      if (hasChanges || justSaved) {
        print('Work history changes detected, forcing reload...');
        
        // Set protection flag
        _isProcessingImmediateFlagDetection = true;
        
        // Clear the flags dengan delay untuk prevent race condition
        await Future.delayed(const Duration(milliseconds: 200));
        await prefs.remove('work_history_has_changes');
        // CRITICAL: DON'T clear work_history_just_saved here! 
        // Let profile_sections_page handle this flag to properly detect "Edited" status
        // await prefs.remove('work_history_just_saved'); // COMMENTED OUT
        print('Cleared work_history_has_changes but preserved work_history_just_saved for profile_sections detection');
        
        // Force reload work history data
        await _reloadWorkHistoryData();
        
        // Clear protection flag setelah selesai
        await Future.delayed(const Duration(milliseconds: 100));
        _isProcessingImmediateFlagDetection = false;
      }
    } catch (e) {
      print('Error checking work history changes: $e');
      _isProcessingImmediateFlagDetection = false;
    }
  }

  Future<void> _loadUserSavedFlags() async {
    if (_isProcessingImmediateFlagDetection) {
      print('Flag detection in progress, skipping user saved flags load');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final previousWorkHistoryUserSaved = _workHistoryUserSaved;
      
      // Check if recently edited via navigation to prevent false status
      await _checkFlagsImmediatelyAfterNavigation();
      
      // Add delay untuk SharedPreferences operations
      await Future.delayed(const Duration(milliseconds: 200));
      
      setState(() {
        _educationUserSaved = prefs.getBool('education_user_saved') ?? false;
        _workHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
        _familyUserSaved = prefs.getBool('family_user_saved') ?? false;
      });
      
      // If work history saved status changed, reset loaded flag to trigger reload
      if (previousWorkHistoryUserSaved != _workHistoryUserSaved) {
        _workHistoryLoaded = false;
        _workHistoryItems.clear();
      }
      
      print('User saved flags - Education: $_educationUserSaved, Work History: $_workHistoryUserSaved, Family: $_familyUserSaved');
    } catch (e) {
      print('Error loading user saved flags: $e');
    }
  }

  // Check flags immediately setelah navigation untuk prevent false status
  Future<void> _checkFlagsImmediatelyAfterNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Protection flag untuk prevent race condition
      if (prefs.getBool('profile_processing_flag_protection') == true) {
        print('Profile processing flag protection active - skipping flag check');
        return;
      }
      
      // Check for navigation-based protection flags
      final sections = ['education', 'work_history', 'family'];
      for (String section in sections) {
        final recentlyEdited = _recentlyEditedViNavigation.contains(section);
        if (recentlyEdited) {
          print('Section $section recently edited via navigation - maintaining status');
        }
      }
      
      // Auto-cleanup navigation status after 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        _recentlyEditedViNavigation.clear();
      });
      
    } catch (e) {
      print('Error checking flags after navigation: $e');
    }
  }

  // Handle logout functionality
  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tampilkan loading indicator
      if (mounted) {
        NotificationUtils.showLoadingDialog(context, message: 'Mengeluarkan...');
      }

      // Clear semua data profile yang telah diubah user
      await prefs.remove('edit_profile_data');
      await prefs.remove('pribadi_data');
      await prefs.remove('honorarium_data');
      await prefs.remove('keluarga_data');
      await prefs.remove('pendidikan_data');
      await prefs.remove('riwayat_pekerjaan_data');
      await prefs.remove('data_lamaran_data');
      
      // Clear education data dan flags - COMPLETE CLEAR for fresh login
      await prefs.remove('education_data'); // Remove old string format
      await prefs.setStringList('education_data', []); // Clear new StringList format
      await prefs.remove('education_has_changes');
      await prefs.remove('education_user_saved');
      await prefs.remove('education_just_saved');
      await prefs.remove('education_just_saved_timestamp');
      
      print('=== EDUCATION COMPLETELY CLEARED IN LOGOUT ===');
      final verifyEducationData = prefs.getStringList('education_data');
      final verifyEducationSaved = prefs.getBool('education_user_saved') ?? false;
      print('After logout - education_data: $verifyEducationData');
      print('After logout - education_user_saved: $verifyEducationSaved');
      
      // Clear work history data AND flags - COMPLETE CLEAR for fresh login
      await prefs.remove('work_history_data'); // Remove old string format
      await prefs.setStringList('work_history_data', []); // Clear new StringList format  
      await prefs.remove('work_history_user_saved');
      await prefs.remove('work_history_has_changes');
      await prefs.remove('work_history_just_saved');
      
      print('=== WORK HISTORY COMPLETELY CLEARED IN LOGOUT ===');
      final verifyWorkData = prefs.getStringList('work_history_data');
      final verifyWorkSaved = prefs.getBool('work_history_user_saved') ?? false;
      
      // Clear family data AND flags - COMPLETE CLEAR for fresh login
      await prefs.remove('family_user_saved');
      await prefs.remove('family_has_changes');
      await prefs.remove('family_just_saved');
      
      print('=== FAMILY COMPLETELY CLEARED IN LOGOUT ===');
      final verifyFamilySaved = prefs.getBool('family_user_saved') ?? false;
      print('After logout - family_user_saved: $verifyFamilySaved');
      print('After logout - work_history_data: $verifyWorkData');
      print('After logout - work_history_user_saved: $verifyWorkSaved');
      
      // Clear family user saved flag tapi JANGAN hapus data dummy
      await prefs.remove('family_user_saved');
      await prefs.remove('family_has_changes');
      await prefs.remove('family_just_saved');
      
      // Clear dokumen data
      await prefs.remove('dokumen_data');
      
      // Clear family/keluarga data - potrebny pre familyDataProvider
      await prefs.remove('family_data');
      await prefs.remove('family_members_data');
      await prefs.remove('family_user_saved');
      await prefs.remove('family_has_changes');
      await prefs.remove('family_just_saved');
      
      // Clear foto/image data
      await prefs.remove('id_card_data');
      
      // Clear completion status
      await prefs.remove('profile_completion_status');
      
      // Clear individual section completion status if stored
      await prefs.remove('editProfile_completed');
      await prefs.remove('identitasDiri_completed');
      await prefs.remove('honorarium_completed');
      await prefs.remove('keluarga_completed');
      await prefs.remove('pasFoto_completed');
      await prefs.remove('dokumen_completed');
      await prefs.remove('pendidikan_completed');
      await prefs.remove('riwayatPekerjaan_completed');
      await prefs.remove('dataLamaran_completed');
      
      // Set logout flag untuk indicate bahwa user telah logout
      await prefs.setBool('is_logged_out', true);
      
      // Verify flag was set
      final verifyLogout = prefs.getBool('is_logged_out') ?? false;
      print('=== LOGOUT FLAG VERIFICATION ===');
      print('is_logged_out flag set to: $verifyLogout');
      print('This should be true, and will be read by other pages on next navigation');
      
      // Clear semua flags status
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
      
      print('All profile data cleared successfully');
      
      // Reset providers dengan cara update data ke nilai default/kosong
      ref.read(editProfileDataProvider.notifier).updateData(EditProfileData());
      ref.read(pribadiDataProvider.notifier).updateData(PribadiData());
      ref.read(honorariumDataProvider.notifier).updateData(HonorariumData());
      ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());
      ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
      ref.read(dataLamaranDataProvider.notifier).updateData(DataLamaranData());
      ref.read(idCardDataProvider.notifier).updateData(IdCardData(fotoPath: '', isUploaded: false));
      ref.read(dokumenDataProvider.notifier).updateData(DokumenData());
      
      // CLEAR familyDataProvider untuk fresh login agar data dummy tidak muncul di profile page
      // Tapi tetap akan ter-populate dengan dummy saat user masuk ke keluarga page nanti
      ref.read(familyDataProvider.notifier).state = [];
      print('Cleared familyDataProvider for fresh login - dummy data will repopulate when entering keluarga page');
      
      // Reset completion status untuk semua sections
      final completionNotifier = ref.read(profileCompletionProvider.notifier);
      completionNotifier.markIncomplete('edit_profile');
      completionNotifier.markIncomplete('pribadi');
      completionNotifier.markIncomplete('honorarium');
      completionNotifier.markIncomplete('keluarga');
      completionNotifier.markIncomplete('pendidikan');
      completionNotifier.markIncomplete('riwayat_pekerjaan');
      completionNotifier.markIncomplete('data_lamaran');
      completionNotifier.markIncomplete('foto');
      completionNotifier.markIncomplete('dokumen');
      
      // Also reset all possible completion keys used in the provider
      completionNotifier.markIncomplete('editProfile');
      completionNotifier.markIncomplete('identitasDiri');
      completionNotifier.markIncomplete('pasFoto');
      completionNotifier.markIncomplete('riwayatPekerjaan');
      completionNotifier.markIncomplete('dataLamaran');
      
      // Tunggu sebentar untuk memastikan semua operasi selesai
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reset bottom navigation ke home tab
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      
      // Close loading dialog dan navigate ke login
      if (mounted) {
        NotificationUtils.hideLoadingDialog(context); // Close loading dialog
        context.go('/login');
      }
      
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        NotificationUtils.hideLoadingDialog(context); // Close loading dialog
        NotificationUtils.showError(context, 'Terjadi kesalahan saat logout');
      }
    }
  }

  Future<void> _loadEducationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Fix: Use getStringList instead of getString to avoid type casting error
      final educationDataList = prefs.getStringList('education_data') ?? [];
      
      if (educationDataList.isNotEmpty) {
        final List<Map<String, String>> loadedData = educationDataList
            .map((jsonStr) => Map<String, String>.from(json.decode(jsonStr)))
            .toList();
        
        setState(() {
          _educationData = loadedData;
          _educationDataLoaded = true;
        });
        print('Loaded ${loadedData.length} education records for profile');
      } else {
        setState(() {
          _educationDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading education data for profile: $e');
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
      print('Error checking file: $e');
      return false;
    }
  }
  
  ImageProvider<Object>? _getImageProvider(String imagePath) {
    if (imagePath.isEmpty) return null;
    
    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    
    // Check if it's a valid local file
    if (_isValidLocalFile(imagePath)) {
      return FileImage(File(imagePath));
    }
    
    // If file doesn't exist or invalid, return null
    print('Invalid image path: $imagePath');
    return null;
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
          'Profil',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Set tab ke Home (index 0) dan navigasi ke MainLayout
            ref.read(bottomNavIndexProvider.notifier).state = 0;
            context.go('/home');
          },
        ),
      ),
      body: _buildProfileDetailPage(theme, isTablet),
    );
  }

  Widget _buildProfileDetailPage(dynamic theme, bool isTablet) {
    // Ambil data dari semua provider
    final editProfileData = ref.watch(editProfileDataProvider);
    final pribadiData = ref.watch(pribadiDataProvider);
    final honorariumData = ref.watch(honorariumDataProvider);
    final keluargaData = ref.watch(keluargaDataProvider);
    final pendidikanData = ref.watch(pendidikanDataProvider);
    final riwayatPekerjaanData = ref.watch(riwayatPekerjaanDataProvider);
    final dokumenData = ref.watch(dokumenDataProvider);
    final dataLamaranData = ref.watch(dataLamaranDataProvider);
    final idCardData = ref.watch(idCardDataProvider);
    
    // Debug print untuk melihat data
    print('=== DEBUG PROFILE DATA ===');
    print('Edit Profile: nama=${editProfileData.nama}, bidang=${editProfileData.bidangKeahlian}');
    print('Pribadi: email=${pribadiData.email}, hp=${pribadiData.handphone}');
    print('Honorarium: ktp=${honorariumData.ktp}, rekening=${honorariumData.rekening}');
    print('Pendidikan: institusi=${pendidikanData.namaInstitusi}, jurusan=${pendidikanData.jurusan}');
    print('Riwayat: perusahaan=${riwayatPekerjaanData.namaPerusahaan}, posisi=${riwayatPekerjaanData.posisi}');
    print('Keluarga: ayah=${keluargaData.namaAyah}, ibu=${keluargaData.namaIbu}, pasangan=${keluargaData.namaPasangan}');
    print('Dokumen: cv=${dokumenData.cvUploaded}, ijazah=${dokumenData.ijazahUploaded}');
    print('========================');
    
    // Real-time data untuk tanggal saja
    final now = DateTime.now();
    
    // Days and months in Indonesian
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                       'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    final dayName = dayNames[now.weekday - 1];
    final monthName = monthNames[now.month - 1];
    final currentDate = '$dayName, ${now.day} $monthName ${now.year}';
    
    // Waktu login tetap (simulasi waktu login session)
    const loginTime = '12:17'; // Waktu login session, tidak berubah
    
    // Gunakan data real atau fallback jika kosong
    final displayName = editProfileData.nama.isNotEmpty ? editProfileData.nama : 'Airlangga Eka Wardhana, S.Kom, M.T.I';
    final displayJob = editProfileData.bidangKeahlian.isNotEmpty ? editProfileData.bidangKeahlian : '';
    final displayNik = editProfileData.nik.isNotEmpty ? editProfileData.nik : '13-0265';
    
    // Status missing data - Hapus variabel yang tidak digunakan
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primarySwatch,
                    theme.primarySwatch.withOpacity(0.9),
                    Colors.deepPurple.shade600,
                    Colors.indigo.shade700,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 28.0, 
                  horizontal: isTablet ? 24.0 : 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture and Basic Info
                    Row(
                      children: [
                        Container(
                          width: isTablet ? 110 : 90,
                          height: isTablet ? 110 : 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 3,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, -2),
                              ),
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              final imageProvider = _getImageProvider(idCardData.fotoPath);
                              return CircleAvatar(
                                radius: isTablet ? 53 : 43,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: imageProvider,
                                onBackgroundImageError: imageProvider != null 
                                  ? (exception, stackTrace) {
                                      print('Error loading profile image: $exception');
                                      // Clear invalid image path from provider
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        ref.read(idCardDataProvider.notifier).updateData(
                                          IdCardData(fotoPath: '', isUploaded: false)
                                        );
                                      });
                                    }
                                  : null,
                                child: imageProvider == null
                                  ? Icon(
                                      Icons.person,
                                      size: isTablet ? 50 : 40,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                              );
                            }
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.typographyRegular.headingSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isTablet ? 26.0 : 22.0,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (displayJob.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  displayJob,
                                  style: theme.typographyRegular.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isTablet ? 16.0 : 14.0,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NIK: $displayNik',
                                    style: theme.typographyRegular.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: isTablet ? 14.0 : 12.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Login: $loginTime',
                                    style: theme.typographyRegular.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: isTablet ? 14.0 : 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Date and Status Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Hari Ini',
                                  style: theme.typographyRegular.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: isTablet ? 14.0 : 12.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentDate,
                                  style: theme.typographyRegular.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 16.0 : 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Active',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14.0 : 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 9 Info Sections - satu untuk setiap section di edit profile
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

            _buildSectionCard('4. Keluarga', 
              _buildFamilyItems(theme), 
              theme, isTablet),

            _buildSectionCard('5. PAS Foto', [
              _buildInfoItem(Icons.camera_alt, 'Status Upload', idCardData.isUploaded ? 'Sudah diupload' : 'Belum diupload', theme, isMissing: !idCardData.isUploaded),
            ], theme, isTablet),

            _buildSectionCard('6. Dokumen', 
              _buildDokumenItems(theme), 
              theme, isTablet),

            _buildSectionCard('7. Pendidikan', 
              _buildEducationItems(theme), 
              theme, isTablet),

            _buildSectionCard('8. Riwayat Pekerjaan', 
              _buildWorkHistoryItems(theme), 
              theme, isTablet),

            _buildSectionCard('9. Data Lamaran', [
              _buildInfoItem(Icons.assignment, 'Posisi', dataLamaranData.position.isNotEmpty ? dataLamaranData.position : 'Belum diisi', theme, isMissing: dataLamaranData.position.isEmpty),
              _buildInfoItem(Icons.location_on, 'Penempatan', dataLamaranData.placement.isNotEmpty ? dataLamaranData.placement : 'Belum diisi', theme, isMissing: dataLamaranData.placement.isEmpty),
            ], theme, isTablet),

            // Tombol Edit Profil
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

            // Tombol Ubah Password
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
                onPressed: () => context.go('/lupa-password'),
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

            // Card Session dan Logout
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
                  // Tombol Keluar dari Aplikasi
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
                  
                  // Divider
                  Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Session Info
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
                  
                  // Date Info
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
            // Header dengan gradient
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
            // Content
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
          // Icon container dengan background circular
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMissing 
                ? Colors.red.withOpacity(0.1) 
                : theme.primarySwatch.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isMissing ? Colors.red[600] : theme.primarySwatch,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Label dan value section
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
          
          // Status badge di kanan
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

  List<Widget> _buildEducationItems(dynamic theme) {
    if (!_educationDataLoaded) {
      return [
        _buildInfoItem(Icons.hourglass_empty, 'Status', 'Memuat data pendidikan...', theme),
      ];
    }

    // CRITICAL: Jika user belum pernah menyimpan data pendidikan, JANGAN tampilkan data apapun
    if (!_educationUserSaved) {
      return [
        _buildInfoItem(Icons.school, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }

    if (_educationData.isEmpty) {
      // JANGAN fallback ke provider data jika user sudah pernah save tapi data kosong
      // Ini kemungkinan berarti user sudah clear semua data mereka
      return [
        _buildInfoItem(Icons.school, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }

    List<Widget> educationWidgets = [];
    
    for (int i = 0; i < _educationData.length; i++) {
      final education = _educationData[i];
      final pendidikanKe = i + 1;
      
      // Add separator if not the first item
      if (i > 0) {
        educationWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.grey[300], height: 1),
          ),
        );
      }
      
      // Add education header
      educationWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Pendidikan $pendidikanKe',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primarySwatch,
            ),
          ),
        ),
      );
      
      // Add education details
      educationWidgets.add(
        _buildInfoItem(
          Icons.school, 
          'Jenjang', 
          education['jenjang']?.isNotEmpty == true ? education['jenjang']! : 'Belum diisi', 
          theme, 
          isMissing: education['jenjang']?.isEmpty != false
        ),
      );
      
      educationWidgets.add(
        _buildInfoItem(
          Icons.business, 
          'Institusi', 
          education['institusi']?.isNotEmpty == true ? education['institusi']! : 'Belum diisi', 
          theme, 
          isMissing: education['institusi']?.isEmpty != false
        ),
      );
      
      educationWidgets.add(
        _buildInfoItem(
          Icons.book, 
          'Jurusan', 
          education['jurusan']?.isNotEmpty == true ? education['jurusan']! : 'Belum diisi', 
          theme, 
          isMissing: education['jurusan']?.isEmpty != false
        ),
      );
      
      educationWidgets.add(
        _buildInfoItem(
          Icons.location_on, 
          'Kota', 
          education['kota']?.isNotEmpty == true ? education['kota']! : 'Belum diisi', 
          theme, 
          isMissing: education['kota']?.isEmpty != false
        ),
      );
      
      educationWidgets.add(
        _buildInfoItem(
          Icons.calendar_today, 
          'Tahun', 
          education['tahun']?.isNotEmpty == true ? education['tahun']! : 'Belum diisi', 
          theme, 
          isMissing: education['tahun']?.isEmpty != false
        ),
      );
    }
    
    return educationWidgets;
  }

  List<Widget> _buildFamilyItems(dynamic theme) {
    print('=== BUILD FAMILY ITEMS DEBUG ===');
    print('_familyUserSaved: $_familyUserSaved');
    
    // CRITICAL: Jika user belum pernah menyimpan data keluarga, JANGAN tampilkan data apapun
    if (!_familyUserSaved) {
      print('User has not saved family data - showing empty state (NO DATA DISPLAYED)');
      return [
        _buildInfoItem(Icons.family_restroom, 'Status Keluarga', 'Belum diisi', theme, isMissing: true),
      ];
    }
    
    print('User has saved family data - checking provider data');
    
    // Ambil data dari familyDataProvider (hanya jika user sudah save)
    final familyMembers = ref.watch(familyDataProvider);
    
    print('Family members from provider: ${familyMembers.length} items');
    for (var member in familyMembers) {
      print('- ${member.nama} (${member.hubungan}) - ID: ${member.id}');
    }
    
    // Filter data dummy - jangan tampilkan data yang masih dummy
    final realFamilyMembers = familyMembers.where((member) {
      // Anggap data dummy jika nama masih default dummy names
      bool isDummy = member.nama.contains('RENI GUMILA') || 
                     member.nama.contains('ARVIE PRAMATYA') ||
                     member.nama.contains('KEYLA NAZWA') ||
                     member.nama.contains('NAURA AULIA');
      return !isDummy;
    }).toList();
    
    print('Real family members (non-dummy): ${realFamilyMembers.length} items');
    
    // Jika tidak ada data keluarga yang real, tampilkan status belum diisi
    if (realFamilyMembers.isEmpty) {
      print('No real family members found - showing empty state');
      return [
        _buildInfoItem(Icons.family_restroom, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }
    
    // Filter istri (hubungan = 'ISTRI') - gunakan realFamilyMembers
    final istriData = realFamilyMembers.where((member) => member.hubungan == 'ISTRI').toList();
    
    // Filter hanya anak-anak (hubungan = 'AK') - gunakan realFamilyMembers
    final anakList = realFamilyMembers.where((member) => member.hubungan == 'AK').toList();
    
    List<Widget> familyWidgets = [];
    
    // Tambahkan data istri jika ada
    if (istriData.isNotEmpty) {
      familyWidgets.add(
        _buildInfoItem(
          Icons.favorite, 
          'Istri', 
          istriData.first.nama, 
          theme, 
          isMissing: false
        )
      );
    }
    
    // Tampilkan maksimal 3 anak sesuai data dummy
    for (int i = 0; i < 3; i++) {
      String anakName = 'Belum diisi';
      bool isMissing = true;
      
      if (i < anakList.length) {
        anakName = anakList[i].nama;
        isMissing = anakName.isEmpty;
      }
      
      familyWidgets.add(
        _buildInfoItem(
          Icons.child_care, 
          'Anak ${i + 1}', 
          anakName, 
          theme, 
          isMissing: isMissing
        )
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
        isMissing: !dokumenData.ktpUploaded
      )
    );
    
    dokumenWidgets.add(
      _buildInfoItem(
        Icons.description, 
        'Ijazah', 
        dokumenData.ijazahUploaded ? 'Sudah diupload' : 'Belum diupload', 
        theme, 
        isMissing: !dokumenData.ijazahUploaded
      )
    );
    
    return dokumenWidgets;
  }

  Future<void> _loadWorkHistoryItems(dynamic theme) async {
    print('=== LOADING WORK HISTORY ITEMS IN PROFILE PAGE ===');
    print('_workHistoryUserSaved: $_workHistoryUserSaved');
    
    // IMPORTANT: ONLY SHOW DATA IN CARD AFTER USER CLICKS SAVE IN RIWAYAT PEKERJAAN PAGE
    try {
      final prefs = await SharedPreferences.getInstance();
      final workHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;
      
      print('work_history_user_saved flag: $workHistoryUserSaved');
      
      // CRITICAL: Check for just_saved flag first before checking user_saved
      final justSaved = prefs.getBool('work_history_just_saved') ?? false;
      print('work_history_just_saved flag: $justSaved');
      
      // CRITICAL: Always try to load data from storage first, regardless of flags
      // This ensures that temporary data in riwayat_pekerjaan_page gets displayed
      final workHistoryDataList = prefs.getStringList('work_history_data') ?? [];
      print('Checking for work history data in storage: ${workHistoryDataList.length} entries');
      
      // If user has never saved BUT there's data in storage (from adding entries), show it
      if (!workHistoryUserSaved && !justSaved && workHistoryDataList.isNotEmpty) {
        print('User hasnt clicked SAVE yet, but found temporary data in storage - displaying it');
        
        // Parse and display temporary data
        final List<Map<String, String>> tempWorkHistoryData = [];
        
        for (int i = 0; i < workHistoryDataList.length; i++) {
          final jsonStr = workHistoryDataList[i];
          try {
            final Map<String, dynamic> workMap = jsonDecode(jsonStr);
            final Map<String, String> workStringMap = workMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));
            
            // Skip dummy data - only load actual user data
            final isDummyFlag = workStringMap['isDummy'] == 'true';
            final hasDummyId = workStringMap['id']?.startsWith('dummy') ?? false;
            
            if (!isDummyFlag && !hasDummyId) {
              tempWorkHistoryData.add(workStringMap);
            }
          } catch (e) {
            print('Error parsing work history item $i: $e');
          }
        }
        
        if (tempWorkHistoryData.isNotEmpty) {
          print('Found ${tempWorkHistoryData.length} temporary work history entries - displaying with unsaved indicator');
          
          _workHistoryItems = [];
          
          for (int i = 0; i < tempWorkHistoryData.length; i++) {
            final work = tempWorkHistoryData[i];
            final entryNumber = i + 1;
            
            // Add separator if not first item
            if (_workHistoryItems.isNotEmpty) {
              _workHistoryItems.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  height: 1,
                  color: Colors.grey[300],
                ),
              );
            }
            
            // Add work history header (clean, no unsaved indicator)
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
            
            // Add work history details
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.business, 
                'Perusahaan', 
                work['company']?.isNotEmpty == true ? work['company']! : 'Belum diisi', 
                theme, 
                isMissing: work['company']?.isEmpty != false
              )
            );
            
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work, 
                'Posisi', 
                work['position']?.isNotEmpty == true ? work['position']! : 'Belum diisi', 
                theme, 
                isMissing: work['position']?.isEmpty != false
              )
            );
            
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.calendar_today, 
                'Periode', 
                '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}', 
                theme, 
                isMissing: work['startYear']?.isEmpty != false
              )
            );
          }
          
          return;
        }
      }
      
      // If user has never saved and no temporary data, check provider
      if (!workHistoryUserSaved && !justSaved) {
        print('User has not saved work history data yet and no recent save - checking for provider data');
        
        // Check for temporary unsaved data in provider
        final hasChanges = prefs.getBool('work_history_has_changes') ?? false;
        print('work_history_has_changes flag: $hasChanges');
        
        if (hasChanges) {
          print('Found unsaved changes flag - checking provider for temporary data');
          
          // Try to get data from riwayat pekerjaan provider (temporary data)
          final riwayatPekerjaanData = ref.read(riwayatPekerjaanDataProvider);
          print('RiwayatPekerjaanData from provider: ${riwayatPekerjaanData.namaPerusahaan} - ${riwayatPekerjaanData.posisi}');
          
          if (riwayatPekerjaanData.namaPerusahaan.isNotEmpty && riwayatPekerjaanData.posisi.isNotEmpty) {
            print('Found temporary work history data in provider');
            
            _workHistoryItems = [];
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work, 
                'Riwayat Pekerjaan', 
                '${riwayatPekerjaanData.posisi} - ${riwayatPekerjaanData.namaPerusahaan} (${riwayatPekerjaanData.tahunMulai}-${riwayatPekerjaanData.tahunSelesai})', 
                theme, 
                isMissing: false
              ),
            );
            
            return;
          }
        }
        
        // No temporary data found, show empty state
        print('No temporary data found - showing empty state');
        
        _workHistoryItems = [];
        _workHistoryItems.add(
          _buildInfoItem(
            Icons.work_off, 
            'Riwayat Pekerjaan', 
            'Belum diisi', 
            theme, 
            isMissing: true
          ),
        );
        
        return;
      }
      
      // CRITICAL: Handle recent save (work_history_just_saved flag)
      if (justSaved) {
        print('Recent work history save detected - preserving flags and loading data');
        // Don't clear the just_saved flag here, let profile_sections handle it
        // Just proceed to load the saved data
      }
      
      print('Work history data from storage (StringList): $workHistoryDataList');
      
      if (workHistoryDataList.isNotEmpty) {
        final List<Map<String, String>> workHistoryData = [];
        
        // Parse data from StringList format
        for (int i = 0; i < workHistoryDataList.length; i++) {
          final jsonStr = workHistoryDataList[i];
          print('=== PARSING WORK HISTORY ITEM $i ===');
          print('Raw JSON string: $jsonStr');
          
          try {
            final Map<String, dynamic> workMap = jsonDecode(jsonStr);
            final Map<String, String> workStringMap = workMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));
            
            print('Parsed workMap: $workMap');
            print('Converted workStringMap: $workStringMap');
            print('isDummy value: ${workStringMap['isDummy']}');
            print('ID value: ${workStringMap['id']}');
            print('ID starts with dummy: ${workStringMap['id']?.startsWith('dummy')}');
            
            // Skip dummy data - only load actual user data
            final isDummyFlag = workStringMap['isDummy'] == 'true';
            final hassDummyId = workStringMap['id']?.startsWith('dummy') ?? false;
            
            print('Is dummy flag: $isDummyFlag');
            print('Has dummy ID: $hassDummyId');
            print('Will skip this item: ${isDummyFlag || hassDummyId}');
            
            if (!isDummyFlag && !hassDummyId) {
              workHistoryData.add(workStringMap);
              print('✅ Added item $i to workHistoryData');
            } else {
              print('❌ Skipped item $i (dummy data)');
            }
          } catch (e) {
            print('Error parsing work history item $i: $e');
          }
        }
        
        print('=== FINAL PARSING RESULT ===');
        print('Parsed user work history data: $workHistoryData');
        print('User work history data count: ${workHistoryData.length}');
        
        for (int i = 0; i < workHistoryData.length; i++) {
          print('Final item $i: ${workHistoryData[i]}');
        }
        
        if (workHistoryData.isNotEmpty) {
          print('Found ${workHistoryData.length} work history entries, displaying user data only');
          
          // Build items for user work history entries only (no dummy data)
          _workHistoryItems = [];
          
          for (int i = 0; i < workHistoryData.length; i++) {
            final work = workHistoryData[i];
            final entryNumber = i + 1;
            
            // Add separator if not first item
            if (_workHistoryItems.isNotEmpty) {
              _workHistoryItems.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  height: 1,
                  color: Colors.grey[300],
                ),
              );
            }
            
            // Add work history header
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
            
            // Add work history details
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.business, 
                'Perusahaan', 
                work['company']?.isNotEmpty == true ? work['company']! : 'Belum diisi', 
                theme, 
                isMissing: work['company']?.isEmpty != false
              )
            );
            
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.work, 
                'Posisi', 
                work['position']?.isNotEmpty == true ? work['position']! : 'Belum diisi', 
                theme, 
                isMissing: work['position']?.isEmpty != false
              )
            );
            
            _workHistoryItems.add(
              _buildInfoItem(
                Icons.calendar_today, 
                'Periode', 
                '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}', 
                theme, 
                isMissing: work['startYear']?.isEmpty != false
              )
            );
          }
          
          print('Work history items created successfully: ${_workHistoryItems.length} items for ${workHistoryData.length} entries');
          
          // CRITICAL: Clear work_history_just_saved flag ONLY after successfully loading and displaying data
          // This prevents the flag from staying forever while ensuring profile_page can load data correctly
          if (justSaved) {
            print('Clearing work_history_just_saved flag after successful data display');
            await prefs.setBool('work_history_just_saved', false);
          }
          
          return;
        } else {
          print('Work history data array is empty after filtering');
        }
      } else {
        print('No work history data in storage (StringList format)');
      }
    } catch (e) {
      print('Error loading work history from storage: $e');
    }

    // If no valid data found, show empty state
    print('No valid user data found in storage, showing empty state');
    _workHistoryItems = [
      _buildInfoItem(Icons.work_off, 'Riwayat Pekerjaan', 'Belum diisi', theme, isMissing: true),
    ];
  }

  List<Widget> _buildWorkHistoryItems(dynamic theme) {
    print('=== BUILD WORK HISTORY ITEMS CALLED ===');
    print('_workHistoryLoaded: $_workHistoryLoaded');
    print('_workHistoryItems.length: ${_workHistoryItems.length}');
    print('_workHistoryUserSaved: $_workHistoryUserSaved');
    
    // Jika belum loaded, tampilkan loading state
    if (!_workHistoryLoaded) {
      print('Work history not loaded, showing loading state');
      return [
        _buildInfoItem(Icons.hourglass_empty, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }
    
    // Jika sudah loaded, return items yang sudah ada
    if (_workHistoryItems.isNotEmpty) {
      print('Returning ${_workHistoryItems.length} work history items');
      return _workHistoryItems;
    } else {
      print('No work history items, showing empty state');
      return [
        _buildInfoItem(Icons.work, 'Status', 'Belum diisi', theme, isMissing: true),
      ];
    }
  }
}
