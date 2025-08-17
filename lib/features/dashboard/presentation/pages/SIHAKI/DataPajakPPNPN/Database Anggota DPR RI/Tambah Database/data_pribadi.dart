import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPribadiPage extends ConsumerStatefulWidget {
  const DataPribadiPage({super.key});

  @override
  ConsumerState<DataPribadiPage> createState() => _DataPribadiPageState();
}

class _DataPribadiPageState extends ConsumerState<DataPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final _handphoneController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _telponRuanganController = TextEditingController(text: '');
  final _ruangKerjaController = TextEditingController(text: '');
  final _bahasaAsingController = TextEditingController(text: '');
  final _alamatRumahController = TextEditingController(text: '');
  final _keteranganDomisiliController = TextEditingController(text: '');
  final _namaAyahKandungController = TextEditingController(text: '');
  final _namaIbuKandungController = TextEditingController(text: '');
  final _noRekeningMitraController = TextEditingController(text: '');
  final _namaRekeningMitraController = TextEditingController(text: '');
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _handphoneController.text = prefs.getString('handphone') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _telponRuanganController.text = prefs.getString('telponRuangan') ?? '';
      _ruangKerjaController.text = prefs.getString('ruangKerja') ?? '';
      _bahasaAsingController.text = prefs.getString('bahasaAsing') ?? '';
      _alamatRumahController.text = prefs.getString('alamatRumah') ?? '';
      _keteranganDomisiliController.text = prefs.getString('keteranganDomisili') ?? '';
      _namaAyahKandungController.text = prefs.getString('namaAyahKandung') ?? '';
      _namaIbuKandungController.text = prefs.getString('namaIbuKandung') ?? '';
      _noRekeningMitraController.text = prefs.getString('noRekeningMitra') ?? '';
      _namaRekeningMitraController.text = prefs.getString('namaRekeningMitra') ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataPribadiFilledProvider.notifier).state = true;
      } else {
        ref.read(dataPribadiFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _handphoneController.text.isNotEmpty &&
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Database Anggota DPR RI (DASI)',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/dataKomisi');
          },
        ),
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
              Text(
                'Data Pribadi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              _buildPersonalDataCard(theme),
              const SizedBox(height: 20),
              _buildAdditionalDataCard(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDataCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch, theme.secondarySwatch.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Pribadi Utama',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextFieldWithRequired(
            'Handphone',
            _handphoneController,
            Icons.phone_android,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor handphone',
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Email',
            _emailController,
            Icons.email,
            theme,
            isRequired: true,
            hintText: 'Masukkan alamat email',
            keyboardType: TextInputType.emailAddress,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Telepon Ruangan',
            _telponRuanganController,
            Icons.phone,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor telepon ruangan',
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Ruang Kerja',
            _ruangKerjaController,
            Icons.work,
            theme,
            isRequired: true,
            hintText: 'Masukkan ruang kerja',
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Bahasa Asing',
            _bahasaAsingController,
            Icons.language,
            theme,
            isRequired: true,
            hintText: 'Masukkan bahasa asing yang dikuasai',
            enabled: _isEditing,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDataCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch.withOpacity(0.9), theme.secondarySwatch],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Tambahan',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextFieldWithRequired(
            'Alamat Rumah',
            _alamatRumahController,
            Icons.home,
            theme,
            isRequired: true,
            hintText: 'Masukkan alamat rumah',
            maxLines: 3,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Keterangan Domisili',
            _keteranganDomisiliController,
            Icons.location_city,
            theme,
            isRequired: true,
            hintText: 'Masukkan keterangan domisili',
            maxLines: 3,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Nama Ayah Kandung',
            _namaAyahKandungController,
            Icons.person,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama ayah kandung',
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Nama Ibu Kandung',
            _namaIbuKandungController,
            Icons.person,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama ibu kandung',
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'No. Rekening Mitra',
            _noRekeningMitraController,
            Icons.credit_card,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor rekening mitra',
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'Nama Rekening Mitra',
            _namaRekeningMitraController,
            Icons.person,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama rekening mitra',
            enabled: _isEditing,
            isLast: true,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEditing ? () => _saveData(context, ref, theme) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? theme.primarySwatch : theme.primarySwatch.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) return theme.primarySwatch.withOpacity(0.5);
                        return theme.primarySwatch;
                      },
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
        ],
      ),
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
    int maxLines = 1,
    bool isLast = false,
    bool enabled = true,
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
                gradient: LinearGradient(
                  colors: [theme.primarySwatch.withOpacity(0.2), theme.secondarySwatch.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primarySwatch.withOpacity(0.3), width: 1),
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
                    maxLines: maxLines,
                    enabled: enabled,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.primarySwatch, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired && enabled
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field ini wajib diisi';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Future<void> _saveData(BuildContext context, WidgetRef ref, dynamic theme) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_handphoneController.text.isEmpty) errors.add('Handphone harus diisi');
      if (_emailController.text.isEmpty) errors.add('Email harus diisi');
      if (_telponRuanganController.text.isEmpty) errors.add('Telepon Ruangan harus diisi');
      if (_ruangKerjaController.text.isEmpty) errors.add('Ruang Kerja harus diisi');
      if (_bahasaAsingController.text.isEmpty) errors.add('Bahasa Asing harus diisi');
      if (_alamatRumahController.text.isEmpty) errors.add('Alamat Rumah harus diisi');
      if (_keteranganDomisiliController.text.isEmpty) errors.add('Keterangan Domisili harus diisi');
      if (_namaAyahKandungController.text.isEmpty) errors.add('Nama Ayah Kandung harus diisi');
      if (_namaIbuKandungController.text.isEmpty) errors.add('Nama Ibu Kandung harus diisi');
      if (_noRekeningMitraController.text.isEmpty) errors.add('No. Rekening Mitra harus diisi');
      if (_namaRekeningMitraController.text.isEmpty) errors.add('Nama Rekening Mitra harus diisi');

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('handphone', _handphoneController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('telponRuangan', _telponRuanganController.text);
      await prefs.setString('ruangKerja', _ruangKerjaController.text);
      await prefs.setString('bahasaAsing', _bahasaAsingController.text);
      await prefs.setString('alamatRumah', _alamatRumahController.text);
      await prefs.setString('keteranganDomisili', _keteranganDomisiliController.text);
      await prefs.setString('namaAyahKandung', _namaAyahKandungController.text);
      await prefs.setString('namaIbuKandung', _namaIbuKandungController.text);
      await prefs.setString('noRekeningMitra', _noRekeningMitraController.text);
      await prefs.setString('namaRekeningMitra', _namaRekeningMitraController.text);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Simpan Data Pribadi',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text('Data pribadi berhasil disimpan.'),
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
        ref.read(dataPribadiFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      context.go('/dataKomisi', extra: {'justSaved': true, 'sourcePage': '/data-pribadi'});
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
}