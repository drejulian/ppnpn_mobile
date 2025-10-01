import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/nav_bar.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataDiri/providers/profile_data_provider.dart';
import 'dart:io';
import 'dart:convert';

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
  ConsumerState<ProfileSectionsPage> createState() => _ProfileSectionsPageState();
}

class _ProfileSectionsPageState extends ConsumerState<ProfileSectionsPage> {
  final Set<String> _editedSections = {};
  final Set<String> _completedSections = {};
  bool _hasUnsavedChanges = false;
  bool _isProcessingImmediateFlagDetection = false;
  final Map<String, Object> _originalData = {};
  late final _AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = _AppLifecycleObserver(onResume: _handleAppResume);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      await _loadCompletionStatus();
      _saveOriginalData();
      _validateIdCardData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  Future<void> _handleAppResume() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedOut = prefs.getBool('is_logged_out') ?? false;

    if (!isLoggedOut) {
      await _loadCompletionStatus();
      return;
    }

    await _clearSharedPreferences(prefs);
    _resetProviders();
    await prefs.setBool('is_logged_out', false);

    if (mounted) {
      setState(() {
        _editedSections.clear();
        _completedSections.clear();
        _hasUnsavedChanges = false;
      });
    }

    await _loadCompletionStatus();
  }

  Future<void> _clearSharedPreferences(SharedPreferences prefs) async {
    await Future.wait([
      prefs.remove('education_has_changes'),
      prefs.remove('education_just_saved'),
      prefs.remove('pendidikan_user_saved'),
      prefs.remove('education_data'),
      prefs.remove('work_history_has_changes'),
      prefs.remove('work_history_just_saved'),
      prefs.remove('work_history_user_saved'),
      prefs.remove('work_history_data'),
      prefs.remove('family_has_changes'),
      prefs.remove('family_just_saved'),
      prefs.remove('family_user_saved'),
      prefs.remove('family_data'),
      prefs.remove('_temp_skip_work_history_processing'),
      prefs.remove('honorarium_has_changes'),
      prefs.remove('honorarium_just_saved'),
      prefs.remove('honorarium_user_saved'),
      prefs.remove('edit_profile_has_changes'),
      prefs.remove('edit_profile_just_saved'),
      prefs.remove('edit_profile_user_saved'),
      prefs.remove('pribadi_has_changes'),
      prefs.remove('pribadi_just_saved'),
      prefs.remove('pribadi_user_saved'),
      prefs.remove('pas_foto_has_changes'),
      prefs.remove('pas_foto_just_saved'),
      prefs.remove('pas_foto_user_saved'),
      prefs.remove('dokumen_has_changes'),
      prefs.remove('dokumen_just_saved'),
      prefs.remove('dokumen_user_saved'),
      prefs.remove('data_lamaran_has_changes'),
      prefs.remove('data_lamaran_just_saved'),
      prefs.remove('data_lamaran_user_saved'),
      prefs.remove('riwayat_pekerjaan_has_changes'),
      prefs.remove('riwayat_pekerjaan_just_saved'),
      prefs.remove('riwayat_pekerjaan_user_saved'),
    ]);
  }

  void _resetProviders() {
    final completionNotifier = ref.read(profileCompletionProvider.notifier);
    const sections = [
      'editProfile',
      'identitasDiri',
      'honorarium',
      'keluarga',
      'pasFoto',
      'dokumen',
      'pendidikan',
      'riwayatPekerjaan',
      'dataLamaran'
    ];
    for (var section in sections) {
      completionNotifier.markIncomplete(section);
    }
    ref.read(editProfileDataProvider.notifier).updateData(EditProfileData());
    ref.read(pribadiDataProvider.notifier).updateData(PribadiData());
    ref.read(honorariumDataProvider.notifier).updateData(HonorariumData());
    ref.read(keluargaDataProvider.notifier).updateData(KeluargaData());
    ref.read(dokumenDataProvider.notifier).updateData(DokumenData());
    ref.read(pendidikanDataProvider.notifier).updateData(PendidikanData());
    ref.read(riwayatPekerjaanDataProvider.notifier).updateData(RiwayatPekerjaanData());
    ref.read(dataLamaranDataProvider.notifier).updateData(DataLamaranData());
    ref.read(idCardDataProvider.notifier).updateData(IdCardData(fotoPath: '', isUploaded: false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(pendidikanDataProvider);
    _loadCompletionStatus();
  }

  void _validateIdCardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final idCardData = ref.read(idCardDataProvider);
      if (idCardData.fotoPath.isNotEmpty) {
        final file = File(idCardData.fotoPath);
        if (!file.existsSync()) {
          ref.read(idCardDataProvider.notifier).updateData(IdCardData(fotoPath: '', isUploaded: false));
        }
      }
    });
  }

  void _saveOriginalData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _originalData
        ..['editProfile'] = ref.read(editProfileDataProvider)
        ..['identitasDiri'] = ref.read(pribadiDataProvider)
        ..['honorarium'] = ref.read(honorariumDataProvider)
        ..['dataLamaran'] = ref.read(dataLamaranDataProvider)
        ..['dokumen'] = ref.read(dokumenDataProvider)
        ..['keluarga'] = ref.read(keluargaDataProvider)
        ..['pendidikan'] = ref.read(pendidikanDataProvider)
        ..['riwayatPekerjaan'] = ref.read(riwayatPekerjaanDataProvider)
        ..['pasFoto'] = ref.read(idCardDataProvider);
    });
  }

  Future<void> _loadCompletionStatus() async {
    if (_isProcessingImmediateFlagDetection) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      if (isLoggedOut) return;

      final completionStatus = ref.read(profileCompletionProvider);
      final data = {
        'editProfile': ref.read(editProfileDataProvider),
        'identitasDiri': ref.read(pribadiDataProvider),
        'honorarium': ref.read(honorariumDataProvider),
        'dataLamaran': ref.read(dataLamaranDataProvider),
        'dokumen': ref.read(dokumenDataProvider),
        'keluarga': ref.read(keluargaDataProvider),
        'pendidikan': ref.read(pendidikanDataProvider),
        'riwayatPekerjaan': ref.read(riwayatPekerjaanDataProvider),
        'pasFoto': ref.read(idCardDataProvider),
      };

      final flags = {
        'Edit Profil': {
          'userSaved': prefs.getBool('edit_profile_user_saved') ?? false,
          'hasChanges': prefs.getBool('edit_profile_has_changes') ?? false,
          'justSaved': prefs.getBool('edit_profile_just_saved') ?? false,
        },
        'Identitas Diri': {
          'userSaved': prefs.getBool('pribadi_user_saved') ?? false,
          'hasChanges': prefs.getBool('pribadi_has_changes') ?? false,
          'justSaved': prefs.getBool('pribadi_just_saved') ?? false,
        },
        'Honorarium': {
          'userSaved': prefs.getBool('honorarium_user_saved') ?? false,
          'hasChanges': prefs.getBool('honorarium_has_changes') ?? false,
          'justSaved': prefs.getBool('honorarium_just_saved') ?? false,
        },
        'Keluarga': {
          'userSaved': prefs.getBool('keluarga_user_saved') ?? false,
          'hasChanges': prefs.getBool('keluarga_has_changes') ?? false,
          'justSaved': prefs.getBool('keluarga_just_saved') ?? false,
        },
        'PAS Foto': {
          'userSaved': prefs.getBool('pas_foto_user_saved') ?? false,
          'hasChanges': prefs.getBool('pas_foto_has_changes') ?? false,
          'justSaved': prefs.getBool('pas_foto_just_saved') ?? false,
        },
        'Dokumen': {
          'userSaved': prefs.getBool('dokumen_user_saved') ?? false,
          'hasChanges': prefs.getBool('dokumen_has_changes') ?? false,
          'justSaved': prefs.getBool('dokumen_just_saved') ?? false,
        },
        'Pendidikan': {
          'userSaved': prefs.getBool('pendidikan_user_saved') ?? false,
          'hasChanges': prefs.getBool('pendidikan_has_changes') ?? false,
          'justSaved': prefs.getBool('pendidikan_just_saved') ?? false,
        },
        'Riwayat Pekerjaan': {
          'userSaved': prefs.getBool('work_history_user_saved') ?? false,
          'hasChanges': prefs.getBool('work_history_has_changes') ?? false,
          'justSaved': prefs.getBool('work_history_just_saved') ?? false,
        },
        'Data Lamaran': {
          'userSaved': prefs.getBool('data_lamaran_user_saved') ?? false,
          'hasChanges': prefs.getBool('data_lamaran_has_changes') ?? false,
          'justSaved': prefs.getBool('data_lamaran_just_saved') ?? false,
        },
      };

      setState(() {
        _completedSections.clear();
        _editedSections.clear();

        for (var section in data.keys) {
          final sectionName = _getSectionNameFromKey(section);
          final sectionData = data[section]!;
          final sectionFlags = flags[sectionName] ?? {
            'userSaved': false,
            'hasChanges': false,
            'justSaved': false,
          };

          _updateSectionStatus(
            sectionName,
            sectionData,
            completionStatus,
            userSaved: sectionFlags['userSaved'] as bool,
            hasChanges: sectionFlags['hasChanges'] as bool,
            justSaved: sectionFlags['justSaved'] as bool,
          );
        }

        _hasUnsavedChanges = _editedSections.isNotEmpty;
      });

      await Future.wait([
        prefs.setBool('edit_profile_just_saved', false),
        prefs.setBool('pribadi_just_saved', false),
        prefs.setBool('honorarium_just_saved', false),
        prefs.setBool('keluarga_just_saved', false),
        prefs.setBool('pas_foto_just_saved', false),
        prefs.setBool('dokumen_just_saved', false),
        prefs.setBool('pendidikan_just_saved', false),
        prefs.setBool('work_history_just_saved', false),
        prefs.setBool('data_lamaran_just_saved', false),
      ]);
    });
  }

  Future<bool> _hasNonEmptyData(String section, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    switch (section) {
      case 'Edit Profil':
        return data.nama?.isNotEmpty == true || data.nik?.isNotEmpty == true || data.bidangKeahlian?.isNotEmpty == true || data.toefl?.isNotEmpty == true;
      case 'Identitas Diri':
        return data.tempatLahir?.isNotEmpty == true || data.email?.isNotEmpty == true || data.handphone?.isNotEmpty == true || data.address?.isNotEmpty == true;
      case 'Honorarium':
        return data.kartuKeluarga?.isNotEmpty == true || data.ktp?.isNotEmpty == true || data.rekening?.isNotEmpty == true;
      case 'Data Lamaran':
        return data.position?.isNotEmpty == true || data.placement?.isNotEmpty == true;
      case 'Dokumen':
        return data.cvUploaded == true || data.ktpUploaded == true || data.kkUploaded == true;
      case 'Keluarga':
        return data.namaAyah?.isNotEmpty == true || 
               data.namaIbu?.isNotEmpty == true || 
               data.namaPasangan?.isNotEmpty == true || 
               (data.namaAnak != null && (data.namaAnak is String ? data.namaAnak.isNotEmpty : (data.namaAnak is List ? (data.namaAnak as List).any((e) => e.isNotEmpty) : false)));
      case 'Pendidikan':
        final savedEducationData = prefs.getStringList('education_data') ?? [];
        bool hasSavedData = false;
        if (savedEducationData.isNotEmpty) {
          try {
            for (String jsonStr in savedEducationData) {
              final Map<String, dynamic> educationMap = jsonDecode(jsonStr);
              if (educationMap['jenjang']?.toString().isNotEmpty == true || educationMap['institusi']?.toString().isNotEmpty == true) {
                hasSavedData = true;
                break;
              }
            }
          } catch (e) {
            debugPrint('ProfileSectionsPage: Error parsing education_data: $e');
          }
        }
        bool hasProviderData = data.tingkatPendidikan?.isNotEmpty == true || data.namaInstitusi?.isNotEmpty == true;
        return hasSavedData || hasProviderData;
      case 'Riwayat Pekerjaan':
        final savedWorkHistoryData = prefs.getStringList('work_history_data') ?? [];
        bool hasSavedData = false;
        if (savedWorkHistoryData.isNotEmpty) {
          try {
            for (String jsonStr in savedWorkHistoryData) {
              final Map<String, dynamic> workMap = jsonDecode(jsonStr);
              if (workMap['position']?.toString().isNotEmpty == true || workMap['company']?.toString().isNotEmpty == true) {
                hasSavedData = true;
                break;
              }
            }
          } catch (e) {
            debugPrint('ProfileSectionsPage: Error parsing work_history_data: $e');
          }
        }
        bool hasProviderData = data.namaPerusahaan?.isNotEmpty == true || data.posisi?.isNotEmpty == true;
        return hasSavedData || hasProviderData;
      case 'PAS Foto':
        return data.fotoPath?.isNotEmpty == true || data.isUploaded == true;
      default:
        return false;
    }
  }

  void _updateSectionStatus(
    String sectionName,
    dynamic data,
    Map<String, dynamic> completionStatus, {
    required bool userSaved,
    required bool hasChanges,
    required bool justSaved,
  }) async {
    final sectionKey = _getSectionKeyFromName(sectionName);
    final hasNonEmptyData = await _hasNonEmptyData(sectionName, data);

    if (hasChanges || justSaved) {
      _editedSections.add(sectionName);
      ref.read(profileCompletionProvider.notifier).markIncomplete(sectionKey);
    } else if (userSaved && hasNonEmptyData) {
      _completedSections.add(sectionName);
      ref.read(profileCompletionProvider.notifier).markCompleted(sectionKey);
    } else {
      _completedSections.remove(sectionName);
      ref.read(profileCompletionProvider.notifier).markIncomplete(sectionKey);
    }
  }

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

  Future<void> _navigateToSection(String routeName, String sectionName) async {
    final completionStatus = ref.read(profileCompletionProvider);
    final wasCompleted = completionStatus[_getSectionKeyFromName(sectionName)] == true;

    final result = await context.pushNamed(routeName);
    await Future.delayed(const Duration(milliseconds: 200));
    await _checkFlagsImmediatelyAfterNavigation(sectionName);

    if (result == 'saved' || result == true) {
      setState(() {
        _editedSections.add(sectionName);
        if (wasCompleted) {
          _completedSections.add(sectionName);
        }
        _hasUnsavedChanges = _editedSections.isNotEmpty;
      });
      await _loadCompletionStatus();
    }
  }

  Future<void> _checkFlagsImmediatelyAfterNavigation(String sectionName) async {
    _isProcessingImmediateFlagDetection = true;
    final prefs = await SharedPreferences.getInstance();
    bool hasChanges = false;
    bool justSaved = false;
    bool userSaved = false;

    switch (sectionName) {
      case 'Edit Profil':
        hasChanges = prefs.getBool('edit_profile_has_changes') ?? false;
        justSaved = prefs.getBool('edit_profile_just_saved') ?? false;
        userSaved = prefs.getBool('edit_profile_user_saved') ?? false;
        break;
      case 'Identitas Diri':
        hasChanges = prefs.getBool('pribadi_has_changes') ?? false;
        justSaved = prefs.getBool('pribadi_just_saved') ?? false;
        userSaved = prefs.getBool('pribadi_user_saved') ?? false;
        break;
      case 'Honorarium':
        hasChanges = prefs.getBool('honorarium_has_changes') ?? false;
        justSaved = prefs.getBool('honorarium_just_saved') ?? false;
        userSaved = prefs.getBool('honorarium_user_saved') ?? false;
        break;
      case 'Keluarga':
        hasChanges = prefs.getBool('keluarga_has_changes') ?? false;
        justSaved = prefs.getBool('keluarga_just_saved') ?? false;
        userSaved = prefs.getBool('keluarga_user_saved') ?? false;
        break;
      case 'PAS Foto':
        hasChanges = prefs.getBool('pas_foto_has_changes') ?? false;
        justSaved = prefs.getBool('pas_foto_just_saved') ?? false;
        userSaved = prefs.getBool('pas_foto_user_saved') ?? false;
        break;
      case 'Dokumen':
        hasChanges = prefs.getBool('dokumen_has_changes') ?? false;
        justSaved = prefs.getBool('dokumen_just_saved') ?? false;
        userSaved = prefs.getBool('dokumen_user_saved') ?? false;
        break;
      case 'Pendidikan':
        hasChanges = prefs.getBool('pendidikan_has_changes') ?? false;
        justSaved = prefs.getBool('pendidikan_just_saved') ?? false;
        userSaved = prefs.getBool('pendidikan_user_saved') ?? false;
        break;
      case 'Riwayat Pekerjaan':
        hasChanges = prefs.getBool('work_history_has_changes') ?? false;
        justSaved = prefs.getBool('work_history_just_saved') ?? false;
        userSaved = prefs.getBool('work_history_user_saved') ?? false;
        break;
      case 'Data Lamaran':
        hasChanges = prefs.getBool('data_lamaran_has_changes') ?? false;
        justSaved = prefs.getBool('data_lamaran_just_saved') ?? false;
        userSaved = prefs.getBool('data_lamaran_user_saved') ?? false;
        break;
    }

    if (justSaved && mounted) {
      setState(() {
        _editedSections.add(sectionName);
        _completedSections.add(sectionName);
        _hasUnsavedChanges = _editedSections.isNotEmpty;
        ref.read(profileCompletionProvider.notifier).markCompleted(_getSectionKeyFromName(sectionName));
      });
      await prefs.setBool('${_getSectionKeyFromName(sectionName)}_just_saved', false);
      await prefs.setBool('${_getSectionKeyFromName(sectionName)}_user_saved', true);
    } else if (hasChanges && mounted) {
      setState(() {
        _editedSections.add(sectionName);
        _hasUnsavedChanges = true;
        ref.read(profileCompletionProvider.notifier).markIncomplete(_getSectionKeyFromName(sectionName));
      });
    } else if (userSaved && await _hasNonEmptyData(sectionName, ref.read(_getProviderForSection(sectionName))) && mounted) {
      setState(() {
        _completedSections.add(sectionName);
        ref.read(profileCompletionProvider.notifier).markCompleted(_getSectionKeyFromName(sectionName));
      });
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _isProcessingImmediateFlagDetection = false;
    });
  }

  dynamic _getProviderForSection(String sectionName) {
    switch (sectionName) {
      case 'Edit Profil':
        return editProfileDataProvider;
      case 'Identitas Diri':
        return pribadiDataProvider;
      case 'Honorarium':
        return honorariumDataProvider;
      case 'Data Lamaran':
        return dataLamaranDataProvider;
      case 'Dokumen':
        return dokumenDataProvider;
      case 'Keluarga':
        return keluargaDataProvider;
      case 'Pendidikan':
        return pendidikanDataProvider;
      case 'Riwayat Pekerjaan':
        return riwayatPekerjaanDataProvider;
      case 'PAS Foto':
        return idCardDataProvider;
      default:
        return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_hasUnsavedChanges) {
      setState(() {
        _completedSections.addAll(_editedSections);
        final completionNotifier = ref.read(profileCompletionProvider.notifier);
        for (var sectionName in _editedSections) {
          completionNotifier.markCompleted(_getSectionKeyFromName(sectionName));
        }
        _editedSections.clear();
        _hasUnsavedChanges = false;
      });

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        if (_completedSections.contains('Edit Profil')) ...[
          prefs.setBool('edit_profile_has_changes', false),
          prefs.setBool('edit_profile_just_saved', false),
          prefs.setBool('edit_profile_user_saved', true),
        ],
        if (_completedSections.contains('Identitas Diri')) ...[
          prefs.setBool('pribadi_has_changes', false),
          prefs.setBool('pribadi_just_saved', false),
          prefs.setBool('pribadi_user_saved', true),
        ],
        if (_completedSections.contains('Honorarium')) ...[
          prefs.setBool('honorarium_has_changes', false),
          prefs.setBool('honorarium_just_saved', false),
          prefs.setBool('honorarium_user_saved', true),
        ],
        if (_completedSections.contains('Keluarga')) ...[
          prefs.setBool('keluarga_has_changes', false),
          prefs.setBool('keluarga_just_saved', false),
          prefs.setBool('keluarga_user_saved', true),
        ],
        if (_completedSections.contains('PAS Foto')) ...[
          prefs.setBool('pas_foto_has_changes', false),
          prefs.setBool('pas_foto_just_saved', false),
          prefs.setBool('pas_foto_user_saved', true),
        ],
        if (_completedSections.contains('Dokumen')) ...[
          prefs.setBool('dokumen_has_changes', false),
          prefs.setBool('dokumen_just_saved', false),
          prefs.setBool('dokumen_user_saved', true),
        ],
        if (_completedSections.contains('Pendidikan')) ...[
          prefs.setBool('pendidikan_has_changes', false),
          prefs.setBool('pendidikan_just_saved', false),
          prefs.setBool('pendidikan_user_saved', true),
        ],
        if (_completedSections.contains('Riwayat Pekerjaan')) ...[
          prefs.setBool('work_history_has_changes', false),
          prefs.setBool('work_history_just_saved', false),
          prefs.setBool('work_history_user_saved', true),
        ],
        if (_completedSections.contains('Data Lamaran')) ...[
          prefs.setBool('data_lamaran_has_changes', false),
          prefs.setBool('data_lamaran_just_saved', false),
          prefs.setBool('data_lamaran_user_saved', true),
        ],
      ]);

      _saveOriginalData();
      NotificationUtils.showSuccess(
        context,
        'Data profil berhasil disimpan!',
        duration: const Duration(seconds: 2),
      );
    } else {
      NotificationUtils.showInfo(
        context,
        'Tidak ada perubahan untuk disimpan',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await SIHAKIConfirmationDialog.show(
          context,
          title: 'Perubahan Belum Disimpan',
          message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
          confirmText: 'Keluar',
          cancelText: 'Batal',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.red.shade600,
          isDestructive: true,
          onConfirm: () {
            if (mounted) {
              _restoreOriginalData();
              NotificationUtils.showSuccess(
                context,
                'Perubahan pada data profil telah dibatalkan',
              );
              ref.read(bottomNavIndexProvider.notifier).state = 3;
              context.go('/home');
            }
          },
          onCancel: () {
            if (mounted) {
              context.pop(false);
            }
          },
        ) ??
        false;
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await _showUnsavedChangesDialog();
    }
    ref.read(bottomNavIndexProvider.notifier).state = 3;
    context.go('/home');
    return false;
  }

  void _restoreOriginalData() {
    if (_originalData.isEmpty) return;

    final providers = {
      'editProfile': editProfileDataProvider,
      'identitasDiri': pribadiDataProvider,
      'honorarium': honorariumDataProvider,
      'dataLamaran': dataLamaranDataProvider,
      'dokumen': dokumenDataProvider,
      'keluarga': keluargaDataProvider,
      'pendidikan': pendidikanDataProvider,
      'riwayatPekerjaan': riwayatPekerjaanDataProvider,
      'pasFoto': idCardDataProvider,
    };

    for (var entry in providers.entries) {
      if (_originalData.containsKey(entry.key)) {
        switch (entry.key) {
          case 'editProfile':
            ref.read(editProfileDataProvider.notifier).updateData(_originalData[entry.key] as EditProfileData);
            break;
          case 'identitasDiri':
            ref.read(pribadiDataProvider.notifier).updateData(_originalData[entry.key] as PribadiData);
            break;
          case 'honorarium':
            ref.read(honorariumDataProvider.notifier).updateData(_originalData[entry.key] as HonorariumData);
            break;
          case 'dataLamaran':
            ref.read(dataLamaranDataProvider.notifier).updateData(_originalData[entry.key] as DataLamaranData);
            break;
          case 'dokumen':
            ref.read(dokumenDataProvider.notifier).updateData(_originalData[entry.key] as DokumenData);
            break;
          case 'keluarga':
            ref.read(keluargaDataProvider.notifier).updateData(_originalData[entry.key] as KeluargaData);
            break;
          case 'pendidikan':
            ref.read(pendidikanDataProvider.notifier).updateData(_originalData[entry.key] as PendidikanData);
            break;
          case 'riwayatPekerjaan':
            ref.read(riwayatPekerjaanDataProvider.notifier).updateData(_originalData[entry.key] as RiwayatPekerjaanData);
            break;
          case 'pasFoto':
            ref.read(idCardDataProvider.notifier).updateData(_originalData[entry.key] as IdCardData);
            break;
        }
      }
    }

    setState(() {
      _editedSections.clear();
      _hasUnsavedChanges = false;
    });
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
        await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
          title: 'Edit Profil',
          onBackPressed: () async {
            await _onWillPop();
          },
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
                  isCompleted,
                  isEdited,
                  item.onTap,
                  theme,
                  index,
                );
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primarySwatch,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              elevation: 3,
            ),
            child: Text(
              'Simpan Perubahan',
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

  int _getCrossAxisCount(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 900) return isLandscape ? 4 : 3;
    if (screenWidth > 600) return isLandscape ? 3 : 3;
    return isLandscape ? 3 : 2;
  }

  double _getChildAspectRatio(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;
    if (screenWidth > 1200) return 1.1;
    if (screenWidth > 900) return isLandscape ? 0.95 : 1.0;
    if (screenWidth > 600) return isLandscape ? 0.9 : 0.95;
    if (screenWidth < 350) return isLandscape ? 0.9 : 1.1;
    return isLandscape ? 0.85 : 1.0;
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    bool isCompleted,
    bool isEdited,
    VoidCallback onTap,
    dynamic theme,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 350;
    final iconContainerSize = isSmallPhone ? 48.0 : (isTablet ? 56.0 : 48.0);
    final iconSize = isSmallPhone ? 24.0 : (isTablet ? 28.0 : 24.0);
    final fontSize = isSmallPhone ? 12.0 : (isTablet ? 14.0 : 12.0);
    final padding = isSmallPhone ? 12.0 : (isTablet ? 20.0 : 16.0);
    final spacing = isTablet ? 16.0 : 12.0;
    final statusSize = isSmallPhone ? 20.0 : 26.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.primarySwatch.withOpacity(0.1),
          highlightColor: theme.primarySwatch.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primarySwatch.withOpacity(0.1),
                        theme.primarySwatch.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.primarySwatch.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, size: iconSize, color: theme.primarySwatch),
                  ),
                ),
                SizedBox(height: spacing),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typographyBold.bodySmall.copyWith(
                      color: const Color(0xFF1E293B),
                      fontSize: fontSize,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (isEdited || isCompleted) SizedBox(height: spacing),
                if (isEdited || isCompleted)
                  SizedBox(
                    height: statusSize,
                    child: isEdited
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallPhone ? 8 : 12,
                              vertical: isSmallPhone ? 3 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(statusSize / 2),
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
                                  style: theme.typographyRegular.bodySmall.copyWith(
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
      ),
    );
  }

  List<MenuItemData> _getDataPribadiItems(BuildContext context) {
    return [
      MenuItemData('Edit Profil', Icons.person, onTap: () async => await _navigateToSection('editProfile', 'Edit Profil')),
      MenuItemData('Identitas Diri', Icons.badge, onTap: () async => await _navigateToSection('pribadi', 'Identitas Diri')),
      MenuItemData('Honorarium', Icons.payments, onTap: () async => await _navigateToSection('honorarium', 'Honorarium')),
      MenuItemData('Keluarga', Icons.family_restroom, onTap: () async => await _navigateToSection('keluarga', 'Keluarga')),
      MenuItemData('PAS Foto', Icons.contact_phone, onTap: () async => await _navigateToSection('idCard', 'PAS Foto')),
      MenuItemData('Dokumen', Icons.folder, onTap: () async => await _navigateToSection('dokumen', 'Dokumen')),
      MenuItemData('Pendidikan', Icons.school, onTap: () async => await _navigateToSection('pendidikan', 'Pendidikan')),
      MenuItemData('Riwayat Pekerjaan', Icons.work, onTap: () async => await _navigateToSection('riwayatPekerjaan', 'Riwayat Pekerjaan')),
      MenuItemData('Data Lamaran', Icons.card_membership, onTap: () async => await _navigateToSection('dataLamaran', 'Data Lamaran')),
    ];
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuItemData(this.title, this.icon, {required this.onTap});
}