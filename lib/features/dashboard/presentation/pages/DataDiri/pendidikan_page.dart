import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
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
      await prefs.remove('education_data');
      await prefs.remove('pendidikan_user_saved');
      await prefs.remove('pendidikan_has_changes');
      await prefs.remove('pendidikan_just_saved');
      await prefs.setStringList('education_data', []);

      setState(() {
        _educationData.clear();
        _originalData.clear();
        _dataLoaded = true;
      });

      ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
      ref.read(profileCompletionProvider.notifier).markIncomplete('pendidikan');
      await prefs.setBool('is_logged_out', false);
      debugPrint('PendidikanPage: Initialized with logout - cleared education data');
      return;
    }

    await _loadEducationData();
  }

  Future<void> _loadEducationData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEducationData = prefs.getStringList('education_data') ?? [];
    final hasEducationUserSaved = prefs.getBool('pendidikan_user_saved') ?? false;

    debugPrint('PendidikanPage: Loading data - hasEducationUserSaved=$hasEducationUserSaved, savedEducationData=$savedEducationData');

    if (!hasEducationUserSaved && savedEducationData.isEmpty) {
      await prefs.remove('pendidikan_has_changes');
      await prefs.remove('pendidikan_just_saved');
      setState(() {
        _educationData = [];
        _dataLoaded = true;
      });
      ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
      ref.read(profileCompletionProvider.notifier).markIncomplete('pendidikan');
      debugPrint('PendidikanPage: No saved data, resetting provider');
      return;
    }

    _educationData.clear();
    if (savedEducationData.isNotEmpty) {
      for (String jsonStr in savedEducationData) {
        try {
          final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
          final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
          _educationData.add(educationMap);
        } catch (e) {
          debugPrint('PendidikanPage: Error parsing education data: $e');
        }
      }
    }

    _updateProviderFromEducationData();
    _originalData = _getCurrentData();
    setState(() => _dataLoaded = true);
    debugPrint('PendidikanPage: Loaded education data: $_educationData');
  }

  void _updateProviderFromEducationData() {
    if (_educationData.isNotEmpty) {
      final latestEducation = _educationData.last;
      final pendidikanData = PendidikanData(
        tingkatPendidikan: latestEducation['jenjang'] ?? '',
        namaInstitusi: latestEducation['institusi'] ?? '',
        jurusan: latestEducation['jurusan'] ?? '',
        tahunLulus: latestEducation['tahun_selesai'] ?? '',
        ipk: latestEducation['ipk'] ?? '',
      );
      ref.read(pendidikanDataProvider.notifier).updateData(pendidikanData);
      ref.read(profileCompletionProvider.notifier).markCompleted('pendidikan');
      debugPrint('PendidikanPage: Updated provider with latest education: $latestEducation');
    } else {
      ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
      ref.read(profileCompletionProvider.notifier).markIncomplete('pendidikan');
      debugPrint('PendidikanPage: No education data, resetting provider');
    }
  }

  Future<void> _saveEducationDataToStorage([List<Map<String, String>>? dataToSave]) async {
    final dataForSaving = dataToSave ?? _educationData;
    final prefs = await SharedPreferences.getInstance();
    final educationJsonList = dataForSaving.map((education) => jsonEncode(education)).toList();
    await prefs.setStringList('education_data', educationJsonList);
    await prefs.setBool('pendidikan_user_saved', dataForSaving.isNotEmpty);
    await prefs.setBool('pendidikan_just_saved', true);
    await prefs.setBool('pendidikan_has_changes', false);
    debugPrint('PendidikanPage: Saved education data: $educationJsonList, pendidikan_user_saved=${dataForSaving.isNotEmpty}');
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'educationCount': _educationData.length,
      'educationData': List<Map<String, String>>.from(_educationData),
    };
  }

  bool _hasUnsavedChanges() {
    final currentData = _getCurrentData();
    final originalCount = _originalData['educationCount'] as int? ?? 0;
    final currentCount = currentData['educationCount'] as int;
    if (originalCount != currentCount) {
      debugPrint('PendidikanPage: Unsaved changes detected - count mismatch (original: $originalCount, current: $currentCount)');
      return true;
    }

    final originalList = List<Map<String, String>>.from(_originalData['educationData'] ?? []);
    final currentList = List<Map<String, String>>.from(currentData['educationData']);
    if (originalList.length != currentList.length) {
      debugPrint('PendidikanPage: Unsaved changes detected - list length mismatch (original: ${originalList.length}, current: ${currentList.length})');
      return true;
    }

    for (int i = 0; i < originalList.length; i++) {
      if (originalList[i].toString() != currentList[i].toString()) {
        debugPrint('PendidikanPage: Unsaved changes detected - data mismatch at index $i');
        return true;
      }
    }
    debugPrint('PendidikanPage: No unsaved changes');
    return false;
  }

  Future<void> _restoreDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEducationData = prefs.getStringList('education_data') ?? [];

    _educationData.clear();
    if (savedEducationData.isNotEmpty) {
      for (String jsonStr in savedEducationData) {
        try {
          final Map<String, dynamic> educationMapDynamic = jsonDecode(jsonStr);
          final Map<String, String> educationMap = educationMapDynamic.map((key, value) => MapEntry(key, value.toString()));
          _educationData.add(educationMap);
        } catch (e) {
          debugPrint('PendidikanPage: Error restoring education data: $e');
        }
      }
    }

    await prefs.setBool('pendidikan_has_changes', false);
    _updateProviderFromEducationData();
    _originalData = _getCurrentData();
    setState(() {});
    debugPrint('PendidikanPage: Restored education data: $_educationData');
  }

  Future<void> _addEducation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahDataPendidikanPage()),
    );

    if (!mounted || result == null || result is! Map || result['action'] != 'add' || result['data'] is! Map) return;

    final newEducation = Map<String, String>.from(result['data'] as Map);

    setState(() {
      _educationData.add(newEducation);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pendidikan_has_changes', true);
    _updateProviderFromEducationData();

    if (mounted) {
      notification.NotificationUtils.showSuccess(
        context,
        'Data pendidikan berhasil ditambahkan',
      );
    }
    debugPrint('PendidikanPage: Added new education: $newEducation');
  }

  Future<void> _editEducation(Map<String, String> education) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDataPendidikanPage(educationToEdit: education)),
    );

    if (!mounted || result == null || result is! Map || result['action'] != 'edit' || result['data'] is! Map) return;

    final updatedEducation = Map<String, String>.from(result['data']);
    final idx = _educationData.indexWhere((e) => e['id'] == updatedEducation['id']);
    if (idx != -1) {
      setState(() {
        _educationData[idx] = updatedEducation;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pendidikan_has_changes', true);
      _updateProviderFromEducationData();

      if (mounted) {
        notification.NotificationUtils.showSuccess(
          context,
          'Data pendidikan berhasil diperbarui',
        );
      }
      debugPrint('PendidikanPage: Updated education: $updatedEducation');
    }
  }

  Future<void> _deleteEducation(Map<String, String> education) async {
    final confirmed = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Data Pendidikan',
      message: 'Apakah Anda yakin ingin menghapus data ${education['jenjang'] ?? education['tingkat'] ?? 'pendidikan'} - ${education['jurusan'] ?? education['institusi'] ?? 'unknown'}?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _educationData.removeWhere((e) => e['id'] == education['id']);
        });
        _saveEducationDataToStorage();
        _updateProviderFromEducationData();
        if (mounted) {
          notification.NotificationUtils.showSuccess(
            context,
            'Data pendidikan telah dihapus',
          );
        }
        final prefs = SharedPreferences.getInstance();
        prefs.then((p) => p.setBool('pendidikan_has_changes', true));
        debugPrint('PendidikanPage: Deleted education: ${education['id']}');
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
      await _saveEducationDataToStorage();
      _updateProviderFromEducationData();
      _originalData = _getCurrentData();

      if (mounted) {
        await ProfileCompletionNotifierCard.show(
          context,
          title: 'Berhasil Menyimpan Data Pendidikan',
          message: 'Data pendidikan Anda telah diperbarui dan tersimpan dengan sukses.',
          onConfirm: () {
            if (mounted) {
              notification.NotificationUtils.showSuccess(
                context,
                'Data pendidikan telah disimpan',
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
      debugPrint('PendidikanPage: Error saving data: $e');
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
          title: 'Batalkan Perubahan Pendidikan',
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
                'Perubahan pada data pendidikan telah dibatalkan',
              );
              context.pop(true);
            }
          },
          onCancel: () => context.mounted ? context.pop(false) : null,
        ) ??
        false;
  }

  List<Map<String, String>> _getCombinedEducationData() {
    return List<Map<String, String>>.from(_educationData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final educationData = _getCombinedEducationData();

    final filteredData = educationData.where((e) {
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) return true;
      return (e['jenjang'] ?? '').toLowerCase().contains(searchTerm) ||
          (e['jurusan'] ?? '').toLowerCase().contains(searchTerm) ||
          (e['institusi'] ?? '').toLowerCase().contains(searchTerm) ||
          (e['kota'] ?? '').toLowerCase().contains(searchTerm);
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
        backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Pendidikan',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
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
                hintText: 'Cari jenjang, jurusan, institusi...',
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
                  onPressed:
                      _isSaving
                          ? null
                          : () {
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
                  child:
                      _isSaving
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MENYIMPAN...',
                                style: theme.typographyRegular.bodyMedium
                                    .copyWith(
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
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

  Widget _buildEducationCards(dynamic theme, List<Map<String, String>> educationData, bool isTablet) {
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: theme.primarySwatch, size: 16),
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
            Column(children: educationData.map((e) => _buildEducationCard(theme, e)).toList()),
        ],
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

  Widget _buildEducationCard(dynamic theme, Map<String, String> e) {
    final jenjang = (e['jenjang'] ?? '').trim();
    final jurusan = (e['jurusan'] ?? '').trim();
    final institusi = (e['institusi'] ?? '').trim();
    final kota = (e['kota'] ?? '').trim();
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
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                      style: theme.typographyRegular.bodySmall.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(icon: Icons.location_on, label: kota.isEmpty ? '-' : kota, theme: theme),
              _pillChip(icon: Icons.calendar_today, label: tahun, theme: theme),
            ],
          ),
          const SizedBox(height: 12),
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
}
