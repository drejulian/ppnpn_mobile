import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
import 'dart:async';
// SQLite imports
import 'package:ppnpm_dpr/common/data/repositories/sihaki/data_pribadi_repository.dart';

class DataPribadiPage extends ConsumerStatefulWidget {
  const DataPribadiPage({super.key});

  @override
  ConsumerState<DataPribadiPage> createState() => _DataPribadiPageState();
}

class _DataPribadiPageState extends ConsumerState<DataPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnggotaController = TextEditingController();
  final _handphoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _telponRuanganController = TextEditingController();
  final _ruangKerjaController = TextEditingController();
  final _bahasaAsingController = TextEditingController();
  final _alamatRumahController = TextEditingController();
  final _keteranganDomisiliController = TextEditingController();
  final _namaAyahKandungController = TextEditingController();
  final _namaIbuKandungController = TextEditingController();
  final _noRekeningMitraController = TextEditingController();
  final _namaRekeningMitraController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isInitializing = false;
  Timer? _saveTimer;

  // SQLite integration
  late final DataPribadiRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = DataPribadiRepository();
    
    // Add listeners for auto-save
    _namaAnggotaController.addListener(_onFieldChanged);
    _handphoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _telponRuanganController.addListener(_onFieldChanged);
    _ruangKerjaController.addListener(_onFieldChanged);
    _bahasaAsingController.addListener(_onFieldChanged);
    _alamatRumahController.addListener(_onFieldChanged);
    _keteranganDomisiliController.addListener(_onFieldChanged);
    _namaAyahKandungController.addListener(_onFieldChanged);
    _namaIbuKandungController.addListener(_onFieldChanged);
    _noRekeningMitraController.addListener(_onFieldChanged);
    _namaRekeningMitraController.addListener(_onFieldChanged);
    

    
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatabase();
    });
  }

  // Initialize database and handle any setup errors
  Future<void> _initializeDatabase() async {
    if (_isInitializing) {
      print('DEBUG: Already initializing, skipping...');
      return;
    }
    
    try {
      setState(() => _isInitializing = true);
      print('DEBUG: ========== INITIALIZING DATA PRIBADI PAGE ==========');
      print('DEBUG: Initializing database for data pribadi...');
      
      // Try to load data first
      // First test database directly 
      await _testDatabaseDirectly();
      
      print('DEBUG: About to call _loadLatestData...');
      await _loadLatestData();
      print('DEBUG: _loadLatestData completed');
      
      // Verify form is loaded
      print('DEBUG: After loading - Nama: "${_namaAnggotaController.text}", HP: "${_handphoneController.text}"');
      
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
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
    // Don't auto-save during initialization or if not editing
    if (!_isEditing || _isInitializing) return;
    
    // Cancel previous timer if exists
    _saveTimer?.cancel();
    
    // Set new timer for auto-save (1 second delay)
    _saveTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _namaAnggotaController.text.trim().isNotEmpty && !_isInitializing) {
        _autoSaveData();
      }
    });
  }



  Future<void> _autoSaveData() async {
    if (!_isAllRequiredFilled()) return;
    
    try {
      await _repository.saveDataPribadi(
        namaAnggota: _namaAnggotaController.text.trim(),
        handphone: _handphoneController.text.trim(),
        email: _emailController.text.trim(),
        telponRuangan: _telponRuanganController.text.trim(),
        ruangKerja: _ruangKerjaController.text.trim(),
        bahasaAsing: _bahasaAsingController.text.trim(),
        alamatRumah: _alamatRumahController.text.trim(),
        keteranganDomisili: _keteranganDomisiliController.text.trim(),
        namaAyahKandung: _namaAyahKandungController.text.trim(),
        namaIbuKandung: _namaIbuKandungController.text.trim(),
        noRekeningMitra: _noRekeningMitraController.text.trim(),
        namaRekeningMitra: _namaRekeningMitraController.text.trim(),
      );
      
      print('DEBUG: Auto-saved data pribadi for ${_namaAnggotaController.text.trim()}');
    } catch (e) {
      print('DEBUG: Auto-save failed: $e');
    }
  }

  Future<void> _loadLatestData() async {
    if (_isLoading) {
      print('DEBUG: Already loading data, skipping...');
      return;
    }
    
    try {
      setState(() => _isLoading = true);
      
      print('DEBUG: Loading latest data pribadi...');
      
      // First ensure database connection is working
      await _repository.getDataPribadiCount();
      print('DEBUG: Database connection verified');
      
      // Try to get all data pribadi first to check what's in database
      final allDataPribadi = await _repository.getAllDataPribadi();
      print('DEBUG: Found ${allDataPribadi.length} data pribadi records in database');
      
      if (allDataPribadi.isNotEmpty) {
        // Get the latest (most recently updated)
        final latestDataPribadi = allDataPribadi.first;
        
        if (mounted) {
          setState(() {
            _namaAnggotaController.text = latestDataPribadi.namaAnggota;
            _handphoneController.text = latestDataPribadi.handphone;
            _emailController.text = latestDataPribadi.email;
            _telponRuanganController.text = latestDataPribadi.telponRuangan;
            _ruangKerjaController.text = latestDataPribadi.ruangKerja;
            _bahasaAsingController.text = latestDataPribadi.bahasaAsing;
            _alamatRumahController.text = latestDataPribadi.alamatRumah;
            _keteranganDomisiliController.text = latestDataPribadi.keteranganDomisili;
            _namaAyahKandungController.text = latestDataPribadi.namaAyahKandung;
            _namaIbuKandungController.text = latestDataPribadi.namaIbuKandung;
            _noRekeningMitraController.text = latestDataPribadi.noRekeningMitra;
            _namaRekeningMitraController.text = latestDataPribadi.namaRekeningMitra;
          });
          
          print('DEBUG: ✅ Successfully loaded data pribadi for ${latestDataPribadi.namaAnggota}');
          print('DEBUG: ✅ Loaded fields - HP: ${latestDataPribadi.handphone}, Email: ${latestDataPribadi.email}');
          print('DEBUG: ✅ Form controllers have been populated with database data');
        }
      } else {
        print('DEBUG: No data pribadi found in database - starting with empty form');
        
        // Clear form when no data
        if (mounted) {
          setState(() {
            _namaAnggotaController.clear();
            _handphoneController.clear();
            _emailController.clear();
            _telponRuanganController.clear();
            _ruangKerjaController.clear();
            _bahasaAsingController.clear();
            _alamatRumahController.clear();
            _keteranganDomisiliController.clear();
            _namaAyahKandungController.clear();
            _namaIbuKandungController.clear();
            _noRekeningMitraController.clear();
            _namaRekeningMitraController.clear();
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
      print('DEBUG: Error loading data pribadi: $e');
      
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
    ref.read(dataPribadiFilledProvider.notifier).state = isFilled;
  }

  Future<void> _testDatabaseDirectly() async {
    try {
      print('DEBUG: ========== TESTING DATABASE DIRECTLY ==========');
      
      // Test database connection
      final count = await _repository.getDataPribadiCount();
      print('DEBUG: Database connection OK, total records: $count');
      
      if (count > 0) {
        // Test getting all data
        final allData = await _repository.getAllDataPribadi();
        print('DEBUG: Retrieved ${allData.length} records from database');
        
        for (int i = 0; i < allData.length && i < 3; i++) {
          final data = allData[i];
          print('DEBUG: Record $i: ${data.namaAnggota} - ${data.handphone} - ${data.email}');
          print('DEBUG: Updated at: ${data.updatedAt}');
        }
        
        if (allData.isNotEmpty) {
          final latest = allData.first;
          print('DEBUG: Latest record should load: ${latest.namaAnggota}');
        }
      } else {
        print('DEBUG: No records found in database');
      }
      
      print('DEBUG: ========== DATABASE TEST COMPLETED ==========');
    } catch (e) {
      print('DEBUG: Database test error: $e');
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _namaAnggotaController.removeListener(_onFieldChanged);

    _handphoneController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _telponRuanganController.removeListener(_onFieldChanged);
    _ruangKerjaController.removeListener(_onFieldChanged);
    _bahasaAsingController.removeListener(_onFieldChanged);
    _alamatRumahController.removeListener(_onFieldChanged);
    _keteranganDomisiliController.removeListener(_onFieldChanged);
    _namaAyahKandungController.removeListener(_onFieldChanged);
    _namaIbuKandungController.removeListener(_onFieldChanged);
    _noRekeningMitraController.removeListener(_onFieldChanged);
    _namaRekeningMitraController.removeListener(_onFieldChanged);
    
    _namaAnggotaController.dispose();
    _handphoneController.dispose();
    _emailController.dispose();
    _telponRuanganController.dispose();
    _ruangKerjaController.dispose();
    _bahasaAsingController.dispose();
    _alamatRumahController.dispose();
    _keteranganDomisiliController.dispose();
    _namaAyahKandungController.dispose();
    _namaIbuKandungController.dispose();
    _noRekeningMitraController.dispose();
    _namaRekeningMitraController.dispose();
    
    _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _namaAnggotaController.text.trim().isNotEmpty &&
        _handphoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _telponRuanganController.text.isNotEmpty &&
        _ruangKerjaController.text.isNotEmpty &&
        _bahasaAsingController.text.isNotEmpty &&
        _alamatRumahController.text.isNotEmpty &&
        _keteranganDomisiliController.text.isNotEmpty &&
        _namaAyahKandungController.text.isNotEmpty &&
        _namaIbuKandungController.text.isNotEmpty &&
        _noRekeningMitraController.text.isNotEmpty &&
        _namaRekeningMitraController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
        title: 'Data Pribadi',
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
                        child: Text('Loading data pribadi dari database...'),
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
                title: 'Data Pribadi Utama',
                titleIcon: Icons.person_outline,
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
                    label: 'Handphone',
                    icon: Icons.phone_android,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _handphoneController,
                    hintText: 'Masukkan nomor handphone',
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
                    label: 'Email',
                    icon: Icons.email,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _emailController,
                    hintText: 'Masukkan alamat email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Telepon Ruangan',
                    icon: Icons.phone,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _telponRuanganController,
                    hintText: 'Masukkan nomor telepon ruangan',
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
                    label: 'Ruang Kerja',
                    icon: Icons.work,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _ruangKerjaController,
                    hintText: 'Masukkan ruang kerja',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Bahasa Asing',
                    icon: Icons.language,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _bahasaAsingController,
                    hintText: 'Masukkan bahasa asing yang dikuasai',
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
                title: 'Data Tambahan',
                titleIcon: Icons.info_outline,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Alamat Rumah',
                    icon: Icons.home,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _alamatRumahController,
                    hintText: 'Masukkan alamat rumah',
                    maxLines: 3,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Keterangan Domisili',
                    icon: Icons.location_city,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _keteranganDomisiliController,
                    hintText: 'Masukkan keterangan domisili',
                    maxLines: 3,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nama Ayah Kandung',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaAyahKandungController,
                    hintText: 'Masukkan nama ayah kandung',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nama Ibu Kandung',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaIbuKandungController,
                    hintText: 'Masukkan nama ibu kandung',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'No. Rekening Mitra',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _noRekeningMitraController,
                    hintText: 'Masukkan nomor rekening mitra',
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
                    label: 'Nama Rekening Mitra',
                    icon: Icons.person,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _namaRekeningMitraController,
                    hintText: 'Masukkan nama rekening mitra',
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
      if (_handphoneController.text.isEmpty) {
        errors.add('Handphone harus diisi');
      }
      if (_emailController.text.isEmpty) {
        errors.add('Email harus diisi');
      }
      if (_telponRuanganController.text.isEmpty) {
        errors.add('Telepon Ruangan harus diisi');
      }
      if (_ruangKerjaController.text.isEmpty) {
        errors.add('Ruang Kerja harus diisi');
      }
      if (_bahasaAsingController.text.isEmpty) {
        errors.add('Bahasa Asing harus diisi');
      }
      if (_alamatRumahController.text.isEmpty) {
        errors.add('Alamat Rumah harus diisi');
      }
      if (_keteranganDomisiliController.text.isEmpty) {
        errors.add('Keterangan Domisili harus diisi');
      }
      if (_namaAyahKandungController.text.isEmpty) {
        errors.add('Nama Ayah Kandung harus diisi');
      }
      if (_namaIbuKandungController.text.isEmpty) {
        errors.add('Nama Ibu Kandung harus diisi');
      }
      if (_noRekeningMitraController.text.isEmpty) {
        errors.add('No. Rekening Mitra harus diisi');
      }
      if (_namaRekeningMitraController.text.isEmpty) {
        errors.add('Nama Rekening Mitra harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        setState(() => _isLoading = true);

        // Save to SQLite database
        await _repository.saveDataPribadi(
          namaAnggota: _namaAnggotaController.text.trim(),
          handphone: _handphoneController.text.trim(),
          email: _emailController.text.trim(),
          telponRuangan: _telponRuanganController.text.trim(),
          ruangKerja: _ruangKerjaController.text.trim(),
          bahasaAsing: _bahasaAsingController.text.trim(),
          alamatRumah: _alamatRumahController.text.trim(),
          keteranganDomisili: _keteranganDomisiliController.text.trim(),
          namaAyahKandung: _namaAyahKandungController.text.trim(),
          namaIbuKandung: _namaIbuKandungController.text.trim(),
          noRekeningMitra: _noRekeningMitraController.text.trim(),
          namaRekeningMitra: _namaRekeningMitraController.text.trim(),
        );

        print('DEBUG: ========== DATA SAVE SUCCESSFUL ==========');
        print('DEBUG: Saved data pribadi to SQLite for ${_namaAnggotaController.text.trim()}');
        
        // Verify the save by immediately reading it back
        final verifyData = await _repository.getDataPribadiByNama(_namaAnggotaController.text.trim());
        if (verifyData != null) {
          print('DEBUG: VERIFICATION: Data successfully written to database');
          print('DEBUG: VERIFICATION: Nama: ${verifyData.namaAnggota}');
          print('DEBUG: VERIFICATION: Handphone: ${verifyData.handphone}');
          print('DEBUG: VERIFICATION: Email: ${verifyData.email}');
        } else {
          print('DEBUG: WARNING: Data verification failed - no data found after save!');
        }
        print('DEBUG: =======================================');

        setState(() => _isLoading = false);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Pribadi',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Data pribadi untuk ${_namaAnggotaController.text.trim()} berhasil disimpan ke database.',
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
        ref.read(dataPribadiFilledProvider.notifier).state = true;

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
              'sourcePage': '/data-pribadi',
              'namaAnggota': _namaAnggotaController.text.trim(),
            },
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(context, theme, 'Gagal menyimpan data pribadi: ${e.toString()}');
        print('DEBUG: Error saving data pribadi: $e');
      }
    }
  }

  Future<void> _showDebugInfo() async {
    try {
      print('DEBUG: ========== DATA PRIBADI DEBUG INFO START ==========');
      
      // Check current form data
      print('DEBUG: Current form data:');
      print('  - Nama Anggota: "${_namaAnggotaController.text}"');
      print('  - Handphone: "${_handphoneController.text}"');
      print('  - Email: "${_emailController.text}"');
      print('  - Telepon Ruangan: "${_telponRuanganController.text}"');
      print('  - Ruang Kerja: "${_ruangKerjaController.text}"');
      print('  - Is Editing: $_isEditing');
      print('  - Is Loading: $_isLoading');
      
      // Check database
      final allDataPribadi = await _repository.getAllDataPribadi();
      print('DEBUG: Total data pribadi in database: ${allDataPribadi.length}');
      
      for (final dataPribadi in allDataPribadi) {
        print('DEBUG: Data Pribadi - ${dataPribadi.namaAnggota}: ${dataPribadi.handphone}, ${dataPribadi.email}');
      }
      
      print('DEBUG: ========== DATA PRIBADI DEBUG INFO END ==========');
      
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
                Text('Database records: ${allDataPribadi.length}'),
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
        print('DEBUG: Database force recreated from data pribadi page');
        
        // Clear form
        _namaAnggotaController.clear();
        _handphoneController.clear();
        _emailController.clear();
        _telponRuanganController.clear();
        _ruangKerjaController.clear();
        _bahasaAsingController.clear();
        _alamatRumahController.clear();
        _keteranganDomisiliController.clear();
        _namaAyahKandungController.clear();
        _namaIbuKandungController.clear();
        _noRekeningMitraController.clear();
        _namaRekeningMitraController.clear();
        
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

  Future<void> _testSaveAndReload() async {
    try {
      print('DEBUG: ========== TEST SAVE AND RELOAD START ==========');
      
      // Fill with test data if form is empty
      if (_namaAnggotaController.text.trim().isEmpty) {
        setState(() {
          _namaAnggotaController.text = 'TEST USER DATA PRIBADI';
          _handphoneController.text = '081234567890';
          _emailController.text = 'test.user@dpr.go.id';
          _telponRuanganController.text = '021-5715409';
          _ruangKerjaController.text = 'Gedung DPR RI Lt. 5 Ruang 510';
          _bahasaAsingController.text = 'English, Mandarin';
          _alamatRumahController.text = 'Jl. Test No. 123, Jakarta Pusat';
          _keteranganDomisiliController.text = 'Jakarta Pusat, DKI Jakarta';
          _namaAyahKandungController.text = 'Bapak Test';
          _namaIbuKandungController.text = 'Ibu Test';
          _noRekeningMitraController.text = '1234567890';
          _namaRekeningMitraController.text = 'Test User Rekening';
        });
        
        // Wait a bit for UI to update
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('DEBUG: Current form data:');
      print('  Nama: ${_namaAnggotaController.text}');
      print('  Handphone: ${_handphoneController.text}');
      print('  Email: ${_emailController.text}');
      
      // Save to database
      await _repository.saveDataPribadi(
        namaAnggota: _namaAnggotaController.text.trim(),
        handphone: _handphoneController.text.trim(),
        email: _emailController.text.trim(),
        telponRuangan: _telponRuanganController.text.trim(),
        ruangKerja: _ruangKerjaController.text.trim(),
        bahasaAsing: _bahasaAsingController.text.trim(),
        alamatRumah: _alamatRumahController.text.trim(),
        keteranganDomisili: _keteranganDomisiliController.text.trim(),
        namaAyahKandung: _namaAyahKandungController.text.trim(),
        namaIbuKandung: _namaIbuKandungController.text.trim(),
        noRekeningMitra: _noRekeningMitraController.text.trim(),
        namaRekeningMitra: _namaRekeningMitraController.text.trim(),
      );
      
      print('DEBUG: Data saved successfully');
      
      // Clear form
      setState(() {
        _namaAnggotaController.clear();
        _handphoneController.clear();
        _emailController.clear();
        _telponRuanganController.clear();
        _ruangKerjaController.clear();
        _bahasaAsingController.clear();
        _alamatRumahController.clear();
        _keteranganDomisiliController.clear();
        _namaAyahKandungController.clear();
        _namaIbuKandungController.clear();
        _noRekeningMitraController.clear();
        _namaRekeningMitraController.clear();
      });
      
      print('DEBUG: Form cleared');
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Reload data
      await _loadLatestData();
      
      print('DEBUG: Data reloaded - checking if persisted...');
      print('  Reloaded Nama: ${_namaAnggotaController.text}');
      print('  Reloaded Handphone: ${_handphoneController.text}');
      
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
}
