import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'providers/profile_data_provider.dart';
import 'riwayatPekerjaan/add_data_pekerjaan_pages.dart';

class WorkHistoryData {
  final String id;
  final String position;
  final String company;
  final String startYear;
  final String endYear;

  WorkHistoryData({
    required this.id,
    required this.position,
    required this.company,
    required this.startYear,
    required this.endYear,
  });

  // Helper to create a copy with new values (useful for editing)
  WorkHistoryData copyWith({
    String? id,
    String? position,
    String? company,
    String? startYear,
    String? endYear,
  }) {
    return WorkHistoryData(
      id: id ?? this.id,
      position: position ?? this.position,
      company: company ?? this.company,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
    );
  }
}

// Provider with work history data
final workHistoryDataProvider = StateProvider<List<WorkHistoryData>>((ref) {
  return []; // Start with empty list - user must add data manually
});

class WorkHistoryPage extends ConsumerStatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  ConsumerState<WorkHistoryPage> createState() => _AddWorkHistoryPageState();
}

class _AddWorkHistoryPageState extends ConsumerState<WorkHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _workHistoryData = [];

  Map<String, dynamic> _originalData = {};
  bool _dataLoaded = false;
  bool _freshLoginProcessed = false;

  @override
  void initState() {
    super.initState();
    print('=== WORK HISTORY initState CALLED ===');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkFreshAppStartAndReset();
    });
  }

  Future<void> _checkFreshAppStartAndReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      final workHistoryUserSaved =
          prefs.getBool('work_history_user_saved') ?? false;

      print('=== FRESH APP START CHECK ===');
      print('isLoggedOut: $isLoggedOut');
      print('workHistoryUserSaved: $workHistoryUserSaved');
      print('Current _workHistoryData BEFORE check: $_workHistoryData');
      print(
        'Current _workHistoryData.length BEFORE check: ${_workHistoryData.length}',
      );

      if (isLoggedOut) {
        print(
          'Fresh login detected - but SKIPPING clearing in riwayat_pekerjaan_page',
        );
        print(
          'Profile_page.dart will handle fresh login clearing to avoid race conditions',
        );
        print('Setting fresh login processed flag to prevent data loading');

        setState(() {
          _freshLoginProcessed = true;
        });

        print(
          'SKIPPED clearing - profile_page.dart is responsible for fresh login clearing',
        );
        return;
      }

      if (!workHistoryUserSaved) {
        print(
          'User never saved work history and fresh app start - ensuring clean state',
        );

        await prefs.remove('work_history_has_changes');
        await prefs.remove('work_history_just_saved');

        setState(() {
          _workHistoryData = [];
          _dataLoaded = false;
          _freshLoginProcessed = true;
        });

        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(RiwayatPekerjaanData());
        ref.read(workHistoryDataProvider.notifier).state = [];

        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        completionNotifier.markIncomplete('riwayatPekerjaan');

        print('Ensured clean state for user who never saved');
        print(
          'Provider data cleared (both riwayatPekerjaanDataProvider and workHistoryDataProvider reset to empty)',
        );
        print(
          'Completion status reset (riwayatPekerjaan marked as incomplete)',
        );
        return;
      }

      print(
        'User has saved before, clearing temporary flags for fresh app start',
      );
      await prefs.remove('work_history_has_changes');
      await prefs.remove('work_history_just_saved');
    } catch (e) {
      print('Error checking fresh app start: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('=== WORK HISTORY didChangeDependencies CALLED ===');
    print('_dataLoaded: $_dataLoaded');
    print('_freshLoginProcessed: $_freshLoginProcessed');
    print('Current _workHistoryData: $_workHistoryData');
    print('_workHistoryData.length: ${_workHistoryData.length}');

    if (_freshLoginProcessed) {
      print(
        'Fresh login already processed - skipping data load to preserve reset state',
      );
      return;
    }

    if (_workHistoryData.isNotEmpty) {
      print(
        'Data exists in memory - ABSOLUTELY preserving it and marking as loaded',
      );
      print('Preserving ${_workHistoryData.length} items: $_workHistoryData');
      setState(() {
        _dataLoaded = true;
      });
      return;
    }

    if (!_dataLoaded && _workHistoryData.isEmpty) {
      print('First time loading data (completely empty state)...');
      _loadWorkHistoryData();
    } else {
      print(
        'Data state: loaded=$_dataLoaded, length=${_workHistoryData.length}',
      );
      print('Skipping any data operations to preserve existing state');
      if (!_dataLoaded) {
        setState(() {
          _dataLoaded = true;
        });
      }
    }
  }

  Future<void> _loadWorkHistoryData() async {
    print('=== LOADING WORK HISTORY DATA ===');

    if (_freshLoginProcessed) {
      print(
        'Fresh login processed - aborting data load to preserve reset state',
      );
      return;
    }

    if (_workHistoryData.isNotEmpty) {
      print(
        'Already have ${_workHistoryData.length} items in memory - aborting load to preserve data',
      );
      print('Existing data: $_workHistoryData');
      setState(() {
        _dataLoaded = true;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      if (isLoggedOut) {
        print(
          'Found is_logged_out flag during data load - aborting load and calling reset',
        );
        await _checkFreshAppStartAndReset();
        return;
      }

      final hasWorkHistoryUserSaved =
          prefs.getBool('work_history_user_saved') ?? false;
      final hasChanges = prefs.getBool('work_history_has_changes') ?? false;

      print('work_history_user_saved flag: $hasWorkHistoryUserSaved');
      print('work_history_has_changes flag: $hasChanges');

      // IMPORTANT: If user has never saved work history, start with empty state (fresh login behavior)
      if (!hasWorkHistoryUserSaved) {
        print(
          'User has never saved work history - fresh login state, showing empty page',
        );

        // Clear any temporary changes flags karena user belum pernah save
        await prefs.remove('work_history_has_changes');
        await prefs.remove('work_history_just_saved');

        setState(() {
          _workHistoryData = [];
        });

        _originalData = _getCurrentData();

        setState(() {
          _dataLoaded = true;
        });

        print('Starting with empty state for fresh user');
        return;
      }

      if (hasChanges) {
        print(
          'Found leftover has_changes flag from previous session - user added data but didn\'t save before app restart',
        );
        print(
          'Resetting to saved data only (ignoring unsaved changes from previous session)',
        );

        // Clear the leftover flag
        await prefs.remove('work_history_has_changes');
        await prefs.remove('work_history_just_saved');
      }

      // If user has saved before, try to load their data from storage
      final workHistoryDataList = prefs.getStringList('work_history_data');

      print('Data from storage (StringList): $workHistoryDataList');

      if (workHistoryDataList != null && workHistoryDataList.isNotEmpty) {
        final List<Map<String, String>> loadedData = [];

        for (String jsonStr in workHistoryDataList) {
          try {
            final Map<String, dynamic> workMap = jsonDecode(jsonStr);

            final Map<String, String> workStringMap = workMap.map(
              (key, value) => MapEntry(key, value?.toString() ?? ''),
            );
            loadedData.add(workStringMap);

            print('Loaded item: $workStringMap');
            print('  - isDummy: ${workStringMap['isDummy']}');
            print('  - ID: ${workStringMap['id']}');
          } catch (e) {
            print('Error parsing work history item: $e');
          }
        }

        final userDataOnly =
            loadedData
                .where(
                  (item) =>
                      item['isDummy'] != 'true' &&
                      !(item['id']?.startsWith('dummy') ?? false),
                )
                .toList();

        setState(() {
          _workHistoryData = userDataOnly;
        });
        print(
          'Loaded ${loadedData.length} total records, ${userDataOnly.length} user records after filtering dummy',
        );
        print('_workHistoryData after loading: $_workHistoryData');
      } else {
        final workHistoryDataJson = prefs.getString('work_history_data');
        print(
          'Trying old format - Data from storage (String): $workHistoryDataJson',
        );

        if (workHistoryDataJson != null && workHistoryDataJson.isNotEmpty) {
          final List<dynamic> decodedData = json.decode(workHistoryDataJson);
          if (decodedData.isNotEmpty) {
            final List<Map<String, String>> loadedData =
                decodedData
                    .map((item) => Map<String, String>.from(item))
                    .toList();

            final userDataOnly =
                loadedData
                    .where(
                      (item) =>
                          item['isDummy'] != 'true' &&
                          !(item['id']?.startsWith('dummy') ?? false),
                    )
                    .toList();

            setState(() {
              _workHistoryData = userDataOnly;
            });
            print(
              'Loaded ${loadedData.length} total records (old format), ${userDataOnly.length} user records after filtering dummy',
            );

            await _saveWorkHistoryDataToStorage(
              userDataOnly,
              false,
            ); // Temporary save, don't set user_saved flag
            print('Converted old format to new StringList format');
          }
        } else {
          print(
            'No data found in either format - user has saved flag but no actual data',
          );
          setState(() {
            _workHistoryData = [];
          });
        }
      }

      _originalData = _getCurrentData();

      setState(() {
        _dataLoaded = true;
      });

      print('Work history data count: ${_workHistoryData.length}');
      print('Original data backed up: $_originalData');
      print('Data marked as loaded: _dataLoaded = $_dataLoaded');
    } catch (e) {
      print('Error loading work history data: $e');
      setState(() {
        _workHistoryData = [];
        _dataLoaded = true;
      });
    }
  }

  Future<void> _saveWorkHistoryDataToStorage([
    List<Map<String, String>>? dataToSave,
    bool setUserSavedFlag = false,
  ]) async {
    try {
      print('=== SAVING TO STORAGE ===');

      final dataForSaving = dataToSave ?? _workHistoryData;
      print('Data to save: $dataForSaving');
      print('Data count: ${dataForSaving.length}');

      for (int i = 0; i < dataForSaving.length; i++) {
        final item = dataForSaving[i];
        print('  Item $i: ${item}');
        print('    - ID: ${item['id']}');
        print('    - Position: ${item['position']}');
        print('    - Company: ${item['company']}');
        print('    - isDummy: ${item['isDummy']}');
      }

      final prefs = await SharedPreferences.getInstance();

      final List<String> workHistoryJsonList =
          dataForSaving.map((work) => jsonEncode(work)).toList();

      print('JSON list to save: $workHistoryJsonList');

      await prefs.setStringList('work_history_data', workHistoryJsonList);

      if (setUserSavedFlag) {
        await prefs.setBool('work_history_user_saved', true);
        print('Set work_history_user_saved = true (explicit save)');
      } else {
        print(
          'Data saved to storage, but NOT setting work_history_user_saved flag (temporary save)',
        );
      }

      print(
        'Work history data saved to storage: ${dataForSaving.length} records',
      );
      print('work_history_user_saved flag set to true');

      final savedData = prefs.getStringList('work_history_data');
      print('Verification - data in storage: $savedData');
      print('Verification - storage data count: ${savedData?.length ?? 0}');

      if (savedData != null) {
        for (int i = 0; i < savedData.length; i++) {
          print('  Storage Item $i: ${savedData[i]}');
          try {
            final parsed = jsonDecode(savedData[i]);
            print('    - Parsed: $parsed');
            print('    - isDummy in storage: ${parsed['isDummy']}');
          } catch (e) {
            print('    - Parse error: $e');
          }
        }
      }
    } catch (e) {
      print('Error saving work history data: $e');
    }
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'workHistoryCount': _workHistoryData.length,
      'workHistoryData': List<Map<String, String>>.from(_workHistoryData),
    };
  }

  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    bool hasChanges = false;

    print('=== CHECKING FOR UNSAVED CHANGES ===');
    print('Original: $_originalData');
    print('Current: $currentData');

    // Check if work history count changed
    if (_originalData['workHistoryCount'] != currentData['workHistoryCount']) {
      print(
        'Work history count changed: ${_originalData['workHistoryCount']} -> ${currentData['workHistoryCount']}',
      );
      hasChanges = true;
    }

    // Check if work history data changed
    if (_originalData['workHistoryData'] != null &&
        currentData['workHistoryData'] != null) {
      final originalList = List<Map<String, String>>.from(
        _originalData['workHistoryData'],
      );
      final currentList = List<Map<String, String>>.from(
        currentData['workHistoryData'],
      );

      if (originalList.length != currentList.length) {
        print('Work history list length changed');
        hasChanges = true;
      } else {
        for (int i = 0; i < originalList.length; i++) {
          if (originalList[i].toString() != currentList[i].toString()) {
            print('Work history item $i changed');
            hasChanges = true;
            break;
          }
        }
      }
    }

    print('Has unsaved changes: $hasChanges');
    return hasChanges;
  }

  void _restoreOriginalData() {
    print('=== RESTORING ORIGINAL DATA ===');
    if (_originalData['workHistoryData'] != null) {
      _workHistoryData.clear();
      _workHistoryData.addAll(
        List<Map<String, String>>.from(_originalData['workHistoryData']),
      );
      setState(() {});
      print('Data restored successfully');
    }
  }

  Future<void> _saveToProvider() async {
    print('=== AUTO-SAVING TO PROVIDER ===');

    // Save only user data (no dummy data)
    List<Map<String, String>> dataToSave = [..._workHistoryData];

    print('Saving user data only: ${dataToSave.length} items');
    print('User data count: ${_workHistoryData.length}');

    if (dataToSave.isNotEmpty) {
      final List<WorkHistoryData> workHistoryDataList =
          dataToSave
              .map(
                (work) => WorkHistoryData(
                  id: work['id'] ?? '',
                  position: work['position'] ?? '',
                  company: work['company'] ?? '',
                  startYear: work['startYear'] ?? '',
                  endYear: work['endYear'] ?? '',
                ),
              )
              .toList();

      ref.read(workHistoryDataProvider.notifier).state = workHistoryDataList;

      print('=== DATA AUTO-SAVED TO PROVIDER ===');
      print('Work history count: ${workHistoryDataList.length}');

      // Also update RiwayatPekerjaanDataProvider with latest entry for profile page
      if (workHistoryDataList.isNotEmpty) {
        // Get the latest entry
        final latestWork = workHistoryDataList.last;
        print(
          'Using latest work entry for provider: ${latestWork.company} - ${latestWork.position}',
        );

        final riwayatPekerjaanData = RiwayatPekerjaanData(
          namaPerusahaan: latestWork.company,
          posisi: latestWork.position,
          tahunMulai: latestWork.startYear,
          tahunSelesai: latestWork.endYear,
          deskripsiTugas: '', // Could be added as a field later
        );
        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(riwayatPekerjaanData);
        print(
          'Updated RiwayatPekerjaanDataProvider with latest work entry: ${latestWork.company} - ${latestWork.position}',
        );
      }

      // Save data to storage (use the same data we prepared above)
      await _saveWorkHistoryDataToStorage(
        dataToSave,
        true,
      ); // Set user saved flag when explicitly saving
    } else {
      // If no data, save empty array
      await _saveWorkHistoryDataToStorage(
        [],
        true,
      ); // Set user saved flag when explicitly saving
      print('Saved empty work history data');
    }

    // IMPORTANT: Set additional flags after user explicitly clicks SAVE
    // Note: work_history_user_saved is already set by _saveWorkHistoryDataToStorage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('work_history_just_saved', true);
    await prefs.setBool(
      'work_history_has_changes',
      false,
    ); // Clear changes flag
    print('Set work_history_just_saved = true');
    print('Set work_history_has_changes = false');

    // IMPORTANT: Mark completion status in provider ONLY when user saves
    final completionNotifier = ref.read(profileCompletionProvider.notifier);
    if (dataToSave.isNotEmpty) {
      completionNotifier.markCompleted('riwayatPekerjaan');
      print('Marked riwayatPekerjaan as COMPLETED (has data and user saved)');
    } else {
      completionNotifier.markIncomplete('riwayatPekerjaan');
      print('Marked riwayatPekerjaan as INCOMPLETE (no data)');
    }

    // Update original data to mark as saved
    _originalData = _getCurrentData();

    print('=== SAVE COMPLETED ===');
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Perubahan Belum Disimpan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            content: Text(
              'Anda memiliki perubahan yang belum disimpan. Apa yang ingin Anda lakukan?',
              style: theme.typographyRegular.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
              ),
              TextButton(
                onPressed: () {
                  _restoreOriginalData();
                  Navigator.pop(context, false);
                  Navigator.pop(context);
                },
                child: Text(
                  'Buang Perubahan',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  _saveData(context, theme);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _saveData(BuildContext context, dynamic theme) async {
    print('=== CALLING _saveData ===');
    print('_workHistoryData before save: $_workHistoryData');
    print('_workHistoryData.length before save: ${_workHistoryData.length}');

    // Save data to provider and storage with explicit await
    await _saveToProvider();

    // EXTENDED delay to ensure data is fully committed to SharedPreferences
    // This prevents race condition with profile_sections_page loading
    await Future.delayed(const Duration(milliseconds: 800));

    // VERIFICATION: Check that data is actually saved
    final prefsVerify = await SharedPreferences.getInstance();
    final verifyData = prefsVerify.getStringList('work_history_data');
    final verifyUserSaved = prefsVerify.getBool('work_history_user_saved');
    print('=== POST-SAVE VERIFICATION ===');
    print('Saved data in storage: $verifyData');
    print('work_history_user_saved flag: $verifyUserSaved');
    print('Local _workHistoryData: $_workHistoryData');

    print('=== DATA SAVE DELAY COMPLETED ===');

    // Clear the unsaved changes flag since data has been saved
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('work_history_has_changes', false);
    print('Set work_history_has_changes = false (data saved successfully)');

    // Update original data backup since we just saved
    _originalData = _getCurrentData();
    print('Updated original data backup after save');

    // CRITICAL: Ensure data is preserved in memory and mark as loaded
    setState(() {
      _dataLoaded = true;
      _freshLoginProcessed = true; // Prevent any reload attempts
    });
    print(
      'Marked data as loaded and fresh login as processed to prevent reload',
    );

    // Show immediate feedback with SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Riwayat Pekerjaan berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('=== SHOWING SUCCESS DIALOG ===');
    // Show success dialog with delay to ensure SnackBar is visible first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && context.mounted) {
        NotificationUtils.showSuccessDialog(
          context,
          title: 'Simpan Data Riwayat Pekerjaan',
          message: 'Data riwayat pekerjaan berhasil disimpan.',
          onPressed: () {
            print('=== SUCCESS DIALOG BUTTON PRESSED ===');
            print(
              'Current _workHistoryData before navigation: $_workHistoryData',
            );
            print(
              '_workHistoryData.length before navigation: ${_workHistoryData.length}',
            );

            // Update original data to clear unsaved changes flag
            _originalData = _getCurrentData();

            // CRITICAL: Final verification before navigation
            print('=== FINAL VERIFICATION BEFORE NAVIGATION ===');
            print('Local data preserved: $_workHistoryData');
            print('Original data backup: $_originalData');

            // Safe navigation back to previous page
            if (Navigator.canPop(context)) {
              print('Using Navigator.pop with saved result');
              Navigator.pop(context, 'saved');
            } else {
              print('Using context.go to profile-sections');
              context.go('/profile-sections');
            }
          },
        );
        print('=== SUCCESS DIALOG COMPLETED ===');
      } else {
        print('=== CONTEXT NOT MOUNTED, SKIPPING DIALOG ===');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // CRITICAL CHECK: Fresh login ALWAYS takes priority - clear ALL data including unsaved changes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_freshLoginProcessed) {
        final prefs = await SharedPreferences.getInstance();
        final isLoggedOut = prefs.getBool('is_logged_out') ?? false;

        // ALWAYS clear data if fresh login detected, regardless of pending changes
        if (isLoggedOut) {
          print(
            'IMMEDIATE BUILD CHECK: Found fresh login flag - FORCE clearing all data including unsaved changes',
          );
          await _checkFreshAppStartAndReset();
        }
      }
    });

    // Show only user data (no dummy data)
    final displayData = <Map<String, String>>[
      ..._workHistoryData, // Show only user data
    ];

    print('=== BUILDING WORK HISTORY PAGE ===');
    print('Current work history data count: ${_workHistoryData.length}');
    print('Display data count: ${displayData.length}');
    print('_dataLoaded: $_dataLoaded');
    print('_freshLoginProcessed: $_freshLoginProcessed');
    print('_workHistoryData contents: $_workHistoryData');
    print('displayData contents: $displayData');

    // Filter work history data based on search
    final filteredData =
        displayData.where((work) {
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;

          return (work['position'] ?? '').toLowerCase().contains(searchTerm) ||
              (work['company'] ?? '').toLowerCase().contains(searchTerm);
        }).toList();

    print('Filtered data count: ${filteredData.length}');
    print('Filtered data: $filteredData');

    // Check if there are active filters
    final hasActiveFilters = _searchController.text.trim().isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_hasUnsavedChanges()) {
          print('=== UNSAVED CHANGES DETECTED ON BACK ===');
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave == true && context.mounted) {
            Navigator.pop(context);
          }
        } else {
          print('=== NO UNSAVED CHANGES, SAFE TO LEAVE ===');
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Data Riwayat Pekerjaan',
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
                final shouldLeave = await _showUnsavedChangesDialog();
                if (shouldLeave == true && context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
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
              // Search + Filter using AppSearchBar
              AppSearchBar(
                controller: _searchController,
                hintText: 'Cari posisi atau perusahaan...',
                onChanged: (value) => setState(() {}),
                onClear: () => setState(() {}),
                hasActiveFilters: hasActiveFilters,
                onFilterReset:
                    hasActiveFilters
                        ? () {
                          _searchController.clear();
                          setState(() {});
                        }
                        : null,
                margin: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              // Note Section (Optional, similar to education page)
              _buildNoteSection(theme),
              const SizedBox(height: 20),

              // Add Work History Button
              _buildAddWorkHistoryButton(theme),
              const SizedBox(height: 20),

              // Work History Data Table
              _buildWorkHistoryTable(theme, filteredData),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
                  child: Text(
                    'SIMPAN',
                    style: theme.typographyRegular.bodyMedium.copyWith(
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
                  'Wajib menambahkan Riwayat Pekerjaan Terakhir',
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

  Widget _buildAddWorkHistoryButton(dynamic theme) {
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
                'Tambah Riwayat Pekerjaan',
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
              onPressed: _addWorkHistory,
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
                'TAMBAH RIWAYAT PEKERJAAN',
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

  Widget _buildWorkHistoryTable(
    dynamic theme,
    List<Map<String, String>> workHistoryData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  Icons.business_center, // Icon for work history
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Riwayat Pekerjaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              // Only show data count if there is data
              if (workHistoryData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${workHistoryData.length} data',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Show data cards or empty state
          if (workHistoryData.isEmpty)
            _buildEmptyState(theme)
          else
            Column(
              children: [
                for (final work in workHistoryData) _buildWorkCard(theme, work),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data riwayat pekerjaan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan riwayat pekerjaan dengan menekan tombol di atas',
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

  // Small rounded "pill" chip used in cards
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

  Widget _buildWorkCard(dynamic theme, Map<String, String> work) {
    final stripeColor = theme.primarySwatch;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stripeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.business_center, color: stripeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work['position'] ?? '',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      work['company'] ?? '',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.business,
                label: work['company'] ?? '',
                theme: theme,
              ),
              _pillChip(
                icon: Icons.calendar_today,
                label: '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}',
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: Icon(Icons.edit, color: theme.primarySwatch),
                onPressed: () => _editWorkHistory(work),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteWorkHistory(work),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addWorkHistory() async {
    print('=== ADD WORK HISTORY BUTTON PRESSED ===');
    print('Current _workHistoryData before add: $_workHistoryData');
    print(
      'Current _workHistoryData.length before add: ${_workHistoryData.length}',
    );

    try {
      // Navigate to add form and wait for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddWorkHistoryPage()),
      );

      print('=== NAVIGATION RETURNED ===');
      print('Navigation result: $result');
      print('Result type: ${result.runtimeType}');

      if (!mounted) {
        print('Widget not mounted after navigation - returning');
        return;
      }

      // If result contains new data, add it to local list
      if (result is Map && result['action'] == 'add' && result['data'] is Map) {
        final newData = Map<String, String>.from(result['data'] as Map);
        print('=== PROCESSING NEW DATA ===');
        print('New data received: $newData');
        print(
          '_workHistoryData BEFORE add: $_workHistoryData (${_workHistoryData.length} items)',
        );

        // Add data and update state
        _workHistoryData.add(newData);
        _originalData = _getCurrentData();

        // IMPORTANT: Trigger setState to rebuild UI
        setState(() {
          _dataLoaded = true; // Mark as loaded to prevent reload
          _freshLoginProcessed =
              true; // Prevent fresh login reset after adding data
        });

        print('=== AFTER ADD AND SETSTATE ===');
        print(
          '_workHistoryData AFTER add: $_workHistoryData (${_workHistoryData.length} items)',
        );
        print('All items in _workHistoryData:');
        for (int i = 0; i < _workHistoryData.length; i++) {
          final item = _workHistoryData[i];
          print('  [$i]: ${item}');
          print('    - ID: ${item['id']}');
          print('    - Position: ${item['position']}');
          print('    - Company: ${item['company']}');
          print('    - Start Year: ${item['startYear']}');
          print('    - End Year: ${item['endYear']}');
          print('    - isDummy: ${item['isDummy']}');
        }

        // CRITICAL: Save temporary data to storage immediately for profile page display
        // This ensures profile page can show all entries even before user clicks "Save"
        // DON'T set user_saved flag (false) since this is temporary save
        await _saveWorkHistoryDataToStorage(_workHistoryData, false);

        // Set flag untuk indicate ada perubahan baru (tapi belum user-saved)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('work_history_has_changes', true);
        // DON'T set work_history_user_saved = true yet (only when user clicks Save button)

        print('Saved temporary data to storage for profile page display');
        print(
          'Set work_history_has_changes = true (new data added, but user hasnt clicked Save yet)',
        );

        // CRITICAL: Update provider untuk profile page display
        // Since profile page will load from SharedPreferences storage,
        // we just need to update provider with latest entry for immediate display
        final riwayatPekerjaanData = RiwayatPekerjaanData(
          namaPerusahaan: newData['company'] ?? '',
          posisi: newData['position'] ?? '',
          tahunMulai: newData['startYear'] ?? '',
          tahunSelesai: newData['endYear'] ?? '',
          deskripsiTugas: '',
        );
        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(riwayatPekerjaanData);
        print('=== UPDATED PROVIDER FOR PROFILE DISPLAY ===');
        print(
          'Provider updated with LATEST entry: ${newData['company']} - ${newData['position']}',
        );
        print(
          'Note: Profile page will load ALL entries from SharedPreferences storage',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil ditambahkan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('=== INVALID RESULT FROM NAVIGATION ===');
        print('Result is not valid format: $result');
      }
    } catch (e) {
      print('=== ERROR IN ADD WORK HISTORY ===');
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void _editWorkHistory(Map<String, String> work) async {
    print('=== EDIT WORK HISTORY BUTTON PRESSED ===');
    print('Editing work: $work');

    try {
      // Navigate to edit page, passing the data
      final result = await context.push('/edit-riwayat-pekerjaan', extra: work);
      if (!mounted) return;

      print('Edit navigation result: $result');

      if (result is Map &&
          result['action'] == 'edit' &&
          result['data'] is Map) {
        final updated = Map<String, String>.from(result['data'] as Map);
        setState(() {
          final idx = _workHistoryData.indexWhere(
            (e) => e['id'] == updated['id'],
          );
          if (idx != -1) _workHistoryData[idx] = updated;
        });

        // CRITICAL: Save temporary data to storage immediately for profile page display
        // This ensures profile page can show all entries even after edit
        await _saveWorkHistoryDataToStorage(_workHistoryData, false);

        // Update provider untuk profile page display dengan entry terakhir
        final riwayatPekerjaanData = RiwayatPekerjaanData(
          namaPerusahaan: updated['company'] ?? '',
          posisi: updated['position'] ?? '',
          tahunMulai: updated['startYear'] ?? '',
          tahunSelesai: updated['endYear'] ?? '',
          deskripsiTugas: '',
        );
        ref
            .read(riwayatPekerjaanDataProvider.notifier)
            .updateData(riwayatPekerjaanData);
        print(
          'Updated RiwayatPekerjaanDataProvider with edited work entry: ${updated['company']} - ${updated['position']}',
        );

        // Set flag untuk indicate ada perubahan yang perlu ditampilkan
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('work_history_has_changes', true);
        print('Set work_history_has_changes = true (data edited)');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error navigating to edit work history: $e');

      // If navigation fails, simulate edit with updated data
      final updatedWork = Map<String, String>.from(work);
      updatedWork['position'] = '${work['position']} (Updated)';
      updatedWork['company'] = '${work['company']} (Updated)';

      setState(() {
        final idx = _workHistoryData.indexWhere((e) => e['id'] == work['id']);
        if (idx != -1) _workHistoryData[idx] = updatedWork;
      });

      // JANGAN save ke storage dulu - biarkan user menekan "Simpan Data" terlebih dahulu
      // await _saveWorkHistoryDataToStorage();

      // Set flag untuk indicate ada perubahan yang perlu ditampilkan sebagai "Edited"
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('work_history_has_changes', true);
      print('Set work_history_has_changes = true (simulated data edited)');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data riwayat pekerjaan berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      print('Simulated edit for work history: $updatedWork');
    }
  }

  void _deleteWorkHistory(Map<String, String> work) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data Riwayat Pekerjaan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${work['position']} - ${work['company']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    setState(() {
                      _workHistoryData.removeWhere(
                        (e) => e['id'] == work['id'],
                      );
                    });

                    // CRITICAL: Save temporary data to storage immediately for profile page display
                    // This ensures profile page reflects the deletion
                    await _saveWorkHistoryDataToStorage(
                      _workHistoryData,
                      false,
                    );

                    // Set flag untuk indicate ada perubahan yang perlu ditampilkan
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('work_history_has_changes', true);
                    print('Set work_history_has_changes = true (data deleted)');
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data ${work['position']} berhasil dihapus',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
}
