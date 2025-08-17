import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKeanggotaanPage extends ConsumerStatefulWidget {
  const DataKeanggotaanPage({super.key});

  @override
  ConsumerState<DataKeanggotaanPage> createState() => _DataKeanggotaanPageState();
}

class _DataKeanggotaanPageState extends ConsumerState<DataKeanggotaanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: 'EVA STEVANY RATABA, S.H');
  final _noAnggotaController = TextEditingController(text: '425');
  final _fraksiController = TextEditingController(text: 'Fraksi Partai NasDem');
  final _dapilController = TextEditingController(text: 'SULAWESI SELATAN III');
  final _areaController = TextEditingController(text: 'ENREKANG, KOTA PALOPO, LUWU, LUWU TIMUR, LUWU UTARA, PINRANG, SIDENRENG RAPPANG, TANA TORAJA, TORAJA UTARA');
  final _noRekeningController = TextEditingController();
  final _namaRekeningController = TextEditingController(text: 'EVA STEVANY RATABA');
  bool _isEditing = false;
  bool _isDataSaved = false;

  // Simulasi memori lokal untuk menyimpan data antar sesi
  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    // Memuat data persisten saat halaman dimuat
    _namaController.text = _persistentData['nama'] ?? 'EVA STEVANY RATABA, S.H';
    _noAnggotaController.text = _persistentData['noAnggota'] ?? '425';
    _fraksiController.text = _persistentData['fraksi'] ?? 'Fraksi Partai NasDem';
    _dapilController.text = _persistentData['dapil'] ?? 'SULAWESI SELATAN III';
    _areaController.text = _persistentData['area'] ?? 'ENREKANG, KOTA PALOPO, LUWU, LUWU TIMUR, LUWU UTARA, PINRANG, SIDENRENG RAPPANG, TANA TORAJA, TORAJA UTARA';
    _noRekeningController.text = _persistentData['noRekening'] ?? '';
    _namaRekeningController.text = _persistentData['namaRekening'] ?? 'EVA STEVANY RATABA';
    _isDataSaved = _isAllRequiredFilled(); // Set status awal berdasarkan data yang dimuat
    // Tunda pembaruan provider hingga setelah frame selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFilledStatus());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noAnggotaController.dispose();
    _fraksiController.dispose();
    _dapilController.dispose();
    _areaController.dispose();
    _noRekeningController.dispose();
    _namaRekeningController.dispose();
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

  void _updateFilledStatus() {
    final isFilled = _isAllRequiredFilled();
    ref.read(dataKeanggotaanFilledProvider.notifier).state = isFilled;
    print('Updated status - dataKeanggotaanFilledProvider: $isFilled');
  }

  void _saveData(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      // Simpan data ke memori persisten
      _persistentData['nama'] = _namaController.text;
      _persistentData['noAnggota'] = _noAnggotaController.text;
      _persistentData['fraksi'] = _fraksiController.text;
      _persistentData['dapil'] = _dapilController.text;
      _persistentData['area'] = _areaController.text;
      _persistentData['noRekening'] = _noRekeningController.text;
      _persistentData['namaRekening'] = _namaRekeningController.text;

      setState(() {
        _isDataSaved = true;
      });
      ref.read(dataKeanggotaanFilledProvider.notifier).state = true;
      print('Data saved, dataKeanggotaanFilledProvider set to: true, _isDataSaved: $_isDataSaved');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Simpan Data Keanggotaan',
            style: ref.read(themeProvider).typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: const Text('Data keanggotaan berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/dataKomisi', extra: {'justSaved': true, 'sourcePage': '/data-keanggotaan'});
                print('Navigating back with extra: ${{'justSaved': true, 'sourcePage': '/data-keanggotaan'}}');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
                'Data Keanggotaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              _buildPersonalDataCard(theme),
              const SizedBox(height: 20),
              _buildBankingDataCard(theme),
              const SizedBox(height: 20),
              Column(
                children: [
                  if (_isDataSaved)
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
                      onPressed: _isEditing || !_isAllRequiredFilled()
                          ? () => _saveData(context, ref)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isEditing || _isAllRequiredFilled())
                            ? theme.primarySwatch
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled))
                              return Colors.grey[400]!;
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
          // Header Cart
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
                  'Data Pribadi Anggota',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Nama',
            _namaController,
            Icons.person,
            theme,
            enabled: _isEditing,
          ),
          _buildTextField(
            'No. Anggota',
            _noAnggotaController,
            Icons.badge,
            theme,
            enabled: _isEditing,
          ),
          _buildTextField(
            'Fraksi',
            _fraksiController,
            Icons.group_work,
            theme,
            enabled: _isEditing,
          ),
          _buildTextField(
            'Dapil',
            _dapilController,
            Icons.location_on,
            theme,
            enabled: _isEditing,
          ),
          _buildTextField(
            'Area',
            _areaController,
            Icons.map,
            theme,
            enabled: _isEditing,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBankingDataCard(dynamic theme) {
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
          // Header Cart
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
                Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Rekening',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'No. Rekening',
            _noRekeningController,
            Icons.credit_card,
            theme,
            enabled: _isEditing,
          ),
          _buildTextField(
            'Nama Rekening',
            _namaRekeningController,
            Icons.person,
            theme,
            enabled: _isEditing,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
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
                  Text(
                    label,
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
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
                      fillColor: enabled ? null : Colors.grey[200],
                      filled: !enabled,
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: enabled ? Colors.grey[800] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (!_isEditing && value == null || value!.isEmpty) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },  
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
}