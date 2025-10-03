import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
import 'dart:async';
// SQLite imports
import 'package:ppnpm_dpr/common/data/repositories/sihaki/kontak_repository.dart';

class DataKontakPage extends ConsumerStatefulWidget {
  const DataKontakPage({super.key});

  @override
  ConsumerState<DataKontakPage> createState() => _DataKontakPageState();
}

class _DataKontakPageState extends ConsumerState<DataKontakPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnggotaController = TextEditingController();
  final _noKontakController = TextEditingController();
  final _namaKontakController = TextEditingController();
  String? _hubunganKontak;
  bool _isEditing = false;
  bool _isLoading = false;
  Timer? _saveTimer;

  // SQLite integration
  late final KontakRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = KontakRepository();
    
    // Add listeners for auto-save
    _namaAnggotaController.addListener(_onFieldChanged);
    _noKontakController.addListener(_onFieldChanged);
    _namaKontakController.addListener(_onFieldChanged);
    
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatabase();
    });
  }

  // Initialize database and handle any setup errors
  Future<void> _initializeDatabase() async {
    try {
      print('DEBUG: Initializing database for kontak...');
      
      // Try to load data first
      await _loadLatestData();
    } catch (e) {
      print('DEBUG: Database initialization error: $e');
      
      // If there's an error, show option to recreate database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: ${e.toString().length > 100 ? e.toString().substring(0, 100) + "..." : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fix Database',
              textColor: Colors.white,
              onPressed: () {
                _showRecreateDialog();
              },
            ),
          ),
        );
      }
    }
  }

  void _onFieldChanged() {
    if (!_isEditing) return;
    
    // Cancel previous timer if exists
    _saveTimer?.cancel();
    
    // Set new timer for auto-save (1 second delay)
    _saveTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _namaAnggotaController.text.trim().isNotEmpty) {
        _autoSaveData();
      }
    });
  }

  Future<void> _autoSaveData() async {
    if (!_isAllRequiredFilled()) return;
    
    try {
      await _repository.saveKontak(
        namaAnggota: _namaAnggotaController.text.trim(),
        noKontak: _noKontakController.text.trim(),
        namaKontak: _namaKontakController.text.trim(),
        hubunganKontak: _hubunganKontak!,
      );
      
      print('DEBUG: Auto-saved kontak data for ${_namaAnggotaController.text.trim()}');
    } catch (e) {
      print('DEBUG: Auto-save failed: $e');
    }
  }

  Future<void> _loadLatestData() async {
    try {
      setState(() => _isLoading = true);
      
      print('DEBUG: Loading latest kontak data...');
      
      // Try to get all kontak data first to check what's in database
      final allKontak = await _repository.getAllKontak();
      print('DEBUG: Found ${allKontak.length} kontak records in database');
      
      if (allKontak.isNotEmpty) {
        // Get the latest (most recently updated)
        final latestKontak = allKontak.first;
        
        if (mounted) {
          setState(() {
            _namaAnggotaController.text = latestKontak.namaAnggota;
            _noKontakController.text = latestKontak.noKontak;
            _namaKontakController.text = latestKontak.namaKontak;
            _hubunganKontak = latestKontak.hubunganKontak;
          });
          
          print('DEBUG: Loaded kontak data for ${latestKontak.namaAnggota}');
          print('DEBUG: Data - No: ${latestKontak.noKontak}, Nama: ${latestKontak.namaKontak}, Hubungan: ${latestKontak.hubunganKontak}');
        }
      } else {
        print('DEBUG: No kontak data found in database');
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateFilledStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('DEBUG: Error loading kontak data: $e');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadKontakByNama(String namaAnggota) async {
    if (namaAnggota.trim().isEmpty) return;
    
    try {
      setState(() => _isLoading = true);
      
      final kontak = await _repository.getKontakByNama(namaAnggota.trim());
      
      if (kontak != null && mounted) {
        setState(() {
          _noKontakController.text = kontak.noKontak;
          _namaKontakController.text = kontak.namaKontak;
          _hubunganKontak = kontak.hubunganKontak;
        });
        
        print('DEBUG: Loaded kontak data for $namaAnggota');
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateFilledStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('DEBUG: Error loading kontak by nama: $e');
    }
  }

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataKontakFilledProvider.notifier).state = isFilled;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _namaAnggotaController.removeListener(_onFieldChanged);
    _noKontakController.removeListener(_onFieldChanged);
    _namaKontakController.removeListener(_onFieldChanged);
    
    _namaAnggotaController.dispose();
    _noKontakController.dispose();
    _namaKontakController.dispose();
    
    _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaAnggotaController.text.trim().isNotEmpty &&
        _noKontakController.text.isNotEmpty &&
        _namaKontakController.text.isNotEmpty &&
        _hubunganKontak != null;
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
      if (_noKontakController.text.isEmpty) {
        errors.add('No Kontak Darurat harus diisi');
      }
      if (_namaKontakController.text.isEmpty) {
        errors.add('Nama Kontak Darurat harus diisi');
      }
      if (_hubunganKontak == null) {
        errors.add('Hubungan Kontak Darurat harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        setState(() => _isLoading = true);

        // Save to SQLite database
        await _repository.saveKontak(
          namaAnggota: _namaAnggotaController.text.trim(),
          noKontak: _noKontakController.text.trim(),
          namaKontak: _namaKontakController.text.trim(),
          hubunganKontak: _hubunganKontak!,
        );

        print('DEBUG: Saved kontak data to SQLite for ${_namaAnggotaController.text.trim()}');

        setState(() => _isLoading = false);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Kontak',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Data kontak untuk ${_namaAnggotaController.text.trim()} berhasil disimpan ke database.',
            ),
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

        // Update provider state
        ref.read(dataKontakFilledProvider.notifier).state = true;

        setState(() {
          _isEditing = false;
        });

        // Reload data to verify save worked
        await _loadLatestData();
        
        // Small delay to ensure data is properly loaded before navigation
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          context.go(
            '/dataKomisi',
            extra: {
              'justSaved': true, 
              'sourcePage': '/data-kontak',
              'namaAnggota': _namaAnggotaController.text.trim(),
            },
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(context, theme, 'Gagal menyimpan data kontak: ${e.toString()}');
        print('DEBUG: Error saving kontak data: $e');
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
      print('DEBUG: ========== KONTAK DEBUG INFO START ==========');
      
      // Check current form data
      print('DEBUG: Current form data:');
      print('  - Nama Anggota: "${_namaAnggotaController.text}"');
      print('  - No Kontak: "${_noKontakController.text}"');
      print('  - Nama Kontak: "${_namaKontakController.text}"');
      print('  - Hubungan: "$_hubunganKontak"');
      print('  - Is Editing: $_isEditing');
      print('  - Is Loading: $_isLoading');
      
      // Check database
      final allKontak = await _repository.getAllKontak();
      print('DEBUG: Total kontak in database: ${allKontak.length}');
      
      for (final kontak in allKontak) {
        print('DEBUG: Kontak - ${kontak.namaAnggota}: ${kontak.noKontak}, ${kontak.namaKontak}, ${kontak.hubunganKontak}');
      }
      
      print('DEBUG: ========== KONTAK DEBUG INFO END ==========');
      
      // Show dialog with info
      final theme = ref.read(themeProvider);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Debug Information',
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
                Text('Database records: ${allKontak.length}'),
                const SizedBox(height: 8),
                Text('Current nama: "${_namaAnggotaController.text}"'),
                const SizedBox(height: 8),
                Text('Form filled: ${_isAllRequiredFilled()}'),
                const SizedBox(height: 8),
                Text('Is editing: $_isEditing'),
                const SizedBox(height: 8),
                Text('Is loading: $_isLoading'),
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

  Future<void> _showRecreateDialog() async {
    final theme = ref.read(themeProvider);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recreate Database',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.orange[700],
          ),
        ),
        content: const Text(
          'Ini akan menghapus semua data dan membuat database baru. '
          'Hanya gunakan untuk testing. Lanjutkan?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Recreate',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        await _repository.forceRecreateDatabase();
        print('DEBUG: Database force recreated from kontak page');
        
        // Clear form
        _namaAnggotaController.clear();
        _noKontakController.clear();
        _namaKontakController.clear();
        _hubunganKontak = null;
        
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database berhasil dibuat ulang'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        print('DEBUG: Error force recreating database: $e');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error recreating database: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
        title: 'Data Kontak',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
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
                      const Expanded(
                        child: Text('Loading data kontak dari database...'),
                      ),
                    ],
                  ),
                ),

              // Data status indicator
              if (!_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _namaAnggotaController.text.trim().isNotEmpty 
                      ? Colors.green[50] 
                      : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _namaAnggotaController.text.trim().isNotEmpty 
                        ? Colors.green[200]! 
                        : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _namaAnggotaController.text.trim().isNotEmpty 
                          ? Icons.check_circle_outline 
                          : Icons.info_outline,
                        size: 16,
                        color: _namaAnggotaController.text.trim().isNotEmpty 
                          ? Colors.green[700] 
                          : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _namaAnggotaController.text.trim().isNotEmpty 
                            ? 'Data tersedia untuk: ${_namaAnggotaController.text.trim()}' 
                            : 'Belum ada data tersimpan di database',
                          style: TextStyle(
                            fontSize: 12,
                            color: _namaAnggotaController.text.trim().isNotEmpty 
                              ? Colors.green[700] 
                              : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              AppFormCard(
                title: 'Kontak Darurat',
                titleIcon: Icons.contact_phone,
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
                    onChanged: (value) {
                      if (value != null && value.trim().isNotEmpty && !_isEditing) {
                        // Auto-load data when nama changes (not in editing mode)
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_namaAnggotaController.text.trim() == value.trim()) {
                            _loadKontakByNama(value.trim());
                          }
                        });
                      }
                    },
                  ),
                  FormFieldConfig(
                    label: 'No Kontak Darurat',
                    icon: Icons.phone,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noKontakController,
                    hintText: 'Masukkan nomor kontak darurat',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nama Kontak Darurat',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaKontakController,
                    hintText: 'Masukkan nama kontak darurat',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Hubungan Kontak Darurat',
                    icon: Icons.family_restroom,
                    type:
                        _isEditing
                            ? FormFieldType.dropdown
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    value: _hubunganKontak,
                    options: const [
                      'Orang Tua',
                      'Suami/Istri',
                      'Anak',
                      'Saudara',
                      'Kerabat',
                      'Teman',
                      'Rekan Kerja',
                      'Lainnya',
                    ],
                    hintText: 'Pilih hubungan dengan kontak darurat',
                    onChanged: (value) {
                      setState(() {
                        _hubunganKontak = value;
                      });
                    },
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
