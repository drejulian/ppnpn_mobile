import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';
import 'pendidikan/tambah_data_pendidikan_page.dart';
import 'pendidikan/edit_data_pendidikan_page.dart';

class PendidikanPage extends ConsumerStatefulWidget {
  const PendidikanPage({super.key});

  @override
  ConsumerState<PendidikanPage> createState() => _PendidikanPageState();
}

class _PendidikanPageState extends ConsumerState<PendidikanPage> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, String>> _educationData = [];
  
  Map<String, dynamic> _originalData = {};
  bool _dataLoaded = false;
  bool _freshLoginProcessed = false; // Flag to prevent data reload after fresh login reset
  bool _isSaving = false; // Loading state for save button

  @override
  void initState() {
    super.initState();
    print('=== PENDIDIKAN initState CALLED ===');
    
    // Check for fresh app restart or fresh login and reset data accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkFreshAppStartAndReset();
    });
  }

  // Check jika ini fresh app start atau user baru logout-login
  Future<void> _checkFreshAppStartAndReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      final educationUserSaved = prefs.getBool('education_user_saved') ?? false;
      
      print('=== PENDIDIKAN FRESH APP START CHECK ===');
      print('isLoggedOut: $isLoggedOut');
      print('educationUserSaved: $educationUserSaved');
      print('Current _educationData BEFORE check: $_educationData');
      print('Current _educationData.length BEFORE check: ${_educationData.length}');
      
      // Jika user baru login setelah logout, clear semua data termasuk unsaved changes
      if (isLoggedOut) {
        print('Fresh login detected - clearing all education data and flags');
        print('BEFORE CLEAR: _educationData = $_educationData');
        
        // Clear semua data dan flags
        await prefs.remove('education_data');
        await prefs.remove('education_user_saved');
        await prefs.remove('education_has_changes');
        await prefs.remove('education_just_saved');
        
        // CRITICAL: Also clear StringList format
        await prefs.setStringList('education_data', []);
        
        // Reset local state dan backup data di memori
        setState(() {
          _educationData.clear();
          _originalData.clear();
          _dataLoaded = true; // Mark as loaded agar tidak reload di didChangeDependencies
          _freshLoginProcessed = true; // Flag to prevent any further data loading
        });
        
        // CRITICAL: Clear provider data untuk fresh login
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        
        // CRITICAL: Clear completion status untuk fresh login
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('pendidikan');
        
        print('AFTER CLEAR: _educationData = $_educationData');
        print('AFTER CLEAR: _educationData.length = ${_educationData.length}');
        print('AFTER CLEAR: _dataLoaded = $_dataLoaded');
        print('AFTER CLEAR: _freshLoginProcessed = $_freshLoginProcessed');
        print('Provider data cleared (pendidikanDataProvider reset to empty)');
        print('Completion status reset (pendidikan marked as incomplete)');
        
        // Verify storage is really cleared
        final verifyData = prefs.getStringList('education_data');
        final verifyUserSaved = prefs.getBool('education_user_saved') ?? false;
        final verifyHasChanges = prefs.getBool('education_has_changes') ?? false;
        final verifyJustSaved = prefs.getBool('education_just_saved') ?? false;
        
        print('VERIFICATION AFTER FRESH LOGIN CLEAR:');
        print('  - education_data: $verifyData');
        print('  - education_user_saved: $verifyUserSaved');
        print('  - education_has_changes: $verifyHasChanges');
        print('  - education_just_saved: $verifyJustSaved');
        print('  - _educationData.length: ${_educationData.length}');
        print('  - provider completion status reset: pendidikan marked incomplete');
  
        
        print('All education data cleared for fresh login (storage, memory, provider, completion)');
        return;
      }
      
      if (!educationUserSaved) {
        print('User never saved education and fresh app start - ensuring clean state');
        
        // Clear any temporary flags that might exist
        await prefs.remove('education_has_changes');
        await prefs.remove('education_just_saved');
        
        // Reset local state ke kosong
        setState(() {
          _educationData = [];
          _dataLoaded = false;
          _freshLoginProcessed = true; // Prevent reload for users who never saved
        });
        
        // CRITICAL: Clear provider data untuk fresh app start
        ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
        
        // CRITICAL: Clear completion status untuk fresh app start
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('pendidikan');
        
        print('Ensured clean state for user who never saved');
        print('Provider data cleared (pendidikanDataProvider reset to empty)');
        print('Completion status reset (pendidikan marked as incomplete)');
        return;
      }
      
      // Jika user sudah pernah save, tapi ini fresh app start, 
      // clear unsaved changes flags untuk fresh start
      print('User has saved before, clearing temporary flags for fresh app start');
      await prefs.remove('education_has_changes');
      await prefs.remove('education_just_saved');
      
    } catch (e) {
      print('Error checking fresh app start: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    print('=== PENDIDIKAN didChangeDependencies CALLED ===');
    print('_dataLoaded: $_dataLoaded');
    print('_freshLoginProcessed: $_freshLoginProcessed');
    print('Current _educationData: $_educationData');
    print('_educationData.length: ${_educationData.length}');
    
    // CRITICAL: Don't load data if fresh login was already processed
    if (_freshLoginProcessed) {
      print('Fresh login already processed - skipping data load to preserve reset state');
      return;
    }
    
    // Only load data on first time AND when data is empty
    // This prevents losing temporary changes that haven't been saved yet
    if (!_dataLoaded && _educationData.isEmpty) {
      print('First time loading data...');
      _loadEducationData();
    } else if (!_dataLoaded && _educationData.isNotEmpty) {
      print('Data already has content, just mark as loaded');
      setState(() {
        _dataLoaded = true;
      });
    } else {
      print('Data already loaded, checking for unsaved changes...');
      _checkForUnsavedChanges();
    }
  }

  Future<void> _checkForUnsavedChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasChanges = prefs.getBool('education_has_changes') ?? false;
      
      print('Has unsaved education changes: $hasChanges');
      
      if (hasChanges) {
        print('User has unsaved education changes, preserving current _educationData');
        print('Preserved _educationData: $_educationData');
      } else {
        print('No unsaved education changes, safe to reload from storage');
        _loadEducationData();
      }
    } catch (e) {
      print('Error checking unsaved education changes: $e');
    }
  }

  Future<void> _loadEducationData() async {
    print('=== LOADING EDUCATION DATA ===');
    
    // CRITICAL: Don't load if fresh login was processed
    if (_freshLoginProcessed) {
      print('Fresh login processed - aborting data load to preserve reset state');
      return;
    }
    
    try {
      final educationPrefs = await SharedPreferences.getInstance();
      
      // Double check for fresh login flag before loading
      final isLoggedOut = educationPrefs.getBool('is_logged_out') ?? false;
      if (isLoggedOut) {
        print('Found is_logged_out flag during data load - aborting load and calling reset');
        await _checkFreshAppStartAndReset();
        return;
      }
      
      final savedEducationData = educationPrefs.getStringList('education_data') ?? [];
      final hasEducationUserSaved = educationPrefs.getBool('education_user_saved') ?? false;
      
      print('Saved education data from storage: $savedEducationData');
      print('savedEducationData.length: ${savedEducationData.length}');
      print('hasEducationUserSaved: $hasEducationUserSaved');
      
      // IMPORTANT: If user has never saved education, start with empty state (fresh login behavior)
      if (!hasEducationUserSaved) {
        print('User has never saved education - fresh login state, showing empty page');
        
        // Clear any temporary changes flags karena user belum pernah save
        await educationPrefs.remove('education_has_changes');
        await educationPrefs.remove('education_just_saved');
        
        setState(() {
          _educationData = [];
        });
        
        // Backup original data for change detection
        _originalData = _getCurrentData();
        
        setState(() {
          _dataLoaded = true;
        });
        
        print('Starting with empty state for fresh user');
        return;
      }
      
      // Clear current list
      _educationData.clear();
      
      // Load user data from storage if any
      if (savedEducationData.isNotEmpty) {
        for (String jsonStr in savedEducationData) {
          try {
            final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
            final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
            
            // Filter out dummy data when loading from storage
            if (educationMap['isDummy'] != 'true') {
              _educationData.add(educationMap);
            }
          } catch (e) {
            print('Error parsing education data: $e');
          }
        }
        print('Loaded user education data: $_educationData');
      } else {
        print('No user education data found in storage');
      }
      
      print('Final _educationData.length: ${_educationData.length}');
      
      // Backup original data for change detection
      _originalData = _getCurrentData();
      
      // Mark data as loaded to prevent unnecessary reloads
      setState(() {
        _dataLoaded = true;
      });
      
      print('Education data count: ${_educationData.length}');
      print('Original data backed up: $_originalData');
      print('Data marked as loaded: _dataLoaded = $_dataLoaded');
    } catch (e) {
      print('Error loading education data: $e');
      setState(() {
        _educationData = [];
        _dataLoaded = true; // Still mark as loaded even on error
      });
    }
  }

  Future<void> _saveEducationDataToStorage([List<Map<String, String>>? dataToSave]) async {
    try {
      print('=== SAVING EDUCATION TO STORAGE ===');
      
      // Use provided data or fallback to _educationData
      final dataForSaving = dataToSave ?? _educationData;
      print('Data to save: $dataForSaving');
      print('Data count: ${dataForSaving.length}');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Convert to StringList format (each item as separate JSON string)
      final List<String> educationJsonList = dataForSaving
          .map((education) => jsonEncode(education))
          .toList();
      
      print('JSON list to save: $educationJsonList');
      
      // Save as StringList for consistency
      await prefs.setStringList('education_data', educationJsonList);
      
      // Set education_user_saved flag
      await prefs.setBool('education_user_saved', true);
      
      print('Education data saved to storage: ${dataForSaving.length} records');
      print('education_user_saved flag set to true');
      
      // Verify data was saved
      final savedData = prefs.getStringList('education_data');
      print('Verification - data in storage: $savedData');
      print('Education data has been saved and will persist');
      
    } catch (e) {
      print('Error saving education data: $e');
    }
  }
  
  Map<String, dynamic> _getCurrentData() {
    return {
      'educationCount': _educationData.length,
      'educationData': List<Map<String, String>>.from(_educationData),
    };
  }
  
  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    bool hasChanges = false;
    
    print('=== CHECKING FOR UNSAVED CHANGES ===');
    print('Original: $_originalData');
    print('Current: $currentData');
    
    // Check if education count changed
    if (_originalData['educationCount'] != currentData['educationCount']) {
      print('Education count changed: ${_originalData['educationCount']} -> ${currentData['educationCount']}');
      hasChanges = true;
    }
    
    // Check if education data changed
    if (_originalData['educationData'] != null && currentData['educationData'] != null) {
      final originalList = List<Map<String, String>>.from(_originalData['educationData']);
      final currentList = List<Map<String, String>>.from(currentData['educationData']);
      
      if (originalList.length != currentList.length) {
        print('Education list length changed');
        hasChanges = true;
      } else {
        for (int i = 0; i < originalList.length; i++) {
          if (originalList[i].toString() != currentList[i].toString()) {
            print('Education item $i changed');
            hasChanges = true;
            break;
          }
        }
      }
    }
    
    print('Has unsaved changes from data comparison: $hasChanges');
    return hasChanges;
  }
  
  Future<void> _restoreDataFromStorage() async {
    print('=== RESTORING DATA FROM STORAGE ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEducationData = prefs.getStringList('education_data') ?? [];
      
      print('Restoring from storage: $savedEducationData');
      
      // Clear current data
      _educationData.clear();
      
      // Load saved data from storage if any
      if (savedEducationData.isNotEmpty) {
        for (String jsonStr in savedEducationData) {
          try {
            final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
            final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
            
            // Only load non-dummy data
            if (educationMap['isDummy'] != 'true') {
              _educationData.add(educationMap);
            }
          } catch (e) {
            print('Error parsing education data during restore: $e');
          }
        }
      }
      
      // Clear the unsaved changes flag
      await prefs.setBool('education_has_changes', false);
      
      // Update original data backup
      _originalData = _getCurrentData();
      
      setState(() {});
      
      print('Data restored from storage. Current _educationData: $_educationData');
      print('Cleared education_has_changes flag');
    } catch (e) {
      print('Error restoring data from storage: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to combine dummy data and user data for display
  List<Map<String, String>> _getCombinedEducationData() {
    print('=== _getCombinedEducationData ===');
    print('_educationData.length: ${_educationData.length}');
    
    // Return only user data (no dummy data)
    return List<Map<String, String>>.from(_educationData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final educationData = _getCombinedEducationData();

    // Real-time Indonesian time (UTC+7)
    // final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Filter education data based on search
    final filteredData =
        educationData.where((e) {
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;

          return (e['jenjang'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['jurusan'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['institusi'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['kota'] ?? '').toLowerCase().contains(searchTerm);
        }).toList();

    // Check if there are active filters
    final hasActiveFilters = _searchController.text.trim().isNotEmpty;

    return PopScope(
      canPop: true, // CRITICAL FIX: Allow normal navigation back
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          print('=== PENDIDIKAN PAGE POPPED - NAVIGATION BACK ===');
          
          // CRITICAL: Ensure flags are set immediately before navigation completes
          if (_hasUnsavedChanges()) {
            print('→ Setting education_has_changes = true before navigation');
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('education_has_changes', true);
          }
          
          return; // Allow normal pop navigation
        }
        
        // Legacy fallback handling (shouldn't be reached with canPop: true)
        if (_hasUnsavedChanges()) {
          print('=== UNSAVED CHANGES DETECTED ON BACK ===');
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave == true && context.mounted) {
            // Restore data from storage before leaving
            await _restoreDataFromStorage();
            context.go('/profile-sections');
          }
        } else {
          print('=== NO UNSAVED CHANGES, SAFE TO LEAVE ===');
          // Add small delay to ensure any pending SharedPreferences operations are completed
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            context.go('/profile-sections');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Data Pendidikan',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: theme.primarySwatch,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (_hasUnsavedChanges()) {
                print('=== UNSAVED CHANGES DETECTED ON BACK BUTTON ===');
                final shouldLeave = await _showUnsavedChangesDialog();
                if (shouldLeave == true && context.mounted) {
                  // Restore data from storage before leaving
                  await _restoreDataFromStorage();
                  context.go('/profile-sections');
                }
              } else {
                print('=== NO UNSAVED CHANGES, SAFE TO LEAVE ===');
                // Add small delay to ensure any pending SharedPreferences operations are completed
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  context.go('/profile-sections');
                }
              }
            },
          ),
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Filter using AppFilterBar
            AppFilterBar(
              controller: _searchController,
              labelText: 'Pencarian Data Pendidikan',
              hintText:
                  'Cari berdasarkan jenjang, jurusan, institusi, atau kota...',
              onChanged: (value) => setState(() {}),
              onClear: () => setState(() {}),
              headerTitle: 'Pencarian',
              hasActiveFilters: hasActiveFilters,
              onReset:
                  hasActiveFilters
                      ? () {
                        _searchController.clear();
                        setState(() {});
                      }
                      : null,
            ),
            const SizedBox(height: 20),

            // Note Section
            _buildNoteSection(theme),
            const SizedBox(height: 20),

            // Add Education Button
            _buildAddEducationButton(theme),
            const SizedBox(height: 20),

            // Education Data Cards (replaces table)
            _buildEducationCards(theme, filteredData, isTablet),

            const SizedBox(height: 30),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () {
                  _saveData(context, theme);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MENYIMPAN...',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'SIMPAN',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
      ),
    );
  }
  
  Future<bool?> _showUnsavedChangesDialog() async {
    final result = await NotificationUtils.showConfirmationDialog(
      context,
      title: 'Perubahan Belum Disimpan',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmButtonText: 'Keluar Tanpa Menyimpan',
      cancelButtonText: 'Batal',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );
    return result;
  }

  Widget _buildNoteSection(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wajib menambahkan Riwayat Pendidikan Terakhir',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEducationButton(dynamic theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tambah Riwayat Pendidikan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEducation,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_circle, size: 20),
              label: Text(
                'TAMBAH RIWAYAT PENDIDIKAN',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCards(
    dynamic theme,
    List<Map<String, String>> educationData,
    bool isTablet,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Riwayat Pendidikan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: theme.primarySwatch,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${educationData.length} data',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: theme.primarySwatch,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (educationData.isEmpty)
            _buildEmptyState(theme)
          else
            Column(
              children:
                  educationData
                      .map((e) => _buildEducationCard(theme, e))
                      .toList(),
            ),
        ],
      ),
    );
  }

  // Helper for pill chips like in WorkHistory
  Widget _pillChip({
    required IconData icon,
    required String label,
    required dynamic theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primarySwatch),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.typographyRegular.bodyExtraSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // New card UI matching WorkHistory style
  Widget _buildEducationCard(dynamic theme, Map<String, String> e) {
    final jenjang = (e['jenjang'] ?? '').trim();
    final jurusan = (e['jurusan'] ?? '').trim();
    final institusi = (e['institusi'] ?? '').trim();
    final kota = (e['kota'] ?? '').trim();

    // Use the formatted tahun field if available, or format the individual years
    String tahun;
    if (e['tahun'] != null && e['tahun']!.isNotEmpty) {
      tahun = e['tahun']!;
    } else if (e['tahun_mulai'] != null && e['tahun_selesai'] != null) {
      tahun = '${e['tahun_mulai']} - ${e['tahun_selesai']}';
    } else {
      tahun = '-';
    }

    final jenjangColor = _getJenjangColor(jenjang);

    return AppCard(
      leftAccentColor: jenjangColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with jenjang icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: jenjangColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jurusan.isEmpty ? '-' : jurusan,
                      style: theme.typographyBold.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institusi.isEmpty ? '-' : institusi,
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Jenjang chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jenjang.isEmpty ? '-' : jenjang,
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: jenjangColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Information pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.location_on,
                label: kota.isEmpty ? '-' : kota,
                theme: theme,
              ),
              _pillChip(icon: Icons.calendar_today, label: tahun, theme: theme),
            ],
          ),

          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: Icon(Icons.edit, color: theme.primarySwatch),
                onPressed: () => _editEducation(e),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteEducation(e),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data pendidikan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan riwayat pendidikan dengan menekan tombol di atas',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getJenjangColor(String jenjang) {
    switch (jenjang.toLowerCase()) {
      case 'sd':
        return Colors.green;
      case 'smp':
        return Colors.blue;
      case 'sma':
      case 'smk':
        return Colors.orange;
      case 'diploma':
      case 'd1':
      case 'd2':
      case 'd3':
      case 'd4':
        return Colors.purple;
      case 's1':
      case 'sarjana':
      case 'sarjana/s1':
        return Colors.indigo;
      case 's2':
      case 'magister':
        return Colors.red;
      case 's3':
      case 'doktor':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addEducation() async {
    print('=== ADD EDUCATION BUTTON PRESSED ===');
    print('Current _educationData before add: $_educationData');
    
    try {
      // Navigate to add education form page
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TambahDataPendidikanPage(),
        ),
      );
      
      if (!mounted) return;
      
      print('Navigation result: $result');
      
      if (result is Map && result['action'] == 'add' && result['data'] is Map) {
        final newEducation = Map<String, String>.from(result['data'] as Map);
        print('Adding new education data from navigation: $newEducation');
        print('_educationData BEFORE add: $_educationData (${_educationData.length} items)');
        
        newEducation['isDummy'] = 'false';
        
        setState(() {
          _educationData.add(newEducation);
          _dataLoaded = true;
        });
        
        print('_educationData AFTER add: $_educationData (${_educationData.length} items)');
        print('All items in _educationData:');
        for (int i = 0; i < _educationData.length; i++) {
          print('  [$i]: ${_educationData[i]}');
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('education_has_changes', true);
        print('Set education_has_changes = true (data added but not saved)');
      }
    } catch (e) {
      print('Error in _addEducation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menambahkan data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _editEducation(Map<String, String> education) async {
    print('=== EDITING EDUCATION ===');
    print('Education to edit: $education');
    print('Is dummy data: ${education['isDummy'] == 'true'}');
    

    bool isDummyData = education['isDummy'] == 'true' || 
                       education['id']?.startsWith('dummy-') == true;
    
    if (isDummyData) {
      print('Cannot edit dummy data, showing message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data dummy tidak dapat diedit. Silakan tambah data baru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    try {

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDataPendidikanPage(educationToEdit: education),
        ),
      );
      
      if (!mounted) return;
      
      print('Edit navigation result: $result');
      
  
      if (result is Map && result['action'] == 'edit' && result['data'] is Map) {
        final updatedEducation = Map<String, String>.from(result['data']);
        
        print('=== UPDATING EDUCATION AFTER EDIT ===');
        print('Updated education: $updatedEducation');
        print('_educationData BEFORE update: $_educationData');
        
        final idx = _educationData.indexWhere((e) => e['id'] == updatedEducation['id']);
        if (idx != -1) {
          setState(() {
            _educationData[idx] = updatedEducation;
          });
          print('Education updated at index $idx');
          print('_educationData AFTER update: $_educationData');
        } else {
          print('ERROR: Could not find education with id ${updatedEducation['id']}');
          print('Available IDs: ${_educationData.map((e) => e['id']).toList()}');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('education_has_changes', true);
        print('Set education_has_changes = true (data edited but not saved)');
      }
    } catch (e) {
      print('Error in _editEducation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengedit data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteEducation(Map<String, String> education) {
    print('=== DELETING EDUCATION ===');
    print('Education to delete: $education');
    print('Education keys: ${education.keys.toList()}');
    print('isDummy field value: ${education['isDummy']}');
    print('isDummy check result: ${education['isDummy'] == 'true'}');
    
    bool isDummyData = education['isDummy'] == 'true' || 
                       education['id']?.startsWith('dummy-') == true;
    
    print('Final isDummyData result: $isDummyData');
    
    if (isDummyData) {
      print('Cannot delete dummy data, showing message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data dummy tidak dapat dihapus'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Pendidikan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data ${education['jenjang'] ?? education['tingkat'] ?? 'pendidikan'} - ${education['jurusan'] ?? education['institusi'] ?? 'unknown'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _educationData.removeWhere(
                  (e) => e['id'] == education['id'],
                );
              });
              
              print('Education deleted from _educationData');
              print('Remaining _educationData length: ${_educationData.length}');
              
              // Set flag untuk detect unsaved changes
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('education_has_changes', true);
              print('Set education_has_changes = true (data deleted but not saved)');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _saveData(BuildContext context, dynamic theme) async {

    if (_isSaving) {
      print('Save already in progress, ignoring duplicate call');
      return;
    }
    
    print('=== CALLING _saveData ===');
    print('_educationData to save: $_educationData');
    print('_educationData.length: ${_educationData.length}');
    
    // Set loading state
    setState(() {
      _isSaving = true;
    });
    
    try {

      await _saveEducationDataToStorage();
 
    if (_educationData.isNotEmpty) {
      final latestEducation = _educationData.last;
      final pendidikanData = PendidikanData(
        tingkatPendidikan: latestEducation['jenjang'] ?? '',
        namaInstitusi: latestEducation['institusi'] ?? '',
        jurusan: latestEducation['jurusan'] ?? '',
        tahunLulus: latestEducation['tahun_selesai'] ?? '',
        ipk: '', // Could be added as a field later
      );
      ref.read(pendidikanDataProvider.notifier).updateData(pendidikanData);
      print('Updated PendidikanDataProvider with latest education entry after save: ${latestEducation['institusi']} - ${latestEducation['jurusan']}');
    }
 
    setState(() {});
    
   
    final prefs = await SharedPreferences.getInstance();
    

    int maxRetries = 3;
    bool flagsSetSuccessfully = false;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      print('=== FLAG SETTING ATTEMPT $attempt ===');
      
      try {
        await prefs.setBool('education_just_saved', true);
        await prefs.setBool('education_user_saved', true);
        await prefs.setBool('education_has_changes', false);
        
  
        await Future.delayed(const Duration(milliseconds: 100));
        
   
        final verifyJustSaved = prefs.getBool('education_just_saved') ?? false;
        final verifyUserSaved = prefs.getBool('education_user_saved') ?? false;
        final verifyHasChanges = prefs.getBool('education_has_changes') ?? false;
        
        print('VERIFICATION ATTEMPT $attempt:');
        print('  - education_just_saved: $verifyJustSaved');
        print('  - education_user_saved: $verifyUserSaved'); 
        print('  - education_has_changes: $verifyHasChanges');
        
        if (verifyJustSaved && verifyUserSaved && !verifyHasChanges) {
          print('✅ All flags set correctly on attempt $attempt');
          flagsSetSuccessfully = true;
          break;
        } else {
          print('❌ Flags not set correctly on attempt $attempt, retrying...');
          await Future.delayed(Duration(milliseconds: 50 * attempt)); 
        }
      } catch (e) {
        print('❌ Error setting flags on attempt $attempt: $e');
        await Future.delayed(Duration(milliseconds: 50 * attempt)); 
      }
    }
    
    if (!flagsSetSuccessfully) {
      print('⚠️ WARNING: Failed to set flags after $maxRetries attempts');
    } else {
      print('✅ SUCCESS: All flags set correctly and will trigger EDITED status in profile_sections');
    }

    if (_educationData.isNotEmpty) {
      final completionNotifier = ref.read(profileCompletionProvider.notifier);
      completionNotifier.markCompleted('pendidikan');
    } else {
      final completionNotifier = ref.read(profileCompletionProvider.notifier);
      completionNotifier.markIncomplete('pendidikan');
    }

    _originalData = _getCurrentData();

    print('=== WAITING FOR SHAREDPREFERENCES OPERATIONS TO COMPLETE ===');
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (context.mounted) {
      await NotificationUtils.showSuccessDialog(
        context,
        title: 'Simpan Data Pendidikan',
        message: 'Data pendidikan berhasil disimpan.',
        buttonText: 'OK',
        onPressed: () {

          print('=== SUCCESS DIALOG OK PRESSED - NAVIGATING ===');
          if (context.mounted) {
            context.go('/profile-sections');
          }
        },
      );
    }
    
    } catch (e) {
      print('Error in _saveData: $e');
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}