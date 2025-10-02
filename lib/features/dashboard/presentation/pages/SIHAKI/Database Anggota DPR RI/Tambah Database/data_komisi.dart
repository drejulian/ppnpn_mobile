import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
// SQLite imports
import 'package:ppnpm_dpr/common/data/models/sihaki/data_komisi_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/data_komisi_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataKomisiPage extends ConsumerStatefulWidget {
  const DataKomisiPage({super.key});

  @override
  ConsumerState<DataKomisiPage> createState() => _DataKomisiPageState();
}

class _DataKomisiPageState extends ConsumerState<DataKomisiPage> {
  final Map<String, bool> _showSavedMessage = {};
  late final DataKomisiRepository _repository;
  bool _isLoadingDatabase = true;
  List<DataKomisiModel> _moduleData = [];
  Map<String, dynamic>? _statistics;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _repository = DataKomisiRepository();
    _resetSavedMessage();
    _initializeDatabase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['justSaved'] == true) {
      final sourcePage = extra['sourcePage'] as String? ?? '';

      if (!_showSavedMessage.containsKey(sourcePage)) {
        setState(() {
          _showSavedMessage[sourcePage] = true;
        });
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showSavedMessage.remove(sourcePage);
            });
          }
        });
      }
      
      // Sync database when returning from a page that was just saved
      if (!_isLoadingDatabase && _currentUserId != null) {
        _autoSaveToDatabase();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoadingDatabase && _currentUserId != null) {
        _autoSaveToDatabase();
      }
      setState(() {});
    });
  }

  Future<void> _autoSaveToDatabase() async {
    try {
      print('DEBUG: 💾 Auto-saving to database...');
      
      final moduleStatuses = {
        'data_pribadi': ref.read(dataPribadiFilledProvider),
        'data_feedback_komisi': ref.read(dataFeedbackKomisiFilledProvider),
        'data_keanggotaan': ref.read(dataKeanggotaanFilledProvider),
        'data_kendaraan': ref.read(dataKendaraanFilledProvider),
        'data_penerbangan': ref.read(dataPenerbanganFilledProvider),
        'data_kesehatan': ref.read(dataKesehatanFilledProvider),
        'data_kontak': ref.read(dataKontakFilledProvider),
        'data_tata_naskah': ref.read(dataTataNaskahFilledProvider),
      };
      
      await _repository.syncModuleStatuses(moduleStatuses, userId: _currentUserId);
      await _saveStatusesToPreferences(moduleStatuses);
      await _loadModuleData(); // Reload to update statistics
      
      print('DEBUG: ✅ Auto-save completed');
    } catch (e) {
      print('DEBUG: ❌ Auto-save failed: $e');
    }
  }

  void _resetSavedMessage() {
    if (_showSavedMessage.isNotEmpty) {
      setState(() {
        _showSavedMessage.clear();
      });
    }
  }

  Future<void> _initializeDatabase() async {
    setState(() {
      _isLoadingDatabase = true;
    });

    try {
      print('DEBUG: 🚀 Initializing Data Komisi database...');
      
      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('current_user_id') ?? 'current_user';
      
      print('DEBUG: 👤 Current user ID: $_currentUserId');
      
      // Initialize default modules if needed
      await _repository.initializeDefaultModules(userId: _currentUserId);
      
      // Load module data from database
      await _loadModuleData();
      
      // Load database statuses to providers (this will override any stale provider states)
      await _loadDatabaseStatusesToProviders();
      
      // Final sync to ensure consistency
      await _syncDatabaseWithProviders();
      
      print('DEBUG: ✅ Database initialization completed');
    } catch (e) {
      print('DEBUG: ❌ Database initialization failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDatabase = false;
        });
      }
    }
  }

  Future<void> _loadModuleData() async {
    try {
      print('DEBUG: 📊 Loading module data from database...');
      
      // Load all modules for current user
      _moduleData = await _repository.getDataKomisiByUserId(_currentUserId!);
      
      // Load statistics
      _statistics = await _repository.getCompletionStatistics(userId: _currentUserId);
      
      print('DEBUG: 📋 Loaded ${_moduleData.length} modules');
      print('DEBUG: 📈 Statistics: $_statistics');
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('DEBUG: ❌ Failed to load module data: $e');
    }
  }

  Future<void> _syncWithProviders() async {
    try {
      print('DEBUG: 🔄 Syncing with providers...');
      
      final moduleStatuses = {
        'data_pribadi': ref.read(dataPribadiFilledProvider),
        'data_feedback_komisi': ref.read(dataFeedbackKomisiFilledProvider),
        'data_keanggotaan': ref.read(dataKeanggotaanFilledProvider),
        'data_kendaraan': ref.read(dataKendaraanFilledProvider),
        'data_penerbangan': ref.read(dataPenerbanganFilledProvider),
        'data_kesehatan': ref.read(dataKesehatanFilledProvider),
        'data_kontak': ref.read(dataKontakFilledProvider),
        'data_tata_naskah': ref.read(dataTataNaskahFilledProvider),
      };
      
      print('DEBUG: 📝 Provider statuses: $moduleStatuses');
      
      await _repository.syncModuleStatuses(moduleStatuses, userId: _currentUserId);
      
      // Save to SharedPreferences for persistence
      await _saveStatusesToPreferences(moduleStatuses);
      
      // Reload data after sync
      await _loadModuleData();
      
      print('DEBUG: ✅ Sync with providers completed');
    } catch (e) {
      print('DEBUG: ❌ Failed to sync with providers: $e');
    }
  }

  Future<void> _saveStatusesToPreferences(Map<String, bool> moduleStatuses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final entry in moduleStatuses.entries) {
        await prefs.setBool('module_${entry.key}_filled', entry.value);
      }
      
      // Save completion statistics
      if (_statistics != null) {
        await prefs.setInt('total_modules', _statistics!['total']);
        await prefs.setInt('completed_modules', _statistics!['completed']);
        await prefs.setInt('completion_percentage', _statistics!['completion_percentage']);
      }
      
      print('DEBUG: 💾 Saved module statuses to SharedPreferences');
    } catch (e) {
      print('DEBUG: ❌ Failed to save statuses to preferences: $e');
    }
  }

  Future<void> _loadStatusesFromPreferences() async {
    try {
      print('DEBUG: 📱 Loading statuses from SharedPreferences...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Load module statuses and update providers
      final moduleKeys = [
        'data_pribadi',
        'data_feedback_komisi', 
        'data_keanggotaan',
        'data_kendaraan',
        'data_penerbangan',
        'data_kesehatan',
        'data_kontak',
        'data_tata_naskah',
      ];
      
      for (final key in moduleKeys) {
        final status = prefs.getBool('module_${key}_filled') ?? false;
        print('DEBUG: 📋 Loading $key: $status');
        
        // Update provider based on module name
        switch (key) {
          case 'data_pribadi':
            ref.read(dataPribadiFilledProvider.notifier).state = status;
            break;
          case 'data_feedback_komisi':
            ref.read(dataFeedbackKomisiFilledProvider.notifier).state = status;
            break;
          case 'data_keanggotaan':
            ref.read(dataKeanggotaanFilledProvider.notifier).state = status;
            break;
          case 'data_kendaraan':
            ref.read(dataKendaraanFilledProvider.notifier).state = status;
            break;
          case 'data_penerbangan':
            ref.read(dataPenerbanganFilledProvider.notifier).state = status;
            break;
          case 'data_kesehatan':
            ref.read(dataKesehatanFilledProvider.notifier).state = status;
            break;
          case 'data_kontak':
            ref.read(dataKontakFilledProvider.notifier).state = status;
            break;
          case 'data_tata_naskah':
            ref.read(dataTataNaskahFilledProvider.notifier).state = status;
            break;
        }
      }
      
      print('DEBUG: ✅ Loaded statuses from SharedPreferences');
    } catch (e) {
      print('DEBUG: ❌ Failed to load statuses from preferences: $e');
    }
  }

  Future<void> _syncDatabaseWithProviders() async {
    try {
      print('DEBUG: 🔄 Syncing database with current provider states...');
      
      final moduleStatuses = {
        'data_pribadi': ref.read(dataPribadiFilledProvider),
        'data_feedback_komisi': ref.read(dataFeedbackKomisiFilledProvider),
        'data_keanggotaan': ref.read(dataKeanggotaanFilledProvider),
        'data_kendaraan': ref.read(dataKendaraanFilledProvider),
        'data_penerbangan': ref.read(dataPenerbanganFilledProvider),
        'data_kesehatan': ref.read(dataKesehatanFilledProvider),
        'data_kontak': ref.read(dataKontakFilledProvider),
        'data_tata_naskah': ref.read(dataTataNaskahFilledProvider),
      };
      
      print('DEBUG: 📝 Current provider states: $moduleStatuses');
      
      await _repository.syncModuleStatuses(moduleStatuses, userId: _currentUserId);
      
      // Reload data after sync
      await _loadModuleData();
      
      print('DEBUG: ✅ Database sync with providers completed');
    } catch (e) {
      print('DEBUG: ❌ Failed to sync database with providers: $e');
    }
  }

  Future<void> _loadDatabaseStatusesToProviders() async {
    try {
      print('DEBUG: 📊 Loading database statuses to providers...');
      
      // Load all modules for current user
      final modules = await _repository.getDataKomisiByUserId(_currentUserId!);
      
      for (final module in modules) {
        print('DEBUG: 📋 Module ${module.moduleName}: ${module.isCompleted}');
        
        // Update provider based on module name
        switch (module.moduleName) {
          case 'data_pribadi':
            ref.read(dataPribadiFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_feedback_komisi':
            ref.read(dataFeedbackKomisiFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_keanggotaan':
            ref.read(dataKeanggotaanFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_kendaraan':
            ref.read(dataKendaraanFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_penerbangan':
            ref.read(dataPenerbanganFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_kesehatan':
            ref.read(dataKesehatanFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_kontak':
            ref.read(dataKontakFilledProvider.notifier).state = module.isCompleted;
            break;
          case 'data_tata_naskah':
            ref.read(dataTataNaskahFilledProvider.notifier).state = module.isCompleted;
            break;
        }
      }
      
      // Save updated states to SharedPreferences
      final moduleStatuses = {
        'data_pribadi': ref.read(dataPribadiFilledProvider),
        'data_feedback_komisi': ref.read(dataFeedbackKomisiFilledProvider),
        'data_keanggotaan': ref.read(dataKeanggotaanFilledProvider),
        'data_kendaraan': ref.read(dataKendaraanFilledProvider),
        'data_penerbangan': ref.read(dataPenerbanganFilledProvider),
        'data_kesehatan': ref.read(dataKesehatanFilledProvider),
        'data_kontak': ref.read(dataKontakFilledProvider),
        'data_tata_naskah': ref.read(dataTataNaskahFilledProvider),
      };
      
      await _saveStatusesToPreferences(moduleStatuses);
      
      print('DEBUG: ✅ Database statuses loaded to providers');
    } catch (e) {
      print('DEBUG: ❌ Failed to load database statuses to providers: $e');
    }
  }

  Future<void> _updateModuleStatus(String moduleName, bool isCompleted) async {
    try {
      print('DEBUG: 🔄 Updating module $moduleName status to $isCompleted');
      
      final success = await _repository.updateModuleCompletionStatus(
        moduleName, 
        isCompleted, 
        userId: _currentUserId
      );
      
      if (success) {
        await _loadModuleData();
        print('DEBUG: ✅ Module status updated successfully');
      } else {
        print('DEBUG: ❌ Failed to update module status');
      }
    } catch (e) {
      print('DEBUG: ❌ Error updating module status: $e');
    }
  }

  Future<void> _refreshData() async {
    print('DEBUG: 🔄 Manual data refresh triggered');
    await _syncWithProviders();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil di-refresh dari database'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetAllData() async {
    try {
      print('DEBUG: 🔄 Resetting all module data');
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Semua Data'),
          content: const Text('Apakah Anda yakin ingin mereset semua data modul? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        final success = await _repository.resetAllModules(userId: _currentUserId);
        
        if (success) {
          // Reset providers as well
          ref.read(dataPribadiFilledProvider.notifier).state = false;
          ref.read(dataFeedbackKomisiFilledProvider.notifier).state = false;
          ref.read(dataKeanggotaanFilledProvider.notifier).state = false;
          ref.read(dataKendaraanFilledProvider.notifier).state = false;
          ref.read(dataPenerbanganFilledProvider.notifier).state = false;
          ref.read(dataKesehatanFilledProvider.notifier).state = false;
          ref.read(dataKontakFilledProvider.notifier).state = false;
          ref.read(dataTataNaskahFilledProvider.notifier).state = false;
          
          await _loadModuleData();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Semua data berhasil direset'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          
          print('DEBUG: ✅ All data reset successfully');
        }
      }
    } catch (e) {
      print('DEBUG: ❌ Error resetting data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mereset data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDatabaseInfo() async {
    try {
      print('DEBUG: ========== DATABASE KOMISI INFO ==========');
      print('DEBUG: User ID: $_currentUserId');
      print('DEBUG: Loading state: $_isLoadingDatabase');
      print('DEBUG: Module count: ${_moduleData.length}');
      print('DEBUG: Statistics: $_statistics');
      
      for (final module in _moduleData) {
        print('DEBUG: Module ${module.moduleName}: ${module.isCompleted} (${module.formattedCompletedAt})');
      }
      
      print('DEBUG: ==========================================');
      
      final theme = ref.read(themeProvider);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Database Information',
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
                Text('User ID: $_currentUserId'),
                const SizedBox(height: 8),
                Text('Total modules: ${_moduleData.length}'),
                const SizedBox(height: 8),
                Text('Completed: ${_statistics?['completed'] ?? 0}/${_statistics?['total'] ?? 0}'),
                const SizedBox(height: 8),
                Text('Progress: ${_statistics?['completion_percentage'] ?? 0}%'),
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
      print('DEBUG: Error showing database info: $e');
    }
  }

  bool? _getModuleStatus(String moduleName) {
    try {
      final module = _moduleData.firstWhere(
        (m) => m.moduleName == moduleName,
        orElse: () => throw StateError('Module not found'),
      );
      return module.isCompleted;
    } catch (e) {
      return null; // Return null if module not found in database
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'DATA KOMISI',
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        backTooltip: 'Kembali',
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataPribadiFilled = ref.watch(dataPribadiFilledProvider);
          final dataFeedbackKomisiFilled = ref.watch(
            dataFeedbackKomisiFilledProvider,
          );
          final dataKeanggotaanFilled = ref.watch(
            dataKeanggotaanFilledProvider,
          );
          final dataKendaraanFilled = ref.watch(dataKendaraanFilledProvider);
          final dataPenerbanganFilled = ref.watch(
            dataPenerbanganFilledProvider,
          );
          final dataKesehatanFilled = ref.watch(dataKesehatanFilledProvider);
          final dataKontakFilled = ref.watch(dataKontakFilledProvider);
          final dataTataNaskahFilled = ref.watch(dataTataNaskahFilledProvider);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading indicator
                if (_isLoadingDatabase)
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Memuat Database',
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Menginisialisasi database dan sinkronisasi data modul...',
                                style: theme.typographyRegular.bodySmall.copyWith(
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SIHAKIDataCard(
                  title: 'Database Anggota DPR RI',
                  subtitle: 'Sistem Informasi Anggota (DASI)',
                  leadingIcon: Icons.storage,
                  statusColor: Colors.blue[600],
                  statusText: 'DASI',
                  fields: [
                    SIHAKIDataField(
                      label: 'Total Modul',
                      value: _isLoadingDatabase 
                          ? 'Loading...' 
                          : '${_statistics?['total'] ?? 8} modul data',
                    ),
                    SIHAKIDataField(
                      label: 'Status Pengisian',
                      value: _isLoadingDatabase
                          ? 'Loading...'
                          : _statistics != null
                              ? '${_statistics!['completed']}/${_statistics!['total']} modul lengkap (${_statistics!['completion_percentage']}%)'
                              : _getFilledCount(
                                        dataPribadiFilled,
                                        dataFeedbackKomisiFilled,
                                        dataKeanggotaanFilled,
                                        dataKendaraanFilled,
                                        dataPenerbanganFilled,
                                        dataKesehatanFilled,
                                        dataKontakFilled,
                                        dataTataNaskahFilled,
                                      ) >
                                      0
                                  ? '${_getFilledCount(dataPribadiFilled, dataFeedbackKomisiFilled, dataKeanggotaanFilled, dataKendaraanFilled, dataPenerbanganFilled, dataKesehatanFilled, dataKontakFilled, dataTataNaskahFilled)}/8 modul lengkap'
                                  : 'Belum ada data',
                    ),
                    SIHAKIDataField(
                      label: 'Database Status',
                      value: _isLoadingDatabase
                          ? 'Connecting...'
                          : 'Connected • User: ${_currentUserId ?? 'N/A'}',
                    ),
                    SIHAKIDataField(
                      label: 'Keterangan',
                      value: 'Lengkapi semua modul untuk menyelesaikan pendataan',
                      isLast: true,
                    ),
                  ],
                  actions: [],
                  isTablet: isTablet,
                ),
                const SizedBox(height: 20),

                // Navigation Cards
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Keanggotaan',
                  'Informasi lengkap keanggotaan DPR RI',
                  Icons.group,
                  () async {
                    await context.push('/data-keanggotaan');
                    // Update status setelah kembali
                    _updateModuleStatus('data_keanggotaan', ref.read(dataKeanggotaanFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_keanggotaan') ?? dataKeanggotaanFilled,
                  sourcePage: '/data-keanggotaan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kendaraan',
                  'Data kendaraan dinas dan pribadi',
                  Icons.directions_car,
                  () async {
                    await context.push('/data-kendaraan');
                    _updateModuleStatus('data_kendaraan', ref.read(dataKendaraanFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_kendaraan') ?? dataKendaraanFilled,
                  sourcePage: '/data-kendaraan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Pribadi',
                  'Informasi personal anggota',
                  Icons.person_outline,
                  () async {
                    await context.push('/data-pribadi');
                    _updateModuleStatus('data_pribadi', ref.read(dataPribadiFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_pribadi') ?? dataPribadiFilled,
                  sourcePage: '/data-pribadi',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Penerbangan',
                  'Informasi perjalanan udara',
                  Icons.flight,
                  () async {
                    await context.push('/data-penerbangan');
                    _updateModuleStatus('data_penerbangan', ref.read(dataPenerbanganFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_penerbangan') ?? dataPenerbanganFilled,
                  sourcePage: '/data-penerbangan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kesehatan',
                  'Informasi kesehatan dan vaksinasi',
                  Icons.health_and_safety,
                  () async {
                    await context.push('/data-kesehatan');
                    _updateModuleStatus('data_kesehatan', ref.read(dataKesehatanFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_kesehatan') ?? dataKesehatanFilled,
                  sourcePage: '/data-kesehatan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kontak',
                  'Informasi kontak dan komunikasi',
                  Icons.contact_phone,
                  () async {
                    await context.push('/data-kontak');
                    _updateModuleStatus('data_kontak', ref.read(dataKontakFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_kontak') ?? dataKontakFilled,
                  sourcePage: '/data-kontak',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Tata Naskah',
                  'Pengelolaan dokumen dan arsip',
                  Icons.description,
                  () async {
                    await context.push('/data-tata-naskah');
                    _updateModuleStatus('data_tata_naskah', ref.read(dataTataNaskahFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_tata_naskah') ?? dataTataNaskahFilled,
                  sourcePage: '/data-tata-naskah',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Feedback Komisi',
                  'Umpan balik dan evaluasi komisi',
                  Icons.feedback,
                  () async {
                    await context.push('/data-feedback-komisi');
                    _updateModuleStatus('data_feedback_komisi', ref.read(dataFeedbackKomisiFilledProvider));
                  },
                  isFilled: _getModuleStatus('data_feedback_komisi') ?? dataFeedbackKomisiFilled,
                  sourcePage: '/data-feedback-komisi',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Sync dengan providers terlebih dahulu
                      await _syncWithProviders();
                      
                      final allFilled = _statistics != null 
                          ? (_statistics!['completed'] == _statistics!['total'])
                          : (dataPribadiFilled &&
                              dataFeedbackKomisiFilled &&
                              dataKeanggotaanFilled &&
                              dataKendaraanFilled &&
                              dataPenerbanganFilled &&
                              dataKesehatanFilled &&
                              dataKontakFilled &&
                              dataTataNaskahFilled);

                      final completedCount = _statistics?['completed'] ?? 0;
                      final totalCount = _statistics?['total'] ?? 8;
                      final percentage = _statistics?['completion_percentage'] ?? 0;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            allFilled
                                ? 'Semua data berhasil disimpan! ($completedCount/$totalCount - $percentage%)'
                                : 'Harap lengkapi semua data terlebih dahulu! ($completedCount/$totalCount - $percentage%)',
                          ),
                          backgroundColor:
                              allFilled ? Colors.green : Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      
                      print('DEBUG: 💾 Save button pressed - All filled: $allFilled ($completedCount/$totalCount)');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primarySwatch,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isLoadingDatabase ? 'LOADING...' : 'SIMPAN',
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
        },
      ),
    );
  }

  int _getFilledCount(
    bool dataPribadiFilled,
    bool dataFeedbackKomisiFilled,
    bool dataKeanggotaanFilled,
    bool dataKendaraanFilled,
    bool dataPenerbanganFilled,
    bool dataKesehatanFilled,
    bool dataKontakFilled,
    bool dataTataNaskahFilled,
  ) {
    int count = 0;
    if (dataPribadiFilled) count++;
    if (dataFeedbackKomisiFilled) count++;
    if (dataKeanggotaanFilled) count++;
    if (dataKendaraanFilled) count++;
    if (dataPenerbanganFilled) count++;
    if (dataKesehatanFilled) count++;
    if (dataKontakFilled) count++;
    if (dataTataNaskahFilled) count++;
    return count;
  }

  Widget _buildModernNavigationCard(
    BuildContext context,
    dynamic theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    required bool isFilled,
    required String sourcePage,
    required bool isTablet,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primarySwatch, theme.secondarySwatch],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primarySwatch.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? 24.0 : 20.0,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 14.0 : 12.0,
                        ),
                      ),
                      if (_showSavedMessage[sourcePage] == true) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Data Tersimpan',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status and Arrow
                Row(
                  children: [
                    if (isFilled) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 16.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 14.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
