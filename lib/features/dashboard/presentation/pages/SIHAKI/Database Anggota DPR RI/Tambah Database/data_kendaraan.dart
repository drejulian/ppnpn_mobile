import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
// SQLite imports
import 'package:ppnpm_dpr/common/data/repositories/sihaki/kendaraan_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataKendaraanPage extends ConsumerStatefulWidget {
  const DataKendaraanPage({super.key});

  @override
  ConsumerState<DataKendaraanPage> createState() => _DataKendaraanPageState();
}

class _DataKendaraanPageState extends ConsumerState<DataKendaraanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nopolDinasController = TextEditingController();
  final _nopolPribadiController = TextEditingController();
  final _namaAnggotaController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isAutoSaving = false;
  
  // SQLite integration
  late final KendaraanRepository _repository;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _repository = KendaraanRepository();
    
    // Load persisted data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
    
    // Add listeners for auto-save
    _namaAnggotaController.addListener(_onFieldChanged);
    _nopolDinasController.addListener(_onFieldChanged);
    _nopolPribadiController.addListener(_onFieldChanged);
  }

  Future<void> _loadSavedData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load nama anggota from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedNamaAnggota = prefs.getString('last_nama_anggota_kendaraan') ?? '';
      
      print('DEBUG: Loading kendaraan data for: $savedNamaAnggota');
      
      if (savedNamaAnggota.isNotEmpty) {
        _namaAnggotaController.text = savedNamaAnggota;
        
        // Load kendaraan data from SQLite
        final kendaraan = await _repository.getKendaraanByNamaAnggota(savedNamaAnggota);
        
        if (kendaraan != null) {
          setState(() {
            _nopolDinasController.text = kendaraan.nopolDinas;
            _nopolPribadiController.text = kendaraan.nopolPribadi;
          });
          print('DEBUG: ✅ Loaded kendaraan data from SQLite');
        } else {
          print('DEBUG: No kendaraan data found in SQLite');
        }
      }
      
      _updateFilledStatus();
      
    } catch (e) {
      print('DEBUG: Error loading saved data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFieldChanged() {
    // Auto-save nama anggota to SharedPreferences
    if (_namaAnggotaController.text.trim().isNotEmpty) {
      _saveNamaAnggotaToPrefs(_namaAnggotaController.text.trim());
    }
    
    // Cancel previous timer
    _autoSaveTimer?.cancel();
    
    // Set new timer for auto-save to SQLite
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (_namaAnggotaController.text.trim().isNotEmpty &&
          _nopolDinasController.text.trim().isNotEmpty &&
          _nopolPribadiController.text.trim().isNotEmpty) {
        _autoSaveToSQLite();
      }
    });
    
    _updateFilledStatus();
  }

  Future<void> _saveNamaAnggotaToPrefs(String namaAnggota) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_nama_anggota_kendaraan', namaAnggota);
      print('DEBUG: Saved nama anggota to SharedPreferences: $namaAnggota');
    } catch (e) {
      print('DEBUG: Error saving nama anggota: $e');
    }
  }

  Future<void> _autoSaveToSQLite() async {
    if (_isAutoSaving) return;
    
    try {
      setState(() {
        _isAutoSaving = true;
      });

      final kendaraan = await _repository.saveKendaraan(
        namaAnggota: _namaAnggotaController.text.trim(),
        nopolDinas: _nopolDinasController.text.trim(),
        nopolPribadi: _nopolPribadiController.text.trim(),
      );

      print('DEBUG: ✅ Auto-saved kendaraan data to SQLite with ID: ${kendaraan.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 Data otomatis tersimpan'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error auto-saving to SQLite: $e');
    } finally {
      setState(() {
        _isAutoSaving = false;
      });
    }
  }

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataKendaraanFilledProvider.notifier).state = isFilled;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _namaAnggotaController.removeListener(_onFieldChanged);
    _nopolDinasController.removeListener(_onFieldChanged);
    _nopolPribadiController.removeListener(_onFieldChanged);
    _namaAnggotaController.dispose();
    _nopolDinasController.dispose();
    _nopolPribadiController.dispose();
    _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaAnggotaController.text.trim().isNotEmpty &&
        _nopolDinasController.text.isNotEmpty &&
        _nopolPribadiController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_namaAnggotaController.text.trim().isEmpty) {
        errors.add('Nama Anggota harus diisi');
      }
      if (_nopolDinasController.text.isEmpty) {
        errors.add('Nopol Dinas harus diisi');
      }
      if (_nopolPribadiController.text.isEmpty) {
        errors.add('Nopol Pribadi harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        setState(() {
          _isLoading = true;
        });

        // Save to SQLite
        final kendaraan = await _repository.saveKendaraan(
          namaAnggota: _namaAnggotaController.text.trim(),
          nopolDinas: _nopolDinasController.text.trim(),
          nopolPribadi: _nopolPribadiController.text.trim(),
        );

        // Save nama anggota to SharedPreferences
        await _saveNamaAnggotaToPrefs(_namaAnggotaController.text.trim());

        print('DEBUG: ✅ Kendaraan data saved to SQLite with ID: ${kendaraan.id}');

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Kendaraan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text('Data kendaraan untuk ${_namaAnggotaController.text.trim()} berhasil disimpan ke database.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        await Future.delayed(Duration.zero, () {
          ref.read(dataKendaraanFilledProvider.notifier).state = true;
        });

        setState(() {
          _isEditing = false;
        });

        if (context.mounted) {
          context.go(
            '/dataKomisi',
            extra: {
              'justSaved': true, 
              'sourcePage': '/data-kendaraan',
              'savedData': {
                'namaAnggota': _namaAnggotaController.text.trim(),
                'nopolDinas': _nopolDinasController.text.trim(),
                'nopolPribadi': _nopolPribadiController.text.trim(),
              }
            },
          );
        }
      } catch (e) {
        _showErrorDialog(context, theme, 'Gagal menyimpan data: ${e.toString()}');
        print('DEBUG: Error saving kendaraan: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDebugInfo() async {
    try {
      print('DEBUG: ========== KENDARAAN DEBUG INFO START ==========');
      
      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedNamaAnggota = prefs.getString('last_nama_anggota_kendaraan') ?? '';
      print('DEBUG: SharedPreferences nama anggota: "$savedNamaAnggota"');
      
      // Check all kendaraan in database
      final allKendaraan = await _repository.getAllKendaraan();
      print('DEBUG: Total kendaraan in database: ${allKendaraan.length}');
      
      for (final kendaraan in allKendaraan) {
        print('DEBUG: Kendaraan - ${kendaraan.namaAnggota}: Dinas(${kendaraan.nopolDinas}) Pribadi(${kendaraan.nopolPribadi})');
      }
      
      // Check current UI state
      print('DEBUG: Current nama anggota in UI: "${_namaAnggotaController.text}"');
      print('DEBUG: Current nopol dinas in UI: "${_nopolDinasController.text}"');
      print('DEBUG: Current nopol pribadi in UI: "${_nopolPribadiController.text}"');
      print('DEBUG: Is editing: $_isEditing');
      print('DEBUG: Is loading: $_isLoading');
      print('DEBUG: Is auto saving: $_isAutoSaving');
      
      print('DEBUG: ========== KENDARAAN DEBUG INFO END ==========');
      
      // Show dialog with info
      final theme = ref.read(themeProvider);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Debug Information - Kendaraan',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SharedPreferences: "$savedNamaAnggota"'),
                const SizedBox(height: 8),
                Text('Database records: ${allKendaraan.length}'),
                const SizedBox(height: 8),
                Text('UI nama anggota: "${_namaAnggotaController.text}"'),
                const SizedBox(height: 8),
                Text('UI nopol dinas: "${_nopolDinasController.text}"'),
                const SizedBox(height: 8),
                Text('UI nopol pribadi: "${_nopolPribadiController.text}"'),
                const SizedBox(height: 8),
                const Text('Check console for detailed logs'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('DEBUG: Error showing debug info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Kendaraan',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('DEBUG: Manual refresh triggered');
              await _loadSavedData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil di-refresh'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
            tooltip: 'Debug Info',
          ),
        ],
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
              // Loading indicator
              if (_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Memuat data kendaraan...',
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),

              // Auto-save indicator
              if (_isAutoSaving)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[100]!, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Menyimpan otomatis...',
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),

              AppFormCard(
                title: 'Data Kendaraan',
                titleIcon: Icons.directions_car,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nama Anggota',
                    icon: Icons.person,
                    type: _isEditing ? FormFieldType.textRequired : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaAnggotaController,
                    hintText: 'Masukkan nama lengkap anggota',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nopol Dinas',
                    icon: Icons.local_police,
                    type: _isEditing ? FormFieldType.textRequired : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nopolDinasController,
                    hintText: 'Masukkan nomor polisi dinas',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nopol Pribadi',
                    icon: Icons.directions_car,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nopolPribadiController,
                    hintText: 'Masukkan nomor polisi pribadi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol EDIT dan SIMPAN
              Column(
                children: [
                  if (!_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
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
                          'EDIT',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveData(context, ref, theme),
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
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
