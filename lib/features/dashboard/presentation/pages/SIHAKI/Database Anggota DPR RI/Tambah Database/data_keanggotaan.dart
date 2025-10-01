import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
// SQLite Integration imports
import 'package:ppnpm_dpr/common/data/models/sihaki/keanggotaan_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/keanggotaan_repository.dart';
// SharedPreferences for persistence
import 'package:shared_preferences/shared_preferences.dart';

class DataKeanggotaanPage extends ConsumerStatefulWidget {
  const DataKeanggotaanPage({super.key});

  @override
  ConsumerState<DataKeanggotaanPage> createState() =>
      _DataKeanggotaanPageState();
}

class _DataKeanggotaanPageState extends ConsumerState<DataKeanggotaanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noAnggotaController = TextEditingController();
  final _fraksiController = TextEditingController();
  final _dapilController = TextEditingController();
  final _areaController = TextEditingController();
  final _noRekeningController = TextEditingController();
  final _namaRekeningController = TextEditingController();
  bool _isEditing = false;
  bool _isLoadingData = false;
  
  // SQLite integration
  late final KeanggotaanRepository _repository;
  KeanggotaanModel? _existingKeanggotaan;

  @override
  void initState() {
    super.initState();
    _repository = KeanggotaanRepository();
    
    // Add listeners untuk auto-save
    _namaController.addListener(_onFieldChanged);
    _noAnggotaController.addListener(_onFieldChanged);
    _fraksiController.addListener(_onFieldChanged);
    _dapilController.addListener(_onFieldChanged);
    _areaController.addListener(_onFieldChanged);
    _noRekeningController.addListener(_onFieldChanged);
    _namaRekeningController.addListener(_onFieldChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Load from SharedPreferences for current user
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      
      // Load from database
      final userKeanggotaan = await _repository.getKeanggotaanByUserId(userId);
      
      if (userKeanggotaan.isNotEmpty) {
        final recentKeanggotaan = userKeanggotaan.first;
        _existingKeanggotaan = recentKeanggotaan;
        
        setState(() {
          _namaController.text = recentKeanggotaan.nama;
          _noAnggotaController.text = recentKeanggotaan.noAnggota;
          _fraksiController.text = recentKeanggotaan.fraksi;
          _dapilController.text = recentKeanggotaan.dapil;
          _areaController.text = recentKeanggotaan.area;
          _noRekeningController.text = recentKeanggotaan.noRekening ?? '';
          _namaRekeningController.text = recentKeanggotaan.namaRekening;
        });

        // Save to SharedPreferences for quick access
        await prefs.setString('keanggotaan_nama', recentKeanggotaan.nama);
        await prefs.setString('keanggotaan_no_anggota', recentKeanggotaan.noAnggota);
        await prefs.setString('keanggotaan_fraksi', recentKeanggotaan.fraksi);
        await prefs.setString('keanggotaan_dapil', recentKeanggotaan.dapil);
        await prefs.setString('keanggotaan_area', recentKeanggotaan.area);
        await prefs.setString('keanggotaan_no_rekening', recentKeanggotaan.noRekening ?? '');
        await prefs.setString('keanggotaan_nama_rekening', recentKeanggotaan.namaRekening);
      } else {
        // Load from SharedPreferences as fallback
        _namaController.text = prefs.getString('keanggotaan_nama') ?? '';
        _noAnggotaController.text = prefs.getString('keanggotaan_no_anggota') ?? '';
        _fraksiController.text = prefs.getString('keanggotaan_fraksi') ?? '';
        _dapilController.text = prefs.getString('keanggotaan_dapil') ?? '';
        _areaController.text = prefs.getString('keanggotaan_area') ?? '';
        _noRekeningController.text = prefs.getString('keanggotaan_no_rekening') ?? '';
        _namaRekeningController.text = prefs.getString('keanggotaan_nama_rekening') ?? '';
      }

      _updateFilledStatus();
    } catch (e) {
      print('ERROR: Failed to load keanggotaan data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _updateFilledStatus() {
    if (_isAllRequiredFilled()) {
      ref.read(dataKeanggotaanFilledProvider.notifier).state = true;
    } else {
      ref.read(dataKeanggotaanFilledProvider.notifier).state = false;
    }
  }

  // Auto-save when field changes
  void _onFieldChanged() {
    // Update filled status immediately
    _updateFilledStatus();
    
    // Auto-save to SharedPreferences immediately (untuk persistence)
    _saveToSharedPreferences();
    
    // Auto-save to database dengan debounce untuk avoid too frequent saves
    _debounceAutoSave();
  }

  // Save to SharedPreferences untuk immediate persistence
  Future<void> _saveToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('keanggotaan_nama', _namaController.text);
      await prefs.setString('keanggotaan_no_anggota', _noAnggotaController.text);
      await prefs.setString('keanggotaan_fraksi', _fraksiController.text);
      await prefs.setString('keanggotaan_dapil', _dapilController.text);
      await prefs.setString('keanggotaan_area', _areaController.text);
      await prefs.setString('keanggotaan_no_rekening', _noRekeningController.text);
      await prefs.setString('keanggotaan_nama_rekening', _namaRekeningController.text);
      
      print('DEBUG: Auto-saved to SharedPreferences');
    } catch (e) {
      print('ERROR: Failed to auto-save to SharedPreferences: $e');
    }
  }

  // Debounce auto-save to database
  Timer? _debounceTimer;
  
  void _debounceAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (_isAllRequiredFilled()) {
        _autoSaveToDatabase();
      }
    });
  }

  // Auto-save to database when all required fields are filled
  Future<void> _autoSaveToDatabase() async {
    if (!_isAllRequiredFilled()) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';

      if (_existingKeanggotaan != null) {
        // Update existing record
        final updatedKeanggotaan = _existingKeanggotaan!.copyWith(
          nama: _namaController.text,
          noAnggota: _noAnggotaController.text,
          fraksi: _fraksiController.text,
          dapil: _dapilController.text,
          area: _areaController.text,
          noRekening: _noRekeningController.text.isNotEmpty ? _noRekeningController.text : null,
          namaRekening: _namaRekeningController.text,
          updatedAt: DateTime.now(),
        );

        await _repository.updateKeanggotaan(updatedKeanggotaan);
        print('SUCCESS: Auto-updated existing keanggotaan with ID: ${updatedKeanggotaan.id}');
      } else {
        // Add new record
        final newKeanggotaan = await _repository.addKeanggotaan(
          nama: _namaController.text,
          noAnggota: _noAnggotaController.text,
          fraksi: _fraksiController.text,
          dapil: _dapilController.text,
          area: _areaController.text,
          noRekening: _noRekeningController.text.isNotEmpty ? _noRekeningController.text : null,
          namaRekening: _namaRekeningController.text,
          userId: userId,
        );
        
        // Update state dengan record yang baru dibuat
        setState(() {
          _existingKeanggotaan = newKeanggotaan;
        });
        
        print('SUCCESS: Auto-added new keanggotaan to database with ID: ${newKeanggotaan.id}');
      }
    } catch (e) {
      print('ERROR: Failed to auto-save to database: $e');
    }
  }

  @override
  void dispose() {
    // Remove listeners
    _namaController.removeListener(_onFieldChanged);
    _noAnggotaController.removeListener(_onFieldChanged);
    _fraksiController.removeListener(_onFieldChanged);
    _dapilController.removeListener(_onFieldChanged);
    _areaController.removeListener(_onFieldChanged);
    _noRekeningController.removeListener(_onFieldChanged);
    _namaRekeningController.removeListener(_onFieldChanged);
    
    // Cancel timer
    _debounceTimer?.cancel();
    
    // Dispose controllers
    _namaController.dispose();
    _noAnggotaController.dispose();
    _fraksiController.dispose();
    _dapilController.dispose();
    _areaController.dispose();
    _noRekeningController.dispose();
    _namaRekeningController.dispose();
    _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaController.text.isNotEmpty &&
        _noAnggotaController.text.isNotEmpty &&
        _fraksiController.text.isNotEmpty &&
        _dapilController.text.isNotEmpty &&
        _areaController.text.isNotEmpty &&
        _namaRekeningController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_namaController.text.isEmpty) {
        errors.add('Nama harus diisi');
      }
      if (_noAnggotaController.text.isEmpty) {
        errors.add('No. Anggota harus diisi');
      }
      if (_fraksiController.text.isEmpty) {
        errors.add('Fraksi harus diisi');
      }
      if (_dapilController.text.isEmpty) {
        errors.add('Dapil harus diisi');
      }
      if (_areaController.text.isEmpty) {
        errors.add('Area harus diisi');
      }
      if (_namaRekeningController.text.isEmpty) {
        errors.add('Nama Rekening harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        // Get user ID from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('current_user_id') ?? 'current_user';

        if (_existingKeanggotaan != null) {
          // Update existing record
          final updatedKeanggotaan = _existingKeanggotaan!.copyWith(
            nama: _namaController.text,
            noAnggota: _noAnggotaController.text,
            fraksi: _fraksiController.text,
            dapil: _dapilController.text,
            area: _areaController.text,
            noRekening: _noRekeningController.text.isNotEmpty ? _noRekeningController.text : null,
            namaRekening: _namaRekeningController.text,
            updatedAt: DateTime.now(),
          );

          await _repository.updateKeanggotaan(updatedKeanggotaan);
          print('SUCCESS: Updated existing keanggotaan with ID: ${updatedKeanggotaan.id}');
        } else {
          // Add new record
          await _repository.addKeanggotaan(
            nama: _namaController.text,
            noAnggota: _noAnggotaController.text,
            fraksi: _fraksiController.text,
            dapil: _dapilController.text,
            area: _areaController.text,
            noRekening: _noRekeningController.text.isNotEmpty ? _noRekeningController.text : null,
            namaRekening: _namaRekeningController.text,
            userId: userId,
          );
          print('SUCCESS: Added new keanggotaan to database');
        }

        // Save to SharedPreferences for quick access
        await prefs.setString('keanggotaan_nama', _namaController.text);
        await prefs.setString('keanggotaan_no_anggota', _noAnggotaController.text);
        await prefs.setString('keanggotaan_fraksi', _fraksiController.text);
        await prefs.setString('keanggotaan_dapil', _dapilController.text);
        await prefs.setString('keanggotaan_area', _areaController.text);
        await prefs.setString('keanggotaan_no_rekening', _noRekeningController.text);
        await prefs.setString('keanggotaan_nama_rekening', _namaRekeningController.text);

      } catch (e) {
        print('ERROR: Failed to save keanggotaan: $e');
        _showErrorDialog(context, theme, 'Gagal menyimpan data: $e');
        return;
      }

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Keanggotaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data keanggotaan berhasil disimpan.'),
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
        ref.read(dataKeanggotaanFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-keanggotaan'},
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      // Get database info
      final allKeanggotaan = await _repository.getAllKeanggotaan();
      final count = await _repository.getKeanggotaanCount();
      final statistics = await _repository.getKeanggotaanStatistics();
      
      // Get SharedPreferences info
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      final savedNama = prefs.getString('keanggotaan_nama') ?? '';
      
      final theme = ref.read(themeProvider);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Debug Info - Keanggotaan SQLite',
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
                  Text('🔍 Database Status:'),
                  Text('  • Total records: $count'),
                  Text('  • Current user: $userId'),
                  Text('  • Saved name: "$savedNama"'),
                  const SizedBox(height: 8),
                  Text('📊 Statistics:'),
                  Text('  • Total: ${statistics['total'] ?? 0}'),
                  Text('  • With rekening: ${statistics['withRekening'] ?? 0}'),
                  Text('  • Without rekening: ${statistics['withoutRekening'] ?? 0}'),
                  const SizedBox(height: 8),
                  Text('💾 Current State:'),
                  Text('  • Existing record: ${_existingKeanggotaan != null ? "Yes (ID: ${_existingKeanggotaan!.id})" : "No"}'),
                  Text('  • Is loading: $_isLoadingData'),
                  Text('  • Is editing: $_isEditing'),
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
      }
      
      // Print detailed debug info
      print('=== KEANGGOTAAN DEBUG INFO ===');
      print('Database records: $count');
      print('User ID: $userId');
      print('Existing keanggotaan: $_existingKeanggotaan');
      print('All keanggotaan: $allKeanggotaan');
      print('Statistics: $statistics');
      print('===============================');
      
    } catch (e) {
      print('ERROR: Failed to get debug info: $e');
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
        title: 'Database Keanggotaan',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadSavedData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil di-refresh dari database'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Refresh Data dari Database',
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
              if (_isLoadingData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Memuat data dari database SQLite...',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Auto-save status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _existingKeanggotaan != null 
                        ? [Colors.green[100]!, Colors.green[50]!]
                        : [Colors.blue[100]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _existingKeanggotaan != null 
                        ? Colors.green[300]! 
                        : Colors.blue[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _existingKeanggotaan != null 
                          ? Icons.cloud_done 
                          : Icons.auto_awesome,
                      color: _existingKeanggotaan != null 
                          ? Colors.green[700] 
                          : Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _existingKeanggotaan != null 
                                ? 'Data Tersimpan di Database' 
                                : 'Auto-Save Aktif',
                            style: theme.typographyRegular.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _existingKeanggotaan != null 
                                  ? Colors.green[800] 
                                  : Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _existingKeanggotaan != null 
                                ? 'ID: ${_existingKeanggotaan!.id} - ${_existingKeanggotaan!.nama}'
                                : 'Data otomatis tersimpan saat Anda mengetik',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: _existingKeanggotaan != null 
                                  ? Colors.green[700] 
                                  : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppFormCard(
                title: 'Data Pribadi Anggota',
                titleIcon: Icons.person_outline,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nama',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaController,
                    hintText: 'Masukkan nama lengkap anggota DPR',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'No. Anggota',
                    icon: Icons.badge,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noAnggotaController,
                    hintText: 'Masukkan nomor anggota',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Fraksi',
                    icon: Icons.group_work,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _fraksiController,
                    hintText: 'Masukkan nama fraksi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Dapil',
                    icon: Icons.location_on,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _dapilController,
                    hintText: 'Masukkan daerah pemilihan',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Area',
                    icon: Icons.map,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _areaController,
                    hintText: 'Masukkan area/wilayah yang diwakili',
                    maxLines: 3,
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
              AppFormCard(
                title: 'Data Rekening',
                titleIcon: Icons.account_balance_wallet,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'No. Rekening',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.text
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _noRekeningController,
                    hintText: 'Masukkan nomor rekening bank',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  FormFieldConfig(
                    label: 'Nama Rekening',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaRekeningController,
                    hintText: 'Masukkan nama pemilik rekening',
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
