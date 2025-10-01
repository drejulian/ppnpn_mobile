import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
import 'dart:async';
// SQLite imports
import 'package:ppnpm_dpr/common/data/repositories/sihaki/penerbangan_repository.dart';

class DataPenerbanganPage extends ConsumerStatefulWidget {
  const DataPenerbanganPage({super.key});

  @override
  ConsumerState<DataPenerbanganPage> createState() =>
      _DataPenerbanganPageState();
}

class _DataPenerbanganPageState extends ConsumerState<DataPenerbanganPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnggotaController = TextEditingController();
  final _nomorPassportController = TextEditingController();
  final _bandaraPreferensiController = TextEditingController();
  final _maskapaiPreferensiController = TextEditingController();
  final _kelasPenerbanganController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  Timer? _saveTimer;

  // SQLite integration
  late final PenerbanganRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = PenerbanganRepository();
    
    // Add listeners for auto-save
    _namaAnggotaController.addListener(_onFieldChanged);
    _nomorPassportController.addListener(_onFieldChanged);
    _bandaraPreferensiController.addListener(_onFieldChanged);
    _maskapaiPreferensiController.addListener(_onFieldChanged);
    _kelasPenerbanganController.addListener(_onFieldChanged);
    
    // Add specific listener for nama anggota to load data when changed
    _namaAnggotaController.addListener(_onNamaAnggotaChanged);
    
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatabase();
    });
  }

  // Initialize database and handle any setup errors
  Future<void> _initializeDatabase() async {
    try {
      print('DEBUG: ========== INITIALIZING DATA PENERBANGAN PAGE ==========');
      print('DEBUG: Initializing database for penerbangan...');
      
      // Try to load data first
      // First test database directly 
      await _testDatabaseDirectly();
      
      print('DEBUG: About to call _loadLatestData...');
      await _loadLatestData();
      print('DEBUG: _loadLatestData completed');
      
      // Verify form is loaded
      print('DEBUG: After loading - Nama: "${_namaAnggotaController.text}", Passport: "${_nomorPassportController.text}"');
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

  void _onNamaAnggotaChanged() {
    // Just update filled status, don't auto-load to avoid conflicts
    _updateFilledStatus();
  }

  Future<void> _autoSaveData() async {
    if (!_isAllRequiredFilled()) return;
    
    try {
      await _repository.savePenerbangan(
        namaAnggota: _namaAnggotaController.text.trim(),
        nomorPassport: _nomorPassportController.text.trim(),
        bandaraPreferensi: _bandaraPreferensiController.text.trim(),
        maskapaiPreferensi: _maskapaiPreferensiController.text.trim(),
        kelasPenerbangan: _kelasPenerbanganController.text.trim(),
      );
      
      print('DEBUG: Auto-saved penerbangan data for ${_namaAnggotaController.text.trim()}');
    } catch (e) {
      print('DEBUG: Auto-save failed: $e');
    }
  }

  Future<void> _loadLatestData() async {
    try {
      setState(() => _isLoading = true);
      
      print('DEBUG: Loading latest penerbangan data...');
      
      // First ensure database connection is working
      await _repository.getPenerbanganCount();
      print('DEBUG: Database connection verified');
      
      // Try to get all penerbangan data first to check what's in database
      final allPenerbangan = await _repository.getAllPenerbangan();
      print('DEBUG: Found ${allPenerbangan.length} penerbangan records in database');
      
      if (allPenerbangan.isNotEmpty) {
        // Get the latest (most recently updated)
        final latestPenerbangan = allPenerbangan.first;
        
        if (mounted) {
          setState(() {
            _namaAnggotaController.text = latestPenerbangan.namaAnggota;
            _nomorPassportController.text = latestPenerbangan.nomorPassport;
            _bandaraPreferensiController.text = latestPenerbangan.bandaraPreferensi;
            _maskapaiPreferensiController.text = latestPenerbangan.maskapaiPreferensi;
            _kelasPenerbanganController.text = latestPenerbangan.kelasPenerbangan;
          });
          
          print('DEBUG: Successfully loaded penerbangan data for ${latestPenerbangan.namaAnggota}');
          print('DEBUG: Loaded fields - Passport: ${latestPenerbangan.nomorPassport}, Bandara: ${latestPenerbangan.bandaraPreferensi}');
          print('DEBUG: Data details - Passport: ${latestPenerbangan.nomorPassport}, Bandara: ${latestPenerbangan.bandaraPreferensi}, Maskapai: ${latestPenerbangan.maskapaiPreferensi}');
        }
      } else {
        print('DEBUG: No penerbangan data found in database - starting with empty form');
        
        // Clear form when no data
        if (mounted) {
          setState(() {
            _namaAnggotaController.clear();
            _nomorPassportController.clear();
            _bandaraPreferensiController.clear();
            _maskapaiPreferensiController.clear();
            _kelasPenerbanganController.clear();
          });
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        _updateFilledStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('DEBUG: Error loading penerbangan data: $e');
      
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



  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataPenerbanganFilledProvider.notifier).state = isFilled;
  }

  Future<void> _testDatabaseDirectly() async {
    try {
      print('DEBUG: ========== TESTING PENERBANGAN DATABASE ==========');
      
      // Test database connection
      final count = await _repository.getPenerbanganCount();
      print('DEBUG: Database connection OK, total records: $count');
      
      if (count > 0) {
        // Test getting all data
        final allData = await _repository.getAllPenerbangan();
        print('DEBUG: Retrieved ${allData.length} records from database');
        
        for (int i = 0; i < allData.length && i < 3; i++) {
          final data = allData[i];
          print('DEBUG: Record $i: ${data.namaAnggota} - ${data.nomorPassport} - ${data.bandaraPreferensi}');
          print('DEBUG: Updated at: ${data.updatedAt}');
        }
        
        if (allData.isNotEmpty) {
          final latest = allData.first;
          print('DEBUG: Latest record should load: ${latest.namaAnggota}');
        }
      } else {
        print('DEBUG: No penerbangan records found in database');
      }
      
      print('DEBUG: ========== PENERBANGAN DATABASE TEST COMPLETED ==========');
    } catch (e) {
      print('DEBUG: Penerbangan database test error: $e');
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _namaAnggotaController.removeListener(_onFieldChanged);
    _namaAnggotaController.removeListener(_onNamaAnggotaChanged);
    _nomorPassportController.removeListener(_onFieldChanged);
    _bandaraPreferensiController.removeListener(_onFieldChanged);
    _maskapaiPreferensiController.removeListener(_onFieldChanged);
    _kelasPenerbanganController.removeListener(_onFieldChanged);
    
    _namaAnggotaController.dispose();
    _nomorPassportController.dispose();
    _bandaraPreferensiController.dispose();
    _maskapaiPreferensiController.dispose();
    _kelasPenerbanganController.dispose();
    
    _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaAnggotaController.text.trim().isNotEmpty &&
        _nomorPassportController.text.isNotEmpty &&
        _bandaraPreferensiController.text.isNotEmpty &&
        _maskapaiPreferensiController.text.isNotEmpty &&
        _kelasPenerbanganController.text.isNotEmpty;
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
      if (_nomorPassportController.text.isEmpty) {
        errors.add('Nomor Passport harus diisi');
      }
      if (_bandaraPreferensiController.text.isEmpty) {
        errors.add('Bandara Preferensi harus diisi');
      }
      if (_maskapaiPreferensiController.text.isEmpty) {
        errors.add('Maskapai Preferensi harus diisi');
      }
      if (_kelasPenerbanganController.text.isEmpty) {
        errors.add('Kelas Penerbangan harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        setState(() => _isLoading = true);

        // Save to SQLite database
        await _repository.savePenerbangan(
          namaAnggota: _namaAnggotaController.text.trim(),
          nomorPassport: _nomorPassportController.text.trim(),
          bandaraPreferensi: _bandaraPreferensiController.text.trim(),
          maskapaiPreferensi: _maskapaiPreferensiController.text.trim(),
          kelasPenerbangan: _kelasPenerbanganController.text.trim(),
        );

        print('DEBUG: ========== DATA SAVE SUCCESSFUL ==========');
        print('DEBUG: Saved penerbangan data to SQLite for ${_namaAnggotaController.text.trim()}');
        
        // Verify the save by immediately reading it back
        final verifyData = await _repository.getPenerbanganByNama(_namaAnggotaController.text.trim());
        if (verifyData != null) {
          print('DEBUG: VERIFICATION: Data successfully written to database');
          print('DEBUG: VERIFICATION: Nama: ${verifyData.namaAnggota}');
          print('DEBUG: VERIFICATION: Passport: ${verifyData.nomorPassport}');
          print('DEBUG: VERIFICATION: Bandara: ${verifyData.bandaraPreferensi}');
        } else {
          print('DEBUG: WARNING: Data verification failed - no data found after save!');
        }
        print('DEBUG: =======================================');

        setState(() => _isLoading = false);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Penerbangan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Data penerbangan untuk ${_namaAnggotaController.text.trim()} berhasil disimpan ke database.',
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
        ref.read(dataPenerbanganFilledProvider.notifier).state = true;

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
              'sourcePage': '/data-penerbangan',
              'namaAnggota': _namaAnggotaController.text.trim(),
            },
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(context, theme, 'Gagal menyimpan data penerbangan: ${e.toString()}');
        print('DEBUG: Error saving penerbangan data: $e');
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
      print('DEBUG: ========== PENERBANGAN DEBUG INFO START ==========');
      
      // Check current form data
      print('DEBUG: Current form data:');
      print('  - Nama Anggota: "${_namaAnggotaController.text}"');
      print('  - Nomor Passport: "${_nomorPassportController.text}"');
      print('  - Bandara Preferensi: "${_bandaraPreferensiController.text}"');
      print('  - Maskapai Preferensi: "${_maskapaiPreferensiController.text}"');
      print('  - Kelas Penerbangan: "${_kelasPenerbanganController.text}"');
      print('  - Is Editing: $_isEditing');
      print('  - Is Loading: $_isLoading');
      
      // Check database
      final allPenerbangan = await _repository.getAllPenerbangan();
      print('DEBUG: Total penerbangan in database: ${allPenerbangan.length}');
      
      for (final penerbangan in allPenerbangan) {
        print('DEBUG: Penerbangan - ${penerbangan.namaAnggota}: ${penerbangan.nomorPassport}, ${penerbangan.bandaraPreferensi}, ${penerbangan.maskapaiPreferensi}');
      }
      
      print('DEBUG: ========== PENERBANGAN DEBUG INFO END ==========');
      
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
                Text('Database records: ${allPenerbangan.length}'),
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

  Future<void> _testSaveAndReload() async {
    try {
      print('DEBUG: ========== TEST SAVE AND RELOAD START ==========');
      
      // Fill with test data if form is empty
      if (_namaAnggotaController.text.trim().isEmpty) {
        setState(() {
          _namaAnggotaController.text = 'TEST USER PENERBANGAN';
          _nomorPassportController.text = 'A1234567';
          _bandaraPreferensiController.text = 'Soekarno-Hatta International Airport';
          _maskapaiPreferensiController.text = 'Garuda Indonesia';
          _kelasPenerbanganController.text = 'Business';
        });
        
        // Wait a bit for UI to update
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('DEBUG: Current form data:');
      print('  Nama: ${_namaAnggotaController.text}');
      print('  Passport: ${_nomorPassportController.text}');
      print('  Bandara: ${_bandaraPreferensiController.text}');
      
      // Save to database
      await _repository.savePenerbangan(
        namaAnggota: _namaAnggotaController.text.trim(),
        nomorPassport: _nomorPassportController.text.trim(),
        bandaraPreferensi: _bandaraPreferensiController.text.trim(),
        maskapaiPreferensi: _maskapaiPreferensiController.text.trim(),
        kelasPenerbangan: _kelasPenerbanganController.text.trim(),
      );
      
      print('DEBUG: Data saved successfully');
      
      // Clear form
      setState(() {
        _namaAnggotaController.clear();
        _nomorPassportController.clear();
        _bandaraPreferensiController.clear();
        _maskapaiPreferensiController.clear();
        _kelasPenerbanganController.clear();
      });
      
      print('DEBUG: Form cleared');
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Reload data
      await _loadLatestData();
      
      print('DEBUG: Data reloaded - checking if persisted...');
      print('  Reloaded Nama: ${_namaAnggotaController.text}');
      print('  Reloaded Passport: ${_nomorPassportController.text}');
      
      print('DEBUG: ========== TEST SAVE AND RELOAD END ==========');
      
      // Show result
      if (mounted) {
        final success = _namaAnggotaController.text.trim().isNotEmpty;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'TEST BERHASIL: Data persisten dan berhasil dimuat ulang!'
              : 'TEST GAGAL: Data tidak persisten setelah reload'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
    } catch (e) {
      print('DEBUG: Error in test save and reload: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        print('DEBUG: Database force recreated from penerbangan page');
        
        // Clear form
        _namaAnggotaController.clear();
        _nomorPassportController.clear();
        _bandaraPreferensiController.clear();
        _maskapaiPreferensiController.clear();
        _kelasPenerbanganController.clear();
        
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
        title: 'Data Penerbangan',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('DEBUG: Manual refresh triggered');
              
              setState(() => _isLoading = true);
              
              try {
                await _loadLatestData();
                
                if (mounted) {
                  // Check if data was loaded
                  final hasData = _namaAnggotaController.text.trim().isNotEmpty;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(hasData 
                        ? 'Data berhasil di-refresh: ${_namaAnggotaController.text.trim()}'
                        : 'Refresh selesai - Tidak ada data tersimpan'
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: hasData ? Colors.green : Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error refresh: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'debug':
                  _showDebugInfo();
                  break;
                case 'recreate':
                  _showRecreateDialog();
                  break;
                case 'test_save':
                  _testSaveAndReload();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report),
                    SizedBox(width: 8),
                    Text('Debug Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recreate',
                child: Row(
                  children: [
                    Icon(Icons.refresh_outlined),
                    SizedBox(width: 8),
                    Text('Recreate Database'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_save',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined),
                    SizedBox(width: 8),
                    Text('Test Save & Reload'),
                  ],
                ),
              ),
            ],
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
                        child: Text('Loading data penerbangan dari database...'),
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
                title: 'Data Penerbangan',
                titleIcon: Icons.flight,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nama Anggota',
                    icon: Icons.person,
                    type: _isEditing
                        ? FormFieldType.textRequired
                        : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaAnggotaController,
                    hintText: 'Masukkan nama lengkap anggota DPR RI',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nomor Passport',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nomorPassportController,
                    hintText: 'Masukkan nomor passport',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Bandara Preferensi',
                    icon: Icons.flight_takeoff,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _bandaraPreferensiController,
                    hintText: 'Masukkan bandara preferensi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Maskapai Preferensi',
                    icon: Icons.airplanemode_active,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _maskapaiPreferensiController,
                    hintText: 'Masukkan maskapai preferensi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Kelas Penerbangan',
                    icon: Icons.event_seat,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _kelasPenerbanganController,
                    hintText:
                        'Masukkan kelas penerbangan (Economy/Business/First)',
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
