import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'providers/profile_data_provider.dart';
import 'riwayatPekerjaan/add_data_pekerjaan_pages.dart';
import 'riwayatPekerjaan/edit_data_pekerjaan_page.dart'; // Asumsi ada halaman edit

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

final workHistoryDataProvider = StateProvider<List<WorkHistoryData>>((ref) => []);

class WorkHistoryPage extends ConsumerStatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  ConsumerState<WorkHistoryPage> createState() => _WorkHistoryPageState();
}

class _WorkHistoryPageState extends ConsumerState<WorkHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _workHistoryData = [];
  Map<String, dynamic> _originalData = {};
  bool _dataLoaded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedOut = prefs.getBool('is_logged_out') ?? false;

    if (isLoggedOut) {
      await prefs.remove('work_history_data');
      await prefs.remove('work_history_user_saved');
      await prefs.remove('work_history_has_changes');
      await prefs.remove('work_history_just_saved');
      await prefs.setStringList('work_history_data', []);

      setState(() {
        _workHistoryData.clear();
        _originalData.clear();
        _dataLoaded = true;
      });

      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
      ref.read(workHistoryDataProvider.notifier).state = [];
      ref.read(profileCompletionProvider.notifier).markIncomplete('riwayatPekerjaan');
      debugPrint('WorkHistoryPage: Initialized with logout - cleared work history data');
      return;
    }

    await _loadWorkHistoryData();
  }

  Future<void> _loadWorkHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWorkHistoryData = prefs.getStringList('work_history_data') ?? [];
    final hasWorkHistoryUserSaved = prefs.getBool('work_history_user_saved') ?? false;

    debugPrint('WorkHistoryPage: Loading data - hasWorkHistoryUserSaved=$hasWorkHistoryUserSaved, savedWorkHistoryData=$savedWorkHistoryData');

    if (!hasWorkHistoryUserSaved && savedWorkHistoryData.isEmpty) {
      await prefs.remove('work_history_has_changes');
      await prefs.remove('work_history_just_saved');
      setState(() {
        _workHistoryData = [];
        _dataLoaded = true;
      });
      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
      ref.read(workHistoryDataProvider.notifier).state = [];
      ref.read(profileCompletionProvider.notifier).markIncomplete('riwayatPekerjaan');
      debugPrint('WorkHistoryPage: No saved data, resetting provider');
      return;
    }

    _workHistoryData.clear();
    if (savedWorkHistoryData.isNotEmpty) {
      for (String jsonStr in savedWorkHistoryData) {
        try {
          final Map<String, dynamic> workMapDynamic = jsonDecode(jsonStr);
          final Map<String, String> workMap = workMapDynamic.map((key, value) => MapEntry(key, value.toString()));
          if (workMap['isDummy'] != 'true' && !(workMap['id']?.startsWith('dummy') ?? false)) {
            _workHistoryData.add(workMap);
          }
        } catch (e) {
          debugPrint('WorkHistoryPage: Error parsing work history data: $e');
        }
      }
    }

    _updateProviderFromWorkHistoryData();
    _originalData = _getCurrentData();
    setState(() => _dataLoaded = true);
    debugPrint('WorkHistoryPage: Loaded work history data: $_workHistoryData');
  }

  void _updateProviderFromWorkHistoryData() {
    if (_workHistoryData.isNotEmpty) {
      final latestWork = _workHistoryData.last;
      final riwayatPekerjaanData = RiwayatPekerjaanData(
        namaPerusahaan: latestWork['company'] ?? '',
        posisi: latestWork['position'] ?? '',
        tahunMulai: latestWork['startYear'] ?? '',
        tahunSelesai: latestWork['endYear'] ?? '',
        deskripsiTugas: '',
      );
      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(riwayatPekerjaanData);
      ref.read(workHistoryDataProvider.notifier).state = _workHistoryData
          .map((work) => WorkHistoryData(
                id: work['id'] ?? '',
                position: work['position'] ?? '',
                company: work['company'] ?? '',
                startYear: work['startYear'] ?? '',
                endYear: work['endYear'] ?? '',
              ))
          .toList();
      ref.read(profileCompletionProvider.notifier).markCompleted('riwayatPekerjaan');
      debugPrint('WorkHistoryPage: Updated provider with latest work: $latestWork');
    } else {
      ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
      ref.read(workHistoryDataProvider.notifier).state = [];
      ref.read(profileCompletionProvider.notifier).markIncomplete('riwayatPekerjaan');
      debugPrint('WorkHistoryPage: No work history data, resetting provider');
    }
  }

  Future<void> _saveWorkHistoryDataToStorage([List<Map<String, String>>? dataToSave]) async {
    final dataForSaving = dataToSave ?? _workHistoryData;
    final prefs = await SharedPreferences.getInstance();
    final workHistoryJsonList = dataForSaving.map((work) => jsonEncode(work)).toList();
    await prefs.setStringList('work_history_data', workHistoryJsonList);
    await prefs.setBool('work_history_user_saved', dataForSaving.isNotEmpty);
    await prefs.setBool('work_history_just_saved', true);
    await prefs.setBool('work_history_has_changes', false);
    debugPrint('WorkHistoryPage: Saved work history data: $workHistoryJsonList, work_history_user_saved=${dataForSaving.isNotEmpty}');
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'workHistoryCount': _workHistoryData.length,
      'workHistoryData': List<Map<String, String>>.from(_workHistoryData),
    };
  }

  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    final originalCount = _originalData['workHistoryCount'] as int? ?? 0;
    final currentCount = currentData['workHistoryCount'] as int;
    if (originalCount != currentCount) {
      debugPrint('WorkHistoryPage: Unsaved changes detected - count mismatch (original: $originalCount, current: $currentCount)');
      return true;
    }

    final originalList = List<Map<String, String>>.from(_originalData['workHistoryData'] ?? []);
    final currentList = List<Map<String, String>>.from(currentData['workHistoryData']);
    if (originalList.length != currentList.length) {
      debugPrint('WorkHistoryPage: Unsaved changes detected - list length mismatch (original: ${originalList.length}, current: ${currentList.length})');
      return true;
    }

    for (int i = 0; i < originalList.length; i++) {
      if (originalList[i].toString() != currentList[i].toString()) {
        debugPrint('WorkHistoryPage: Unsaved changes detected - data mismatch at index $i');
        return true;
      }
    }
    debugPrint('WorkHistoryPage: No unsaved changes');
    return false;
  }

  Future<void> _restoreDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWorkHistoryData = prefs.getStringList('work_history_data') ?? [];

    _workHistoryData.clear();
    if (savedWorkHistoryData.isNotEmpty) {
      for (String jsonStr in savedWorkHistoryData) {
        try {
          final Map<String, dynamic> workMapDynamic = jsonDecode(jsonStr);
          final Map<String, String> workMap = workMapDynamic.map((key, value) => MapEntry(key, value.toString()));
          if (workMap['isDummy'] != 'true' && !(workMap['id']?.startsWith('dummy') ?? false)) {
            _workHistoryData.add(workMap);
          }
        } catch (e) {
          debugPrint('WorkHistoryPage: Error restoring work history data: $e');
        }
      }
    }

    await prefs.setBool('work_history_has_changes', false);
    _updateProviderFromWorkHistoryData();
    _originalData = _getCurrentData();
    setState(() {});
    debugPrint('WorkHistoryPage: Restored work history data: $_workHistoryData');
  }

  Future<void> _addWorkHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWorkHistoryPage()),
    );

    if (!mounted || result == null || result is! Map || result['action'] != 'add' || result['data'] is! Map) return;

    final newWork = Map<String, String>.from(result['data'] as Map);

    setState(() {
      _workHistoryData.add(newWork);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('work_history_has_changes', true);
    _updateProviderFromWorkHistoryData();

    if (mounted) {
      notification.NotificationUtils.showSuccess(
        context,
        'Data riwayat pekerjaan berhasil ditambahkan',
      );
    }
    debugPrint('WorkHistoryPage: Added new work history: $newWork');
  }

  Future<void> _editWorkHistory(Map<String, String> work) async {
    final result = await context.push('/edit-riwayat-pekerjaan', extra: work);

    if (!mounted || result == null || result is! Map || result['action'] != 'edit' || result['data'] is! Map) return;

    final updatedWork = Map<String, String>.from(result['data']);
    final idx = _workHistoryData.indexWhere((e) => e['id'] == updatedWork['id']);
    if (idx != -1) {
      setState(() {
        _workHistoryData[idx] = updatedWork;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('work_history_has_changes', true);
      _updateProviderFromWorkHistoryData();

      if (mounted) {
        notification.NotificationUtils.showSuccess(
          context,
          'Data riwayat pekerjaan berhasil diperbarui',
        );
      }
      debugPrint('WorkHistoryPage: Updated work history: $updatedWork');
    }
  }

  Future<void> _deleteWorkHistory(Map<String, String> work) async {
    final confirmed = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Data Riwayat Pekerjaan',
      message: 'Apakah Anda yakin ingin menghapus data ${work['position']} - ${work['company']}?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _workHistoryData.removeWhere((e) => e['id'] == work['id']);
        });
        _saveWorkHistoryDataToStorage();
        _updateProviderFromWorkHistoryData();
        if (mounted) {
          notification.NotificationUtils.showSuccess(
            context,
            'Data riwayat pekerjaan telah dihapus',
          );
        }
        final prefs = SharedPreferences.getInstance();
        prefs.then((p) => p.setBool('work_history_has_changes', true));
        debugPrint('WorkHistoryPage: Deleted work history: ${work['id']}');
      },
      onCancel: () {},
    );
  }

  Future<void> _saveData(BuildContext context, dynamic theme) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _saveWorkHistoryDataToStorage();
      _updateProviderFromWorkHistoryData();
      _originalData = _getCurrentData();

      if (mounted) {
        await ProfileCompletionNotifierCard.show(
          context,
          title: 'Berhasil Menyimpan Data Riwayat Pekerjaan',
          message: 'Data riwayat pekerjaan Anda telah diperbarui dan tersimpan dengan sukses.',
          onConfirm: () {
            if (mounted) {
              notification.NotificationUtils.showSuccess(
                context,
                'Data riwayat pekerjaan telah disimpan',
              );
              context.pop('saved');
            }
          },
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green[600],
        );
      }
    } catch (e) {
      if (mounted) {
        notification.NotificationUtils.showError(
          context,
          'Gagal menyimpan data: $e',
        );
      }
      debugPrint('WorkHistoryPage: Error saving data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);
    return await SIHAKIConfirmationDialog.show(
          context,
          title: 'Batalkan Perubahan Riwayat Pekerjaan',
          message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
          confirmText: 'Batalkan',
          cancelText: 'Batal',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.red[600]!,
          isDestructive: true,
          onConfirm: () {
            if (mounted) {
              notification.NotificationUtils.showWarning(
                context,
                'Perubahan pada data riwayat pekerjaan telah dibatalkan',
              );
              context.pop(true);
            }
          },
          onCancel: () => context.mounted ? context.pop(false) : null,
        ) ??
        false;
  }

  List<Map<String, String>> _getCombinedWorkHistoryData() {
    return List<Map<String, String>>.from(_workHistoryData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final workHistoryData = _getCombinedWorkHistoryData();

    final filteredData = workHistoryData.where((work) {
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) return true;
      return (work['position']?.toLowerCase().contains(searchTerm) ?? false) ||
          (work['company']?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();

    final hasActiveFilters = _searchController.text.trim().isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasUnsavedChanges()) {
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave && context.mounted) {
            await _restoreDataFromStorage();
            context.pop();
          }
        } else if (context.mounted) {
          context.pop();
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
                if (shouldLeave && context.mounted) {
                  await _restoreDataFromStorage();
                  context.pop();
                }
              } else if (context.mounted) {
                context.pop();
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
              AppFilterBar(
                controller: _searchController,
                labelText: 'Pencarian Riwayat Pekerjaan',
                hintText: 'Cari berdasarkan posisi atau perusahaan...',
                onChanged: (value) => setState(() {}),
                onClear: () => setState(() => _searchController.clear()),
                headerTitle: 'Pencarian',
                hasActiveFilters: hasActiveFilters,
                onReset: hasActiveFilters ? () => setState(() => _searchController.clear()) : null,
              ),
              const SizedBox(height: 20),
              _buildNoteSection(theme),
              const SizedBox(height: 20),
              _buildAddWorkHistoryButton(theme),
              const SizedBox(height: 20),
              _buildWorkHistoryTable(theme, filteredData),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveData(context, theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasUnsavedChanges() ? theme.primarySwatch : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
              const SizedBox(height: 20),
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
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                  gradient: LinearGradient(colors: [theme.primarySwatch, theme.secondarySwatch]),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: const Icon(Icons.add_circle, color: Colors.white, size: 20),
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
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

  Widget _buildWorkHistoryTable(dynamic theme, List<Map<String, String>> workHistoryData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primarySwatch, theme.secondarySwatch]),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: const Icon(Icons.business_center, color: Colors.white, size: 20),
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
              if (workHistoryData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business_center_outlined, color: theme.primarySwatch, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${workHistoryData.length} data',
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
          if (workHistoryData.isEmpty)
            _buildEmptyState(theme)
          else
            Column(children: workHistoryData.map((work) => _buildWorkCard(theme, work)).toList()),
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
            Icon(Icons.business_center_outlined, size: 80, color: Colors.grey[400]),
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
              style: theme.typographyRegular.bodySmall.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillChip({required IconData icon, required String label, required dynamic theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
    final position = (work['position'] ?? '').trim();
    final company = (work['company'] ?? '').trim();
    final years = '${work['startYear'] ?? ''} - ${work['endYear'] ?? ''}';

    return AppCard(
      leftAccentColor: stripeColor,
      gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stripeColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Icon(Icons.business_center, color: stripeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.isEmpty ? '-' : position,
                      style: theme.typographyBold.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.isEmpty ? '-' : company,
                      style: theme.typographyRegular.bodySmall.copyWith(color: Colors.grey[600]),
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
              _pillChip(icon: Icons.business, label: company.isEmpty ? '-' : company, theme: theme),
              _pillChip(icon: Icons.calendar_today, label: years.isEmpty ? '-' : years, theme: theme),
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
}