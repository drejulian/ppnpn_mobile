import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/profile_data_provider.dart';

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

    SharedPreferences.getInstance().then((prefs) {
      final hasChanges = prefs.getBool('pribadi_has_changes') ?? false;
      if (hasChanges && mounted) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
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

  void _saveData(BuildContext context, dynamic theme) {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];
      if (_selectedStatusPerkawinan.isEmpty) errors.add('Status Perkawinan harus dipilih');
      if (_selectedAgama.isEmpty) errors.add('Agama harus dipilih');
      if (_tempatLahirController.text.isEmpty) errors.add('Tempat Lahir harus diisi');
      if (_tanggalLahirController.text.isEmpty) errors.add('Tanggal Lahir harus diisi');
      if (_selectedJenisKelamin.isEmpty) errors.add('Jenis Kelamin harus dipilih');
      if (_selectedGolonganDarah.isEmpty) errors.add('Golongan Darah harus dipilih');
      if (_selectedStatusDomisili.isEmpty) errors.add('Status Domisili harus dipilih');
      if (_addressController.text.isEmpty) errors.add('Alamat harus diisi');
      if (_propinsiController.text.isEmpty) errors.add('Propinsi harus diisi');
      if (_kotaController.text.isEmpty) errors.add('Kota harus diisi');
      if (_kecamatanController.text.isEmpty) errors.add('Kecamatan harus diisi');
      if (_kelurahanController.text.isEmpty) errors.add('Kelurahan harus diisi');
      if (_rtController.text.isEmpty) errors.add('RT harus diisi');
      if (_rwController.text.isEmpty) errors.add('RW harus diisi');
      if (_kodePosController.text.isEmpty) errors.add('Kode Pos harus diisi');
      if (_teleponRumahController.text.isEmpty) errors.add('Telepon Rumah harus diisi');
      if (_teleponKantorController.text.isEmpty) errors.add('Telepon Kantor harus diisi');
      if (_handphoneController.text.isEmpty) errors.add('Handphone harus diisi');
      if (_emailController.text.isEmpty) errors.add('Email harus diisi');
      else if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
        errors.add('Format email tidak valid');
      }

      if (errors.isNotEmpty) {
        notification.NotificationUtils.showErrorDialog(
          context,
          title: 'Gagal Menyimpan',
          message: 'Terjadi kesalahan saat menyimpan data pribadi:\n${errors.join('\n')}',
        );
        return;
      }

      final pribadiData = PribadiData(
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _tanggalLahirController.text.trim(),
        address: _addressController.text.trim(),
        propinsi: _propinsiController.text.trim(),
        kota: _kotaController.text.trim(),
        kecamatan: _kecamatanController.text.trim(),
        kelurahan: _kelurahanController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
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
      ref.read(profileCompletionProvider.notifier).markCompleted('pribadi');

      SharedPreferences.getInstance().then((prefs) {
        Future.wait([
          prefs.setBool('pribadi_has_changes', false),
          prefs.setBool('pribadi_just_saved', true),
          prefs.setBool('pribadi_user_saved', true),
        ]);
      });

      ProfileCompletionNotifierCard.show(
        context,
        title: 'Berhasil Menyimpan Data Pribadi',
        message: 'Data pribadi Anda telah diperbarui dan tersimpan dengan sukses.',
        onConfirm: () {
          if (context.mounted) {
            notification.NotificationUtils.showSuccess(
              context,
              'Data pribadi telah disimpan',
            );
            setState(() {
              _hasUnsavedChanges = false;
            });
            context.pop('saved');
          }
        },
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green[600],
      );
    }
  }
}