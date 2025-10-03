import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/profile_data_provider.dart';
// SQLite imports
import 'package:ppnpm_dpr/common/services/profile_service.dart';

class PribadiPage extends ConsumerStatefulWidget {
  const PribadiPage({super.key});

  @override
  ConsumerState<PribadiPage> createState() => _PribadiPageState();
}

class _PribadiPageState extends ConsumerState<PribadiPage> {
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _propinsiController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _teleponRumahController = TextEditingController();
  final TextEditingController _teleponKantorController = TextEditingController();
  final TextEditingController _handphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // SQLite service
  final ProfileService _profileService = ProfileService();

  String _selectedStatusPerkawinan = 'Kawin';
  String _selectedAgama = 'Islam';
  String _selectedGolonganDarah = 'O';
  String _selectedJenisKelamin = 'Laki-Laki';
  String _selectedStatusDomisili = 'Alamat Rumah dan Alamat Sesuai KTP';
  bool _hasUnsavedChanges = false;

  final List<String> _statusPerkawinanOptions = [
    'Belum Kawin',
    'Kawin',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  final List<String> _golonganDarahOptions = ['A', 'B', 'AB', 'O'];

  final List<String> _jenisKelaminOptions = ['Laki-Laki', 'Perempuan'];

  final List<String> _statusDomisiliOptions = [
    'Alamat Rumah dan Alamat Sesuai KTP',
    'Alamat Rumah dan Alamat Sesuai KTP berbeda',
  ];

  @override
  void initState() {
    super.initState();
    _tempatLahirController.addListener(_updateUnsavedChanges);
    _tanggalLahirController.addListener(_updateUnsavedChanges);
    _addressController.addListener(_updateUnsavedChanges);
    _propinsiController.addListener(_updateUnsavedChanges);
    _kotaController.addListener(_updateUnsavedChanges);
    _kecamatanController.addListener(_updateUnsavedChanges);
    _kelurahanController.addListener(_updateUnsavedChanges);
    _rtController.addListener(_updateUnsavedChanges);
    _rwController.addListener(_updateUnsavedChanges);
    _kodePosController.addListener(_updateUnsavedChanges);
    _teleponRumahController.addListener(_updateUnsavedChanges);
    _teleponKantorController.addListener(_updateUnsavedChanges);
    _handphoneController.addListener(_updateUnsavedChanges);
    _emailController.addListener(_updateUnsavedChanges);

    // Initialize SQLite and load data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAndLoadData();
      
      SharedPreferences.getInstance().then((prefs) {
        final hasChanges = prefs.getBool('pribadi_has_changes') ?? false;
        if (hasChanges && mounted) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedData = ref.read(pribadiDataProvider);
    if (_tempatLahirController.text.isEmpty) {
      _tempatLahirController.text = savedData.tempatLahir.isNotEmpty ? savedData.tempatLahir : '';
      _tanggalLahirController.text = savedData.tanggalLahir.isNotEmpty ? savedData.tanggalLahir : '';
      _addressController.text = savedData.address.isNotEmpty ? savedData.address : '';
      _propinsiController.text = savedData.propinsi.isNotEmpty ? savedData.propinsi : '';
      _kotaController.text = savedData.kota.isNotEmpty ? savedData.kota : '';
      _kecamatanController.text = savedData.kecamatan.isNotEmpty ? savedData.kecamatan : '';
      _kelurahanController.text = savedData.kelurahan.isNotEmpty ? savedData.kelurahan : '';
      _rtController.text = savedData.rt.isNotEmpty ? savedData.rt : '000';
      _rwController.text = savedData.rw.isNotEmpty ? savedData.rw : '000';
      _kodePosController.text = savedData.kodePos.isNotEmpty ? savedData.kodePos : '';
      _teleponRumahController.text = savedData.teleponRumah.isNotEmpty ? savedData.teleponRumah : '';
      _teleponKantorController.text = savedData.teleponKantor.isNotEmpty ? savedData.teleponKantor : '';
      _handphoneController.text = savedData.handphone.isNotEmpty ? savedData.handphone : '';
      _emailController.text = savedData.email.isNotEmpty ? savedData.email : '';
      _selectedStatusPerkawinan = savedData.statusPerkawinan.isNotEmpty ? savedData.statusPerkawinan : 'Kawin';
      _selectedAgama = savedData.agama.isNotEmpty ? savedData.agama : 'Islam';
      _selectedGolonganDarah = savedData.golonganDarah.isNotEmpty ? savedData.golonganDarah : 'O';
      _selectedJenisKelamin = savedData.jenisKelamin.isNotEmpty ? savedData.jenisKelamin : 'Laki-Laki';
      _selectedStatusDomisili = savedData.statusDomisili.isNotEmpty ? savedData.statusDomisili : 'Alamat Rumah dan Alamat Sesuai KTP';
    }
  }

  /// Initialize SQLite service and load data
  Future<void> _initializeAndLoadData() async {
    try {
      print('PribadiPage: Initializing SQLite...');
      
      // Initialize ProfileService
      await _profileService.initialize();
      
      // Load data from SQLite first
      await _loadDataFromSQLite();
      
      print('PribadiPage: SQLite initialization completed');
    } catch (e) {
      print('PribadiPage: Error initializing SQLite: $e');
    }
  }

  /// Load data from SQLite database
  Future<void> _loadDataFromSQLite() async {
    try {
      print('PribadiPage: Loading data from SQLite...');
      
      // Get pribadi data from SQLite
      final pribadiData = await _profileService.getCurrentPribadiData();
      
      if (pribadiData != null && mounted) {
        // Update controllers with SQLite data
        setState(() {
          _tempatLahirController.text = pribadiData.tempatLahir;
          _tanggalLahirController.text = pribadiData.tanggalLahir;
          _addressController.text = pribadiData.address;
          _propinsiController.text = pribadiData.propinsi;
          _kotaController.text = pribadiData.kota;
          _kecamatanController.text = pribadiData.kecamatan;
          _kelurahanController.text = pribadiData.kelurahan;
          _rtController.text = pribadiData.rt;
          _rwController.text = pribadiData.rw;
          _kodePosController.text = pribadiData.kodePos;
          _teleponRumahController.text = pribadiData.teleponRumah;
          _teleponKantorController.text = pribadiData.teleponKantor;
          _handphoneController.text = pribadiData.handphone;
          _emailController.text = pribadiData.email;
          _selectedStatusPerkawinan = pribadiData.statusPerkawinan;
          _selectedAgama = pribadiData.agama;
          _selectedGolonganDarah = pribadiData.golonganDarah;
          _selectedJenisKelamin = pribadiData.jenisKelamin;
          _selectedStatusDomisili = pribadiData.statusDomisili;
        });

        // Update Riverpod provider with SQLite data
        final updatedPribadiData = PribadiData(
          tempatLahir: pribadiData.tempatLahir,
          tanggalLahir: pribadiData.tanggalLahir,
          address: pribadiData.address,
          propinsi: pribadiData.propinsi,
          kota: pribadiData.kota,
          kecamatan: pribadiData.kecamatan,
          kelurahan: pribadiData.kelurahan,
          rt: pribadiData.rt,
          rw: pribadiData.rw,
          kodePos: pribadiData.kodePos,
          teleponRumah: pribadiData.teleponRumah,
          teleponKantor: pribadiData.teleponKantor,
          handphone: pribadiData.handphone,
          email: pribadiData.email,
          statusPerkawinan: pribadiData.statusPerkawinan,
          agama: pribadiData.agama,
          golonganDarah: pribadiData.golonganDarah,
          jenisKelamin: pribadiData.jenisKelamin,
          statusDomisili: pribadiData.statusDomisili,
        );
        
        ref.read(pribadiDataProvider.notifier).updateData(updatedPribadiData);
        ref.read(profileCompletionProvider.notifier).markCompleted('identitasDiri');

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pribadi_user_saved', true);

        print('PribadiPage: Data loaded from SQLite successfully');
        print('  - Tempat Lahir: ${pribadiData.tempatLahir}');
        print('  - Email: ${pribadiData.email}');
        print('  - Handphone: ${pribadiData.handphone}');
        print('  - Address: ${pribadiData.address.length > 50 ? pribadiData.address.substring(0, 50) + "..." : pribadiData.address}');
      } else {
        print('PribadiPage: No data found in SQLite, using defaults from provider');
        
        // Use existing provider data if no SQLite data
        final savedData = ref.read(pribadiDataProvider);
        if (_tempatLahirController.text.isEmpty) {
          _tempatLahirController.text = savedData.tempatLahir;
          _tanggalLahirController.text = savedData.tanggalLahir;
          _addressController.text = savedData.address;
          _propinsiController.text = savedData.propinsi;
          _kotaController.text = savedData.kota;
          _kecamatanController.text = savedData.kecamatan;
          _kelurahanController.text = savedData.kelurahan;
          _rtController.text = savedData.rt.isNotEmpty ? savedData.rt : '000';
          _rwController.text = savedData.rw.isNotEmpty ? savedData.rw : '000';
          _kodePosController.text = savedData.kodePos;
          _teleponRumahController.text = savedData.teleponRumah;
          _teleponKantorController.text = savedData.teleponKantor;
          _handphoneController.text = savedData.handphone;
          _emailController.text = savedData.email;
          _selectedStatusPerkawinan = savedData.statusPerkawinan.isNotEmpty ? savedData.statusPerkawinan : 'Kawin';
          _selectedAgama = savedData.agama.isNotEmpty ? savedData.agama : 'Islam';
          _selectedGolonganDarah = savedData.golonganDarah.isNotEmpty ? savedData.golonganDarah : 'O';
          _selectedJenisKelamin = savedData.jenisKelamin.isNotEmpty ? savedData.jenisKelamin : 'Laki-Laki';
          _selectedStatusDomisili = savedData.statusDomisili.isNotEmpty ? savedData.statusDomisili : 'Alamat Rumah dan Alamat Sesuai KTP';
        }
      }
    } catch (e) {
      print('PribadiPage: Error loading data from SQLite: $e');
    }
  }

  @override
  void dispose() {
    _tempatLahirController.removeListener(_updateUnsavedChanges);
    _tanggalLahirController.removeListener(_updateUnsavedChanges);
    _addressController.removeListener(_updateUnsavedChanges);
    _propinsiController.removeListener(_updateUnsavedChanges);
    _kotaController.removeListener(_updateUnsavedChanges);
    _kecamatanController.removeListener(_updateUnsavedChanges);
    _kelurahanController.removeListener(_updateUnsavedChanges);
    _rtController.removeListener(_updateUnsavedChanges);
    _rwController.removeListener(_updateUnsavedChanges);
    _kodePosController.removeListener(_updateUnsavedChanges);
    _teleponRumahController.removeListener(_updateUnsavedChanges);
    _teleponKantorController.removeListener(_updateUnsavedChanges);
    _handphoneController.removeListener(_updateUnsavedChanges);
    _emailController.removeListener(_updateUnsavedChanges);
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _addressController.dispose();
    _propinsiController.dispose();
    _kotaController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _kodePosController.dispose();
    _teleponRumahController.dispose();
    _teleponKantorController.dispose();
    _handphoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateUnsavedChanges() {
    final hasChanges = _hasUnsavedChangesInternal();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('pribadi_has_changes', hasChanges);
    });
    if (mounted) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  bool _hasUnsavedChangesInternal() {
    final savedData = ref.read(pribadiDataProvider);
    final expectedTempatLahir = savedData.tempatLahir.isNotEmpty ? savedData.tempatLahir : '';
    final expectedTanggalLahir = savedData.tanggalLahir.isNotEmpty ? savedData.tanggalLahir : '';
    final expectedAddress = savedData.address.isNotEmpty ? savedData.address : '';
    final expectedPropinsi = savedData.propinsi.isNotEmpty ? savedData.propinsi : '';
    final expectedKota = savedData.kota.isNotEmpty ? savedData.kota : '';
    final expectedKecamatan = savedData.kecamatan.isNotEmpty ? savedData.kecamatan : '';
    final expectedKelurahan = savedData.kelurahan.isNotEmpty ? savedData.kelurahan : '';
    final expectedRt = savedData.rt.isNotEmpty ? savedData.rt : '000';
    final expectedRw = savedData.rw.isNotEmpty ? savedData.rw : '000';
    final expectedKodePos = savedData.kodePos.isNotEmpty ? savedData.kodePos : '';
    final expectedTeleponRumah = savedData.teleponRumah.isNotEmpty ? savedData.teleponRumah : '';
    final expectedTeleponKantor = savedData.teleponKantor.isNotEmpty ? savedData.teleponKantor : '';
    final expectedHandphone = savedData.handphone.isNotEmpty ? savedData.handphone : '';
    final expectedEmail = savedData.email.isNotEmpty ? savedData.email : '';
    final expectedStatusPerkawinan = savedData.statusPerkawinan.isNotEmpty ? savedData.statusPerkawinan : 'Kawin';
    final expectedAgama = savedData.agama.isNotEmpty ? savedData.agama : 'Islam';
    final expectedGolonganDarah = savedData.golonganDarah.isNotEmpty ? savedData.golonganDarah : 'O';
    final expectedJenisKelamin = savedData.jenisKelamin.isNotEmpty ? savedData.jenisKelamin : 'Laki-Laki';
    final expectedStatusDomisili = savedData.statusDomisili.isNotEmpty ? savedData.statusDomisili : 'Alamat Rumah dan Alamat Sesuai KTP';

    return _tempatLahirController.text.trim() != expectedTempatLahir.trim() ||
        _tanggalLahirController.text.trim() != expectedTanggalLahir.trim() ||
        _addressController.text.trim() != expectedAddress.trim() ||
        _propinsiController.text.trim() != expectedPropinsi.trim() ||
        _kotaController.text.trim() != expectedKota.trim() ||
        _kecamatanController.text.trim() != expectedKecamatan.trim() ||
        _kelurahanController.text.trim() != expectedKelurahan.trim() ||
        _rtController.text.trim() != expectedRt.trim() ||
        _rwController.text.trim() != expectedRw.trim() ||
        _kodePosController.text.trim() != expectedKodePos.trim() ||
        _teleponRumahController.text.trim() != expectedTeleponRumah.trim() ||
        _teleponKantorController.text.trim() != expectedTeleponKantor.trim() ||
        _handphoneController.text.trim() != expectedHandphone.trim() ||
        _emailController.text.trim() != expectedEmail.trim() ||
        _selectedStatusPerkawinan != expectedStatusPerkawinan ||
        _selectedAgama != expectedAgama ||
        _selectedGolonganDarah != expectedGolonganDarah ||
        _selectedJenisKelamin != expectedJenisKelamin ||
        _selectedStatusDomisili != expectedStatusDomisili;
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final savedData = ref.read(pribadiDataProvider);
    bool? result = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan Data Pribadi',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        if (context.mounted) {
          try {
            // Reload data from SQLite to restore last saved state
            await _loadDataFromSQLite();
          } catch (e) {
            print('PribadiPage: Error reloading data from SQLite: $e');
            
            // Fallback to provider data
            _tempatLahirController.text = savedData.tempatLahir.isNotEmpty ? savedData.tempatLahir : '';
            _tanggalLahirController.text = savedData.tanggalLahir.isNotEmpty ? savedData.tanggalLahir : '';
            _addressController.text = savedData.address.isNotEmpty ? savedData.address : '';
            _propinsiController.text = savedData.propinsi.isNotEmpty ? savedData.propinsi : '';
            _kotaController.text = savedData.kota.isNotEmpty ? savedData.kota : '';
            _kecamatanController.text = savedData.kecamatan.isNotEmpty ? savedData.kecamatan : '';
            _kelurahanController.text = savedData.kelurahan.isNotEmpty ? savedData.kelurahan : '';
            _rtController.text = savedData.rt.isNotEmpty ? savedData.rt : '000';
            _rwController.text = savedData.rw.isNotEmpty ? savedData.rw : '000';
            _kodePosController.text = savedData.kodePos.isNotEmpty ? savedData.kodePos : '';
            _teleponRumahController.text = savedData.teleponRumah.isNotEmpty ? savedData.teleponRumah : '';
            _teleponKantorController.text = savedData.teleponKantor.isNotEmpty ? savedData.teleponKantor : '';
            _handphoneController.text = savedData.handphone.isNotEmpty ? savedData.handphone : '';
            _emailController.text = savedData.email.isNotEmpty ? savedData.email : '';
            _selectedStatusPerkawinan = savedData.statusPerkawinan.isNotEmpty ? savedData.statusPerkawinan : 'Kawin';
            _selectedAgama = savedData.agama.isNotEmpty ? savedData.agama : 'Islam';
            _selectedGolonganDarah = savedData.golonganDarah.isNotEmpty ? savedData.golonganDarah : 'O';
            _selectedJenisKelamin = savedData.jenisKelamin.isNotEmpty ? savedData.jenisKelamin : 'Laki-Laki';
            _selectedStatusDomisili = savedData.statusDomisili.isNotEmpty ? savedData.statusDomisili : 'Alamat Rumah dan Alamat Sesuai KTP';
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('pribadi_has_changes', false);

          setState(() {
            _hasUnsavedChanges = false;
          });

          notification.NotificationUtils.showWarning(
            context,
            'Perubahan pada data pribadi telah dibatalkan',
          );

          if (context.mounted) {
            context.pop();
          }
        }
      },
      onCancel: () {},
    );
    return result ?? false;
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
        if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
          final shouldLeave = await _showUnsavedChangesDialog(context, theme);
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Pribadi',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug SQLite',
            onPressed: () => _showPribadiDebug(context),
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
                _buildFormDataPribadi(theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormDataPribadi(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Pribadi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            'Status Perkawinan (Marital Status)',
            _selectedStatusPerkawinan,
            _statusPerkawinanOptions,
            Icons.favorite,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedStatusPerkawinan = value!;
                _updateUnsavedChanges();
              });
            },
          ),
          _buildDropdownField(
            'Agama (Religion)',
            _selectedAgama,
            _agamaOptions,
            Icons.place,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedAgama = value!;
                _updateUnsavedChanges();
              });
            },
          ),
          _buildTextFieldWithRequired(
            'Tempat Lahir (Place of Birth)',
            _tempatLahirController,
            Icons.location_city,
            theme,
            isRequired: true,
            hintText: 'Masukkan tempat lahir',
          ),
          _buildDatePickerField(
            'Tanggal Lahir (Date of Birth)',
            _tanggalLahirController,
            Icons.cake,
            theme,
            isRequired: true,
          ),
          _buildRadioButtonField(
            'Jenis Kelamin (Gender)',
            _selectedJenisKelamin,
            _jenisKelaminOptions,
            Icons.wc,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedJenisKelamin = value!;
                _updateUnsavedChanges();
              });
            },
          ),
          _buildDropdownField(
            'Golongan Darah (Blood Type)',
            _selectedGolonganDarah,
            _golonganDarahOptions,
            Icons.bloodtype,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedGolonganDarah = value!;
                _updateUnsavedChanges();
              });
            },
          ),
          _buildRadioButtonField(
            'Status Domisili (Domicile Status)',
            _selectedStatusDomisili,
            _statusDomisiliOptions,
            Icons.home,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedStatusDomisili = value!;
                _updateUnsavedChanges();
              });
            },
          ),
          _buildTextAreaField(
            'Address',
            _addressController,
            Icons.location_on,
            theme,
            isRequired: true,
            hintText: 'Masukkan alamat lengkap',
          ),
          _buildTextFieldWithRequired(
            'Propinsi (Province)',
            _propinsiController,
            Icons.map,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama propinsi',
          ),
          _buildTextFieldWithRequired(
            'Kota (City)',
            _kotaController,
            Icons.location_city,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kota',
          ),
          _buildTextFieldWithRequired(
            'Kecamatan (District)',
            _kecamatanController,
            Icons.place,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kecamatan',
          ),
          _buildTextFieldWithRequired(
            'Kelurahan (Sub-district)',
            _kelurahanController,
            Icons.location_on,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kelurahan',
          ),
          _buildTextFieldWithRequired(
            'RT',
            _rtController,
            Icons.home_outlined,
            theme,
            isRequired: true,
            hintText: 'Ketik \'000\' Jika Tidak Diketahui',
            keyboardType: TextInputType.number,
          ),
          _buildTextFieldWithRequired(
            'RW',
            _rwController,
            Icons.home_outlined,
            theme,
            isRequired: true,
            hintText: 'Ketik \'000\' Jika Tidak Diketahui',
            keyboardType: TextInputType.number,
          ),
          _buildTextFieldWithRequired(
            'Kode Pos (Postal Code)',
            _kodePosController,
            Icons.local_post_office,
            theme,
            isRequired: true,
            hintText: 'Masukkan kode pos',
            keyboardType: TextInputType.number,
          ),
          _buildTextFieldWithRequired(
            'Telepon Rumah (Home Phone)',
            _teleponRumahController,
            Icons.phone,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor telepon rumah',
            keyboardType: TextInputType.phone,
          ),
          _buildTextFieldWithRequired(
            'Telepon Kantor (Office Phone)',
            _teleponKantorController,
            Icons.business,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor telepon kantor',
            keyboardType: TextInputType.phone,
          ),
          _buildTextFieldWithRequired(
            'Handphone (WA) (Whatsapp Mobile Phone)',
            _handphoneController,
            Icons.phone_android,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor handphone',
            keyboardType: TextInputType.phone,
          ),
          _buildTextFieldWithRequired(
            'Email',
            _emailController,
            Icons.email,
            theme,
            isRequired: true,
            hintText: 'Masukkan alamat email',
            keyboardType: TextInputType.emailAddress,
            isLast: true,
          ),
          const SizedBox(height: 30),
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

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    required Function(String?) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primarySwatch),
                      ),
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildRadioButtonField(
    String label,
    String selectedValue,
    List<String> options,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    required Function(String?) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: options.map((String option) {
                      return RadioListTile<String>(
                        title: Text(
                          option,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                        value: option,
                        groupValue: selectedValue,
                        onChanged: onChanged,
                        activeColor: theme.primarySwatch,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal lahir',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: theme.primarySwatch,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primarySwatch),
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1981, 10, 5),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildTextAreaField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primarySwatch),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildTextFieldWithRequired(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primarySwatch),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Future<void> _saveData(BuildContext context, dynamic theme) async {
    if (_formKey.currentState!.validate()) {
      // Prepare data with default values
      final rtValue = _rtController.text.trim().isEmpty ? '000' : _rtController.text.trim();
      final rwValue = _rwController.text.trim().isEmpty ? '000' : _rwController.text.trim();
      
      // Debug logging
      print('PribadiPage: Validating data...');
      print('Tempat Lahir: ${_tempatLahirController.text}');
      print('Tanggal Lahir: ${_tanggalLahirController.text}');
      print('Jenis Kelamin: $_selectedJenisKelamin');
      print('Agama: $_selectedAgama');
      print('Status Perkawinan: $_selectedStatusPerkawinan');
      print('Golongan Darah: $_selectedGolonganDarah');
      print('Status Domisili: $_selectedStatusDomisili');
      print('Address: ${_addressController.text}');
      print('Propinsi: ${_propinsiController.text}');
      print('Kota: ${_kotaController.text}');
      print('Kecamatan: ${_kecamatanController.text}');
      print('Kelurahan: ${_kelurahanController.text}');
      print('RT: $rtValue');
      print('RW: $rwValue');
      print('Kode Pos: ${_kodePosController.text}');
      print('Telepon Rumah: ${_teleponRumahController.text}');
      print('Telepon Kantor: ${_teleponKantorController.text}');
      print('Handphone: ${_handphoneController.text}');
      print('Email: ${_emailController.text}');
      
      // Validate data using ProfileService
      final errors = _profileService.getPribadiDataValidationErrors(
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _tanggalLahirController.text,
        jenisKelamin: _selectedJenisKelamin,
        agama: _selectedAgama,
        statusPerkawinan: _selectedStatusPerkawinan,
        golonganDarah: _selectedGolonganDarah,
        statusDomisili: _selectedStatusDomisili,
        address: _addressController.text,
        propinsi: _propinsiController.text,
        kota: _kotaController.text,
        kecamatan: _kecamatanController.text,
        kelurahan: _kelurahanController.text,
        rt: rtValue,
        rw: rwValue,
        kodePos: _kodePosController.text,
        teleponRumah: _teleponRumahController.text,
        teleponKantor: _teleponKantorController.text,
        handphone: _handphoneController.text,
        email: _emailController.text,
      );

      if (errors.isNotEmpty) {
        print('PribadiPage: Validation errors found (${errors.length}):');
        for (int i = 0; i < errors.length; i++) {
          print('  ${i + 1}. ${errors[i]}');
        }
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      print('PribadiPage: ✅ All validations passed, proceeding to save...');

      try {
        // Initialize ProfileService first
        print('PribadiPage: 🔄 Initializing ProfileService...');
        await _profileService.initialize();
        print('PribadiPage: ✅ ProfileService initialized successfully');

        // Save to SQLite first
        print('PribadiPage: 🔄 Calling ProfileService.savePribadiData()...');
        print('PribadiPage: 📋 Data to save:');
        print('  - Tempat Lahir: "${_tempatLahirController.text}"');
        print('  - Tanggal Lahir: "${_tanggalLahirController.text}"');
        print('  - Jenis Kelamin: "$_selectedJenisKelamin"');
        print('  - Email: "${_emailController.text}"');
        print('  - Handphone: "${_handphoneController.text}"');

        final sqliteSuccess = await _profileService.savePribadiData(
          tempatLahir: _tempatLahirController.text.trim(),
          tanggalLahir: _tanggalLahirController.text.trim(),
          jenisKelamin: _selectedJenisKelamin,
          agama: _selectedAgama,
          statusPerkawinan: _selectedStatusPerkawinan,
          golonganDarah: _selectedGolonganDarah,
          statusDomisili: _selectedStatusDomisili,
          address: _addressController.text.trim(),
          propinsi: _propinsiController.text.trim(),
          kota: _kotaController.text.trim(),
          kecamatan: _kecamatanController.text.trim(),
          kelurahan: _kelurahanController.text.trim(),
          rt: rtValue,
          rw: rwValue,
          kodePos: _kodePosController.text.trim(),
          teleponRumah: _teleponRumahController.text.trim(),
          teleponKantor: _teleponKantorController.text.trim(),
          handphone: _handphoneController.text.trim(),
          email: _emailController.text.trim(),
        );

        print('PribadiPage: 📋 SQLite save result: $sqliteSuccess');
        
        if (!sqliteSuccess) {
          print('PribadiPage: ❌ SQLite save failed - showing error dialog');
          
          // Try to get more detailed error information
          final hasDataBefore = await _profileService.hasPribadiData();
          print('PribadiPage: 📊 Has data before save: $hasDataBefore');
          
          _showErrorDialog(context, theme, 'Gagal menyimpan data ke database SQLite. Silakan coba lagi atau gunakan tombol Debug untuk detail error.');
          return;
        }

        print('PribadiPage: ✅ Data saved to SQLite successfully!');

        // Update Riverpod provider
        final pribadiData = PribadiData(
          tempatLahir: _tempatLahirController.text.trim(),
          tanggalLahir: _tanggalLahirController.text.trim(),
          address: _addressController.text.trim(),
          propinsi: _propinsiController.text.trim(),
          kota: _kotaController.text.trim(),
          kecamatan: _kecamatanController.text.trim(),
          kelurahan: _kelurahanController.text.trim(),
          rt: rtValue,
          rw: rwValue,
          kodePos: _kodePosController.text.trim(),
          teleponRumah: _teleponRumahController.text.trim(),
          teleponKantor: _teleponKantorController.text.trim(),
          handphone: _handphoneController.text.trim(),
          email: _emailController.text.trim(),
          statusPerkawinan: _selectedStatusPerkawinan,
          agama: _selectedAgama,
          golonganDarah: _selectedGolonganDarah,
          jenisKelamin: _selectedJenisKelamin,
          statusDomisili: _selectedStatusDomisili,
        );

        ref.read(pribadiDataProvider.notifier).updateData(pribadiData);
        ref.read(profileCompletionProvider.notifier).markCompleted('identitasDiri');

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setBool('pribadi_has_changes', false),
          prefs.setBool('pribadi_just_saved', true),
          prefs.setBool('pribadi_user_saved', true),
        ]);

        print('PribadiPage: All data saved successfully');

        // Show success dialog
        await ProfileCompletionNotifierCard.show(
          context,
          title: 'Berhasil Menyimpan Data Pribadi',
          message: 'Data pribadi Anda telah diperbarui dan tersimpan dengan sukses di database.',
          onConfirm: () {
            notification.NotificationUtils.showSuccess(
              context,
              'Data pribadi telah disimpan ke database',
            );
            if (context.mounted) {
              context.pop('saved');
            }
          },
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green[600],
        );

        if (context.mounted) {
          setState(() {
            _hasUnsavedChanges = false;
          });
        }
      } catch (e, stackTrace) {
        print('PribadiPage: ❌ Critical error saving pribadi data: $e');
        print('PribadiPage: 📚 Stack trace: $stackTrace');
        
        // Try to diagnose the error
        try {
          print('PribadiPage: 🔍 Attempting to diagnose error...');
          final hasDataAfter = await _profileService.hasPribadiData();
          print('PribadiPage: 📊 Has data after error: $hasDataAfter');
        } catch (diagError) {
          print('PribadiPage: 🚫 Error during diagnosis: $diagError');
        }
        
        _showErrorDialog(context, theme, 'Terjadi kesalahan saat menyimpan data: $e\n\nGunakan tombol Debug (🐛) untuk informasi detail.');
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    notification.NotificationUtils.showErrorDialog(
      context,
      title: 'Gagal Menyimpan',
      message: 'Terjadi kesalahan saat menyimpan data pribadi: $message',
    );
  }

  /// Show debug page for testing SQLite operations
  void _showPribadiDebug(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PribadiDebugPage(profileService: _profileService),
      ),
    );
  }
}

// Debug page for testing Pribadi SQLite operations
class PribadiDebugPage extends StatefulWidget {
  final ProfileService profileService;

  const PribadiDebugPage({
    super.key,
    required this.profileService,
  });

  @override
  State<PribadiDebugPage> createState() => _PribadiDebugPageState();
}

class _PribadiDebugPageState extends State<PribadiDebugPage> {
  String _debugOutput = 'Pribadi Debug Console Ready\n';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pribadi SQLite Debug'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pribadi SQLite Debug Tools',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSavePribadi,
                  icon: const Icon(Icons.save),
                  label: const Text('Test Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testLoadPribadi,
                  icon: const Icon(Icons.download),
                  label: const Text('Test Load'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testHasPribadi,
                  icon: const Icon(Icons.search),
                  label: const Text('Test Has Data'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testValidation,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Test Validation'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testInitialize,
                  icon: const Icon(Icons.settings),
                  label: const Text('Test Initialize'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearDebugOutput,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Log'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addDebugOutput(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _debugOutput += '[$timestamp] $message\n';
    });
  }

  void _clearDebugOutput() {
    setState(() {
      _debugOutput = 'Pribadi Debug Console Cleared\n';
    });
  }

  Future<void> _testInitialize() async {
    setState(() => _isLoading = true);
    _addDebugOutput('🔄 Testing ProfileService initialize...');

    try {
      await widget.profileService.initialize();
      _addDebugOutput('✅ Initialize test: SUCCESS');
    } catch (e) {
      _addDebugOutput('❌ Initialize test error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testSavePribadi() async {
    setState(() => _isLoading = true);
    _addDebugOutput('🔄 Testing save pribadi data...');

    try {
      final success = await widget.profileService.savePribadiData(
        tempatLahir: 'Jakarta Test SQLite',
        tanggalLahir: '15/08/1990',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Kawin',
        golonganDarah: 'O',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP',
        address: 'Jl. Test SQLite No. 123, Jakarta',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta Selatan',
        kecamatan: 'Kebayoran Baru',
        kelurahan: 'Senayan',
        rt: '001',
        rw: '002',
        kodePos: '12190',
        teleponRumah: '021-1234567',
        teleponKantor: '021-7654321',
        handphone: '08123456789',
        email: 'test@sqlite.com',
      );

      if (success) {
        _addDebugOutput('✅ Save pribadi test: SUCCESS');
      } else {
        _addDebugOutput('❌ Save pribadi test: FAILED');
      }
    } catch (e) {
      _addDebugOutput('❌ Save pribadi test error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testLoadPribadi() async {
    setState(() => _isLoading = true);
    _addDebugOutput('🔄 Testing load pribadi data...');

    try {
      final data = await widget.profileService.getCurrentPribadiData();

      if (data != null) {
        _addDebugOutput('✅ Load pribadi test: SUCCESS');
        _addDebugOutput('📄 Data found:');
        _addDebugOutput('   - ID: ${data.id}');
        _addDebugOutput('   - User ID: ${data.userId}');
        _addDebugOutput('   - Tempat Lahir: "${data.tempatLahir}"');
        _addDebugOutput('   - Tanggal Lahir: "${data.tanggalLahir}"');
        _addDebugOutput('   - Jenis Kelamin: "${data.jenisKelamin}"');
        _addDebugOutput('   - Agama: "${data.agama}"');
        _addDebugOutput('   - Status Perkawinan: "${data.statusPerkawinan}"');
        _addDebugOutput('   - Golongan Darah: "${data.golonganDarah}"');
        _addDebugOutput('   - Address: "${data.address}"');
        _addDebugOutput('   - Propinsi: "${data.propinsi}"');
        _addDebugOutput('   - Kota: "${data.kota}"');
        _addDebugOutput('   - Kecamatan: "${data.kecamatan}"');
        _addDebugOutput('   - Kelurahan: "${data.kelurahan}"');
        _addDebugOutput('   - RT: "${data.rt}"');
        _addDebugOutput('   - RW: "${data.rw}"');
        _addDebugOutput('   - Kode Pos: "${data.kodePos}"');
        _addDebugOutput('   - Handphone: "${data.handphone}"');
        _addDebugOutput('   - Email: "${data.email}"');
        _addDebugOutput('   - Created: ${data.createdAt}');
        _addDebugOutput('   - Updated: ${data.updatedAt}');
      } else {
        _addDebugOutput('ℹ️ Load pribadi test: No data found');
      }
    } catch (e) {
      _addDebugOutput('❌ Load pribadi test error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testHasPribadi() async {
    setState(() => _isLoading = true);
    _addDebugOutput('🔄 Testing has pribadi data...');

    try {
      final hasData = await widget.profileService.hasPribadiData();
      _addDebugOutput('✅ Has pribadi test: ${hasData ? "HAS DATA" : "NO DATA"}');
    } catch (e) {
      _addDebugOutput('❌ Has pribadi test error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testValidation() async {
    setState(() => _isLoading = true);
    _addDebugOutput('🔄 Testing pribadi validation...');

    try {
      // Test empty data validation
      var errors = widget.profileService.getPribadiDataValidationErrors(
        tempatLahir: '',
        tanggalLahir: '',
        jenisKelamin: '',
        agama: '',
        statusPerkawinan: '',
        golonganDarah: '',
        statusDomisili: '',
        address: '',
        propinsi: '',
        kota: '',
        kecamatan: '',
        kelurahan: '',
        rt: '',
        rw: '',
        kodePos: '',
        teleponRumah: '',
        teleponKantor: '',
        handphone: '',
        email: '',
      );
      _addDebugOutput('📝 Empty data validation: ${errors.length} errors');
      for (var error in errors) {
        _addDebugOutput('   - $error');
      }

      // Test valid data validation
      errors = widget.profileService.getPribadiDataValidationErrors(
        tempatLahir: 'Jakarta',
        tanggalLahir: '15/08/1990',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Kawin',
        golonganDarah: 'O',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP',
        address: 'Jl. Test No. 123',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta',
        kecamatan: 'Kebayoran',
        kelurahan: 'Senayan',
        rt: '001',
        rw: '002',
        kodePos: '12190',
        teleponRumah: '021-1234567',
        teleponKantor: '021-7654321',
        handphone: '08123456789',
        email: 'test@example.com',
      );
      _addDebugOutput('📝 Valid data validation: ${errors.length} errors');
      if (errors.isNotEmpty) {
        for (var error in errors) {
          _addDebugOutput('   - $error');
        }
      }

      // Test invalid email
      errors = widget.profileService.getPribadiDataValidationErrors(
        tempatLahir: 'Jakarta',
        tanggalLahir: '15/08/1990',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Kawin',
        golonganDarah: 'O',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP',
        address: 'Jl. Test No. 123',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta',
        kecamatan: 'Kebayoran',
        kelurahan: 'Senayan',
        rt: '001',
        rw: '002',
        kodePos: '12190',
        teleponRumah: '021-1234567',
        teleponKantor: '021-7654321',
        handphone: '08123456789',
        email: 'invalid-email',
      );
      _addDebugOutput('📝 Invalid email validation: ${errors.length} errors');
      for (var error in errors) {
        _addDebugOutput('   - $error');
      }
    } catch (e) {
      _addDebugOutput('❌ Validation test error: $e');
    }

    setState(() => _isLoading = false);
  }
}